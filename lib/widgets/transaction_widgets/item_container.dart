import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/label.dart';

class ItemContainer extends StatelessWidget {
  bool isExpense;
  dynamic transactionItem;
  ItemContainer(
      {required this.isExpense, required this.transactionItem, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Color(0xffe5ecdd), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                transactionItem.name,
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
              Label(),
            ],
          ),
          isExpense
              ? Text(
                  '${transactionItem.quantity} x RM${transactionItem.price.toStringAsFixed(2)}',
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w600, fontSize: 14),
                )
              : SizedBox(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                isExpense
                    ? '-RM${(transactionItem.price * transactionItem.quantity).toStringAsFixed(2)}'
                    : '+RM${transactionItem.amount.toStringAsFixed(2)}',
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              isExpense
                  ? Text(
                      '+${transactionItem.carbon_footprint.toStringAsFixed(2)}kg CO2e',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    )
                  : SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}
