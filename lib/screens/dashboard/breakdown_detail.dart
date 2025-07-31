import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:steadypunpipi_vhack/models/transaction_model.dart';

class BreakdownDetailPage extends StatelessWidget {
  final String category;
  final String type; // Expense, Income, CO₂
  final List<TransactionModel> transactions;

  const BreakdownDetailPage({
    Key? key,
    required this.category,
    required this.type,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filtered = transactions.where((tx) {
      if (type == "CO₂") {
        return tx.carbonFootprint != null && tx.category == category;
      } else {
        return tx.type.toLowerCase() == type.toLowerCase() &&
            tx.category.toLowerCase() == category.toLowerCase();
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$category Details",
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: filtered.isEmpty
          ? Center(
              child: Text(
                "No transactions found for this category.",
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final tx = filtered[index];
                return TransactionItem(tx: tx);
              },
            ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final TransactionModel tx;

  const TransactionItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.amount < 0;
    final amountText = isExpense
        ? "- RM ${tx.amount.abs().toStringAsFixed(2)}"
        : "+ RM ${tx.amount.toStringAsFixed(2)}";
    final carbonText =
        tx.carbonFootprint != null ? "+${tx.carbonFootprint!.toStringAsFixed(1)} CO₂e" : "";

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffe5ecdd),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tx.description,
                style: GoogleFonts.quicksand(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(tx.date),
                style: GoogleFonts.quicksand(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                tx.category,
                style: GoogleFonts.quicksand(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Right Side
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: GoogleFonts.quicksand(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (carbonText.isNotEmpty)
                Text(
                  carbonText,
                  style: GoogleFonts.quicksand(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
