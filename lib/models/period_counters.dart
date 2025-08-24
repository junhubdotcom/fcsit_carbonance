import 'package:cloud_firestore/cloud_firestore.dart';

class PeriodCounters {
  final String id;
  final String userId;
  final String period;
  final String periodId;
  final Totals totals;
  final Breakdowns breakdowns;
  final List<String> appliedTxIds;
  final DateTime lastUpdated;
  final Map<String, List<String>> insights;

  PeriodCounters({
    required this.id,
    required this.userId,
    required this.period,
    required this.periodId,
    required this.totals,
    required this.breakdowns,
    required this.appliedTxIds,
    required this.lastUpdated,
    this.insights = const {},
  });

  // Create from JSON
  factory PeriodCounters.fromJson(String id, Map<String, dynamic> json) {
    return PeriodCounters(
      id: id,
      userId: json['userId'] ?? '',
      period: json['period'] ?? '',
      periodId: json['periodId'] ?? '',
      totals: Totals.fromJson(json['totals'] ?? {}),
      breakdowns: Breakdowns.fromJson(json['breakdowns'] ?? {}),
      appliedTxIds: _convertToStringList(json['appliedTxIds'] ?? []),
      lastUpdated: json['lastUpdated'] is Timestamp
          ? (json['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
      insights: _convertToInsightsMap(json['insights']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'period': period,
      'periodId': periodId,
      'totals': totals.toJson(),
      'breakdowns': breakdowns.toJson(),
      'appliedTxIds': appliedTxIds,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'insights': insights,
    };
  }

  static List<String> _convertToStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    } else if (value is Map) {
      // Handle case where it might be a map with boolean values
      return value.keys.map((e) => e.toString()).toList();
    } else {
      return [];
    }
  }

  static Map<String, List<String>> _convertToInsightsMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.map((key, value) {
        if (value is List) {
          return MapEntry(key, value.map((e) => e.toString()).toList());
        } else {
          return MapEntry(key, <String>[]);
        }
      });
    } else {
      return {};
    }
  }

  // Create a copy with updated values
  PeriodCounters copyWith({
    String? id,
    String? userId,
    String? period,
    String? periodId,
    Totals? totals,
    Breakdowns? breakdowns,
    List<String>? appliedTxIds,
    DateTime? lastUpdated,
    Map<String, List<String>>? insights,
  }) {
    return PeriodCounters(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      period: period ?? this.period,
      periodId: periodId ?? this.periodId,
      totals: totals ?? this.totals,
      breakdowns: breakdowns ?? this.breakdowns,
      appliedTxIds: appliedTxIds ?? this.appliedTxIds,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      insights: insights ?? this.insights,
    );
  }
}

class Totals {
  final double income;
  final double expense;
  final double co2Kg;

  Totals({
    this.income = 0.0,
    this.expense = 0.0,
    this.co2Kg = 0.0,
  });

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      income: (json['income'] ?? 0).toDouble(),
      expense: (json['expense'] ?? 0).toDouble(),
      co2Kg: (json['co2Kg'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'income': income,
      'expense': expense,
      'co2Kg': co2Kg,
    };
  }

  Totals copyWith({
    double? income,
    double? expense,
    double? co2Kg,
  }) {
    return Totals(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      co2Kg: co2Kg ?? this.co2Kg,
    );
  }

  // Helper methods for calculations
  double get balance => income - expense;
  double get carbonIntensity => expense > 0 ? co2Kg / expense : 0.0;
}

class Breakdowns {
  final Map<String, double> incomeByCategory;
  final Map<String, double> expenseByCategory;
  final Map<String, double> co2ByCategory;

  Breakdowns({
    this.incomeByCategory = const {},
    this.expenseByCategory = const {},
    this.co2ByCategory = const {},
  });

  factory Breakdowns.fromJson(Map<String, dynamic> json) {
    return Breakdowns(
      incomeByCategory: _convertMapToDouble(json['incomeByCategory'] ?? {}),
      expenseByCategory: _convertMapToDouble(json['expenseByCategory'] ?? {}),
      co2ByCategory: _convertMapToDouble(json['co2ByCategory'] ?? {}),
    );
  }

  static Map<String, double> _convertMapToDouble(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value is int) {
        return MapEntry(key, value.toDouble());
      } else if (value is double) {
        return MapEntry(key, value);
      } else if (value is num) {
        return MapEntry(key, value.toDouble());
      } else {
        return MapEntry(key, 0.0);
      }
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'incomeByCategory': incomeByCategory,
      'expenseByCategory': expenseByCategory,
      'co2ByCategory': co2ByCategory,
    };
  }

  Breakdowns copyWith({
    Map<String, double>? incomeByCategory,
    Map<String, double>? expenseByCategory,
    Map<String, double>? co2ByCategory,
  }) {
    return Breakdowns(
      incomeByCategory: incomeByCategory ?? this.incomeByCategory,
      expenseByCategory: expenseByCategory ?? this.expenseByCategory,
      co2ByCategory: co2ByCategory ?? this.co2ByCategory,
    );
  }

  // Helper methods for expense (main spending category)
  String get topExpenseCategory {
    if (expenseByCategory.isEmpty) return 'N/A';
    return expenseByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double get topExpenseCategoryAmount {
    if (expenseByCategory.isEmpty) return 0.0;
    return expenseByCategory.values.reduce((a, b) => a > b ? a : b);
  }

  // Helper methods for income
  String get topIncomeCategory {
    if (incomeByCategory.isEmpty) return 'N/A';
    return incomeByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double get topIncomeCategoryAmount {
    if (incomeByCategory.isEmpty) return 0.0;
    return incomeByCategory.values.reduce((a, b) => a > b ? a : b);
  }

  // Helper methods for CO2
  String get topCO2Category {
    if (co2ByCategory.isEmpty) return 'N/A';
    return co2ByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double get topCO2CategoryAmount {
    if (co2ByCategory.isEmpty) return 0.0;
    return co2ByCategory.values.reduce((a, b) => a > b ? a : b);
  }
}
