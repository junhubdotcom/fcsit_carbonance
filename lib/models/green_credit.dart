import 'package:cloud_firestore/cloud_firestore.dart';

class GreenCredit {
  String? id;
  String? userId;
  double totalCarbonSaved;
  double totalCarbonEmitted;
  double creditScore;
  double creditBalance;
  double sustainabilityScore;
  List<String> achievements;
  DateTime? lastUpdated;
  int greenActionsCount;
  double creditMultiplier;
  double netEnvironmentalImpact;

  GreenCredit({
    this.id,
    this.userId,
    this.totalCarbonSaved = 0.0,
    this.totalCarbonEmitted = 0.0,
    this.creditScore = 0.0,
    this.creditBalance = 0.0,
    this.sustainabilityScore = 0.0,
    this.achievements = const [],
    this.lastUpdated,
    this.greenActionsCount = 0,
    this.creditMultiplier = 1.0,
    this.netEnvironmentalImpact = 0.0,
  });

  factory GreenCredit.fromJson(Map<String, dynamic> json) {
    return GreenCredit(
      id: json['id'],
      userId: json['userId'],
      totalCarbonSaved: (json['totalCarbonSaved'] ?? 0.0).toDouble(),
      totalCarbonEmitted: (json['totalCarbonEmitted'] ?? 0.0).toDouble(),
      creditScore: (json['creditScore'] ?? 0.0).toDouble(),
      creditBalance: (json['creditBalance'] ?? 0.0).toDouble(),
      sustainabilityScore: (json['sustainabilityScore'] ?? 0.0).toDouble(),
      achievements: List<String>.from(json['achievements'] ?? []),
      lastUpdated: json['lastUpdated'] != null
          ? (json['lastUpdated'] as Timestamp).toDate()
          : null,
      greenActionsCount: json['greenActionsCount'] ?? 0,
      creditMultiplier: (json['creditMultiplier'] ?? 1.0).toDouble(),
      netEnvironmentalImpact:
          (json['netEnvironmentalImpact'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'totalCarbonSaved': totalCarbonSaved,
      'totalCarbonEmitted': totalCarbonEmitted,
      'creditScore': creditScore,
      'creditBalance': creditBalance,
      'sustainabilityScore': sustainabilityScore,
      'achievements': achievements,
      'lastUpdated':
          lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
      'greenActionsCount': greenActionsCount,
      'creditMultiplier': creditMultiplier,
      'netEnvironmentalImpact': netEnvironmentalImpact,
    };
  }

  GreenCredit copyWith({
    String? id,
    String? userId,
    double? totalCarbonSaved,
    double? totalCarbonEmitted,
    double? creditScore,
    double? creditBalance,
    double? sustainabilityScore,
    List<String>? achievements,
    DateTime? lastUpdated,
  }) {
    return GreenCredit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalCarbonSaved: totalCarbonSaved ?? this.totalCarbonSaved,
      totalCarbonEmitted: totalCarbonEmitted ?? this.totalCarbonEmitted,
      creditScore: creditScore ?? this.creditScore,
      creditBalance: creditBalance ?? this.creditBalance,
      sustainabilityScore: sustainabilityScore ?? this.sustainabilityScore,
      achievements: achievements ?? this.achievements,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      greenActionsCount: greenActionsCount ?? this.greenActionsCount,
      creditMultiplier: creditMultiplier ?? this.creditMultiplier,
      netEnvironmentalImpact:
          netEnvironmentalImpact ?? this.netEnvironmentalImpact,
    );
  }

  void addCredits(double amount, String category) {
    creditBalance += amount;
    greenActionsCount++;
    lastUpdated = DateTime.now();
  }

  void updateCarbonMetrics(double carbonSaved, double carbonEmitted) {
    totalCarbonSaved += carbonSaved;
    totalCarbonEmitted += carbonEmitted;
    netEnvironmentalImpact = totalCarbonSaved - totalCarbonEmitted;
    lastUpdated = DateTime.now();
  }

  void addAchievement(String achievement) {
    if (!achievements.contains(achievement)) {
      achievements.add(achievement);
      lastUpdated = DateTime.now();
    }
  }
}
