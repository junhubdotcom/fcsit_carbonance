import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steadypunpipi_vhack/models/finance_data.dart';
import 'package:steadypunpipi_vhack/models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TransactionModel>> fetchTransactions(
      DateTime startDate, DateTime endDate) async {
    List<TransactionModel> transactions = [];

    // Fetch income
    final incomeSnapshot = await _firestore
        .collection("Income")
        .where("dateTime",
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where("dateTime", isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    for (var doc in incomeSnapshot.docs) {
      final data = doc.data();
      transactions.add(TransactionModel(
        id: doc.id,
        date: data['dateTime'].toDate(),
        category: data['category'] ?? 'Unknown',
        amount: (data['amount'] as num).toDouble(),
        type: 'income',
        carbonFootprint: 0,
        description: data['name'] ?? '',
      ));
    }

    // Fetch expense
    final expenseSnapshot = await _firestore
        .collection("Expense")
        .where("dateTime",
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where("dateTime", isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    for (var expenseDoc in expenseSnapshot.docs) {
      final expense = expenseDoc.data();
      final List<dynamic> itemRefs = expense['items'] ?? [];

      for (final ref in itemRefs) {
        if (ref is DocumentReference) {
          final itemSnap = await ref.get();
          if (!itemSnap.exists) continue;
          print("📦 Raw item snapshot: ${itemSnap.data()}");
          final item = itemSnap.data() as Map<String, dynamic>;
          print("💰 Price: ${item['price']} (${item['price']?.runtimeType})");
          print(
              "📦 Quantity: ${item['quantity']} (${item['quantity']?.runtimeType})");
          print(
              "🌱 CO2: ${item['carbon_footprint']} (${item['carbon_footprint']?.runtimeType})");

          transactions.add(TransactionModel(
            id: expenseDoc.id,
            date: expense['dateTime'].toDate(),
            category: item['category'] ?? 'General',
            amount: (item['price'] is String
                    ? double.tryParse(item['price']) ?? 0
                    : (item['price'] as num).toDouble()) *
                ((item['quantity'] ?? 1) as num).toDouble(),
            type: 'expense',
            carbonFootprint: item['carbon_footprint'] != null
                ? (item['carbon_footprint'] is String
                    ? double.tryParse(item['carbon_footprint']) ?? 0
                    : (item['carbon_footprint'] as num).toDouble())
                : 0,
            description: item['name'] ?? expense['transactionName'] ?? '',
          ));
        }
      }
    }

    return transactions;
  }

  Future<List<FinanceCO2Data>> processFCO2(
      List<TransactionModel> transactions, String period) async {
    Map<String, FinanceCO2Data> groupedData = {};

    for (var transaction in transactions) {
      String key = getGroupingKey(transaction.date, period);

      if (!groupedData.containsKey(key)) {
        groupedData[key] =
            FinanceCO2Data(label: key, income: 0, expense: 0, co2: 0);
      }

      if (transaction.type == 'income') {
        groupedData[key]!.income += transaction.amount;
      } else {
        groupedData[key]!.expense += transaction.amount;
        groupedData[key]!.co2 += transaction.carbonFootprint ?? 0;
      }
    }

    return groupedData.values.toList();
  }

  String getGroupingKey(DateTime date, String period) {
    if (period == "Daily") {
      return getTimeSlot(date);
    } else if (period == "Weekly") {
      DateTime startOfWeek = getStartOfWeek(date);
      return "${startOfWeek.day}/${startOfWeek.month}";
    } else if (period == "Monthly") {
      int weekInMonth = getWeekInMonth(date);
      return "Week $weekInMonth";
    } else {
      return "${date.year}-${date.month}";
    }
  }

  String getTimeSlot(DateTime date) {
    int hour = date.hour;
    if (hour < 6) return "12AM";
    if (hour < 12) return "6AM";
    if (hour < 18) return "12PM";
    return "6PM";
  }

  DateTime getStartOfWeek(DateTime date) {
    int daysSinceSunday = date.weekday % 7;
    return date.subtract(Duration(days: daysSinceSunday));
  }

  int getWeekInMonth(DateTime date) {
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    int firstDayWeekday = firstDayOfMonth.weekday % 7;
    return ((date.day + firstDayWeekday - 1) ~/ 7) + 1;
  }
}