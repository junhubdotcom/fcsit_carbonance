import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../services/dashboard_data_service.dart';
import '../../models/transaction_model.dart';
import '../../models/breakdown_item.dart';
import '../../models/finance_data.dart';

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
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: 1, // Start with Category Analysis (index 1)
    );
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await DashboardDataService.loadData();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFFAFBFF),
        appBar: AppBar(
          title: Text('Dashboard',
              style: GoogleFonts.quicksand(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Color(0xFFFAFBFF),
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
      backgroundColor: Color(0xFFFAFBFF),
      appBar: AppBar(
        title: Text('Dashboard',
            style: GoogleFonts.quicksand(
                fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFFAFBFF),
        elevation: 0,
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
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton("Daily", 0, Icons.today_rounded),
          _buildPeriodButton("Weekly", 1, Icons.view_week_rounded),
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
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF74C95C) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14,
                  color: isSelected ? Colors.white : Colors.grey[600]),
              SizedBox(width: 4),
              Text(text,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewMetrics() {
    final stats = DashboardDataService.getSummaryStats(_currentPeriod);
    final carbonIntensity = stats['totalSpent'] > 0
        ? (stats['totalCarbon'] / stats['totalSpent']).toStringAsFixed(2)
        : '0.00';

    return Container(
      margin: EdgeInsets.all(12),
      child: Row(
        children: [
          _buildMetricCard(
              "Income",
              "RM ${stats['totalIncome'].toStringAsFixed(2)}",
              Color(0xFF4CAF50),
              Icons.arrow_downward,
              "+12%"),
          SizedBox(width: 6),
          _buildMetricCard(
              "Expenses",
              "RM ${stats['totalSpent'].toStringAsFixed(2)}",
              Color(0xFFF44336),
              Icons.arrow_upward,
              "+5%"),
          SizedBox(width: 6),
          _buildMetricCard(
              "Balance",
              "RM ${(stats['totalIncome'] - stats['totalSpent']).toStringAsFixed(2)}",
              Color(0xFF2196F3),
              Icons.account_balance_wallet,
              ""),
          SizedBox(width: 6),
          _buildMetricCard(
              "Carbon",
              "${stats['totalCarbon'].toStringAsFixed(1)} kg",
              Color(0xFFFF9800),
              Icons.eco,
              "-8%"),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, Color color, IconData icon, String trend) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 16),
                if (trend.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: trend.startsWith('+')
                          ? Color(0xFFF44336).withOpacity(0.1)
                          : Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(trend,
                        style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: trend.startsWith('+')
                                ? Color(0xFFF44336)
                                : Color(0xFF4CAF50))),
                  ),
              ],
            ),
            SizedBox(height: 4),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666))),
            SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 400,
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
                  SizedBox(width: 8),
                  _buildChartIndicator(1, "Category Analysis"),
                  SizedBox(width: 8),
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
              height: 350,
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
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFF74C95C) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isActive ? Color(0xFF74C95C) : Color(0xFFE0E0E0),
              width: 1),
        ),
        child: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.white : Color(0xFF666666))),
      ),
    );
  }

  Widget _buildChartContent(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    final colors = [Color(0xFF74C95C), Color(0xFF4CAF50), Color(0xFF2196F3)];
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Text(titles[index],
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700, color: colors[index])),
    );
  }

  Widget _buildChartDescription(int index) {
    final descriptions = [
      "Compare your income and expenses by ${_currentPeriod}",
      "Analyze spending, income, and carbon emissions by category",
      "Track carbon emissions trend vs peers"
    ];
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      child: Text(descriptions[index],
          style: GoogleFonts.poppins(
              fontSize: 10, color: Color(0xFF666666), height: 1.2),
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
    final transactions = DashboardDataService.getTransactionsByPeriod(
        _currentPeriod, null, null);
    List<FinanceCO2Data> data = [];

    if (_currentPeriod == 'daily') {
      // Group by day of week for July 2025
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 0; i < 7; i++) {
        double income = 0, expense = 0, co2 = 0;
        for (var transaction in transactions) {
          if (transaction.date.weekday == i + 1) {
            if (transaction.type == 'income') {
              income += transaction.amount;
            } else {
              expense += transaction.amount;
              co2 += transaction.carbonFootprint ?? 0;
            }
          }
        }
        data.add(FinanceCO2Data(
            label: days[i], income: income, expense: expense, co2: co2));
      }
    } else if (_currentPeriod == 'weekly') {
      // Group by week for July 2025 (5 weeks)
      final weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'];
      for (int i = 0; i < 5; i++) {
        double income = 0, expense = 0, co2 = 0;
        for (var transaction in transactions) {
          int weekOfMonth = ((transaction.date.day - 1) / 7).floor();
          if (weekOfMonth == i) {
            if (transaction.type == 'income') {
              income += transaction.amount;
            } else {
              expense += transaction.amount;
              co2 += transaction.carbonFootprint ?? 0;
            }
          }
        }
        data.add(FinanceCO2Data(
            label: weeks[i], income: income, expense: expense, co2: co2));
      }
    } else {
      // Monthly - show July 2025 data
      final months = ['Jul'];
      for (int i = 0; i < 1; i++) {
        double income = 0, expense = 0, co2 = 0;
        for (var transaction in transactions) {
          if (transaction.date.month == 7) {
            // July = 7
            if (transaction.type == 'income') {
              income += transaction.amount;
            } else {
              expense += transaction.amount;
              co2 += transaction.carbonFootprint ?? 0;
            }
          }
        }
        data.add(FinanceCO2Data(
            label: months[i], income: income, expense: expense, co2: co2));
      }
    }

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: SfCartesianChart(
              legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  textStyle: GoogleFonts.poppins(fontSize: 10)),
              primaryXAxis:
                  CategoryAxis(labelStyle: GoogleFonts.poppins(fontSize: 10)),
              primaryYAxis:
                  NumericAxis(labelStyle: GoogleFonts.poppins(fontSize: 10)),
              series: <CartesianSeries>[
                ColumnSeries<FinanceCO2Data, String>(
                  name: 'Income',
                  dataSource: data,
                  xValueMapper: (FinanceCO2Data finance, _) => finance.label,
                  yValueMapper: (FinanceCO2Data finance, _) => finance.income,
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
                ColumnSeries<FinanceCO2Data, String>(
                  name: 'Expense',
                  dataSource: data,
                  xValueMapper: (FinanceCO2Data finance, _) => finance.label,
                  yValueMapper: (FinanceCO2Data finance, _) => finance.expense,
                  color: Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          // Interaction hint
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("💡 Tap bars to see detailed breakdown",
                style:
                    GoogleFonts.poppins(fontSize: 9, color: Color(0xFF666666))),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownChart() {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                _buildBreakdownTabButton("Expense", 0),
                _buildBreakdownTabButton("Income", 1),
                _buildBreakdownTabButton("CO₂", 2),
              ],
            ),
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
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF74C95C) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[600]),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildBreakdownChartContent() {
    final transactions = DashboardDataService.getTransactionsByPeriod(
        _currentPeriod, null, null);
    List<BreakdownItem> data = [];
    String unit = "";
    Color valueColor = Colors.red;

    switch (_breakdownTabIndex) {
      case 0:
        data = processTransactions(transactions, "expense");
        unit = "RM";
        valueColor = Colors.red;
        break;
      case 1:
        data = processTransactions(transactions, "income");
        unit = "RM";
        valueColor = Color(0xFF4CAF50);
        break;
      case 2:
        data = processCO2(transactions);
        unit = "kg CO₂";
        valueColor = Colors.blueGrey;
        break;
    }

    if (data.isEmpty) {
      return Center(
          child: Text("No data available",
              style:
                  GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])));
    }

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () =>
                _showBreakdownModal(data, unit, valueColor, transactions),
            child: Container(
              padding: EdgeInsets.all(8),
              child: PieChart(
                PieChartData(
                  sections: data.map((item) {
                    double percentage =
                        data.fold(0.0, (sum, i) => sum + i.value) > 0
                            ? (item.value /
                                    data.fold(0.0, (sum, i) => sum + i.value)) *
                                100
                            : 0;
                    return PieChartSectionData(
                      value: percentage,
                      color: _getCategoryColor(item.category),
                      radius: 60,
                      title:
                          "${percentage.toStringAsFixed(1)}%\n${_formatValue(item.value, unit)}",
                      titleStyle: GoogleFonts.poppins(
                          fontSize: 9,
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
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: data.map((item) {
              double percentage = data.fold(0.0, (sum, i) => sum + i.value) > 0
                  ? (item.value / data.fold(0.0, (sum, i) => sum + i.value)) *
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
                  SizedBox(width: 4),
                  Text(
                    "${item.category} (${percentage.toStringAsFixed(1)}%)",
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsChart() {
    final transactions = DashboardDataService.getTransactionsByPeriod(
        _currentPeriod, null, null);

    // Prepare data for carbon chart only
    List<FlSpot> carbonSpots = [];
    List<FlSpot> carbonPeerSpots = [];
    List<String> labels = [];
    double maxCarbon = 0;

    if (_currentPeriod == 'daily') {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 0; i < 7; i++) {
        double totalCarbon = 0;
        for (var transaction in transactions) {
          if (transaction.date.weekday == i + 1) {
            if (transaction.type == 'expense') {
              totalCarbon += transaction.carbonFootprint ?? 0;
            }
          }
        }
        carbonSpots.add(FlSpot(i.toDouble(), totalCarbon));
        carbonPeerSpots.add(FlSpot(i.toDouble(), totalCarbon * 1.2));
        maxCarbon = totalCarbon > maxCarbon ? totalCarbon : maxCarbon;
        labels.add(days[i]);
      }
    } else if (_currentPeriod == 'weekly') {
      final weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'];
      for (int i = 0; i < 5; i++) {
        double totalCarbon = 0;
        for (var transaction in transactions) {
          int weekOfMonth = ((transaction.date.day - 1) / 7).floor();
          if (weekOfMonth == i) {
            if (transaction.type == 'expense') {
              totalCarbon += transaction.carbonFootprint ?? 0;
            }
          }
        }
        carbonSpots.add(FlSpot(i.toDouble(), totalCarbon));
        carbonPeerSpots.add(FlSpot(i.toDouble(), totalCarbon * 1.15));
        maxCarbon = totalCarbon > maxCarbon ? totalCarbon : maxCarbon;
        labels.add(weeks[i]);
      }
    } else {
      final months = ['Jul'];
      for (int i = 0; i < 1; i++) {
        double totalCarbon = 0;
        for (var transaction in transactions) {
          if (transaction.date.month == 7) {
            if (transaction.type == 'expense') {
              totalCarbon += transaction.carbonFootprint ?? 0;
            }
          }
        }
        carbonSpots.add(FlSpot(i.toDouble(), totalCarbon));
        carbonPeerSpots.add(FlSpot(i.toDouble(), totalCarbon * 1.1));
        maxCarbon = totalCarbon > maxCarbon ? totalCarbon : maxCarbon;
        labels.add(months[i]);
      }
    }

    double carbonInterval = maxCarbon > 0 ? (maxCarbon / 3).ceilToDouble() : 10;

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          // Carbon Chart Only
          Container(
            height: 200,
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
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Color(0xFF666666))),
                    SizedBox(width: 12),
                    Container(
                      width: 12,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Color(0xFF9C27B0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text("Peer Avg",
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Color(0xFF666666))),
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
                          getDrawingHorizontalLine: (value) =>
                              FlLine(color: Color(0xFFE0E0E0), strokeWidth: 1)),
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
                                    style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF666666)));
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
                                style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF666666))),
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
                            getDotPainter: (spot, percent, barData, index) =>
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
                            getDotPainter: (spot, percent, barData, index) =>
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
          // Interaction hint
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("💡 Compare your carbon emissions with peers",
                style:
                    GoogleFonts.poppins(fontSize: 9, color: Color(0xFF666666))),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Color(0xFFFFD700), size: 18),
              SizedBox(width: 8),
              Text("Smart Insights",
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A))),
            ],
          ),
          SizedBox(height: 12),
          ..._buildChartSpecificInsights(_currentChartIndex),
        ],
      ),
    );
  }

  List<Widget> _buildChartSpecificInsights(int chartIndex) {
    final transactions = DashboardDataService.getTransactionsByPeriod(
        _currentPeriod, null, null);
    final stats = DashboardDataService.getSummaryStats(_currentPeriod);

    // Calculate insights based on real data
    Map<String, double> categorySpending = {};
    Map<String, double> categoryCarbon = {};
    double totalSpent = 0;
    double totalCarbon = 0;

    for (var transaction in transactions) {
      if (transaction.type == 'expense') {
        totalSpent += transaction.amount;
        totalCarbon += transaction.carbonFootprint ?? 0;
        categorySpending[transaction.category] =
            (categorySpending[transaction.category] ?? 0) + transaction.amount;
        categoryCarbon[transaction.category] =
            (categoryCarbon[transaction.category] ?? 0) +
                (transaction.carbonFootprint ?? 0);
      }
    }

    // Find highest spending category
    String highestCategory = categorySpending.isEmpty
        ? 'Food'
        : categorySpending.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
    double highestSpending = categorySpending[highestCategory] ?? 0;
    double highestCarbon = categoryCarbon[highestCategory] ?? 0;

    // Calculate carbon intensity
    double carbonIntensity = totalSpent > 0 ? totalCarbon / totalSpent : 0;
    double avgCarbonIntensity = 0.15; // Mock average (RM per kg CO2)
    bool isBelowAverage = carbonIntensity < avgCarbonIntensity;

    // Calculate savings potential
    double savingsPotential = totalSpent * 0.2; // 20% savings potential

    final insights = [
      [
        // Financial insights
        "Your ${_currentPeriod} spending is RM${totalSpent.toStringAsFixed(2)} with RM${stats['totalIncome'].toStringAsFixed(2)} income",
        "You could save RM${savingsPotential.toStringAsFixed(2)} by reducing non-essential expenses by 20%",
        "Your balance is RM${(stats['totalIncome'] - totalSpent).toStringAsFixed(2)} - consider increasing savings"
      ],
      [
        // Breakdown insights
        "$highestCategory is your highest spending at RM${highestSpending.toStringAsFixed(2)} (${((highestSpending / totalSpent) * 100).toStringAsFixed(1)}%)",
        "Your carbon intensity is ${isBelowAverage ? 'below' : 'above'} average at RM${carbonIntensity.toStringAsFixed(2)} per kg CO₂",
        "Consider switching to public transport to reduce transport emissions by 30%"
      ],
      [
        // Trend insights
        "Your spending pattern shows ${_getTrendDirection(transactions)} compared to peers",
        "You're spending ${isBelowAverage ? '15% less' : '10% more'} than similar income households",
        "Focus on reducing $highestCategory spending to improve your carbon efficiency"
      ]
    ];

    return insights[chartIndex]
        .map((insight) => _buildInsightItem(insight))
        .toList();
  }

  String _getTrendDirection(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return "stable patterns";

    // Simple trend analysis
    double recentSpending = 0;
    double olderSpending = 0;
    int midPoint = transactions.length ~/ 2;

    for (int i = 0; i < transactions.length; i++) {
      if (transactions[i].type == 'expense') {
        if (i < midPoint) {
          olderSpending += transactions[i].amount;
        } else {
          recentSpending += transactions[i].amount;
        }
      }
    }

    if (recentSpending > olderSpending * 1.1) return "increasing trends";
    if (recentSpending < olderSpending * 0.9) return "decreasing trends";
    return "stable patterns";
  }

  Widget _buildInsightItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.only(top: 5, right: 10),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                  color: Color(0xFF74C95C), shape: BoxShape.circle)),
          Expanded(
              child: Text(text,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
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
      Color valueColor, List<TransactionModel> transactions) {
    double totalValue = data.fold(0, (sum, item) => sum + item.value);
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
  }

  void _showCategoryTransactions(
      String category, List<TransactionModel> transactions) {
    final categoryTransactions =
        transactions.where((t) => t.category == category).toList();
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
}
