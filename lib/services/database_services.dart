import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/models/income.dart';
// import 'package:steadypunpipi_vhack/models/expensealt.dart';
// import 'package:steadypunpipi_vhack/models/expense_itemalt.dart';

const String EXPENSE_COLLECTION_REF = "expense";
const String INCOME_COLLECTION_REF = "income";
const String EXPENSE_ITEM_COLLECTION_REF = "expenseItem";

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a datetime-based document name for better tracking
  String _generateDocumentName(String prefix, DateTime dateTime) {
    final formattedDate =
        "${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}";
    final formattedTime =
        "${dateTime.hour.toString().padLeft(2, '0')}${dateTime.minute.toString().padLeft(2, '0')}${dateTime.second.toString().padLeft(2, '0')}";
    final formattedMicroseconds = dateTime.microsecond.toString().padLeft(6, '0');
    return "${prefix}_${formattedDate}${formattedTime}${formattedMicroseconds}";
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

  Future<List<Income>> getIncomesByDay(DateTime targetDate) async {
    try {
      DateTime startOfDay = targetDate.copyWith(
          hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      DateTime endOfDay = targetDate.copyWith(
          hour: 23, minute: 59, second: 59, millisecond: 999, microsecond: 999);

      QuerySnapshot<Income> snapshot = await incomesCollection
          .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
          .where('dateTime', isLessThanOrEqualTo: endOfDay)
          .get();

      return snapshot.docs.map((doc) {
        Income income = doc.data();
        income.id = doc.id;
        return income;
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

  Future<List<Income>> getAllIncomes() async {
    try {
      QuerySnapshot<Income> snapshot = await incomesCollection.get();
      return snapshot.docs.map((doc) {
        Income income = doc.data();
        income.id = doc.id;
        return income;
      }).toList();
    } catch (e) {
      print("Error getting all expenses: $e");
      return [];
    }
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
      // Use microsecond precision to ensure unique document names
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
