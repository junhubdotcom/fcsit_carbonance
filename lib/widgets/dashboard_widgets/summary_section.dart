import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/models/transaction_model.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/expandable_card.dart';

class SummarySection extends StatelessWidget {
  final List<String> insights;
  final List<TransactionModel> transactions;

  const SummarySection({required this.insights, required this.transactions});

  @override
  Widget build(BuildContext context) {
    SummaryData summaryData = SummaryData(transactions: transactions);

    return ExpandableCard(
      title: "Summary",
      subtitle: "A big picture",
      icon: Icons.tips_and_updates,
      tabs: const [
        Tab(text: "Overall"),
      ],
      tabViews: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Insights
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        insights.join(),
                        style: GoogleFonts.quicksand(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _summaryTile(
                      "Income",
                      "RM ${summaryData.totalIncome.toStringAsFixed(2)}",
                      Colors.green,
                      Icons.arrow_downward),
                  _summaryTile(
                      "Expense",
                      "RM ${summaryData.totalExpense.toStringAsFixed(2)}",
                      Colors.red,
                      Icons.arrow_upward),
                  _summaryTile(
                      "Balance",
                      "RM ${(summaryData.totalIncome - summaryData.totalExpense).toStringAsFixed(2)}",
                      Colors.indigo,
                      Icons.account_balance_wallet),
                  _summaryTile(
                      "CO₂",
                      "${summaryData.totalCO2.toStringAsFixed(1)} kg",
                      Colors.blue,
                      Icons.eco),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryTile(String title, String value, Color color, IconData icon) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryData {
  final List<TransactionModel> transactions;

  SummaryData({required this.transactions});

  double get totalIncome {
    return transactions
        .where((tx) => tx.type == 'income')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpense {
    return transactions
        .where((tx) => tx.type == 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalCO2 {
    return transactions.fold(
        0.0, (sum, tx) => sum + (tx.carbonFootprint ?? 0.0));
  }

  double get balance {
    return totalIncome - totalExpense;
  }
}
