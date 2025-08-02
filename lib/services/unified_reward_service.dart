import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steadypunpipi_vhack/models/unified_reward_system.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';

class UnifiedRewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();

  // Eco-friendly category detection
  static const Set<String> _ecoFriendlyCategories = {
    'organic_food',
    'public_transport',
    'renewable_energy',
    'sustainable_fashion',
    'eco_products',
    'local_produce',
    'bike_sharing',
    'solar_panels',
    'electric_vehicle',
    'green_building'
  };

  // Get or create user's reward profile
  Future<UnifiedRewardSystem> getUserRewardProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.UNIFIED_REWARDS)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UnifiedRewardSystem.fromJson(doc.data()!);
      } else {
        // Create new profile
        final newProfile = UnifiedRewardSystem(userId: userId);
        await _saveRewardProfile(newProfile);
        return newProfile;
      }
    } catch (e) {
      print('Error getting reward profile: $e');
      return UnifiedRewardSystem(userId: userId);
    }
  }

  // Process transaction and calculate rewards
  Future<Map<String, dynamic>> processTransaction({
    required String userId,
    required List<ExpenseItem> items,
    required double totalAmount,
  }) async {
    final profile = await getUserRewardProfile(userId);

    Map<String, dynamic> totalRewards = {
      'points': 0,
      'greenCredits': 0.0,
      'experience': 0,
      'carbonSaved': 0.0,
      'carbonEmitted': 0.0,
    };

    for (ExpenseItem item in items) {
      final rewards = _calculateItemRewards(item, profile);

      // Accumulate rewards
      totalRewards['points'] += rewards['points'];
      totalRewards['greenCredits'] += rewards['greenCredits'];
      totalRewards['experience'] += rewards['experience'];
      totalRewards['carbonSaved'] += rewards['carbonSaved'];
      totalRewards['carbonEmitted'] += rewards['carbonEmitted'];
    }

    // Update profile
    profile.addRewards(totalRewards);
    profile.totalTransactions++;
    profile.lastActivity = DateTime.now();

    // Check for achievements
    await _checkAchievements(profile);

    // Save updated profile
    await _saveRewardProfile(profile);

    return {
      'profile': profile,
      'rewards': totalRewards,
      'newAchievements': _getNewAchievements(profile),
    };
  }

  Map<String, dynamic> _calculateItemRewards(
      ExpenseItem item, UnifiedRewardSystem profile) {
    final amount = item.price * item.quantity;
    final carbonFootprint = item.carbon_footprint ?? 0.0;
    final isEcoFriendly = _isEcoFriendlyCategory(item.category);

    return profile.calculateRewards(
      amount: amount,
      category: item.category,
      carbonFootprint: carbonFootprint,
      isEcoFriendly: isEcoFriendly,
    );
  }

  bool _isEcoFriendlyCategory(String category) {
    return _ecoFriendlyCategories.contains(category.toLowerCase());
  }

  Future<void> _checkAchievements(UnifiedRewardSystem profile) async {
    final newAchievements = <String>[];

    // Tier achievements
    if (profile.tierLevel == TierLevel.silver &&
        !profile.achievements.contains('Silver Star')) {
      newAchievements.add('Silver Star');
    }
    if (profile.tierLevel == TierLevel.gold &&
        !profile.achievements.contains('Gold Master')) {
      newAchievements.add('Gold Master');
    }
    if (profile.tierLevel == TierLevel.platinum &&
        !profile.achievements.contains('Platinum Elite')) {
      newAchievements.add('Platinum Elite');
    }
    if (profile.tierLevel == TierLevel.diamond &&
        !profile.achievements.contains('Diamond Legend')) {
      newAchievements.add('Diamond Legend');
    }

    // Activity achievements
    if (profile.totalTransactions >= 10 &&
        !profile.achievements.contains('Transaction Pro')) {
      newAchievements.add('Transaction Pro');
    }
    if (profile.totalTransactions >= 50 &&
        !profile.achievements.contains('Transaction Master')) {
      newAchievements.add('Transaction Master');
    }

    // Carbon achievements
    if (profile.totalCarbonSaved >= 100 &&
        !profile.achievements.contains('Carbon Saver')) {
      newAchievements.add('Carbon Saver');
    }
    if (profile.totalCarbonSaved >= 500 &&
        !profile.achievements.contains('Carbon Hero')) {
      newAchievements.add('Carbon Hero');
    }

    // Sustainability achievements
    if (profile.sustainabilityScore >= 80 &&
        !profile.achievements.contains('Eco Warrior')) {
      newAchievements.add('Eco Warrior');
    }
    if (profile.sustainabilityScore >= 95 &&
        !profile.achievements.contains('Eco Champion')) {
      newAchievements.add('Eco Champion');
    }

    // Add new achievements
    for (String achievement in newAchievements) {
      profile.achievements.add(achievement);
    }
  }

  List<String> _getNewAchievements(UnifiedRewardSystem profile) {
    // This would track newly added achievements
    // For now, return empty list
    return [];
  }

  Future<void> _saveRewardProfile(UnifiedRewardSystem profile) async {
    try {
      await _firestore
          .collection(FirestoreCollections.UNIFIED_REWARDS)
          .doc(profile.userId)
          .set(profile.toJson());
    } catch (e) {
      print('Error saving reward profile: $e');
    }
  }

  // Get reward statistics
  Future<Map<String, dynamic>> getRewardStatistics(String userId) async {
    final profile = await getUserRewardProfile(userId);

    return {
      'totalPoints': profile.totalPoints,
      'greenCredits': profile.greenCredits,
      'experience': profile.experience,
      'level': profile.level,
      'tierLevel': profile.tierLevel.toString().split('.').last,
      'tierMultiplier': profile.tierMultiplier,
      'pointsToNextTier': profile.pointsToNextTier,
      'sustainabilityScore': profile.sustainabilityScore,
      'totalCarbonSaved': profile.totalCarbonSaved,
      'totalCarbonEmitted': profile.totalCarbonEmitted,
      'achievements': profile.achievements,
      'totalTransactions': profile.totalTransactions,
      'consecutiveDays': profile.consecutiveDays,
    };
  }

  // Get tier benefits
  Map<String, dynamic> getTierBenefits(TierLevel tier) {
    switch (tier) {
      case TierLevel.bronze:
        return {
          'name': 'Bronze',
          'multiplier': 1.0,
          'benefits': ['Basic rewards', 'Standard features'],
          'color': 0xFFCD7F32,
        };
      case TierLevel.silver:
        return {
          'name': 'Silver',
          'multiplier': 1.2,
          'benefits': ['20% bonus rewards', 'Priority support'],
          'color': 0xFFC0C0C0,
        };
      case TierLevel.gold:
        return {
          'name': 'Gold',
          'multiplier': 1.5,
          'benefits': ['50% bonus rewards', 'Exclusive features'],
          'color': 0xFFFFD700,
        };
      case TierLevel.platinum:
        return {
          'name': 'Platinum',
          'multiplier': 2.0,
          'benefits': ['100% bonus rewards', 'VIP features'],
          'color': 0xFFE5E4E2,
        };
      case TierLevel.diamond:
        return {
          'name': 'Diamond',
          'multiplier': 2.5,
          'benefits': ['150% bonus rewards', 'All features unlocked'],
          'color': 0xFFB9F2FF,
        };
    }
  }

  // Redeem points for rewards
  Future<bool> redeemPoints(
      String userId, int points, String rewardType) async {
    final profile = await getUserRewardProfile(userId);

    if (profile.totalPoints < points) {
      return false;
    }

    profile.totalPoints -= points;
    await _saveRewardProfile(profile);

    // Log redemption
    await _logRedemption(userId, points, rewardType);

    return true;
  }

  Future<void> _logRedemption(
      String userId, int points, String rewardType) async {
    try {
      await _firestore.collection(FirestoreCollections.REWARD_REDEMPTIONS).add({
        'userId': userId,
        'points': points,
        'rewardType': rewardType,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error logging redemption: $e');
    }
  }
}
