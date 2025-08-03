import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import '../models/transaction_model.dart';

class DashboardDataService {
  static List<TransactionModel> _transactions = [];
  static Map<String, dynamic> _insights = {};
  static bool _isLoaded = false;

  static Future<void> loadData() async {
    if (_isLoaded) return;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/mock_transactions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _transactions = (jsonData['transactions'] as List)
          .map((transaction) => TransactionModel.fromJSON(transaction))
          .toList();

      _insights = jsonData['insights'] as Map<String, dynamic>;
      _isLoaded = true;
    } catch (e) {
      print('Error loading mock data: $e');
    }
  }

  static List<TransactionModel> getTransactions() {
    return _transactions;
  }

  static List<TransactionModel> getTransactionsByPeriod(
      String period, DateTime? startDate, DateTime? endDate) {
    if (!_isLoaded) return [];

    // Filter transactions based on period
    DateTime now = DateTime.now();
    DateTime periodStart;
    DateTime periodEnd = now;

    switch (period) {
      case 'daily':
        // Last 7 days
        periodStart = now.subtract(Duration(days: 7));
        break;
      case 'weekly':
        // Last 4 weeks
        periodStart = now.subtract(Duration(days: 28));
        break;
      case 'monthly':
        // Last 3 months
        periodStart = now.subtract(Duration(days: 90));
        break;
      default:
        return _transactions;
    }

    return _transactions.where((transaction) {
      return transaction.date.isAfter(periodStart) &&
          transaction.date.isBefore(periodEnd.add(Duration(days: 1)));
    }).toList();
  }

  // Spending data based on real transactions
  static List<PieChartSectionData> getSpendingData(String period) {
    List<TransactionModel> periodTransactions =
        getTransactionsByPeriod(period, null, null);

    Map<String, double> categoryTotals = {};
    double totalAmount = 0;

    for (var transaction in periodTransactions) {
      // Only include expenses, not income
      if (transaction.type != 'income') {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
        totalAmount += transaction.amount;
      }
    }

    if (totalAmount == 0) {
      return [
        PieChartSectionData(
            value: 100, color: Color(0xFFE0E0E0), title: 'No Data', radius: 80),
      ];
    }

    final colors = [
      Color(0xFF74C95C), // Food
      Color(0xFF2196F3), // Transport
      Color(0xFFFF9800), // Shopping
      Color(0xFF9C27B0), // Entertainment
      Color(0xFF4CAF50), // Others
    ];

    int colorIndex = 0;
    return categoryTotals.entries.map((entry) {
      double percentage = (entry.value / totalAmount) * 100;
      return PieChartSectionData(
        value: percentage,
        color: colors[colorIndex++ % colors.length],
        title: entry.key,
        radius: 80,
      );
    }).toList();
  }

  // Carbon footprint data based on real transactions
  static List<FlSpot> getCarbonData(String period) {
    List<TransactionModel> periodTransactions =
        getTransactionsByPeriod(period, null, null);

    // Group by day and calculate daily carbon footprint
    Map<String, double> dailyCarbon = {};

    for (var transaction in periodTransactions) {
      // Only include expenses for carbon footprint
      if (transaction.type != 'income') {
        String dayKey = transaction.date.toIso8601String().split('T')[0];
        dailyCarbon[dayKey] =
            (dailyCarbon[dayKey] ?? 0) + (transaction.carbonFootprint ?? 0);
      }
    }

    // Convert to FlSpot format
    List<FlSpot> spots = [];
    int index = 0;
    for (var entry in dailyCarbon.entries) {
      spots.add(FlSpot(index.toDouble(), entry.value));
      index++;
    }

    return spots.isNotEmpty ? spots : [FlSpot(0, 0)];
  }

  // Trends data based on real transactions
  static Map<String, dynamic> getTrendsData(String period) {
    List<TransactionModel> periodTransactions =
        getTransactionsByPeriod(period, null, null);

    double totalSpending = 0;
    double totalCarbon = 0;
    Map<String, double> categorySpending = {};

    for (var transaction in periodTransactions) {
      if (transaction.type != 'income') {
        totalSpending += transaction.amount;
        totalCarbon += transaction.carbonFootprint ?? 0;
        categorySpending[transaction.category] =
            (categorySpending[transaction.category] ?? 0) + transaction.amount;
      }
    }

    // Calculate trends
    double avgSpending = periodTransactions.isNotEmpty
        ? totalSpending / periodTransactions.length
        : 0;
    double avgCarbon = periodTransactions.isNotEmpty
        ? totalCarbon / periodTransactions.length
        : 0;

    String topCategory = categorySpending.isNotEmpty
        ? categorySpending.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
        : 'N/A';

    return {
      'totalSpending': totalSpending,
      'totalCarbon': totalCarbon,
      'avgSpending': avgSpending,
      'avgCarbon': avgCarbon,
      'topCategory': topCategory,
      'transactionCount': periodTransactions.length,
    };
  }

  // Summary stats based on real transactions
  static Map<String, dynamic> getSummaryStats(String period) {
    List<TransactionModel> periodTransactions =
        getTransactionsByPeriod(period, null, null);

    double totalSpent = 0;
    double totalIncome = 0;
    double totalCarbon = 0;
    double carbonSaved = 0;

    for (var transaction in periodTransactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalSpent += transaction.amount;
      }
      totalCarbon += transaction.carbonFootprint ?? 0;

      // Calculate carbon saved (assuming some transactions are more sustainable)
      if (transaction.category == 'Transport' &&
          transaction.description.contains('Public transport')) {
        carbonSaved += 2.0; // Saved by using public transport
      }
    }

    return {
      'totalSpent': totalSpent,
      'totalIncome': totalIncome,
      'totalCarbon': totalCarbon,
      'carbonSaved': carbonSaved,
    };
  }

  // Chart-specific insights based on period
  static List<List<String>> getChartInsights(String period) {
    if (!_isLoaded || !_insights.containsKey(period)) {
      return [
        ["No insights available for this period"],
        ["No insights available for this period"],
        ["No insights available for this period"],
      ];
    }

    Map<String, dynamic> periodInsights = _insights[period];

    // Properly cast the dynamic lists to List<String>
    List<String> spendingInsights = [];
    List<String> carbonInsights = [];
    List<String> trendsInsights = [];

    if (periodInsights['spending'] != null) {
      spendingInsights = (periodInsights['spending'] as List)
          .map((item) => item.toString())
          .toList();
    } else {
      spendingInsights = ["No spending insights available"];
    }

    if (periodInsights['carbon'] != null) {
      carbonInsights = (periodInsights['carbon'] as List)
          .map((item) => item.toString())
          .toList();
    } else {
      carbonInsights = ["No carbon insights available"];
    }

    if (periodInsights['trends'] != null) {
      trendsInsights = (periodInsights['trends'] as List)
          .map((item) => item.toString())
          .toList();
    } else {
      trendsInsights = ["No trend insights available"];
    }

    return [spendingInsights, carbonInsights, trendsInsights];
  }

  // Chart descriptions based on period
  static List<String> getChartDescriptions(String period) {
    return [
      "Breakdown of your $period spending by category. Shows where your money goes.",
      "Daily carbon footprint tracking for $period. Shows your environmental impact over time.",
      "Trends and patterns in your $period data. Key insights and recommendations."
    ];
  }
}
