import 'package:cloud_firestore/cloud_firestore.dart';

enum RewardType {
  points,
  greenCredits,
  experience,
  carbonOffset,
  achievements,
  vouchers,
  donations
}

enum TierLevel {
  bronze, // 0-1000 points
  silver, // 1001-3000 points
  gold, // 3001-6000 points
  platinum, // 6001-10000 points
  diamond // 10000+ points
}

class UnifiedRewardSystem {
  String? id;
  String userId;

  // Unified Currency
  int totalPoints;
  double greenCredits;
  int experience;
  int level;

  // Carbon & Sustainability
  double totalCarbonSaved;
  double totalCarbonEmitted;
  double sustainabilityScore;

  // Tier System
  TierLevel tierLevel;
  Map<String, int> categoryPoints;
  List<String> achievements;

  // Activity Tracking
  int consecutiveDays;
  int totalTransactions;
  DateTime lastActivity;

  UnifiedRewardSystem({
    this.id,
    required this.userId,
    this.totalPoints = 0,
    this.greenCredits = 0.0,
    this.experience = 0,
    this.level = 1,
    this.totalCarbonSaved = 0.0,
    this.totalCarbonEmitted = 0.0,
    this.sustainabilityScore = 0.0,
    this.tierLevel = TierLevel.bronze,
    Map<String, int>? categoryPoints,
    List<String>? achievements,
    this.consecutiveDays = 0,
    this.totalTransactions = 0,
    DateTime? lastActivity,
  })  : categoryPoints = categoryPoints ?? {},
        achievements = achievements ?? [],
        lastActivity = lastActivity ?? DateTime.now();

  // Tier Benefits
  double get tierMultiplier {
    switch (tierLevel) {
      case TierLevel.bronze:
        return 1.0;
      case TierLevel.silver:
        return 1.2;
      case TierLevel.gold:
        return 1.5;
      case TierLevel.platinum:
        return 2.0;
      case TierLevel.diamond:
        return 2.5;
    }
  }

  int get pointsToNextTier {
    switch (tierLevel) {
      case TierLevel.bronze:
        return 1000 - totalPoints;
      case TierLevel.silver:
        return 3000 - totalPoints;
      case TierLevel.gold:
        return 6000 - totalPoints;
      case TierLevel.platinum:
        return 10000 - totalPoints;
      case TierLevel.diamond:
        return 0; // Max tier
    }
  }

  // Reward Calculation
  Map<String, dynamic> calculateRewards({
    required double amount,
    required String category,
    required double carbonFootprint,
    required bool isEcoFriendly,
  }) {
    // Base points calculation
    int basePoints = (amount * 10).round(); // 10 points per MYR

    // Category multipliers
    double categoryMultiplier = _getCategoryMultiplier(category);

    // Carbon impact bonus/penalty
    double carbonMultiplier = carbonFootprint < 0 ? 1.5 : 0.8;

    // Eco-friendly bonus
    double ecoMultiplier = isEcoFriendly ? 1.3 : 1.0;

    // Tier multiplier
    double tierBonus = tierMultiplier;

    // Final calculations
    int finalPoints = (basePoints *
            categoryMultiplier *
            carbonMultiplier *
            ecoMultiplier *
            tierBonus)
        .round();
    double greenCreditsEarned =
        isEcoFriendly ? (amount * 2.0 * tierBonus) : 0.0;
    int experienceEarned = (finalPoints * 0.1).round();

    return {
      'points': finalPoints,
      'greenCredits': greenCreditsEarned,
      'experience': experienceEarned,
      'carbonSaved': isEcoFriendly ? (amount * 0.5) : 0.0,
      'carbonEmitted': carbonFootprint,
    };
  }

  double _getCategoryMultiplier(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return 1.0;
      case 'transport':
        return 1.2;
      case 'energy':
        return 1.5;
      case 'shopping':
        return 0.8;
      case 'entertainment':
        return 0.9;
      default:
        return 1.0;
    }
  }

  // Update methods
  void addRewards(Map<String, dynamic> rewards) {
    totalPoints += (rewards['points'] ?? 0) as int;
    greenCredits += (rewards['greenCredits'] ?? 0.0) as double;
    experience += (rewards['experience'] ?? 0) as int;

    totalCarbonSaved += (rewards['carbonSaved'] ?? 0.0) as double;
    totalCarbonEmitted += (rewards['carbonEmitted'] ?? 0.0) as double;

    _updateTier();
    _updateLevel();
    _updateSustainabilityScore();
  }

  void _updateTier() {
    if (totalPoints >= 10000) {
      tierLevel = TierLevel.diamond;
    } else if (totalPoints >= 6000) {
      tierLevel = TierLevel.platinum;
    } else if (totalPoints >= 3000) {
      tierLevel = TierLevel.gold;
    } else if (totalPoints >= 1000) {
      tierLevel = TierLevel.silver;
    } else {
      tierLevel = TierLevel.bronze;
    }
  }

  void _updateLevel() {
    level = (experience / 100).floor() + 1;
  }

  void _updateSustainabilityScore() {
    double baseScore = 50.0;

    // Carbon impact (40% weight)
    double carbonFactor = (totalCarbonSaved / (totalCarbonEmitted + 1)) * 40;

    // Activity factor (30% weight)
    double activityFactor = (totalTransactions / 100) * 30;

    // Points factor (20% weight)
    double pointsFactor = (totalPoints / 10000) * 20;

    // Achievement factor (10% weight)
    double achievementFactor = (achievements.length / 10) * 10;

    sustainabilityScore = (baseScore +
            carbonFactor +
            activityFactor +
            pointsFactor +
            achievementFactor)
        .clamp(0, 100);
  }

  // Serialization
  factory UnifiedRewardSystem.fromJson(Map<String, dynamic> json) {
    return UnifiedRewardSystem(
      id: json['id'],
      userId: json['userId'],
      totalPoints: json['totalPoints'] ?? 0,
      greenCredits: (json['greenCredits'] ?? 0.0).toDouble(),
      experience: json['experience'] ?? 0,
      level: json['level'] ?? 1,
      totalCarbonSaved: (json['totalCarbonSaved'] ?? 0.0).toDouble(),
      totalCarbonEmitted: (json['totalCarbonEmitted'] ?? 0.0).toDouble(),
      sustainabilityScore: (json['sustainabilityScore'] ?? 0.0).toDouble(),
      tierLevel: TierLevel.values.firstWhere(
        (e) => e.toString() == 'TierLevel.${json['tierLevel']}',
        orElse: () => TierLevel.bronze,
      ),
      categoryPoints: Map<String, int>.from(json['categoryPoints'] ?? {}),
      achievements: List<String>.from(json['achievements'] ?? []),
      consecutiveDays: json['consecutiveDays'] ?? 0,
      totalTransactions: json['totalTransactions'] ?? 0,
      lastActivity: json['lastActivity'] != null
          ? (json['lastActivity'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'totalPoints': totalPoints,
      'greenCredits': greenCredits,
      'experience': experience,
      'level': level,
      'totalCarbonSaved': totalCarbonSaved,
      'totalCarbonEmitted': totalCarbonEmitted,
      'sustainabilityScore': sustainabilityScore,
      'tierLevel': tierLevel.toString().split('.').last,
      'categoryPoints': categoryPoints,
      'achievements': achievements,
      'consecutiveDays': consecutiveDays,
      'totalTransactions': totalTransactions,
      'lastActivity': Timestamp.fromDate(lastActivity),
    };
  }
}
