import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';

enum ActivityType {
  transportation,
  food,
  energy,
  shopping,
  entertainment,
  housing,
  waste,
  water
}

class ActivityCarbonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Activity-based carbon factors (kg CO2e per unit)
  static const Map<String, Map<String, double>> _carbonFactors = {
    'transportation': {
      'car': 0.2, // kg CO2e per km
      'bus': 0.05, // kg CO2e per km
      'train': 0.04, // kg CO2e per km
      'bike': 0.0, // kg CO2e per km
      'walk': 0.0, // kg CO2e per km
      'electric_car': 0.08, // kg CO2e per km
    },
    'food': {
      'organic_vegetables': 0.5, // kg CO2e per kg
      'conventional_vegetables': 1.2,
      'organic_fruits': 0.6,
      'conventional_fruits': 1.5,
      'beef': 13.3,
      'pork': 5.8,
      'chicken': 2.9,
      'fish': 3.0,
      'dairy': 2.4,
      'grains': 0.9,
    },
    'energy': {
      'electricity': 0.5, // kg CO2e per kWh
      'natural_gas': 2.0, // kg CO2e per m3
      'heating_oil': 2.7, // kg CO2e per liter
      'solar': 0.0, // kg CO2e per kWh
      'wind': 0.0, // kg CO2e per kWh
    },
    'shopping': {
      'clothing': 23.0, // kg CO2e per item
      'electronics': 50.0, // kg CO2e per item
      'furniture': 100.0, // kg CO2e per item
      'books': 2.5, // kg CO2e per book
    },
    'entertainment': {
      'movie': 0.5, // kg CO2e per hour
      'streaming': 0.1, // kg CO2e per hour
      'gaming': 0.2, // kg CO2e per hour
      'sports': 0.3, // kg CO2e per hour
    },
  };

  // Calculate carbon footprint for an activity
  double calculateActivityCarbon({
    required ActivityType activityType,
    required String subCategory,
    required double quantity,
    required String unit,
  }) {
    final category = activityType.toString().split('.').last;
    final factors = _carbonFactors[category];

    if (factors == null || !factors.containsKey(subCategory)) {
      return 0.0;
    }

    final factor = factors[subCategory]!;
    return factor * quantity;
  }

  // Process expense items for activity-based carbon accounting
  Future<Map<String, dynamic>> processExpenseForActivityCarbon({
    required String userId,
    required List<ExpenseItem> items,
    required DateTime transactionDate,
  }) async {
    Map<String, double> activityCarbon = {};
    Map<String, double> categoryCarbon = {};
    double totalCarbon = 0.0;

    for (ExpenseItem item in items) {
      final activityAnalysis = _analyzeItemActivity(item);

      for (String activity in activityAnalysis.keys) {
        final carbon = activityAnalysis[activity]!;
        activityCarbon[activity] = (activityCarbon[activity] ?? 0.0) + carbon;
        totalCarbon += carbon;
      }

      // Categorize by expense category
      final category = item.category.toLowerCase();
      categoryCarbon[category] =
          (categoryCarbon[category] ?? 0.0) + (item.carbon_footprint ?? 0.0);
    }

    // Save activity carbon data
    await _saveActivityCarbonData(
      userId: userId,
      activityCarbon: activityCarbon,
      categoryCarbon: categoryCarbon,
      totalCarbon: totalCarbon,
      transactionDate: transactionDate,
    );

    return {
      'activityCarbon': activityCarbon,
      'categoryCarbon': categoryCarbon,
      'totalCarbon': totalCarbon,
      'date': transactionDate,
    };
  }

  Map<String, double> _analyzeItemActivity(ExpenseItem item) {
    final category = item.category.toLowerCase();
    final amount = item.price * item.quantity;
    final carbonFootprint = item.carbon_footprint ?? 0.0;

    Map<String, double> activities = {};

    // Analyze based on item name and category
    if (category.contains('transport') || category.contains('travel')) {
      activities['transportation'] = carbonFootprint;
    } else if (category.contains('food') || category.contains('restaurant')) {
      activities['food'] = carbonFootprint;
    } else if (category.contains('energy') ||
        category.contains('electricity')) {
      activities['energy'] = carbonFootprint;
    } else if (category.contains('shopping') || category.contains('clothing')) {
      activities['shopping'] = carbonFootprint;
    } else if (category.contains('entertainment') ||
        category.contains('movie')) {
      activities['entertainment'] = carbonFootprint;
    } else {
      // Default categorization
      activities['other'] = carbonFootprint;
    }

    return activities;
  }

  Future<void> _saveActivityCarbonData({
    required String userId,
    required Map<String, double> activityCarbon,
    required Map<String, double> categoryCarbon,
    required double totalCarbon,
    required DateTime transactionDate,
  }) async {
    try {
      await _firestore.collection(FirestoreCollections.ACTIVITY_CARBON).add({
        'userId': userId,
        'activityCarbon': activityCarbon,
        'categoryCarbon': categoryCarbon,
        'totalCarbon': totalCarbon,
        'transactionDate': Timestamp.fromDate(transactionDate),
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error saving activity carbon data: $e');
    }
  }

  // Get activity carbon statistics
  Future<Map<String, dynamic>> getActivityCarbonStats(String userId,
      {int days = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final query = await _firestore
          .collection(FirestoreCollections.ACTIVITY_CARBON)
          .where('userId', isEqualTo: userId)
          .where('transactionDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(cutoffDate))
          .get();

      Map<String, double> totalActivityCarbon = {};
      Map<String, double> totalCategoryCarbon = {};
      double totalCarbon = 0.0;
      List<Map<String, dynamic>> dailyData = [];

      for (var doc in query.docs) {
        final data = doc.data();

        // Accumulate activity carbon
        final activityCarbon =
            Map<String, double>.from(data['activityCarbon'] ?? {});
        for (String activity in activityCarbon.keys) {
          totalActivityCarbon[activity] =
              (totalActivityCarbon[activity] ?? 0.0) +
                  activityCarbon[activity]!;
        }

        // Accumulate category carbon
        final categoryCarbon =
            Map<String, double>.from(data['categoryCarbon'] ?? {});
        for (String category in categoryCarbon.keys) {
          totalCategoryCarbon[category] =
              (totalCategoryCarbon[category] ?? 0.0) +
                  categoryCarbon[category]!;
        }

        totalCarbon += (data['totalCarbon'] ?? 0.0).toDouble();

        // Daily data for trends
        dailyData.add({
          'date': (data['transactionDate'] as Timestamp).toDate(),
          'carbon': (data['totalCarbon'] ?? 0.0).toDouble(),
        });
      }

      return {
        'totalActivityCarbon': totalActivityCarbon,
        'totalCategoryCarbon': totalCategoryCarbon,
        'totalCarbon': totalCarbon,
        'dailyData': dailyData,
        'period': days,
      };
    } catch (e) {
      print('Error getting activity carbon stats: $e');
      return {
        'totalActivityCarbon': {},
        'totalCategoryCarbon': {},
        'totalCarbon': 0.0,
        'dailyData': [],
        'period': days,
      };
    }
  }

  // Get carbon reduction recommendations
  List<Map<String, dynamic>> getCarbonReductionRecommendations(
      Map<String, double> activityCarbon) {
    List<Map<String, dynamic>> recommendations = [];

    // Transportation recommendations
    if ((activityCarbon['transportation'] ?? 0.0) > 50.0) {
      recommendations.add({
        'category': 'Transportation',
        'title': 'Switch to Public Transport',
        'description':
            'Consider using public transport 2-3 times per week to reduce your carbon footprint.',
        'potentialSavings': 30.0, // kg CO2e per month
        'difficulty': 'Medium',
        'icon': 'directions_bus',
      });
    }

    // Food recommendations
    if ((activityCarbon['food'] ?? 0.0) > 100.0) {
      recommendations.add({
        'category': 'Food',
        'title': 'Choose Plant-Based Options',
        'description':
            'Replace meat with plant-based alternatives 3-4 times per week.',
        'potentialSavings': 50.0, // kg CO2e per month
        'difficulty': 'Easy',
        'icon': 'eco',
      });
    }

    // Energy recommendations
    if ((activityCarbon['energy'] ?? 0.0) > 80.0) {
      recommendations.add({
        'category': 'Energy',
        'title': 'Switch to LED Bulbs',
        'description':
            'Replace traditional bulbs with LED alternatives to reduce energy consumption.',
        'potentialSavings': 20.0, // kg CO2e per month
        'difficulty': 'Easy',
        'icon': 'lightbulb',
      });
    }

    // Shopping recommendations
    if ((activityCarbon['shopping'] ?? 0.0) > 60.0) {
      recommendations.add({
        'category': 'Shopping',
        'title': 'Buy Second-Hand',
        'description':
            'Consider purchasing second-hand items for clothing and electronics.',
        'potentialSavings': 40.0, // kg CO2e per month
        'difficulty': 'Medium',
        'icon': 'shopping_bag',
      });
    }

    return recommendations;
  }

  // Calculate carbon offset needed
  double calculateCarbonOffset(double totalCarbon) {
    // Simple calculation: offset 20% of total carbon
    return totalCarbon * 0.2;
  }

  // Get carbon offset options
  List<Map<String, dynamic>> getCarbonOffsetOptions(double offsetAmount) {
    return [
      {
        'name': 'Tree Planting',
        'description': 'Plant trees to absorb CO2',
        'costPerKg': 0.05, // $0.05 per kg CO2
        'totalCost': offsetAmount * 0.05,
        'icon': 'park',
      },
      {
        'name': 'Renewable Energy',
        'description': 'Support renewable energy projects',
        'costPerKg': 0.08, // $0.08 per kg CO2
        'totalCost': offsetAmount * 0.08,
        'icon': 'solar_power',
      },
      {
        'name': 'Ocean Conservation',
        'description': 'Protect marine ecosystems',
        'costPerKg': 0.06, // $0.06 per kg CO2
        'totalCost': offsetAmount * 0.06,
        'icon': 'water',
      },
    ];
  }
}
