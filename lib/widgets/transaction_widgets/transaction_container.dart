import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/models/income.dart';
import 'package:steadypunpipi_vhack/screens/transaction/transaction_details.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';
import 'package:steadypunpipi_vhack/utils/category_utils.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/label.dart';

class TransactionContainer extends StatelessWidget {
  final String transactionId;
  final String transactionType; // 'expense' or 'income'
  final DatabaseService db = DatabaseService();

  TransactionContainer({
    super.key,
    required this.transactionId,
    required this.transactionType,
  });

  Future<dynamic> _loadTransaction() async {
    if (transactionType == 'expense') {
      final expense = await db.getExpense(transactionId);
      if (expense != null && expense.items != null) {
        final items = <ExpenseItem>[];
        for (final itemRef in expense.items!) {
          try {
            final snapshot = await itemRef.get();
            final item = snapshot.data() as ExpenseItem?;
            if (item != null) items.add(item);
          } catch (e) {
            print("Error fetching ExpenseItem: $e");
          }
        }
        return {"expense": expense, "items": items};
      }
      return {"expense": null, "items": <ExpenseItem>[]};
    } else {
      final income = await db.getIncome(transactionId);
      return {"income": income};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadTransaction(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Text("Error: transaction not found");
        }

        final data = snapshot.data as Map<String, dynamic>;
        final expense = data["expense"] as Expense?;
        final income = data["income"] as Income?;
        final items = (data["items"] as List<ExpenseItem>?) ?? [];

        // === Pick values depending on type ===
        final transactionName = transactionType == "income"
            ? (income?.transactionName.isNotEmpty == true
                ? income!.transactionName
                : "No Transaction Name")
            : (expense?.transactionName?.isNotEmpty == true
                ? expense!.transactionName!
                : (items.isNotEmpty ? items[0].name : "No Transaction Name"));

        final paymentMethod = transactionType == "income"
            ? income?.paymentMethod ?? "Unknown"
            : expense?.paymentMethod ?? "Unknown";

        final totalAmount = transactionType == "income"
            ? income?.amount ?? 0.0
            : items.fold<double>(
                0.0,
                (sum, item) =>
                    sum + item.price * (item.quantity ?? 1),
              );

        final carbon = transactionType == "income"
            ? 0.0
            : expense?.carbonFootprint ?? 0.0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetails(
                  transactionId: transactionId,
                  isExpense: transactionType == 'expense',
                  fromForm: false,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffe5ecdd),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Left side
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transactionName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.quicksand(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          paymentMethod,
                          style: GoogleFonts.quicksand(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    /// Right side
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${transactionType == "income" ? "+" : "-"}RM${totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.quicksand(
                            color: transactionType == "income"
                                ? const Color(0xff58c849)
                                : const Color(0xffcd5151),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (transactionType == "expense")
                          Text(
                            '+${carbon.toStringAsFixed(2)}kg C02e',
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

                const SizedBox(height: 6),

                /// Category labels
transactionType == "income"
    ? Label(
        color: getCategoryColor(income?.category ?? "Income"),
        icon: getCategoryIcon(income?.category ?? "Income"),
        text: income?.category ?? "Income",
      )
    : Wrap(
        spacing: 6,
        runSpacing: 3,
        children: {
          ...items.map((item) => item.category) // extract all categories
        }.map((category) => Label(
              color: getCategoryColor(category),
              icon: getCategoryIcon(category),
              text: category,
            )).toList(),
      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
