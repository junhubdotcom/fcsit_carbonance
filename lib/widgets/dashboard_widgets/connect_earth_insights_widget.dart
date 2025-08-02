import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steadypunpipi_vhack/common/constants.dart';
import 'package:steadypunpipi_vhack/models/transaction_model.dart';
import 'package:steadypunpipi_vhack/services/connect_earth_insights_service.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';

class ConnectEarthInsightsWidget extends StatefulWidget {
  final List<TransactionModel> transactions;
  final String periodId; // e.g., "daily_2024-06-01"
  final String userId; // User ID for Connect Earth

  const ConnectEarthInsightsWidget({
    Key? key,
    required this.transactions,
    required this.periodId,
    required this.userId,
  }) : super(key: key);

  @override
  State<ConnectEarthInsightsWidget> createState() =>
      _ConnectEarthInsightsWidgetState();
}

class _ConnectEarthInsightsWidgetState
    extends State<ConnectEarthInsightsWidget> {
  final ConnectEarthInsightsService _insightsService =
      ConnectEarthInsightsService();
  Map<String, dynamic> _insights = {};
  bool _isLoading = false;
  bool _hasUploadedTransactions = false;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    if (widget.transactions.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Try to load from Firestore first
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestoreCollections.CONNECT_EARTH_INSIGHTS)
          .doc(widget.periodId)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _insights = doc.data()!;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      print('Error loading from Firestore: $e');
    }

    // Convert TransactionModel to format expected by Connect Earth API
    final expenseTransactions = widget.transactions
        .where((txn) =>
            txn.type == 'expense') // Only expenses have carbon footprint
        .map((txn) => {
              'id': txn.id,
              'name': txn.description,
              'category': txn.category,
              'quantity': 1,
              'price': txn.amount,
              'carbon_footprint': txn.carbonFootprint ?? 0,
              'date': txn.date.toIso8601String().split('T')[0],
              'description': txn.description,
            })
        .toList();

    if (expenseTransactions.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Step 1: Upload transactions to Connect Earth
      print(
          '📤 Uploading ${expenseTransactions.length} transactions to Connect Earth...');
      final uploadSuccess = await _insightsService.uploadTransactions(
        expenseTransactions,
        widget.userId,
      );

      if (!uploadSuccess) {
        print('❌ Failed to upload transactions to Connect Earth');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _hasUploadedTransactions = true;
      print('✅ Successfully uploaded transactions to Connect Earth');

      // Step 2: Get insights from Connect Earth (async - uses uploaded transactions)
      print('📊 Fetching insights from Connect Earth...');
      final insights =
          await _insightsService.getComprehensiveInsights(widget.userId);

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.CONNECT_EARTH_INSIGHTS)
          .doc(widget.periodId)
          .set({
        ...insights,
        'generatedAt': FieldValue.serverTimestamp(),
        'userId': widget.userId,
        'transactionCount': expenseTransactions.length,
      });

      setState(() {
        _insights = insights;
        _isLoading = false;
      });

      print('✅ Successfully loaded Connect Earth insights');
    } catch (e) {
      print('❌ Error loading insights: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_insights.isEmpty) {
      return _buildEmptyCard();
    }

    return Column(
      children: [
        _buildPieChartSection(),
        _buildRecommendationsSection(),
        _buildTipsSection(),
        _buildMonthlyTotalsSection(),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: EdgeInsets.all(AppConstants.paddingMedium),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              _hasUploadedTransactions
                  ? 'Loading Connect Earth Insights...'
                  : 'Uploading transactions to Connect Earth...',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Card(
      margin: EdgeInsets.all(AppConstants.paddingMedium),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            Icon(
              Icons.eco_outlined,
              size: 48,
              color: AppConstants.textSecondary,
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              'No Connect Earth insights available',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppConstants.textSecondary,
              ),
            ),
            SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Add some expense transactions to see carbon insights',
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSection() {
    final pieChartData = _insights['pieChart'] as Map<String, dynamic>?;
    if (pieChartData == null || pieChartData.isEmpty) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(AppConstants.paddingMedium),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: AppConstants.primaryColor),
                SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Carbon Emissions by Category',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingMedium),
            // Here you would integrate with a chart library like fl_chart
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: Center(
                child: Text(
                  'Pie Chart Visualization\n(Integrate with fl_chart)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final recommendations = _insights['recommendations'] as List<dynamic>?;
    if (recommendations == null || recommendations.isEmpty)
      return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(AppConstants.paddingMedium),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppConstants.accentColor),
                SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Connect Earth Recommendations',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingMedium),
            ...recommendations.take(3).map(
                (recommendation) => _buildRecommendationTile(recommendation)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationTile(dynamic recommendation) {
    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.paddingSmall),
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up,
            color: AppConstants.primaryColor,
            size: 20,
          ),
          SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              recommendation['title'] ?? 'Recommendation',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w500,
                color: AppConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    final tips = _insights['tips'] as List<dynamic>?;
    if (tips == null || tips.isEmpty) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(AppConstants.paddingMedium),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: AppConstants.infoColor),
                SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Connect Earth Carbon Tips',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingMedium),
            ...tips.take(3).map((tip) => _buildTipTile(tip)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipTile(dynamic tip) {
    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.paddingSmall),
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: AppConstants.infoColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.eco,
            color: AppConstants.infoColor,
            size: 20,
          ),
          SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              tip['tip'] ?? 'Carbon reduction tip',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTotalsSection() {
    final monthlyTotals = _insights['monthlyTotals'] as Map<String, dynamic>?;
    if (monthlyTotals == null || monthlyTotals.isEmpty)
      return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(AppConstants.paddingMedium),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppConstants.secondaryColor),
                SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Connect Earth Monthly Summary',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total CO2',
                    '${monthlyTotals['total_co2']?.toStringAsFixed(2) ?? '0.00'} kg',
                    AppConstants.errorColor,
                  ),
                ),
                SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: _buildMetricCard(
                    'Avg per Day',
                    '${monthlyTotals['avg_per_day']?.toStringAsFixed(2) ?? '0.00'} kg',
                    AppConstants.warningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color: AppConstants.textSecondary,
            ),
          ),
          SizedBox(height: AppConstants.paddingExtraSmall),
          Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
