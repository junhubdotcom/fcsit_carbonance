import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/period_counters.dart';
import '../models/expense.dart';
import '../models/income.dart';
import 'period_counters_service.dart';

class PeriodCountersUpdaterService {
  static final PeriodCountersUpdaterService _instance =
      PeriodCountersUpdaterService._internal();
  factory PeriodCountersUpdaterService() => _instance;
  PeriodCountersUpdaterService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PeriodCountersService _periodCountersService = PeriodCountersService();

  // ==================== UPDATE PERIOD COUNTERS ON TRANSACTION CHANGES ====================

  /// Update period counters when an expense is created/updated/deleted
  Future<void> updatePeriodCountersForExpense({
    required String userId,
    required Expense expense,
    required String operation, // 'create', 'update', 'delete'
    Expense? oldExpense, // for update operations
  }) async {
    try {
      print(
          '🔄 Updating period counters for expense: ${expense.id ?? 'unknown'} - $operation');

      // Get the date from the expense
      final expenseDate = expense.dateTime.toDate();

      // Get all affected periods
      final affectedPeriods =
          _getAffectedPeriods(expenseDate, oldExpense?.dateTime.toDate());

      for (final period in affectedPeriods) {
        await _updatePeriodCounterForExpense(
          userId: userId,
          period: period['period']!,
          periodId: period['periodId']!,
          expense: expense,
          operation: operation,
          oldExpense: oldExpense,
        );
      }

      print(
          '✅ Period counters updated for expense: ${expense.id ?? 'unknown'}');
    } catch (e) {
      print('❌ Error updating period counters for expense: $e');
      rethrow;
    }
  }

  /// Update period counters when an income is created/updated/deleted
  Future<void> updatePeriodCountersForIncome({
    required String userId,
    required Income income,
    required String operation, // 'create', 'update', 'delete'
    Income? oldIncome, // for update operations
  }) async {
    try {
      print(
          '🔄 Updating period counters for income: ${income.id ?? 'unknown'} - $operation');

      // Get the date from the income
      final incomeDate = income.dateTime.toDate();

      // Get all affected periods
      final affectedPeriods =
          _getAffectedPeriods(incomeDate, oldIncome?.dateTime.toDate());

      for (final period in affectedPeriods) {
        await _updatePeriodCounterForIncome(
          userId: userId,
          period: period['period']!,
          periodId: period['periodId']!,
          income: income,
          operation: operation,
          oldIncome: oldIncome,
        );
      }

      print('✅ Period counters updated for income: ${income.id ?? 'unknown'}');
    } catch (e) {
      print('❌ Error updating period counters for income: $e');
      rethrow;
    }
  }

  // ==================== PRIVATE HELPER METHODS ====================

  /// Get all affected periods for a date change
  List<Map<String, String>> _getAffectedPeriods(
      DateTime newDate, DateTime? oldDate) {
    final periods = <Map<String, String>>[];

    // Always include the new date periods
    final newPeriodIds = _periodCountersService.getPeriodIdsForDate(newDate);
    periods.addAll([
      {'period': 'daily', 'periodId': newPeriodIds['daily']!},
      {'period': 'weekly', 'periodId': newPeriodIds['weekly']!},
      {'period': 'monthly', 'periodId': newPeriodIds['monthly']!},
    ]);

    // If updating, also include old date periods
    if (oldDate != null) {
      final oldPeriodIds = _periodCountersService.getPeriodIdsForDate(oldDate);
      for (final entry in oldPeriodIds.entries) {
        final period = entry.key;
        final periodId = entry.value;

        // Only add if not already included
        if (!periods
            .any((p) => p['period'] == period && p['periodId'] == periodId)) {
          periods.add({'period': period, 'periodId': periodId});
        }
      }
    }

    return periods;
  }

  /// Update period counter for an expense
  Future<void> _updatePeriodCounterForExpense({
    required String userId,
    required String period,
    required String periodId,
    required Expense expense,
    required String operation,
    Expense? oldExpense,
  }) async {
    try {
      // Get current period counter
      final currentCounter = await _periodCountersService.getPeriodCounter(
        userId: userId,
        period: period,
        periodId: periodId,
      );

      // Calculate changes - for now, use carbon footprint as expense amount
      // TODO: Calculate actual expense amount from expense items
      double expenseChange = 0.0;
      double co2Change = 0.0;
      Map<String, double> categoryChanges = {};

      switch (operation) {
        case 'create':
          // Use carbon footprint as proxy for expense amount for now
          expenseChange = expense.carbonFootprint * 10; // Rough estimate
          co2Change = expense.carbonFootprint;
          categoryChanges['General'] = expenseChange;
          break;
        case 'update':
          if (oldExpense != null) {
            expenseChange = (expense.carbonFootprint * 10) -
                (oldExpense.carbonFootprint * 10);
            co2Change = expense.carbonFootprint - oldExpense.carbonFootprint;
            categoryChanges['General'] = expenseChange;
          }
          break;
        case 'delete':
          expenseChange = -(expense.carbonFootprint * 10);
          co2Change = -expense.carbonFootprint;
          categoryChanges['General'] = expenseChange;
          break;
      }

      // Update or create period counter
      await _updatePeriodCounter(
        userId: userId,
        period: period,
        periodId: periodId,
        currentCounter: currentCounter,
        expenseChange: expenseChange,
        co2Change: co2Change,
        categoryChanges: categoryChanges,
        transactionId: expense.id ?? 'unknown',
        operation: operation,
      );
    } catch (e) {
      print('❌ Error updating period counter for expense: $e');
      rethrow;
    }
  }

  /// Update period counter for an income
  Future<void> _updatePeriodCounterForIncome({
    required String userId,
    required String period,
    required String periodId,
    required Income income,
    required String operation,
    Income? oldIncome,
  }) async {
    try {
      // Get current period counter
      final currentCounter = await _periodCountersService.getPeriodCounter(
        userId: userId,
        period: period,
        periodId: periodId,
      );

      // Calculate changes
      double incomeChange = 0.0;
      Map<String, double> categoryChanges = {};

      switch (operation) {
        case 'create':
          incomeChange = income.amount ?? 0.0;
          categoryChanges[income.category ?? 'Uncategorized'] =
              income.amount ?? 0.0;
          break;
        case 'update':
          if (oldIncome != null) {
            incomeChange = (income.amount ?? 0.0) - (oldIncome.amount ?? 0.0);

            // Update category changes
            final oldCategory = oldIncome.category ?? 'Uncategorized';
            final newCategory = income.category ?? 'Uncategorized';

            if (oldCategory != newCategory) {
              categoryChanges[oldCategory] = -(oldIncome.amount ?? 0.0);
              categoryChanges[newCategory] = income.amount ?? 0.0;
            } else {
              categoryChanges[newCategory] = incomeChange;
            }
          }
          break;
        case 'delete':
          incomeChange = -(income.amount ?? 0.0);
          categoryChanges[income.category ?? 'Uncategorized'] =
              -(income.amount ?? 0.0);
          break;
      }

      // Update or create period counter
      await _updatePeriodCounter(
        userId: userId,
        period: period,
        periodId: periodId,
        currentCounter: currentCounter,
        incomeChange: incomeChange,
        categoryChanges: categoryChanges,
        transactionId: income.id ?? 'unknown',
        operation: operation,
      );
    } catch (e) {
      print('❌ Error updating period counter for income: $e');
      rethrow;
    }
  }

  /// Core method to update period counter
  Future<void> _updatePeriodCounter({
    required String userId,
    required String period,
    required String periodId,
    required PeriodCounters? currentCounter,
    double expenseChange = 0.0,
    double incomeChange = 0.0,
    double co2Change = 0.0,
    Map<String, double> categoryChanges = const {},
    required String transactionId,
    required String operation,
  }) async {
    try {
      // Create new counter or update existing one
      final newCounter = currentCounter ??
          PeriodCounters(
            id: _periodCountersService.generateDocumentId(
                userId, period, periodId),
            userId: userId,
            period: period,
            periodId: periodId,
            totals: Totals(),
            breakdowns: Breakdowns(),
            appliedTxIds: [],
            lastUpdated: DateTime.now(),
            insights: {},
          );

      // Update totals
      final newTotals = Totals(
        income: newCounter.totals.income + incomeChange,
        expense: newCounter.totals.expense + expenseChange,
        co2Kg: newCounter.totals.co2Kg + co2Change,
      );

      // Update breakdowns - separate for income, expense, and CO2
      final newBreakdowns = Breakdowns(
        incomeByCategory: _updateCategoryBreakdown(
          newCounter.breakdowns.incomeByCategory,
          categoryChanges,
          operation == 'delete' ? -1 : 1,
        ),
        expenseByCategory: _updateCategoryBreakdown(
          newCounter.breakdowns.expenseByCategory,
          categoryChanges,
          operation == 'delete' ? -1 : 1,
        ),
        co2ByCategory: _updateCategoryBreakdown(
          newCounter.breakdowns.co2ByCategory,
          categoryChanges,
          operation == 'delete' ? -1 : 1,
        ),
      );

      // Update applied transaction IDs
      final newAppliedTxIds = List<String>.from(newCounter.appliedTxIds);
      if (operation == 'create' || operation == 'update') {
        if (!newAppliedTxIds.contains(transactionId)) {
          newAppliedTxIds.add(transactionId);
        }
      } else if (operation == 'delete') {
        newAppliedTxIds.remove(transactionId);
      }

      // Create updated counter
      final updatedCounter = newCounter.copyWith(
        totals: newTotals,
        breakdowns: newBreakdowns,
        appliedTxIds: newAppliedTxIds,
        lastUpdated: DateTime.now(),
      );

      // Save to Firestore
      await _periodCountersService.upsertPeriodCounter(
        userId: userId,
        period: period,
        periodId: periodId,
        data: updatedCounter.toJson(),
      );

      print('✅ Period counter updated: $period - $periodId');
    } catch (e) {
      print('❌ Error updating period counter: $e');
      rethrow;
    }
  }

  /// Update category breakdown with changes
  Map<String, double> _updateCategoryBreakdown(
    Map<String, double> currentBreakdown,
    Map<String, double> changes,
    int multiplier,
  ) {
    final newBreakdown = Map<String, double>.from(currentBreakdown);

    for (final entry in changes.entries) {
      final category = entry.key;
      final change = entry.value * multiplier;

      if (newBreakdown.containsKey(category)) {
        newBreakdown[category] = newBreakdown[category]! + change;

        // Remove category if amount becomes 0 or negative
        if (newBreakdown[category]! <= 0) {
          newBreakdown.remove(category);
        }
      } else if (change > 0) {
        newBreakdown[category] = change;
      }
    }

    return newBreakdown;
  }
}
