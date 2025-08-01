import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/models/income.dart';
// import 'package:steadypunpipi_vhack/models/expensealt.dart';
// import 'package:steadypunpipi_vhack/models/expense_itemalt.dart';

const String EXPENSE_COLLECTION_REF = "expense";
const String INCOME_COLLECTION_REF = "expenseIncome";
const String EXPENSE_ITEM_COLLECTION_REF = "expenseItem";

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    return await expensesCollection.add(expense);
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
    return await incomesCollection.add(income);
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
    return await expenseItemsCollection.add(expenseItem);
  }

  Future<ExpenseItem?> getExpenseItem(String expenseItemId) async {
    final snapshot = await expenseItemsCollection.doc(expenseItemId).get();
    return snapshot.data();
  }
}
