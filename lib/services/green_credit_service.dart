import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steadypunpipi_vhack/models/green_credit.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';

class GreenCreditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();

  // Credit earning rates for different categories (credits per RM spent)
  static const Map<String, double> _creditRates = {
    'Organic Food': 2.0,
    'Public Transport': 3.0,
    'Renewable Energy': 5.0,
    'Sustainable Products': 2.5,
    'Local Produce': 2.0,
    'Eco-friendly': 2.0,
    'Recycling': 1.5,
    'Energy Efficient': 3.0,
    'Water Conservation': 2.0,
    'Carbon Offset': 4.0,
  };

  // Carbon saving rates (kg CO2 saved per RM spent)
  static const Map<String, double> _carbonSavingRates = {
    'Organic Food': 0.1,
    'Public Transport': 0.5,
    'Renewable Energy': 2.0,
    'Sustainable Products': 0.3,
    'Local Produce': 0.2,
    'Eco-friendly': 0.2,
    'Recycling': 0.1,
    'Energy Efficient': 0.8,
    'Water Conservation': 0.1,
    'Carbon Offset': 1.0,
  };

  // Get or create user's green credit profile
  Future<GreenCredit> getUserGreenCredit(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.GREEN_CREDITS)
          .doc(userId)
          .get();

      if (doc.exists) {
        return GreenCredit.fromJson(doc.data()!);
      } else {
        // Create new green credit profile
        final newCredit = GreenCredit();
        await _firestore
            .collection(FirestoreCollections.GREEN_CREDITS)
            .doc(userId)
            .set(newCredit.toJson());
        return newCredit;
      }
    } catch (e) {
      print('🔥 [GREEN_CREDIT] Error getting user green credit: $e');
      return GreenCredit();
    }
  }

  // Calculate credits earned from an expense item
  double calculateCreditsEarned(ExpenseItem item) {
    double baseCredits = 0.0;
    double carbonSaved = 0.0;

    // Check if item category qualifies for credits
    for (String category in _creditRates.keys) {
      if (item.category.toLowerCase().contains(category.toLowerCase()) ||
          item.name.toLowerCase().contains(category.toLowerCase())) {
        baseCredits += item.price * _creditRates[category]!;
        carbonSaved += item.price * _carbonSavingRates[category]!;
        break;
      }
    }

    // Additional credits for low carbon footprint items
    if (item.carbon_footprint < 1.0) {
      baseCredits += item.price * 0.5; // Bonus for very low carbon items
    }

    return baseCredits;
  }

  // Calculate carbon saved from an expense item
  double calculateCarbonSaved(ExpenseItem item) {
    double carbonSaved = 0.0;

    for (String category in _carbonSavingRates.keys) {
      if (item.category.toLowerCase().contains(category.toLowerCase()) ||
          item.name.toLowerCase().contains(category.toLowerCase())) {
        carbonSaved += item.price * _carbonSavingRates[category]!;
        break;
      }
    }

    return carbonSaved;
  }

  // Process expense and award credits
  Future<void> processExpenseForCredits(
      String userId, List<ExpenseItem> items) async {
    try {
      final greenCredit = await getUserGreenCredit(userId);
      double totalCreditsEarned = 0.0;
      double totalCarbonSaved = 0.0;
      double totalCarbonEmitted = 0.0;

      for (ExpenseItem item in items) {
        double creditsEarned = calculateCreditsEarned(item);
        double carbonSaved = calculateCarbonSaved(item);

        totalCreditsEarned += creditsEarned;
        totalCarbonSaved += carbonSaved;
        totalCarbonEmitted += item.carbon_footprint;

        // Add credits to specific category
        if (creditsEarned > 0) {
          greenCredit.addCredits(creditsEarned, item.category);
        }
      }

      // Update carbon metrics
      greenCredit.updateCarbonMetrics(totalCarbonSaved, totalCarbonEmitted);

      // Check for achievements
      _checkAndAwardAchievements(greenCredit);

      // Save updated green credit
      await _firestore
          .collection(FirestoreCollections.GREEN_CREDITS)
          .doc(userId)
          .set(greenCredit.toJson());

      print(
          '🌱 [GREEN_CREDIT] Awarded $totalCreditsEarned credits to user $userId');
      print(
          '🌱 [GREEN_CREDIT] Carbon saved: $totalCarbonSaved kg, emitted: $totalCarbonEmitted kg');
    } catch (e) {
      print('🔥 [GREEN_CREDIT] Error processing expense for credits: $e');
    }
  }

  // Check and award achievements
  void _checkAndAwardAchievements(GreenCredit greenCredit) {
    // First green action
    if (greenCredit.greenActionsCount == 1) {
      greenCredit.addAchievement('First Green Step');
    }

    // Credit milestones
    if (greenCredit.creditBalance >= 100 &&
        !greenCredit.achievements.contains('Green Starter')) {
      greenCredit.addAchievement('Green Starter');
    }
    if (greenCredit.creditBalance >= 500 &&
        !greenCredit.achievements.contains('Eco Warrior')) {
      greenCredit.addAchievement('Eco Warrior');
    }
    if (greenCredit.creditBalance >= 1000 &&
        !greenCredit.achievements.contains('Sustainability Champion')) {
      greenCredit.addAchievement('Sustainability Champion');
    }

    // Carbon saving milestones
    if (greenCredit.totalCarbonSaved >= 100 &&
        !greenCredit.achievements.contains('Carbon Saver')) {
      greenCredit.addAchievement('Carbon Saver');
    }
    if (greenCredit.totalCarbonSaved >= 500 &&
        !greenCredit.achievements.contains('Climate Hero')) {
      greenCredit.addAchievement('Climate Hero');
    }

    // Sustainability score milestones
    if (greenCredit.sustainabilityScore >= 80 &&
        !greenCredit.achievements.contains('High Performer')) {
      greenCredit.addAchievement('High Performer');
    }
    if (greenCredit.sustainabilityScore >= 95 &&
        !greenCredit.achievements.contains('Sustainability Master')) {
      greenCredit.addAchievement('Sustainability Master');
    }
  }

  // Get credit earning suggestions
  List<Map<String, dynamic>> getCreditEarningSuggestions() {
    return [
      {
        'category': 'Organic Food',
        'description': 'Buy organic produce and sustainable food products',
        'creditRate': _creditRates['Organic Food']!,
        'carbonSaving': _carbonSavingRates['Organic Food']!,
      },
      {
        'category': 'Public Transport',
        'description': 'Use public transportation instead of private vehicles',
        'creditRate': _creditRates['Public Transport']!,
        'carbonSaving': _carbonSavingRates['Public Transport']!,
      },
      {
        'category': 'Renewable Energy',
        'description': 'Invest in solar panels or renewable energy products',
        'creditRate': _creditRates['Renewable Energy']!,
        'carbonSaving': _carbonSavingRates['Renewable Energy']!,
      },
      {
        'category': 'Sustainable Products',
        'description': 'Choose eco-friendly and sustainable products',
        'creditRate': _creditRates['Sustainable Products']!,
        'carbonSaving': _carbonSavingRates['Sustainable Products']!,
      },
      {
        'category': 'Local Produce',
        'description':
            'Support local farmers and reduce transportation emissions',
        'creditRate': _creditRates['Local Produce']!,
        'carbonSaving': _carbonSavingRates['Local Produce']!,
      },
    ];
  }

  // Get sustainability tips based on user's current score
  List<String> getSustainabilityTips(double sustainabilityScore) {
    List<String> tips = [];

    if (sustainabilityScore < 50) {
      tips.addAll([
        'Start with small changes like using reusable bags',
        'Switch to energy-efficient light bulbs',
        'Reduce meat consumption by one meal per week',
        'Use public transport for short trips',
      ]);
    } else if (sustainabilityScore < 70) {
      tips.addAll([
        'Consider installing solar panels',
        'Switch to an electric vehicle',
        'Invest in home insulation',
        'Support local and organic food producers',
      ]);
    } else if (sustainabilityScore < 90) {
      tips.addAll([
        'Offset remaining carbon emissions',
        'Invest in renewable energy projects',
        'Start a sustainable business',
        'Mentor others in sustainability practices',
      ]);
    } else {
      tips.addAll([
        'You\'re a sustainability leader!',
        'Share your knowledge with others',
        'Consider carbon-negative investments',
        'Advocate for environmental policies',
      ]);
    }

    return tips;
  }

  // Get credit balance history (for charts)
  Future<List<Map<String, dynamic>>> getCreditHistory(
      String userId, int days) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      final query = await _firestore
          .collection(FirestoreCollections.GREEN_CREDITS)
          .doc(userId)
          .collection('history')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('date')
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('🔥 [GREEN_CREDIT] Error getting credit history: $e');
      return [];
    }
  }
}
