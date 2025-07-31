import 'package:flutter/material.dart';
import 'package:steadypunpipi_vhack/models/breakdown_item.dart';
import 'package:steadypunpipi_vhack/models/transaction_model.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/breakdown_tab.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/expandable_card.dart';

class BreakdownSection extends StatelessWidget {
  final List<TransactionModel> transactions;

  const BreakdownSection({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      title: "Breakdown",
      subtitle: "Understand where it all goes",
      icon: Icons.pie_chart,
      tabs: const [
        Tab(text: "Expense"),
        Tab(text: "Income"),
        Tab(text: "CO₂"),
      ],
      tabViews: [
        expenseTab(context, transactions),
        incomeTab(context, transactions),
        carbonTab(context, transactions),
      ],
    );
  }
}

Widget expenseTab(BuildContext context, List<TransactionModel> transactions) {
  return buildBreakdownTab(
    context: context,
    title: "Expense",
    data: processTransactions(transactions, "expense"),
    unit: "RM",
    valueColor: Colors.red,
    type: "Expense",
    transactions: transactions,
  );
}

Widget incomeTab(BuildContext context, List<TransactionModel> transactions) {
  return buildBreakdownTab(
    context: context,
    title: "Income",
    data: processTransactions(transactions, "income"),
    unit: "RM",
    valueColor: const Color.fromRGBO(76, 175, 80, 1),
    type: "Income",
    transactions: transactions,
  );
}

Widget carbonTab(BuildContext context, List<TransactionModel> transactions) {
  return buildBreakdownTab(
    context: context,
    title: "CO₂ Emissions",
    data: processCO2(transactions),
    unit: "kg CO₂",
    valueColor: Colors.blueGrey,
    type: "CO2",
    transactions: transactions,
  );
}

/// **Process transactions based on type (expense/income)**
List<BreakdownItem> processTransactions(
    List<TransactionModel> transactions, String type) {
  Map<String, double> categoryTotals = {};

  for (var transaction in transactions) {
    if (transaction.type == type) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
  }

  return categoryTotals.entries
      .map((e) => BreakdownItem(category: e.key, value: e.value))
      .toList();
}

/// **Process CO₂ emissions from transactions**
List<BreakdownItem> processCO2(List<TransactionModel> transactions) {
  Map<String, double> categoryCO2 = {};

  for (var transaction in transactions) {
    if (transaction.carbonFootprint != null && transaction.carbonFootprint! > 0) {
      categoryCO2[transaction.category] =
          (categoryCO2[transaction.category] ?? 0) +
              transaction.carbonFootprint!;
    }
  }

  return categoryCO2.entries
      .map((e) => BreakdownItem(category: e.key, value: e.value))
      .toList();
}
