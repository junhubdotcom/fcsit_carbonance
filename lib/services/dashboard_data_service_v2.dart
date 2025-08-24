import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dashboard_firestore_service.dart';

class DashboardDataServiceV2 {
  static final DashboardDataServiceV2 _instance =
      DashboardDataServiceV2._internal();
  factory DashboardDataServiceV2() => _instance;
  DashboardDataServiceV2._internal();

  final DashboardFirestoreService _firestoreService =
      DashboardFirestoreService();

  // Get summary stats from Firestore
  Future<Map<String, dynamic>> getSummaryStats(String period) async {
    try {
      return await _firestoreService.getSummaryStats(period: period);
    } catch (e) {
      print('❌ Error getting summary stats: $e');
      return {
        'totalSpent': 0.0,
        'totalIncome': 0.0,
        'totalCarbon': 0.0,
        'carbonSaved': 0.0,
      };
    }
  }

  // Get spending data for charts from Firestore
  Future<List<PieChartSectionData>> getSpendingData(String period) async {
    try {
      final categoryData =
          await _firestoreService.getSpendingByCategory(period: period);

      if (categoryData.isEmpty) {
        return [
          PieChartSectionData(
              value: 100,
              color: Color(0xFFE0E0E0),
              title: 'No Data',
              radius: 80),
        ];
      }

      final colors = [
        Color(0xFF74C95C), // Food
        Color(0xFF2196F3), // Transport
        Color(0xFFFF9800), // Shopping
        Color(0xFF9C27B0), // Entertainment
        Color(0xFF4CAF50), // Others
      ];

      double totalAmount =
          categoryData.fold(0, (sum, item) => sum + item['amount']);

      int colorIndex = 0;
      return categoryData.map((item) {
        double percentage =
            totalAmount > 0 ? (item['amount'] / totalAmount) * 100 : 0;
        return PieChartSectionData(
          value: percentage,
          color: colors[colorIndex++ % colors.length],
          title: item['category'],
          radius: 80,
        );
      }).toList();
    } catch (e) {
      print('❌ Error getting spending data: $e');
      return [
        PieChartSectionData(
            value: 100, color: Color(0xFFE0E0E0), title: 'Error', radius: 80),
      ];
    }
  }

  // Get carbon data for charts from Firestore
  Future<List<FlSpot>> getCarbonData(String period) async {
    try {
      // For now, return a simple line chart with placeholder data
      // TODO: Implement proper carbon data aggregation from Firestore
      return [
        FlSpot(0, 2.3),
        FlSpot(1, 8.5),
        FlSpot(2, 3.2),
        FlSpot(3, 4.1),
        FlSpot(4, 1.2),
        FlSpot(5, 0.8),
        FlSpot(6, 3.0),
      ];
    } catch (e) {
      print('❌ Error getting carbon data: $e');
      return [FlSpot(0, 0)];
    }
  }

  // Get trends data from Firestore
  Future<Map<String, dynamic>> getTrendsData(String period) async {
    try {
      final stats = await getSummaryStats(period);

      return {
        'totalSpending': stats['totalSpent'] ?? 0.0,
        'totalCarbon': stats['totalCarbon'] ?? 0.0,
        'avgSpending': 0.0, // TODO: Calculate from transaction count
        'avgCarbon': 0.0, // TODO: Calculate from transaction count
        'topCategory': 'N/A', // TODO: Get from category breakdown
        'transactionCount': 0, // TODO: Get actual count
      };
    } catch (e) {
      print('❌ Error getting trends data: $e');
      return {
        'totalSpending': 0.0,
        'totalCarbon': 0.0,
        'avgSpending': 0.0,
        'avgCarbon': 0.0,
        'topCategory': 'N/A',
        'transactionCount': 0,
      };
    }
  }

  // Get chart insights (placeholder for now)
  List<List<String>> getChartInsights(String period) {
    return [
      ["Fetching insights from Firestore..."],
      ["Carbon data is being calculated..."],
      ["Trends are being analyzed..."],
    ];
  }

  // Get chart descriptions
  List<String> getChartDescriptions(String period) {
    return [
      "Breakdown of your $period spending by category. Shows where your money goes.",
      "Daily carbon footprint tracking for $period. Shows your environmental impact over time.",
      "Trends and patterns in your $period data. Key insights and recommendations."
    ];
  }
}


