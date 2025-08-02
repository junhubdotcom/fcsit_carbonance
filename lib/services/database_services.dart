import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/models/income.dart';

class FirestoreCollections {
  // Main Data Collections (Matching Firebase Functions)
  static const String EXPENSES = "Expense";
  static const String INCOMES = "Income";
  static const String EXPENSE_ITEMS = "ExpenseItem";

  // AI & Insights Collections (Matching Production)
  static const String CONNECT_EARTH_INSIGHTS = "ConnectEarthInsights";
  static const String INSIGHTS_SUMMARY = "InsightsSummary";

  // Green Credit & Loan Collections
  static const String GREEN_CREDITS = "GreenCredits";
  static const String GREEN_LOANS = "GreenLoans";

  // Unified Reward System Collections
  static const String UNIFIED_REWARDS = "UnifiedRewards";
  static const String REWARD_REDEMPTIONS = "RewardRedemptions";

  // Activity Carbon Collections
  static const String ACTIVITY_CARBON = "ActivityCarbon";

  // Income Collections
  static const String INCOME = "Income";

  // System Collections
  static const String TRIGGERS = "Triggers";
}

// Legacy collection names (for backward compatibility)
const String EXPENSE_COLLECTION_REF = FirestoreCollections.EXPENSES;
const String INCOME_COLLECTION_REF = FirestoreCollections.INCOMES;
const String EXPENSE_ITEM_COLLECTION_REF = FirestoreCollections.EXPENSE_ITEMS;

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a datetime-based document name for better tracking
  String _generateDocumentName(String prefix, DateTime dateTime) {
    final formattedDate =
        "${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}";
    final formattedTime =
        "${dateTime.hour.toString().padLeft(2, '0')}${dateTime.minute.toString().padLeft(2, '0')}";
    return "${prefix}_${formattedDate}${formattedTime}";
  }

  CollectionReference<Expense> get expensesCollection =>
      _firestore.collection(EXPENSE_COLLECTION_REF).withConverter<Expense>(
          fromFirestore: (snapshots, _) => Expense.fromJson(
                snapshots.data()!,
              ),
          toFirestore: (expense, _) => (expense as Expense).toJson());

  CollectionReference<Income> get incomesCollection =>
      _firestore.collection(INCOME_COLLECTION_REF).withConverter<Income>(
          fromFirestore: (snapshots, _) => Income.fromJson(
                snapshots.data()!,
              ),
          toFirestore: (income, _) => (income as Income).toJson());

  CollectionReference<ExpenseItem> get expenseItemsCollection => _firestore
      .collection(EXPENSE_ITEM_COLLECTION_REF)
      .withConverter<ExpenseItem>(
          fromFirestore: (snapshots, _) => ExpenseItem.fromJson(
                snapshots.data()!,
              ),
          toFirestore: (expenseItem, _) =>
              (expenseItem as ExpenseItem).toJson());

  DatabaseService() {}

  Future<List<Expense>> getAllExpenses() async {
    try {
      QuerySnapshot<Expense> snapshot = await expensesCollection.get();
      return snapshot.docs.map((doc) {
        Expense expense = doc.data();
        expense.id = doc.id;
        return expense;
      }).toList();
    } catch (e) {
      print("Error getting all expenses: $e");
      return [];
    }
  }

  Future<List<Expense>> getExpensesByDay(DateTime targetDate) async {
    try {
      DateTime startOfDay = targetDate.copyWith(
          hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      DateTime endOfDay = targetDate.copyWith(
          hour: 23, minute: 59, second: 59, millisecond: 999, microsecond: 999);

      QuerySnapshot<Expense> snapshot = await expensesCollection
          .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
          .where('dateTime', isLessThanOrEqualTo: endOfDay)
          .get();

      return snapshot.docs.map((doc) {
        Expense expense = doc.data();
        expense.id = doc.id;
        return expense;
      }).toList();
    } catch (e) {
      print(
          "Error getting expenses for ${targetDate.toLocal().toString().split(' ')[0]}: $e");
      return [];
    }
  }

  Future<DocumentReference<Expense>> addExpense(Expense expense) async {
    try {
      final now = DateTime.now();
      final documentName = _generateDocumentName("expense", now);

      await expensesCollection.doc(documentName).set(expense);

      print("✅ Expense saved at: ${expensesCollection.doc(documentName).path}");
      print("📄 Document: $documentName");

      return expensesCollection.doc(documentName);
    } catch (e) {
      print("❌ Error saving expense: $e");
      rethrow;
    }
  }

  Future<void> updateExpense(String expenseId, Expense expense) async {
    await expensesCollection.doc(expenseId).update(expense.toJson());
  }

  Future<Expense?> getExpense(String expenseId) async {
    final snapshot = await expensesCollection.doc(expenseId).get();
    return snapshot.data();
  }

  Future<void> deleteExpense(String expenseId) async {
    await expensesCollection.doc(expenseId).delete();
  }

  //Income
  Future<DocumentReference<Income>> addIncome(Income income) async {
    try {
      final now = DateTime.now();
      final documentName = _generateDocumentName("income", now);

      await incomesCollection.doc(documentName).set(income);

      print("✅ Income saved at: ${incomesCollection.doc(documentName).path}");
      print("📄 Document: $documentName");

      return incomesCollection.doc(documentName);
    } catch (e) {
      print("❌ Error saving income: $e");
      rethrow;
    }
  }

  Future<void> updateIncome(String incomeId, Income income) async {
    await expensesCollection.doc(incomeId).update(income.toJson());
  }

  Future<Income?> getIncome(String incomeId) async {
    final snapshot = await incomesCollection.doc(incomeId).get();
    return snapshot.data();
  }

  Future<void> deleteIncome(String incomeId) async {
    await incomesCollection.doc(incomeId).delete();
  }

  //Expense Item
  Future<DocumentReference<ExpenseItem>> addExpenseItem(
      ExpenseItem expenseItem) async {
    try {
      final now = DateTime.now();
      final documentName = _generateDocumentName("item", now);

      await expenseItemsCollection.doc(documentName).set(expenseItem);

      print(
          "✅ Expense item saved at: ${expenseItemsCollection.doc(documentName).path}");
      print("📄 Document: $documentName");

      return expenseItemsCollection.doc(documentName);
    } catch (e) {
      print("❌ Error saving expense item: $e");
      rethrow;
    }
  }

  Future<ExpenseItem?> getExpenseItem(String expenseItemId) async {
    final snapshot = await expenseItemsCollection.doc(expenseItemId).get();
    return snapshot.data();
  }
}
