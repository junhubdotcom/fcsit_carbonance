import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import '../models/income.dart';

class DashboardFirestoreService {
  static final DashboardFirestoreService _instance =
      DashboardFirestoreService._internal();
  factory DashboardFirestoreService() => _instance;
  DashboardFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get expenses for dashboard (simplified - no complex queries yet)
  Future<List<Expense>> getExpenses({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .orderBy('dateTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return Expense.fromJson(doc.data());
      }).toList();
    } catch (e) {
      print('❌ Error fetching expenses: $e');
      return [];
    }
  }

  // Get income for dashboard
  Future<List<Income>> getIncome({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection('income')
          .orderBy('dateTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return Income.fromJson(doc.data());
      }).toList();
    } catch (e) {
      print('❌ Error fetching income: $e');
      return [];
    }
  }

  // Get expenses by period (for dashboard filtering)
  Future<List<Expense>> getExpensesByPeriod({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 100,
  }) async {
    try {
      final startTimestamp = Timestamp.fromDate(startDate);
      final endTimestamp = Timestamp.fromDate(endDate);

      final snapshot = await _firestore
          .collection('expenses')
          .where('dateTime', isGreaterThanOrEqualTo: startTimestamp)
          .where('dateTime', isLessThanOrEqualTo: endTimestamp)
          .orderBy('dateTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return Expense.fromJson(doc.data());
      }).toList();
    } catch (e) {
      print('❌ Error fetching expenses by period: $e');
      return [];
    }
  }

  // Get income by period
  Future<List<Income>> getIncomeByPeriod({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 100,
  }) async {
    try {
      final startTimestamp = Timestamp.fromDate(startDate);
      final endTimestamp = Timestamp.fromDate(endDate);

      final snapshot = await _firestore
          .collection('income')
          .where('dateTime', isGreaterThanOrEqualTo: startTimestamp)
          .where('dateTime', isLessThanOrEqualTo: endTimestamp)
          .orderBy('dateTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return Income.fromJson(doc.data());
      }).toList();
    } catch (e) {
      print('❌ Error fetching income by period: $e');
      return [];
    }
  }

  // Get summary stats for dashboard
  Future<Map<String, dynamic>> getSummaryStats({
    required String period,
  }) async {
    try {
      DateTime now = DateTime.now();
      DateTime periodStart;
      DateTime periodEnd = now;

      switch (period) {
        case 'daily':
          periodStart = now.subtract(Duration(days: 7));
          break;
        case 'weekly':
          periodStart = now.subtract(Duration(days: 28));
          break;
        case 'monthly':
          periodStart = now.subtract(Duration(days: 90));
          break;
        default:
          periodStart = now.subtract(Duration(days: 7));
      }

      // Get expenses and income for the period
      final expenses = await getExpensesByPeriod(
        startDate: periodStart,
        endDate: periodEnd,
      );

      final income = await getIncomeByPeriod(
        startDate: periodStart,
        endDate: periodEnd,
      );

      // Calculate totals
      // Note: We need to calculate total expenses from expense items since expense itself doesn't have amount
      double totalExpenses = 0;
      for (var expense in expenses) {
        // Calculate total from expense items
        for (var itemRef in expense.items) {
          // This is a temporary workaround - ideally we'd get the actual item data
          // For now, we'll use a placeholder calculation
          totalExpenses += expense
              .carbonFootprint; // Placeholder - should be item.price * item.quantity
        }
      }

      double totalIncome = income.fold(0, (sum, inc) => sum + inc.amount);
      double totalCarbon =
          expenses.fold(0, (sum, expense) => sum + expense.carbonFootprint);

      return {
        'totalSpent': totalExpenses,
        'totalIncome': totalIncome,
        'totalCarbon': totalCarbon,
        'carbonSaved': 0.0, // TODO: Implement carbon savings calculation
      };
    } catch (e) {
      print('❌ Error calculating summary stats: $e');
      return {
        'totalSpent': 0.0,
        'totalIncome': 0.0,
        'totalCarbon': 0.0,
        'carbonSaved': 0.0,
      };
    }
  }

  // Get spending data by category for charts
  Future<List<Map<String, dynamic>>> getSpendingByCategory({
    required String period,
  }) async {
    try {
      DateTime now = DateTime.now();
      DateTime periodStart;

      switch (period) {
        case 'daily':
          periodStart = now.subtract(Duration(days: 7));
          break;
        case 'weekly':
          periodStart = now.subtract(Duration(days: 28));
          break;
        case 'monthly':
          periodStart = now.subtract(Duration(days: 90));
          break;
        default:
          periodStart = now.subtract(Duration(days: 7));
      }

      final expenses = await getExpensesByPeriod(
        startDate: periodStart,
        endDate: now,
      );

      // Group by category (simplified - assuming expense has category field)
      Map<String, double> categoryTotals = {};

      for (var expense in expenses) {
        // For now, we'll use a default category since expense doesn't have category field
        // This is where we need to adapt to your new structure
        String category = 'Other'; // Default category

        // Try to get category from expense items if available
        if (expense.items.isNotEmpty) {
          // This is a temporary workaround - ideally expense should have category
          category = 'General'; // Placeholder
        }

        categoryTotals[category] =
            (categoryTotals[category] ?? 0) + expense.carbonFootprint;
      }

      return categoryTotals.entries.map((entry) {
        return {
          'category': entry.key,
          'amount': entry.value,
          'percentage': 0.0, // Will be calculated in UI
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting spending by category: $e');
      return [];
    }
  }
}
