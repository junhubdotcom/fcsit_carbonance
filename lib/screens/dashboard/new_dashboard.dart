import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../common/constants.dart';
import '../../models/period_counters.dart';
import '../../models/transaction_model.dart';

class NewDashboardPage extends StatefulWidget {
  const NewDashboardPage({Key? key}) : super(key: key);

  @override
  _NewDashboardPageState createState() => _NewDashboardPageState();
}

class _NewDashboardPageState extends State<NewDashboardPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _rotationController;

  int _currentChartIndex = 1; // Start with Category Analysis
  int _selectedPeriodIndex = 1;
  String _currentPeriod = 'weekly';
  bool _isLoading = true;
  int _breakdownTabIndex = 0; // 0: Expense, 1: Income, 2: CO₂

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: 1,
    );
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize Firestore stream
    _initializePeriodCounterStream();

    setState(() {
      _isLoading = false;
    });
  }

  // Firestore streams for real-time data
  late StreamController<DocumentSnapshot> _periodCounterController;
  late Stream<DocumentSnapshot> _periodCounterStream;
  final String _userId = 'default_user'; // Replace with actual user ID
  late DateTime _selectedDate;
  bool _isStreamInitialized = false;

  // Cache for period counter data
  DocumentSnapshot? _cachedPeriodDoc;
  PeriodCounters? _cachedPeriodCounters;
  bool _isDataLoading = false;

  // Background data cache for instant access
  Map<String, TransactionModel> _cachedTransactions = {};
  Map<String, Map<String, dynamic>> _cachedExpenseItems = {};
  bool _isBackgroundFetching = false;
  bool _isBackgroundFetchComplete = false;

  void _initializePeriodCounterStream() {
    // Prevent multiple initializations
    if (_isStreamInitialized) {
      return;
    }

    // Create a new stream controller and stream
    _periodCounterController =
        StreamController<DocumentSnapshot>.broadcast(); // Use broadcast stream
    _periodCounterStream = _periodCounterController.stream;

    // Fetch and cache the current period document
    _fetchAndCachePeriodData();

    _isStreamInitialized = true;
  }

  Future<void> _fetchAndCachePeriodData() async {
    if (_isDataLoading) return;

    setState(() {
      _isDataLoading = true;
    });

    try {
      final periodIds = _getCurrentPeriodIds();
      final docId = '${_userId}_${_currentPeriod}_${periodIds[_currentPeriod]}';

      print("🔄 Fetching period data for: $docId");

      final snapshot = await FirebaseFirestore.instance
          .collection('period_counters')
          .doc(docId)
          .get();

      setState(() {
        _cachedPeriodDoc = snapshot;
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          _cachedPeriodCounters = PeriodCounters.fromJson(snapshot.id, data);
          print(
              "✅ Cached period data: ${_cachedPeriodCounters?.totals.income ?? 0} income, ${_cachedPeriodCounters?.totals.expense ?? 0} expense");
        } else {
          _cachedPeriodCounters = null;
          print("❌ No period data found for: $docId");
        }
        _isDataLoading = false;
      });

      // Also add to stream for backward compatibility
      _periodCounterController.add(snapshot);

      // Start background fetch of all transaction data for instant access
      _startBackgroundDataFetch();
    } catch (e) {
      print("❌ Error fetching period data: $e");
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  /// Start background fetch of all transaction data for instant modal access
  Future<void> _startBackgroundDataFetch() async {
    if (_isBackgroundFetching || _cachedPeriodCounters == null) return;

    _isBackgroundFetching = true;
    print("🚀 Starting background data fetch for instant access...");

    try {
      final appliedTxIds = _cachedPeriodCounters!.appliedTxIds;
      if (appliedTxIds.isEmpty) {
        print("ℹ️ No transactions to fetch");
        _isBackgroundFetchComplete = true;
        return;
      }

      // Batch fetch all expense documents
      final expenseDocs = await Future.wait(appliedTxIds.map((id) =>
          FirebaseFirestore.instance.collection('expense').doc(id).get()));

      // Batch fetch all income documents
      final incomeDocs = await Future.wait(appliedTxIds.map((id) =>
          FirebaseFirestore.instance.collection('income').doc(id).get()));

      // Process and cache expense data
      for (int i = 0; i < appliedTxIds.length; i++) {
        final txId = appliedTxIds[i];
        final expenseDoc = expenseDocs[i];

        if (expenseDoc.exists) {
          final expenseData = expenseDoc.data() as Map<String, dynamic>;

          // Cache expense items for instant access
          if (expenseData['items'] != null) {
            final items = expenseData['items'] as List<dynamic>;
            final itemDocs =
                await Future.wait(items.map((itemRef) => itemRef.get()));

            final itemData = itemDocs
                .where((doc) => doc.data() != null)
                .map((doc) => doc.data()! as Map<String, dynamic>)
                .toList();
            _cachedExpenseItems[txId] = {
              'expense': expenseData,
              'items': itemData,
            };
          }

          // Create transaction model
          _cachedTransactions[txId] = TransactionModel(
            id: txId,
            type: 'expense',
            amount: _calculateExpenseTotalFromCache(txId),
            category: _getExpenseCategoryFromCache(txId),
            description: expenseData['transactionName'] ?? '',
            date: (expenseData['dateTime'] as Timestamp).toDate(),
            carbonFootprint: (expenseData['carbon_footprint'] ?? 0).toDouble(),
          );
        }
      }

      // Process and cache income data
      for (int i = 0; i < appliedTxIds.length; i++) {
        final txId = appliedTxIds[i];
        final incomeDoc = incomeDocs[i];

        if (incomeDoc.exists) {
          final incomeData = incomeDoc.data() as Map<String, dynamic>;

          _cachedTransactions[txId] = TransactionModel(
            id: txId,
            type: 'income',
            amount: (incomeData['amount'] ?? 0).toDouble(),
            category: incomeData['name'] ?? 'Unknown',
            description: incomeData['name'] ?? '',
            date: (incomeData['dateTime'] as Timestamp).toDate(),
            carbonFootprint: 0,
          );
        }
      }

      print(
          "✅ Background data fetch complete! Cached ${_cachedTransactions.length} transactions");
      _isBackgroundFetchComplete = true;
    } catch (e) {
      print("❌ Error in background data fetch: $e");
    } finally {
      _isBackgroundFetching = false;
    }
  }

  /// Calculate expense total from cached data
  double _calculateExpenseTotalFromCache(String txId) {
    final cachedData = _cachedExpenseItems[txId];
    if (cachedData == null) return 0.0;

    final items = cachedData['items'] as List<Map<String, dynamic>>?;
    if (items == null) return 0.0;

    double total = 0.0;
    for (var item in items) {
      final price = (item['price'] ?? 0).toDouble();
      final quantity = (item['quantity'] ?? 1).toDouble();
      total += price * quantity;
    }
    return total;
  }

  /// Get expense category from cached data
  String _getExpenseCategoryFromCache(String txId) {
    final cachedData = _cachedExpenseItems[txId];
    if (cachedData == null) return 'General';

    final items = cachedData['items'] as List<Map<String, dynamic>>?;
    if (items == null || items.isEmpty) return 'General';

    return items.first['category'] ?? 'General';
  }

  Map<String, String> _getCurrentPeriodIds() {
    return {
      'daily': _generateDailyPeriodId(_selectedDate),
      'weekly': _generateWeeklyPeriodId(_selectedDate),
      'monthly': _generateMonthlyPeriodId(_selectedDate),
    };
  }

  String _generateDailyPeriodId(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day+GMT8';
  }

  String _generateWeeklyPeriodId(DateTime date) {
    final year = date.year;
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final weekOfYear =
        ((startOfWeek.difference(DateTime(year, 1, 1)).inDays) / 7).floor() + 1;

    print(
        "📅 Weekly ID Debug: date=$date, startOfWeek=$startOfWeek, weekOfYear=$weekOfYear");

    return '$year-W${weekOfYear.toString().padLeft(2, '0')}+GMT8';
  }

  String _getDateRepresentation() {
    final now = DateTime.now();
    switch (_currentPeriod) {
      case 'daily':
        return 'Today';
      case 'weekly':
        // Get current week number
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final weekOfYear =
            ((startOfWeek.difference(DateTime(now.year, 1, 1)).inDays) / 7)
                    .floor() +
                1;
        return 'This Week (W$weekOfYear)';
      case 'monthly':
        final monthNames = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        return 'This ${monthNames[now.month - 1]}';
      default:
        return '';
    }
  }

  String _generateMonthlyPeriodId(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    return '$year-$month+GMT8';
  }

  void _updatePeriod() {
    // Reset stream initialization flag when period changes
    _isStreamInitialized = false;

    final periodIds = _getCurrentPeriodIds();
    final docId = '${_userId}_${_currentPeriod}_${periodIds[_currentPeriod]}';

    print("🔄 Period changed to: $_currentPeriod, fetching new data...");

    // Clear cache and fetch new data
    setState(() {
      _cachedPeriodDoc = null;
      _cachedPeriodCounters = null;
    });

    _initializePeriodCounterStream();
  }

  // Fetch multiple period counter documents for trend analysis
  Future<List<PeriodCounters>> _fetchPeriodCountersForTrend() async {
    List<PeriodCounters> periodCounters = [];

    try {
      if (_currentPeriod == 'daily') {
        // Fetch last 7 days
        final now = DateTime.now();
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final periodId = _generateDailyPeriodId(date);
          final docId = '${_userId}_daily_$periodId';

          final doc = await FirebaseFirestore.instance
              .collection('period_counters')
              .doc(docId)
              .get();

          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;

            try {
              final periodCounter = PeriodCounters.fromJson(doc.id, data);

              periodCounters.add(periodCounter);
            } catch (parseError) {}
          } else {
            // Create empty period counter for missing days
            periodCounters.add(PeriodCounters(
              id: docId,
              userId: _userId,
              period: 'daily',
              periodId: periodId,
              totals: Totals(income: 0, expense: 0, co2Kg: 0),
              breakdowns: Breakdowns(
                incomeByCategory: {},
                expenseByCategory: {},
                co2ByCategory: {},
              ),
              appliedTxIds: [],
              lastUpdated: DateTime.now(),
              insights: {},
            ));
          }
        }
      } else if (_currentPeriod == 'weekly') {
        // Fetch weeks in current month
        final now = DateTime.now();
        final weeksInMonth = _getWeeksInMonth(now);

        for (int i = 0; i < weeksInMonth.length; i++) {
          final weekStart = _getWeekStartDate(now, i);
          final periodId = _generateWeeklyPeriodId(weekStart);
          final docId = '${_userId}_weekly_$periodId';

          final doc = await FirebaseFirestore.instance
              .collection('period_counters')
              .doc(docId)
              .get();

          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;

            try {
              final periodCounter = PeriodCounters.fromJson(doc.id, data);

              periodCounters.add(periodCounter);
            } catch (parseError) {
              // Handle parsing error silently
            }
          } else {
            // Create empty period counter for missing weeks
            periodCounters.add(PeriodCounters(
              id: docId,
              userId: _userId,
              period: 'weekly',
              periodId: periodId,
              totals: Totals(income: 0, expense: 0, co2Kg: 0),
              breakdowns: Breakdowns(
                incomeByCategory: {},
                expenseByCategory: {},
                co2ByCategory: {},
              ),
              appliedTxIds: [],
              lastUpdated: DateTime.now(),
              insights: {},
            ));
          }
        }
      } else {
        // Fetch last 6 months
        final now = DateTime.now();
        for (int i = 5; i >= 0; i--) {
          final date = DateTime(now.year, now.month - i, 1);
          final periodId = _generateMonthlyPeriodId(date);
          final docId = '${_userId}_monthly_$periodId';

          final doc = await FirebaseFirestore.instance
              .collection('period_counters')
              .doc(docId)
              .get();

          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;

            try {
              final periodCounter = PeriodCounters.fromJson(doc.id, data);

              periodCounters.add(periodCounter);
            } catch (parseError) {
              // Handle parsing error silently
            }
          } else {
            // Create empty period counter for missing months
            periodCounters.add(PeriodCounters(
              id: docId,
              userId: _userId,
              period: 'monthly',
              periodId: periodId,
              totals: Totals(income: 0, expense: 0, co2Kg: 0),
              breakdowns: Breakdowns(
                incomeByCategory: {},
                expenseByCategory: {},
                co2ByCategory: {},
              ),
              appliedTxIds: [],
              lastUpdated: DateTime.now(),
              insights: {},
            ));
          }
        }
      }
    } catch (e) {
      // Handle error silently
    }

    return periodCounters;
  }

  // Helper method to get week start date
  DateTime _getWeekStartDate(DateTime date, int weekIndex) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final firstMonday =
        firstDayOfMonth.add(Duration(days: (8 - firstWeekday) % 7));
    return firstMonday.add(Duration(days: weekIndex * 7));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rotationController.dispose();
    if (_periodCounterController.hasListener) {
      _periodCounterController.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          title: Text('Dashboard',
              style: GoogleFonts.quicksand(
                  fontSize: AppConstants.fontSizeExtraLarge,
                  fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: AppConstants.backgroundColor,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF74C95C))),
              SizedBox(height: 16),
              Text("Loading dashboard...",
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Color(0xFF666666))),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text('Dashboard',
            style: GoogleFonts.quicksand(
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: AppConstants.paddingMedium),
            child: Text(
              _getDateRepresentation(),
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppConstants.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildPeriodSelector(),
              _buildOverviewMetrics(),
              _buildChartSection(),
              _buildInsightsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          _buildPeriodButton("Daily", 0, Icons.today_rounded),
          SizedBox(width: AppConstants.paddingMedium),
          _buildPeriodButton("Weekly", 1, Icons.view_week_rounded),
          SizedBox(width: AppConstants.paddingMedium),
          _buildPeriodButton("Monthly", 2, Icons.calendar_month_rounded),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String text, int index, IconData icon) {
    final isSelected = _selectedPeriodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriodIndex = index;
            switch (index) {
              case 0:
                _currentPeriod = 'daily';
                break;
              case 1:
                _currentPeriod = 'weekly';
                break;
              case 2:
                _currentPeriod = 'monthly';
                break;
            }
            // Update the stream when period changes
            _updatePeriod();
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
              vertical: AppConstants.paddingSmall, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xff92b977) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            border: Border.all(
              color: isSelected
                  ? Color(0xff92b977)
                  : AppConstants.textSecondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color:
                      isSelected ? Colors.white : AppConstants.textSecondary),
              SizedBox(width: AppConstants.paddingExtraSmall),
              Text(text,
                  style: GoogleFonts.quicksand(
                      fontSize: AppConstants.fontSizeSmall,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppConstants.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewMetrics() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _periodCounterStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Container(
            margin: EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _buildMetricCard("Income", "RM 0.00",
                            Color(0xFF4CAF50), Icons.arrow_downward, "")),
                    SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                        child: _buildMetricCard("Expenses", "RM 0.00",
                            Color(0xFFF44336), Icons.arrow_upward, "")),
                    SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                        child: _buildMetricCard(
                            "Balance",
                            "RM 0.00",
                            Color(0xFF2196F3),
                            Icons.account_balance_wallet,
                            "")),
                    SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                        child: _buildMetricCard("Carbon", "0.0 kg",
                            Color(0xFFFF9800), Icons.eco, "")),
                  ],
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final periodCounters = PeriodCounters.fromJson(snapshot.data!.id, data);

        final income = periodCounters.totals.income;
        final expense = periodCounters.totals.expense;
        final co2 = periodCounters.totals.co2Kg;
        final balance = periodCounters.totals.balance;

        return Container(
          margin: EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: _buildMetricCard(
                          "Income",
                          "RM ${income.toStringAsFixed(2)}",
                          Color(0xFF4CAF50),
                          Icons.arrow_downward,
                          _calculateTrend(periodCounters, 'income'))),
                  SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                      child: _buildMetricCard(
                          "Expense",
                          "RM ${expense.toStringAsFixed(2)}",
                          Color(0xFFF44336),
                          Icons.arrow_upward,
                          _calculateTrend(periodCounters, 'expense'))),
                  SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                      child: _buildMetricCard(
                          "Balance",
                          "RM ${balance.toStringAsFixed(2)}",
                          Color(0xFF2196F3),
                          Icons.account_balance_wallet,
                          _calculateTrend(periodCounters, 'balance'))),
                  SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                      child: _buildMetricCard(
                          "Carbon",
                          "${co2.toStringAsFixed(1)} kg",
                          Color(0xFFFF9800),
                          Icons.eco,
                          _calculateTrend(periodCounters, 'co2'))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
      String title, String value, Color color, IconData icon, String trend) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: 6),
              Text(title,
                  style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.textSecondary)),
              Spacer(),
              if (trend.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: trend.startsWith('+')
                        ? Color(0xFFF44336).withOpacity(0.1)
                        : Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  child: Text(trend,
                      style: GoogleFonts.quicksand(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: trend.startsWith('+')
                              ? Color(0xFFF44336)
                              : Color(0xFF4CAF50))),
                ),
            ],
          ),
          SizedBox(height: AppConstants.paddingSmall),
          _buildValueWithUnit(value, color),
        ],
      ),
    );
  }

  Widget _buildValueWithUnit(String value, Color color) {
    // Split value into unit and number parts
    String unit = '';
    String number = value;

    if (value.contains('RM ')) {
      // For RM values: show unit first, then number
      unit = 'RM ';
      number = value.replaceAll('RM ', '');

      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(unit,
              style: GoogleFonts.quicksand(
                  fontSize: 9, fontWeight: FontWeight.w500, color: color)),
          Text(number,
              style: GoogleFonts.quicksand(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      );
    } else if (value.endsWith(' kg')) {
      // For kg values: show number first, then unit
      unit = ' kg';
      number = value.replaceAll(' kg', '');

      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(number,
              style: GoogleFonts.quicksand(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          Text(unit,
              style: GoogleFonts.quicksand(
                  fontSize: 9, fontWeight: FontWeight.w500, color: color)),
        ],
      );
    } else {
      // If no unit found, return original value
      return Text(value,
          style: GoogleFonts.quicksand(
              fontSize: 13, fontWeight: FontWeight.w700, color: color));
    }
  }

  Widget _buildChartSection() {
    return Container(
      height: 450,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildChartIndicator(0, "Spending"),
                  SizedBox(width: AppConstants.paddingSmall),
                  _buildChartIndicator(1, "Category Analysis"),
                  SizedBox(width: AppConstants.paddingSmall),
                  _buildChartIndicator(2, "Trend"),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentChartIndex = index);
                  _rotationController.reset();
                  Future.delayed(Duration(milliseconds: 50), () {
                    if (mounted) {
                      _rotationController.forward();
                    }
                  });
                },
                itemCount: 3, // Only 3 charts
                itemBuilder: (context, index) {
                  final actualIndex = index; // Direct mapping
                  final isActive = actualIndex == _currentChartIndex;
                  final offset = (actualIndex - _currentChartIndex) * 0.4;
                  return AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..translate(offset * 150, 0.0, isActive ? 0.0 : -30.0)
                          ..rotateY(isActive ? 0.0 : offset * 0.3)
                          ..scale(isActive ? 1.0 : 0.9),
                        alignment: Alignment.center,
                        child: _buildChartContent(actualIndex),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartIndicator(int index, String title) {
    final isActive = _currentChartIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(index,
            duration: Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall),
        decoration: BoxDecoration(
          color: isActive ? Color(0xff92b977) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(
              color: isActive
                  ? Color(0xff92b977)
                  : AppConstants.textSecondary.withOpacity(0.3),
              width: 1),
        ),
        child: Text(title,
            style: GoogleFonts.quicksand(
                fontSize: AppConstants.fontSizeSmall,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.white : AppConstants.textSecondary)),
      ),
    );
  }

  Widget _buildChartContent(int index) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall),
      child: Column(
        children: [
          _buildChartTitle(index),
          _buildChartDescription(index),
          Expanded(child: _buildChartByIndex(index)),
        ],
      ),
    );
  }

  Widget _buildChartTitle(int index) {
    final titles = [
      "Spending Overview",
      "Category Analysis",
      "Carbon Emissions Trend"
    ];
    final colors = [Color(0xff92b977), Color(0xff92b977), Color(0xFF2196F3)];
    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Text(titles[index],
          style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.w700,
              color: colors[index])),
    );
  }

  Widget _buildChartDescription(int index) {
    final descriptions = [
      "Compare your income and expenses by ${_currentPeriod}",
      "Analyze spending, income, and carbon emissions by category",
      "Track carbon emissions trend vs peers"
    ];
    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Text(descriptions[index],
          style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeSmall,
              color: AppConstants.textSecondary,
              height: 1.2),
          textAlign: TextAlign.center),
    );
  }

  Widget _buildChartByIndex(int index) {
    switch (index) {
      case 0:
        return _buildFinancialBarChart();
      case 1:
        return _buildBreakdownChart();
      case 2:
        return _buildTrendsChart();
      default:
        return Container();
    }
  }

  Widget _buildFinancialBarChart() {
    return FutureBuilder<List<PeriodCounters>>(
      future: _fetchPeriodCountersForTrend(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<FinanceCO2Data> data = [];

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final periodCounters = snapshot.data!;

          if (_currentPeriod == 'daily') {
            // Show last 7 days with real data
            for (int i = 0; i < periodCounters.length; i++) {
              final counter = periodCounters[i];
              final dayName = _getDayName(
                  DateTime.now().subtract(Duration(days: 6 - i)).weekday);

              data.add(FinanceCO2Data(
                label: dayName,
                income: counter.totals.income,
                expense: counter.totals.expense,
                co2: counter.totals.co2Kg,
              ));
            }
          } else if (_currentPeriod == 'weekly') {
            // Show weeks in current month with real data
            final weeksInMonth = _getWeeksInMonth(DateTime.now());
            for (int i = 0; i < periodCounters.length; i++) {
              final counter = periodCounters[i];
              data.add(FinanceCO2Data(
                label: weeksInMonth[i],
                income: counter.totals.income,
                expense: counter.totals.expense,
                co2: counter.totals.co2Kg,
              ));
            }
          } else {
            // Monthly - show last 6 months with real data
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
            for (int i = 0; i < periodCounters.length; i++) {
              final counter = periodCounters[i];
              data.add(FinanceCO2Data(
                label: months[i],
                income: counter.totals.income,
                expense: counter.totals.expense,
                co2: counter.totals.co2Kg,
              ));
            }
          }
        } else {
          // No data - show empty chart
          if (_currentPeriod == 'daily') {
            final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            for (String day in days) {
              data.add(
                  FinanceCO2Data(label: day, income: 0, expense: 0, co2: 0));
            }
          } else if (_currentPeriod == 'weekly') {
            final weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
            for (String week in weeks) {
              data.add(
                  FinanceCO2Data(label: week, income: 0, expense: 0, co2: 0));
            }
          } else {
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
            for (String month in months) {
              data.add(
                  FinanceCO2Data(label: month, income: 0, expense: 0, co2: 0));
            }
          }
        }

        return Container(
          padding: EdgeInsets.all(AppConstants.paddingSmall),
          child: Column(
            children: [
              Expanded(
                child: SfCartesianChart(
                  legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: GoogleFonts.quicksand(
                          fontSize: AppConstants.fontSizeSmall)),
                  primaryXAxis: CategoryAxis(
                      labelStyle: GoogleFonts.quicksand(
                          fontSize: AppConstants.fontSizeSmall)),
                  primaryYAxis: NumericAxis(
                      labelStyle: GoogleFonts.quicksand(
                          fontSize: AppConstants.fontSizeSmall)),
                  series: <CartesianSeries>[
                    ColumnSeries<FinanceCO2Data, String>(
                      name: 'Income',
                      dataSource: data,
                      xValueMapper: (FinanceCO2Data finance, _) =>
                          finance.label,
                      yValueMapper: (FinanceCO2Data finance, _) =>
                          finance.income,
                      color: Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    ColumnSeries<FinanceCO2Data, String>(
                      name: 'Expense',
                      dataSource: data,
                      xValueMapper: (FinanceCO2Data finance, _) =>
                          finance.label,
                      yValueMapper: (FinanceCO2Data finance, _) =>
                          finance.expense,
                      color: Color(0xFFF44336),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownChart() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingSmall),
      child: Column(
        children: [
          Row(
            children: [
              _buildBreakdownTabButton("Expense", 0),
              SizedBox(width: AppConstants.paddingMedium),
              _buildBreakdownTabButton("Income", 1),
              SizedBox(width: AppConstants.paddingMedium),
              _buildBreakdownTabButton("CO₂", 2),
            ],
          ),
          Expanded(child: _buildBreakdownChartContent()),
        ],
      ),
    );
  }

  Widget _buildBreakdownTabButton(String text, int index) {
    final isSelected = _breakdownTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _breakdownTabIndex = index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
              vertical: AppConstants.paddingSmall,
              horizontal: AppConstants.paddingExtraSmall),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xff92b977) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            border: Border.all(
              color: isSelected
                  ? Color(0xff92b977)
                  : AppConstants.textSecondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(text,
              style: GoogleFonts.quicksand(
                  fontSize: AppConstants.fontSizeSmall,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected ? Colors.white : AppConstants.textSecondary),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildBreakdownChartContent() {
    print(
        "🔍 _buildBreakdownChartContent called, breakdown tab index: $_breakdownTabIndex");
    return StreamBuilder<DocumentSnapshot>(
      stream: _periodCounterStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<BreakdownItem> data = [];
        String unit = "";
        Color valueColor = Colors.red;

        if (snapshot.hasData && snapshot.data!.exists) {
          final periodData = snapshot.data!.data() as Map<String, dynamic>;
          final periodCounters =
              PeriodCounters.fromJson(snapshot.data!.id, periodData);

          switch (_breakdownTabIndex) {
            case 0: // Expense by Category
              data = _processExpenseCategories(
                  periodCounters.breakdowns.expenseByCategory);
              unit = "RM";
              valueColor = Colors.red;
              break;
            case 1: // Income by Category
              data = _processIncomeCategories(
                  periodCounters.breakdowns.incomeByCategory);
              unit = "RM";
              valueColor = Color(0xFF4CAF50);
              break;
            case 2: // CO2 by Category
              data = _processCO2Categories(
                  periodCounters.breakdowns.co2ByCategory);
              unit = "kg CO₂";
              valueColor = Colors.blueGrey;
              break;
          }
        } else {
          // No data - show zero values for current tab
          switch (_breakdownTabIndex) {
            case 0: // Expense
              data = [];
              unit = "RM";
              valueColor = Colors.red;
              break;
            case 1: // Income
              data = [];
              unit = "RM";
              valueColor = Color(0xFF4CAF50);
              break;
            case 2: // CO2
              data = [];
              unit = "kg CO₂";
              valueColor = Colors.blueGrey;
              break;
          }
        }

        if (data.isEmpty) {
          // Show empty pie chart with 0 value instead of "no data" message
          data = [BreakdownItem(category: "No Data", value: 0)];
        }

        return Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  print("🎯 Chart tapped! Starting breakdown modal...");

                  // Fetch transactions for the current breakdown tab
                  String type = 'expense';
                  if (_breakdownTabIndex == 1)
                    type = 'income';
                  else if (_breakdownTabIndex == 2)
                    type = 'expense'; // CO2 comes from expenses

                  print(
                      "📊 Breakdown tab index: $_breakdownTabIndex, Type: $type");

                  // Use cached data for instant modal access
                  if (_isBackgroundFetchComplete &&
                      _cachedTransactions.isNotEmpty) {
                    print("🚀 Using cached transactions for instant modal!");
                    final transactions = _cachedTransactions.values
                        .where((tx) => tx.type == type)
                        .toList();
                    print(
                        "📋 Found ${transactions.length} cached transactions");
                    _showBreakdownModal(data, unit, valueColor, transactions);
                  } else if (_cachedPeriodCounters != null) {
                    print(
                        "✅ Using cached period data, fetching transactions...");
                    final transactions = await _fetchBreakdownDetails(
                        _cachedPeriodCounters!.appliedTxIds, type);
                    print("📋 Fetched ${transactions.length} transactions");
                    _showBreakdownModal(data, unit, valueColor, transactions);
                  } else {
                    print("❌ No cached data, trying to fetch...");
                    // Fallback to stream if cache is empty
                    try {
                      final periodDoc = await _periodCounterStream.first;
                      if (periodDoc.exists) {
                        final periodData =
                            periodDoc.data() as Map<String, dynamic>;
                        final periodCounters =
                            PeriodCounters.fromJson(periodDoc.id, periodData);
                        final transactions = await _fetchBreakdownDetails(
                            periodCounters.appliedTxIds, type);
                        print(
                            "📋 Fetched ${transactions.length} transactions from stream");
                        _showBreakdownModal(
                            data, unit, valueColor, transactions);
                      } else {
                        print("❌ Period doc doesn't exist");
                        _showBreakdownModal(data, unit, valueColor, []);
                      }
                    } catch (e) {
                      print("❌ Error fetching from stream: $e");
                      _showBreakdownModal(data, unit, valueColor, []);
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(AppConstants.paddingSmall),
                  child: PieChart(
                    PieChartData(
                      sections: data.map((item) {
                        double percentage =
                            data.fold(0.0, (sum, i) => sum + i.value) > 0
                                ? (item.value /
                                        data.fold(
                                            0.0, (sum, i) => sum + i.value)) *
                                    100
                                : 0;
                        return PieChartSectionData(
                          value: percentage,
                          color: _getCategoryColor(item.category),
                          radius: 60,
                          title:
                              "${percentage.toStringAsFixed(1)}%\n${_formatValue(item.value, unit)}",
                          titleStyle: GoogleFonts.quicksand(
                              fontSize: AppConstants.fontSizeSmall,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        );
                      }).toList(),
                      centerSpaceRadius: 30,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              ),
            ),
            // Legend - Horizontal layout to save space
            Container(
              margin: EdgeInsets.only(top: AppConstants.paddingSmall),
              padding: EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Wrap(
                spacing: AppConstants.paddingSmall,
                runSpacing: AppConstants.paddingExtraSmall,
                children: data.map((item) {
                  double percentage =
                      data.fold(0.0, (sum, i) => sum + i.value) > 0
                          ? (item.value /
                                  data.fold(0.0, (sum, i) => sum + i.value)) *
                              100
                          : 0;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(item.category),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: AppConstants.paddingExtraSmall),
                      Text(
                        "${item.category} (${percentage.toStringAsFixed(1)}%)",
                        style: GoogleFonts.quicksand(
                          fontSize: AppConstants.fontSizeSmall,
                          fontWeight: FontWeight.w500,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendsChart() {
    return FutureBuilder<List<PeriodCounters>>(
      future: _fetchPeriodCountersForTrend(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Prepare data for carbon chart only
        List<FlSpot> carbonSpots = [];
        List<FlSpot> carbonPeerSpots = [];
        List<String> labels = [];
        double maxCarbon = 0;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final periodCounters = snapshot.data!;

          if (_currentPeriod == 'daily') {
            // Show last 7 days with real data
            final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            for (int i = 0; i < periodCounters.length && i < 7; i++) {
              final counter = periodCounters[i];
              final carbonValue = counter.totals.co2Kg;

              carbonSpots.add(FlSpot(i.toDouble(), carbonValue));
              carbonPeerSpots.add(FlSpot(i.toDouble(), carbonValue * 1.2));
              maxCarbon = carbonValue > maxCarbon ? carbonValue : maxCarbon;
              labels.add(days[i]);
            }
          } else if (_currentPeriod == 'weekly') {
            // Show weeks in current month with real data
            final weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'];
            for (int i = 0; i < periodCounters.length && i < 5; i++) {
              final counter = periodCounters[i];
              final carbonValue = counter.totals.co2Kg;

              carbonSpots.add(FlSpot(i.toDouble(), carbonValue));
              carbonPeerSpots.add(FlSpot(i.toDouble(), carbonValue * 1.15));
              maxCarbon = carbonValue > maxCarbon ? carbonValue : maxCarbon;
              labels.add(weeks[i]);
            }
          } else {
            // Monthly - show last 6 months with real data
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
            for (int i = 0; i < periodCounters.length && i < 6; i++) {
              final counter = periodCounters[i];
              final carbonValue = counter.totals.co2Kg;

              carbonSpots.add(FlSpot(i.toDouble(), carbonValue));
              carbonPeerSpots.add(FlSpot(i.toDouble(), carbonValue * 1.1));
              maxCarbon = carbonValue > maxCarbon ? carbonValue : maxCarbon;
              labels.add(months[i]);
            }
          }
        } else {
          // No data - show empty chart with 0 values
          if (_currentPeriod == 'daily') {
            final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            for (int i = 0; i < 7; i++) {
              carbonSpots.add(FlSpot(i.toDouble(), 0));
              carbonPeerSpots.add(FlSpot(i.toDouble(), 0));
              labels.add(days[i]);
            }
          } else if (_currentPeriod == 'weekly') {
            final weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'];
            for (int i = 0; i < 5; i++) {
              carbonSpots.add(FlSpot(i.toDouble(), 0));
              carbonPeerSpots.add(FlSpot(i.toDouble(), 0));
              labels.add(weeks[i]);
            }
          } else {
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
            for (int i = 0; i < 6; i++) {
              carbonSpots.add(FlSpot(i.toDouble(), 0));
              carbonPeerSpots.add(FlSpot(i.toDouble(), 0));
              labels.add(months[i]);
            }
          }
        }

        double carbonInterval =
            maxCarbon > 0 ? (maxCarbon / 3).ceilToDouble() : 10;

        return Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              // Carbon Chart Only
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF9800),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text("Your Carbon",
                            style: GoogleFonts.quicksand(
                                fontSize: AppConstants.fontSizeSmall,
                                color: AppConstants.textSecondary)),
                        SizedBox(width: AppConstants.paddingMedium),
                        Container(
                          width: 12,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Color(0xFF9C27B0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: AppConstants.paddingSmall),
                        Text("Peer Avg",
                            style: GoogleFonts.quicksand(
                                fontSize: AppConstants.fontSizeSmall,
                                color: AppConstants.textSecondary)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: carbonInterval,
                              getDrawingHorizontalLine: (value) => FlLine(
                                  color: Color(0xFFE0E0E0), strokeWidth: 1)),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 25,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < labels.length) {
                                    return Text(labels[value.toInt()],
                                        style: GoogleFonts.quicksand(
                                            fontSize:
                                                AppConstants.fontSizeSmall,
                                            fontWeight: FontWeight.w500,
                                            color: AppConstants.textSecondary));
                                  }
                                  return Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: carbonInterval,
                                getTitlesWidget: (value, meta) => Text(
                                    '${value.toInt()}kg',
                                    style: GoogleFonts.quicksand(
                                        fontSize: AppConstants.fontSizeSmall,
                                        fontWeight: FontWeight.w500,
                                        color: AppConstants.textSecondary)),
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: carbonSpots,
                              isCurved: true,
                              color: Color(0xFFFF9800),
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                            radius: 4,
                                            color: Color(0xFFFF9800),
                                            strokeWidth: 2,
                                            strokeColor: Colors.white),
                              ),
                              belowBarData: BarAreaData(
                                  show: true,
                                  color: Color(0xFFFF9800).withOpacity(0.1)),
                            ),
                            LineChartBarData(
                              spots: carbonPeerSpots,
                              isCurved: true,
                              color: Color(0xFF9C27B0),
                              barWidth: 2,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                            radius: 3,
                                            color: Color(0xFF9C27B0),
                                            strokeWidth: 1,
                                            strokeColor: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightsSection() {
    return Container(
      margin: EdgeInsets.all(AppConstants.paddingMedium),
      padding: EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded,
                  color: AppConstants.accentColor, size: 20),
              SizedBox(width: AppConstants.paddingSmall),
              Text("Smart Insights",
                  style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff92b977))),
            ],
          ),
          SizedBox(height: AppConstants.paddingSmall),
          _buildCompactInsights(_currentChartIndex),
        ],
      ),
    );
  }

  Widget _buildCompactInsights(int chartIndex) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _periodCounterStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 60,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF74C95C)),
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Container(
            height: 60,
            child: Center(
              child: Text(
                "No data available for insights",
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textPrimary,
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final periodCounters = PeriodCounters.fromJson(snapshot.data!.id, data);

        // Fetch insights from Firestore period counter data
        List<String> insights = [];

        if (periodCounters.insights.isNotEmpty) {
          // Always add core insights first
          if (periodCounters.insights.containsKey('core')) {
            final coreInsights = periodCounters.insights['core'];
            if (coreInsights != null) {
              if (coreInsights is List) {
                final list = coreInsights as List;
                if (list.isNotEmpty) {
                  insights.addAll(list.cast<String>());
                }
              } else if (coreInsights is String) {
                final string = coreInsights as String;
                if (string.isNotEmpty) {
                  // If it's a single string, split by newlines or bullet points
                  final coreList = string
                      .split('\n')
                      .where((line) => line.trim().isNotEmpty)
                      .map((line) => line.trim())
                      .toList();
                  insights.addAll(coreList);
                }
              }
            }
          }

          // Then get insights based on current chart type
          String insightKey = '';
          switch (chartIndex) {
            case 0: // Spending Overview
              insightKey = 'spending';
              break;
            case 1: // Category Analysis
              insightKey = 'category';
              break;
            case 2: // Carbon Trend
              insightKey = 'carbon';
              break;
          }

          // Try to get insights for the specific chart type
          if (periodCounters.insights.containsKey(insightKey)) {
            final chartInsights = periodCounters.insights[insightKey];
            if (chartInsights != null) {
              if (chartInsights is List) {
                final list = chartInsights as List;
                if (list.isNotEmpty) {
                  insights.addAll(list.cast<String>());
                }
              } else if (chartInsights is String) {
                final string = chartInsights as String;
                if (string.isNotEmpty) {
                  // If it's a single string, split by newlines or bullet points
                  final chartList = string
                      .split('\n')
                      .where((line) => line.trim().isNotEmpty)
                      .map((line) => line.trim())
                      .toList();
                  insights.addAll(chartList);
                }
              }
            }
          }

          // If no specific chart insights, try to get general insights
          final hasCoreInsights = periodCounters.insights.containsKey('core');
          final coreInsightsCount = hasCoreInsights
              ? (periodCounters.insights['core'] is List
                  ? (periodCounters.insights['core'] as List).length
                  : 1)
              : 0;

          if (insights.length <= coreInsightsCount) {
            if (periodCounters.insights.containsKey('general')) {
              final generalInsights = periodCounters.insights['general'];
              if (generalInsights != null) {
                if (generalInsights is List) {
                  final list = generalInsights as List;
                  if (list.isNotEmpty) {
                    insights.addAll(list.cast<String>());
                  }
                } else if (generalInsights is String) {
                  final string = generalInsights as String;
                  if (string.isNotEmpty) {
                    final generalList = string
                        .split('\n')
                        .where((line) => line.trim().isNotEmpty)
                        .map((line) => line.trim())
                        .toList();
                    insights.addAll(generalList);
                  }
                }
              }
            }
          }

          // If still no insights, try to get any available insights
          if (insights.length <= coreInsightsCount) {
            for (var entry in periodCounters.insights.entries) {
              if (entry.key != 'core' &&
                  entry.key != 'general' &&
                  entry.value != null) {
                if (entry.value is List) {
                  final list = entry.value as List;
                  if (list.isNotEmpty) {
                    insights.addAll(list.cast<String>());
                    break;
                  }
                } else if (entry.value is String) {
                  final string = entry.value as String;
                  if (string.isNotEmpty) {
                    final entryList = string
                        .split('\n')
                        .where((line) => line.trim().isNotEmpty)
                        .map((line) => line.trim())
                        .toList();
                    insights.addAll(entryList);
                    break;
                  }
                }
              }
            }
          }
        }

        // If no Firestore insights, fallback to simple generated insights
        if (insights.isEmpty) {
          switch (chartIndex) {
            case 0: // Spending Overview
              insights = _generateSimpleSpendingInsights(periodCounters);
              break;
            case 1: // Category Analysis
              insights = _generateSimpleCategoryInsights(periodCounters);
              break;
            case 2: // Carbon Trend
              insights = _generateSimpleCarbonInsights(periodCounters);
              break;
          }
        } else {}

        if (insights.isEmpty) {
          return Container(
            height: 60,
            child: Center(
              child: Text(
                "Add transactions to get insights",
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textPrimary,
                ),
              ),
            ),
          );
        }

        // Show all insights (no limit)
        // insights = insights; // Keep all insights

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...insights.map((insight) => Padding(
                  padding:
                      EdgeInsets.only(bottom: AppConstants.paddingExtraSmall),
                  child: Text(
                    "• $insight",
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  // Generate detailed insights for spending overview
  List<InsightData> _generateDetailedSpendingInsights(
      PeriodCounters periodCounters) {
    final income = periodCounters.totals.income;
    final expense = periodCounters.totals.expense;
    final balance = periodCounters.totals.balance;

    List<InsightData> insights = [];

    if (income > 0 && expense > 0) {
      final savingsRate = ((income - expense) / income) * 100;
      if (savingsRate > 20) {
        insights.add(InsightData(
          title: "Excellent Savings Rate",
          description:
              "You're saving ${savingsRate.toStringAsFixed(1)}% of your income - above the recommended 20%",
          icon: Icons.trending_up,
          color: Color(0xFF4CAF50),
          type: InsightType.positive,
        ));
      } else if (savingsRate > 0) {
        insights.add(InsightData(
          title: "Good Progress",
          description:
              "Current savings rate: ${savingsRate.toStringAsFixed(1)}% - aim for 20%+ for financial security",
          icon: Icons.info,
          color: Color(0xFFFF9800),
          type: InsightType.info,
        ));
      } else {
        insights.add(InsightData(
          title: "Action Needed",
          description:
              "Expenses exceed income by RM${balance.abs().toStringAsFixed(2)} - review spending habits",
          icon: Icons.warning,
          color: Color(0xFFF44336),
          type: InsightType.warning,
        ));
      }
    }

    if (expense > 0) {
      insights.add(InsightData(
        title: "Expense Summary",
        description:
            "Total ${_currentPeriod} expenses: RM${expense.toStringAsFixed(2)}",
        icon: Icons.receipt,
        color: Color(0xFF2196F3),
        type: InsightType.info,
      ));

      if (expense > income * 0.8) {
        insights.add(InsightData(
          title: "High Expense Alert",
          description:
              "Expenses are ${((expense / income) * 100).toStringAsFixed(1)}% of income - consider budget review",
          icon: Icons.warning,
          color: Color(0xFFFF9800),
          type: InsightType.warning,
        ));
      }
    }

    if (balance > 0) {
      insights.add(InsightData(
        title: "Current Balance",
        description: "Available balance: RM${balance.toStringAsFixed(2)}",
        icon: Icons.account_balance_wallet,
        color: Color(0xFF4CAF50),
        type: InsightType.positive,
      ));
    }

    return insights;
  }

  // Generate detailed insights for category analysis
  List<InsightData> _generateDetailedCategoryInsights(
      PeriodCounters periodCounters) {
    List<InsightData> insights = [];

    // Expense category insights
    final expenseCategories = periodCounters.breakdowns.expenseByCategory;
    if (expenseCategories.isNotEmpty) {
      final highestExpense =
          expenseCategories.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(InsightData(
        title: "Highest Expense Category",
        description:
            "${highestExpense.key} accounts for RM${highestExpense.value.toStringAsFixed(2)} of your spending",
        icon: Icons.category,
        color: Color(0xFFF44336),
        type: InsightType.info,
      ));

      if (expenseCategories.length > 3) {
        insights.add(InsightData(
          title: "Category Consolidation",
          description:
              "You have ${expenseCategories.length} expense categories - consider consolidating similar ones",
          icon: Icons.merge,
          color: Color(0xFFFF9800),
          type: InsightType.info,
        ));
      }
    }

    // Income category insights
    final incomeCategories = periodCounters.breakdowns.incomeByCategory;
    if (incomeCategories.isNotEmpty) {
      final highestIncome =
          incomeCategories.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(InsightData(
        title: "Primary Income Source",
        description:
            "${highestIncome.key} contributes RM${highestIncome.value.toStringAsFixed(2)} to your income",
        icon: Icons.work,
        color: Color(0xFF4CAF50),
        type: InsightType.positive,
      ));
    }

    // CO2 category insights
    final co2Categories = periodCounters.breakdowns.co2ByCategory;
    if (co2Categories.isNotEmpty) {
      final highestCO2 =
          co2Categories.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(InsightData(
        title: "Highest Carbon Impact",
        description:
            "${highestCO2.key} generates ${highestCO2.value.toStringAsFixed(1)} kg CO₂",
        icon: Icons.eco,
        color: Color(0xFF795548),
        type: InsightType.info,
      ));
    }

    return insights;
  }

  // Generate detailed insights for carbon trend
  List<InsightData> _generateDetailedCarbonInsights(
      PeriodCounters periodCounters) {
    List<InsightData> insights = [];
    final co2 = periodCounters.totals.co2Kg;

    if (co2 > 0) {
      insights.add(InsightData(
        title: "Carbon Footprint",
        description:
            "Your ${_currentPeriod} carbon footprint: ${co2.toStringAsFixed(1)} kg CO₂",
        icon: Icons.eco,
        color: Color(0xFF795548),
        type: InsightType.info,
      ));

      // Carbon intensity insights
      final expense = periodCounters.totals.expense;
      if (expense > 0) {
        final carbonIntensity = co2 / expense;
        if (carbonIntensity < 0.1) {
          insights.add(InsightData(
            title: "Eco-Friendly Choices",
            description:
                "Low carbon intensity (${carbonIntensity.toStringAsFixed(3)} kg/RM) - excellent environmental impact",
            icon: Icons.check_circle,
            color: Color(0xFF4CAF50),
            type: InsightType.positive,
          ));
        } else if (carbonIntensity < 0.2) {
          insights.add(InsightData(
            title: "Moderate Impact",
            description:
                "Carbon intensity: ${carbonIntensity.toStringAsFixed(3)} kg/RM - room for sustainable improvements",
            icon: Icons.info,
            color: Color(0xFFFF9800),
            type: InsightType.info,
          ));
        } else {
          insights.add(InsightData(
            title: "High Carbon Impact",
            description:
                "Carbon intensity: ${carbonIntensity.toStringAsFixed(3)} kg/RM - consider sustainable alternatives",
            icon: Icons.warning,
            color: Color(0xFFF44336),
            type: InsightType.warning,
          ));
        }
      }
    }

    return insights;
  }

  // Generate simple text insights for spending overview
  List<String> _generateSimpleSpendingInsights(PeriodCounters periodCounters) {
    final income = periodCounters.totals.income;
    final expense = periodCounters.totals.expense;
    final balance = periodCounters.totals.balance;

    List<String> insights = [];

    if (income > 0 && expense > 0) {
      final savingsRate = ((income - expense) / income) * 100;
      if (savingsRate > 20) {
        insights.add(
            "Excellent! Saving ${savingsRate.toStringAsFixed(1)}% of income");
      } else if (savingsRate > 0) {
        insights.add(
            "Good progress: ${savingsRate.toStringAsFixed(1)}% savings rate");
      } else {
        insights.add("Consider reducing expenses for positive savings");
      }
    }

    if (expense > 0) {
      insights
          .add("${_currentPeriod} expenses: RM${expense.toStringAsFixed(2)}");

      if (expense > income * 0.8) {
        insights.add(
            "High expenses: ${((expense / income) * 100).toStringAsFixed(1)}% of income");
      }
    }

    if (balance > 0) {
      insights.add("Available balance: RM${balance.toStringAsFixed(2)}");
    }

    return insights;
  }

  // Generate simple text insights for category analysis
  List<String> _generateSimpleCategoryInsights(PeriodCounters periodCounters) {
    List<String> insights = [];

    // Expense category insights
    final expenseCategories = periodCounters.breakdowns.expenseByCategory;
    if (expenseCategories.isNotEmpty) {
      final highestExpense =
          expenseCategories.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(
          "${highestExpense.key}: RM${highestExpense.value.toStringAsFixed(2)}");

      if (expenseCategories.length > 3) {
        insights.add(
            "${expenseCategories.length} categories - consider consolidation");
      }
    }

    // Income category insights
    final incomeCategories = periodCounters.breakdowns.incomeByCategory;
    if (incomeCategories.isNotEmpty) {
      final highestIncome =
          incomeCategories.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add("Primary income: ${highestIncome.key}");
    }

    // CO2 category insights
    final co2Categories = periodCounters.breakdowns.co2ByCategory;
    if (co2Categories.isNotEmpty) {
      final highestCO2 =
          co2Categories.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(
          "Highest CO₂: ${highestCO2.key} (${highestCO2.value.toStringAsFixed(1)} kg)");
    }

    return insights;
  }

  // Generate simple text insights for carbon trend
  List<String> _generateSimpleCarbonInsights(PeriodCounters periodCounters) {
    List<String> insights = [];
    final co2 = periodCounters.totals.co2Kg;

    if (co2 > 0) {
      insights
          .add("${_currentPeriod} carbon: ${co2.toStringAsFixed(1)} kg CO₂");

      // Carbon intensity insights
      final expense = periodCounters.totals.expense;
      if (expense > 0) {
        final carbonIntensity = co2 / expense;
        if (carbonIntensity < 0.1) {
          insights.add("Eco-friendly choices! Low carbon intensity");
        } else if (carbonIntensity < 0.2) {
          insights.add("Moderate carbon impact - room for improvement");
        } else {
          insights.add("High carbon impact - consider alternatives");
        }
      }
    } else {
      insights.add("No carbon footprint recorded");
    }

    return insights;
  }

  // Helper methods
  List<BreakdownItem> processTransactions(
      List<TransactionModel> transactions, String type) {
    Map<String, double> categoryTotals = {};
    for (var transaction in transactions) {
      if (transaction.type == type) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return categoryTotals.entries
        .map((e) => BreakdownItem(category: e.key, value: e.value))
        .toList();
  }

  List<BreakdownItem> processCO2(List<TransactionModel> transactions) {
    Map<String, double> categoryCO2 = {};
    for (var transaction in transactions) {
      if (transaction.carbonFootprint != null &&
          transaction.carbonFootprint! > 0) {
        categoryCO2[transaction.category] =
            (categoryCO2[transaction.category] ?? 0) +
                transaction.carbonFootprint!;
      }
    }
    return categoryCO2.entries
        .map((e) => BreakdownItem(category: e.key, value: e.value))
        .toList();
  }

  Color _getCategoryColor(String category) {
    // Define specific colors for known categories to ensure consistency
    final categoryColors = {
      'Food': Color(0xFFFF9800), // Orange
      'Transport': Color(0xFF2196F3), // Blue
      'Shopping': Color(0xFF9C27B0), // Purple
      'Entertainment': Color(0xFF4CAF50), // Green
      'Salary': Color(0xFF74C95C), // Light Green
      'Freelance': Color(0xFF607D8B), // Blue Grey
      'Investment': Color(0xFF795548), // Brown
    };

    // Return specific color if category exists, otherwise use hash-based color
    if (categoryColors.containsKey(category)) {
      return categoryColors[category]!;
    }

    // Fallback colors for unknown categories
    final fallbackColors = [
      Color(0xFFF44336), // Red
      Color(0xFFE91E63), // Pink
      Color(0xFF00BCD4), // Cyan
      Color(0xFF8BC34A), // Light Green
      Color(0xFFFFC107), // Amber
      Color(0xFF673AB7), // Deep Purple
    ];

    int index = category.hashCode % fallbackColors.length;
    return fallbackColors[index.abs()];
  }

  String _formatValue(double value, String unit) {
    if (unit == "RM") {
      return "RM ${value.toStringAsFixed(2)}";
    } else {
      return "${value.toStringAsFixed(1)} $unit";
    }
  }

  void _showBreakdownModal(List<BreakdownItem> data, String unit,
      Color valueColor, List<TransactionModel> transactions) async {
    print(
        "🚀 _showBreakdownModal called with ${data.length} categories and ${transactions.length} transactions");
    double totalValue = data.fold(0, (sum, item) => sum + item.value);

    // If no transactions provided, fetch them from period counter data
    if (transactions.isEmpty) {
      try {
        // Get current period counter data
        final periodDoc = await _periodCounterStream.first;
        if (periodDoc.exists) {
          final periodData = periodDoc.data() as Map<String, dynamic>;
          final periodCounters =
              PeriodCounters.fromJson(periodDoc.id, periodData);

          // Fetch transactions based on current breakdown tab
          String type = 'expense';
          if (_breakdownTabIndex == 1)
            type = 'income';
          else if (_breakdownTabIndex == 2)
            type = 'expense'; // CO2 comes from expenses

          transactions =
              await _fetchBreakdownDetails(periodCounters.appliedTxIds, type);
        }
      } catch (e) {}
    }

    print("🎯 Attempting to show modal with context: $context");

    // Ensure we have a valid context
    if (!mounted) {
      print("❌ Widget not mounted, cannot show modal");
      return;
    }

    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Category Breakdown",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text("Tap a category to see related transactions",
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Color(0xFF666666))),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      double percentage =
                          totalValue > 0 ? (item.value / totalValue) * 100 : 0;
                      return GestureDetector(
                        onTap: () => _showCategoryTransactions(
                            item.category, transactions),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFFE0E0E0))),
                          child: Row(
                            children: [
                              Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                      color: _getCategoryColor(item.category),
                                      shape: BoxShape.circle)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.category,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        "${_formatValue(item.value, unit)} (${percentage.toStringAsFixed(1)}%)",
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Color(0xFF666666))),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print("❌ Error showing modal: $e");
    }
  }

  void _showCategoryTransactions(
      String category, List<TransactionModel> transactions) {
    final categoryTransactions = transactions
        .where((TransactionModel t) => t.category == category)
        .toList();

    if (categoryTransactions.isEmpty) {
      // Show no transactions message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Transactions'),
          content: Text('No transactions found for category: $category'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$category Transactions",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 16),
              Expanded(
                child: categoryTransactions.isEmpty
                    ? Center(
                        child: Text("No transactions found for this category",
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.grey[600])))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: categoryTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = categoryTransactions[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Color(0xFFE0E0E0))),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Color(0xFF74C95C).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(Icons.receipt,
                                      color: Color(0xFF74C95C), size: 20),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(transaction.description,
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                          "${transaction.date.day}/${transaction.date.month}/${transaction.date.year}",
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Color(0xFF666666))),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        "RM ${transaction.amount.toStringAsFixed(2)}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: transaction.type == 'income'
                                                ? Color(0xFF4CAF50)
                                                : Color(0xFFF44336))),
                                    if (transaction.carbonFootprint != null)
                                      Text(
                                          "${transaction.carbonFootprint!.toStringAsFixed(1)} kg CO₂",
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: Colors.grey[600])),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for chart data
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return 'Mon';
    }
  }

  List<String> _getWeeksInMonth(DateTime date) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    final weeksCount = ((daysInMonth - 1) / 7).ceil();
    List<String> weeks = [];
    for (int i = 1; i <= weeksCount; i++) {
      weeks.add('Week $i');
    }
    return weeks;
  }

  // Calculate trend percentage for metrics
  String _calculateTrend(PeriodCounters currentPeriod, String metricType) {
    try {
      // For now, return empty string (no trend calculation yet)
      // TODO: Implement trend calculation by comparing with previous period
      return "";
    } catch (e) {
      return "";
    }
  }

  // Helper methods for processing category data from period counters
  List<BreakdownItem> _processExpenseCategories(
      Map<String, double> expenseByCategory) {
    return expenseByCategory.entries
        .where((entry) => entry.value > 0)
        .map((entry) => BreakdownItem(
              category: entry.key,
              value: entry.value,
            ))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sort by value descending
  }

  List<BreakdownItem> _processIncomeCategories(
      Map<String, double> incomeByCategory) {
    return incomeByCategory.entries
        .where((entry) => entry.value > 0)
        .map((entry) => BreakdownItem(
              category: entry.key,
              value: entry.value,
            ))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sort by value descending
  }

  List<BreakdownItem> _processCO2Categories(Map<String, double> co2ByCategory) {
    return co2ByCategory.entries
        .where((entry) => entry.value > 0)
        .map((entry) => BreakdownItem(
              category: entry.key,
              value: entry.value,
            ))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sort by value descending
  }

  // Fetch breakdown details from applied transaction IDs
  Future<List<TransactionModel>> _fetchBreakdownDetails(
      List<String> appliedTxIds, String type) async {
    List<TransactionModel> transactions = [];

    try {
      if (appliedTxIds.isEmpty) {
        return transactions;
      }

      for (String txId in appliedTxIds) {
        // Check if it's income or expense based on ID prefix or collection
        if (type == 'income') {
          // Try to fetch from income collection
          final incomeDoc = await FirebaseFirestore.instance
              .collection('income')
              .doc(txId)
              .get();

          if (incomeDoc.exists) {
            final data = incomeDoc.data() as Map<String, dynamic>;

            transactions.add(TransactionModel(
              id: txId,
              type: 'income',
              amount: (data['amount'] ?? 0).toDouble(),
              category: data['name'] ?? 'Unknown', // income uses 'name' field
              description: data['name'] ?? '',
              date: (data['dateTime'] as Timestamp).toDate(),
              carbonFootprint: 0, // Income has no carbon footprint
            ));
          } else {}
        } else if (type == 'expense') {
          // Try to fetch from expense collection
          final expenseDoc = await FirebaseFirestore.instance
              .collection('expense')
              .doc(txId)
              .get();

          if (expenseDoc.exists) {
            final data = expenseDoc.data() as Map<String, dynamic>;

            final expenseTotal = await _calculateExpenseTotal(data);
            final expenseCategory = await _getExpenseCategory(data);
            transactions.add(TransactionModel(
              id: txId,
              type: 'expense',
              amount: expenseTotal, // Calculate from expense items
              category: expenseCategory, // Get primary category
              description: data['transactionName'] ?? '',
              date: (data['dateTime'] as Timestamp).toDate(),
              carbonFootprint: (data['carbon_footprint'] ?? 0).toDouble(),
            ));
          } else {}
        }
      }
    } catch (e) {}

    return transactions;
  }

  // Helper method to calculate expense total from expense items
  Future<double> _calculateExpenseTotal(
      Map<String, dynamic> expenseData) async {
    double total = 0;
    final items = expenseData['items'] as List<dynamic>?;

    if (items != null) {
      for (var itemRef in items) {
        try {
          // Fetch expense item document
          final itemDoc = await itemRef.get();
          if (itemDoc.exists) {
            final itemData = itemDoc.data() as Map<String, dynamic>;
            final price = (itemData['price'] ?? 0).toDouble();
            final quantity = (itemData['quantity'] ?? 1).toDouble();
            total += price * quantity;
          }
        } catch (e) {}
      }
    }

    return total;
  }

  // Helper method to get primary category from expense
  Future<String> _getExpenseCategory(Map<String, dynamic> expenseData) async {
    final items = expenseData['items'] as List<dynamic>?;

    if (items != null && items.isNotEmpty) {
      try {
        // Get first item's category
        final firstItemRef = items.first;
        final itemDoc = await firstItemRef.get();
        if (itemDoc.exists) {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          return itemData['category'] ?? 'General';
        }
      } catch (e) {}
    }

    return 'General';
  }

  // MARK: - Insight UI Methods

  Widget _buildLoadingInsights() {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF74C95C)),
            ),
            SizedBox(height: 12),
            Text("Analyzing your data...",
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Color(0xFF666666))),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataInsights() {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 48, color: Color(0xFFCCCCCC)),
            SizedBox(height: 12),
            Text("No data available for insights",
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Color(0xFF666666))),
            Text("Add some transactions to get personalized recommendations",
                style: GoogleFonts.poppins(
                    fontSize: 10, color: Color(0xFF999999))),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightSectionHeader(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Color(0xFF74C95C)),
          SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }

  Widget _buildInsightCard(InsightData insight) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: insight.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(insight.icon, color: insight.color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A))),
                SizedBox(height: 4),
                Text(insight.description,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Color(0xFF666666), height: 1.3)),
              ],
            ),
          ),
          if (insight.actionText != null)
            TextButton(
                onPressed: insight.onAction,
                child: Text(insight.actionText!,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: insight.color))),
        ],
      ),
    );
  }
}

// Add this class for chart data
class FinanceCO2Data {
  final String label;
  final double income;
  final double expense;
  final double co2;

  FinanceCO2Data({
    required this.label,
    required this.income,
    required this.expense,
    required this.co2,
  });
}

// Add this class for breakdown data
class BreakdownItem {
  final String category;
  final double value;

  BreakdownItem({
    required this.category,
    required this.value,
  });
}

// Add this class for insights data
class InsightData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final InsightType type;
  final String? actionText;
  final VoidCallback? onAction;

  InsightData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    this.actionText,
    this.onAction,
  });
}

enum InsightType {
  positive,
  warning,
  info,
}
