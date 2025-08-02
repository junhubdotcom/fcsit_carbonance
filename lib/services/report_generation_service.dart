import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:steadypunpipi_vhack/services/unified_reward_service.dart';
import 'package:steadypunpipi_vhack/services/activity_carbon_service.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';

enum ReportType { monthly, quarterly, yearly, custom }

enum ExportFormat { json, csv, pdf }

class ReportGenerationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UnifiedRewardService _rewardService = UnifiedRewardService();
  final ActivityCarbonService _activityCarbonService = ActivityCarbonService();

  // Generate comprehensive report
  Future<Map<String, dynamic>> generateComprehensiveReport({
    required String userId,
    required ReportType reportType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dateRange = _getDateRange(reportType, startDate, endDate);

    // Get all data sources
    final rewardStats = await _rewardService.getRewardStatistics(userId);
    final activityCarbonStats = await _activityCarbonService
        .getActivityCarbonStats(userId, days: dateRange['days']);
    final expenseData =
        await _getExpenseData(userId, dateRange['start'], dateRange['end']);
    final incomeData =
        await _getIncomeData(userId, dateRange['start'], dateRange['end']);

    return {
      'reportInfo': {
        'userId': userId,
        'reportType': reportType.toString().split('.').last,
        'startDate': dateRange['start'].toIso8601String(),
        'endDate': dateRange['end'].toIso8601String(),
        'generatedAt': DateTime.now().toIso8601String(),
      },
      'rewardData': rewardStats,
      'carbonData': activityCarbonStats,
      'financialData': {
        'expenses': expenseData,
        'income': incomeData,
        'netSavings': _calculateNetSavings(expenseData, incomeData),
      },
      'analytics':
          _generateAnalytics(rewardStats, activityCarbonStats, expenseData),
      'recommendations':
          _generateRecommendations(rewardStats, activityCarbonStats),
    };
  }

  Map<String, dynamic> _getDateRange(
      ReportType reportType, DateTime? startDate, DateTime? endDate) {
    final now = DateTime.now();

    switch (reportType) {
      case ReportType.monthly:
        return {
          'start': DateTime(now.year, now.month, 1),
          'end': now,
          'days': 30,
        };
      case ReportType.quarterly:
        return {
          'start': DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1),
          'end': now,
          'days': 90,
        };
      case ReportType.yearly:
        return {
          'start': DateTime(now.year, 1, 1),
          'end': now,
          'days': 365,
        };
      case ReportType.custom:
        return {
          'start': startDate ?? now.subtract(Duration(days: 30)),
          'end': endDate ?? now,
          'days': endDate
                  ?.difference(startDate ?? now.subtract(Duration(days: 30)))
                  .inDays ??
              30,
        };
    }
  }

  Future<List<Map<String, dynamic>>> _getExpenseData(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final query = await _firestore
          .collection(FirestoreCollections.EXPENSES)
          .where('userId', isEqualTo: userId)
          .where('dateTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'amount': data['amount'] ?? 0.0,
          'category': data['category'] ?? '',
          'date': (data['dateTime'] as Timestamp).toDate().toIso8601String(),
          'description': data['description'] ?? '',
          'carbonFootprint': data['carbonFootprint'] ?? 0.0,
        };
      }).toList();
    } catch (e) {
      print('Error getting expense data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getIncomeData(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final query = await _firestore
          .collection(FirestoreCollections.INCOME)
          .where('userId', isEqualTo: userId)
          .where('dateTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'amount': data['amount'] ?? 0.0,
          'source': data['source'] ?? '',
          'date': (data['dateTime'] as Timestamp).toDate().toIso8601String(),
          'description': data['description'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error getting income data: $e');
      return [];
    }
  }

  double _calculateNetSavings(
      List<Map<String, dynamic>> expenses, List<Map<String, dynamic>> income) {
    final totalExpenses = expenses.fold<double>(
        0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));
    final totalIncome = income.fold<double>(
        0.0, (sum, income) => sum + (income['amount'] ?? 0.0));
    return totalIncome - totalExpenses;
  }

  Map<String, dynamic> _generateAnalytics(
    Map<String, dynamic> rewardStats,
    Map<String, dynamic> carbonStats,
    List<Map<String, dynamic>> expenseData,
  ) {
    // Calculate expense breakdown
    Map<String, double> categoryBreakdown = {};
    for (var expense in expenseData) {
      final category = expense['category'] ?? 'Other';
      categoryBreakdown[category] =
          (categoryBreakdown[category] ?? 0.0) + (expense['amount'] ?? 0.0);
    }

    // Calculate carbon efficiency
    final totalExpenses = expenseData.fold<double>(
        0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));
    final totalCarbon = carbonStats['totalCarbon'] ?? 0.0;
    final carbonEfficiency =
        totalExpenses > 0 ? totalCarbon / totalExpenses : 0.0;

    return {
      'categoryBreakdown': categoryBreakdown,
      'carbonEfficiency': carbonEfficiency,
      'sustainabilityScore': rewardStats['sustainabilityScore'] ?? 0.0,
      'tierLevel': rewardStats['tierLevel'] ?? 'bronze',
      'totalTransactions': expenseData.length,
      'averageTransactionValue': totalExpenses / expenseData.length,
      'carbonPerTransaction': totalCarbon / expenseData.length,
    };
  }

  List<Map<String, dynamic>> _generateRecommendations(
    Map<String, dynamic> rewardStats,
    Map<String, dynamic> carbonStats,
  ) {
    List<Map<String, dynamic>> recommendations = [];

    // Sustainability score recommendations
    final sustainabilityScore = rewardStats['sustainabilityScore'] ?? 0.0;
    if (sustainabilityScore < 70) {
      recommendations.add({
        'type': 'sustainability',
        'title': 'Improve Sustainability Score',
        'description':
            'Your sustainability score is below 70. Focus on eco-friendly purchases.',
        'priority': 'high',
        'potentialImpact': 'Increase score by 10-15 points',
      });
    }

    // Carbon reduction recommendations
    final activityCarbon = carbonStats['totalActivityCarbon'] ?? {};
    if ((activityCarbon['transportation'] ?? 0.0) > 50.0) {
      recommendations.add({
        'type': 'carbon',
        'title': 'Reduce Transportation Carbon',
        'description':
            'Consider public transport or carpooling to reduce carbon footprint.',
        'priority': 'medium',
        'potentialImpact': 'Reduce carbon by 30-50%',
      });
    }

    // Tier progression recommendations
    final pointsToNextTier = rewardStats['pointsToNextTier'] ?? 0;
    if (pointsToNextTier < 500) {
      recommendations.add({
        'type': 'rewards',
        'title': 'Tier Progression',
        'description':
            'You\'re close to the next tier. Increase spending in eco-friendly categories.',
        'priority': 'low',
        'potentialImpact': 'Unlock higher reward multipliers',
      });
    }

    return recommendations;
  }

  // Export report to file
  Future<String> exportReport({
    required Map<String, dynamic> reportData,
    required ExportFormat format,
    required String fileName,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/$fileName.${format.toString().split('.').last}';
      final file = File(filePath);

      String content = '';
      switch (format) {
        case ExportFormat.json:
          content = JsonEncoder.withIndent('  ').convert(reportData);
          break;
        case ExportFormat.csv:
          content = _convertToCSV(reportData);
          break;
        case ExportFormat.pdf:
          // For PDF, we'd need a PDF generation library
          content = _convertToPDF(reportData);
          break;
      }

      await file.writeAsString(content);
      return filePath;
    } catch (e) {
      print('Error exporting report: $e');
      throw Exception('Failed to export report');
    }
  }

  String _convertToCSV(Map<String, dynamic> reportData) {
    final buffer = StringBuffer();

    // Report header
    buffer.writeln('Carbonance Report');
    buffer.writeln('Generated: ${reportData['reportInfo']['generatedAt']}');
    buffer.writeln(
        'Period: ${reportData['reportInfo']['startDate']} to ${reportData['reportInfo']['endDate']}');
    buffer.writeln();

    // Reward summary
    buffer.writeln('Reward Summary');
    buffer
        .writeln('Points,Green Credits,Experience,Level,Sustainability Score');
    final rewardData = reportData['rewardData'];
    buffer.writeln(
        '${rewardData['totalPoints']},${rewardData['greenCredits']},${rewardData['experience']},${rewardData['level']},${rewardData['sustainabilityScore']}');
    buffer.writeln();

    // Carbon summary
    buffer.writeln('Carbon Summary');
    buffer.writeln(
        'Total Carbon (kg CO2e),Carbon Saved (kg CO2e),Carbon Emitted (kg CO2e)');
    final carbonData = reportData['carbonData'];
    buffer.writeln(
        '${carbonData['totalCarbon']},${carbonData['totalCarbonSaved'] ?? 0},${carbonData['totalCarbonEmitted'] ?? 0}');
    buffer.writeln();

    // Financial summary
    buffer.writeln('Financial Summary');
    buffer.writeln('Total Expenses,Total Income,Net Savings');
    final financialData = reportData['financialData'];
    final totalExpenses = (financialData['expenses'] as List)
        .fold<double>(0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));
    final totalIncome = (financialData['income'] as List)
        .fold<double>(0.0, (sum, income) => sum + (income['amount'] ?? 0.0));
    buffer
        .writeln('$totalExpenses,$totalIncome,${financialData['netSavings']}');

    return buffer.toString();
  }

  String _convertToPDF(Map<String, dynamic> reportData) {
    // This would use a PDF generation library like pdf or flutter_pdf
    // For now, return a simple text representation
    return '''
Carbonance Report
================

Generated: ${reportData['reportInfo']['generatedAt']}
Period: ${reportData['reportInfo']['startDate']} to ${reportData['reportInfo']['endDate']}

Reward Summary:
- Points: ${reportData['rewardData']['totalPoints']}
- Green Credits: ${reportData['rewardData']['greenCredits']}
- Experience: ${reportData['rewardData']['experience']}
- Level: ${reportData['rewardData']['level']}
- Sustainability Score: ${reportData['rewardData']['sustainabilityScore']}

Carbon Summary:
- Total Carbon: ${reportData['carbonData']['totalCarbon']} kg CO2e
- Carbon Saved: ${reportData['carbonData']['totalCarbonSaved'] ?? 0} kg CO2e
- Carbon Emitted: ${reportData['carbonData']['totalCarbonEmitted'] ?? 0} kg CO2e

Recommendations:
${(reportData['recommendations'] as List).map((rec) => '- ${rec['title']}: ${rec['description']}').join('\n')}
''';
  }

  // Generate summary report for dashboard
  Future<Map<String, dynamic>> generateDashboardSummary(String userId) async {
    final rewardStats = await _rewardService.getRewardStatistics(userId);
    final carbonStats =
        await _activityCarbonService.getActivityCarbonStats(userId, days: 30);

    return {
      'rewardSummary': {
        'points': rewardStats['totalPoints'],
        'greenCredits': rewardStats['greenCredits'],
        'tier': rewardStats['tierLevel'],
        'sustainabilityScore': rewardStats['sustainabilityScore'],
      },
      'carbonSummary': {
        'totalCarbon': carbonStats['totalCarbon'],
        'carbonSaved': carbonStats['totalCarbonSaved'] ?? 0.0,
        'carbonEmitted': carbonStats['totalCarbonEmitted'] ?? 0.0,
      },
      'trends': {
        'pointsTrend':
            'increasing', // This would be calculated from historical data
        'carbonTrend': 'decreasing',
        'sustainabilityTrend': 'stable',
      },
    };
  }

  // Generate comparison report
  Future<Map<String, dynamic>> generateComparisonReport({
    required String userId,
    required DateTime period1Start,
    required DateTime period1End,
    required DateTime period2Start,
    required DateTime period2End,
  }) async {
    final period1Report = await generateComprehensiveReport(
      userId: userId,
      reportType: ReportType.custom,
      startDate: period1Start,
      endDate: period1End,
    );

    final period2Report = await generateComprehensiveReport(
      userId: userId,
      reportType: ReportType.custom,
      startDate: period2Start,
      endDate: period2End,
    );

    return {
      'period1': period1Report,
      'period2': period2Report,
      'comparison': _comparePeriods(period1Report, period2Report),
    };
  }

  Map<String, dynamic> _comparePeriods(
      Map<String, dynamic> period1, Map<String, dynamic> period2) {
    final p1Rewards = period1['rewardData'];
    final p2Rewards = period2['rewardData'];
    final p1Carbon = period1['carbonData'];
    final p2Carbon = period2['carbonData'];

    return {
      'rewardChanges': {
        'pointsChange':
            ((p2Rewards['totalPoints'] ?? 0) - (p1Rewards['totalPoints'] ?? 0))
                .toDouble(),
        'greenCreditsChange': (p2Rewards['greenCredits'] ?? 0.0) -
            (p1Rewards['greenCredits'] ?? 0.0),
        'sustainabilityScoreChange': (p2Rewards['sustainabilityScore'] ?? 0.0) -
            (p1Rewards['sustainabilityScore'] ?? 0.0),
      },
      'carbonChanges': {
        'totalCarbonChange':
            (p2Carbon['totalCarbon'] ?? 0.0) - (p1Carbon['totalCarbon'] ?? 0.0),
        'carbonSavedChange': (p2Carbon['totalCarbonSaved'] ?? 0.0) -
            (p1Carbon['totalCarbonSaved'] ?? 0.0),
        'carbonEmittedChange': (p2Carbon['totalCarbonEmitted'] ?? 0.0) -
            (p1Carbon['totalCarbonEmitted'] ?? 0.0),
      },
    };
  }
}
