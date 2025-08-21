import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/utils/category_utils.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/label.dart';

class ItemContainer extends StatelessWidget {
  final bool isExpense;
  final dynamic transactionItem;
  
  const ItemContainer({
    required this.isExpense, 
    required this.transactionItem, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xffe5ecdd) , // Original green for expenses
        borderRadius: BorderRadius.circular(8)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Item name and category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  transactionItem.transactionName ,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w700, 
                    fontSize: 15
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Label(
                  color: getCategoryColor(transactionItem.category ?? 'Unknown'),
                  icon: getCategoryIcon(transactionItem.category ?? 'Unknown'),
                  text: transactionItem.category ?? 'Unknown',
                ),
              ],
            ),
          ),
          
          SizedBox(width: 12),
          
          // Middle: Quantity and price (for expenses only)
          if (isExpense && transactionItem.quantity != null && transactionItem.price != null)
            Text(
              '${transactionItem.quantity} x RM${transactionItem.price.toStringAsFixed(2)}',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w600, 
                fontSize: 14
              ),
            ),
          
          SizedBox(width: 12),
          
          // Right side: Total amount and carbon footprint
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                isExpense
                    ? '-RM${_calculateExpenseTotal().toStringAsFixed(2)}'
                    : '+RM${_calculateIncomeAmount().toStringAsFixed(2)}',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w600, 
                  fontSize: 14,
                  color: isExpense 
                      ? Color(0xffcd5151)  // Red for expenses
                      : Color(0xff58c849), // Green for income
                ),
              ),
              // if (isExpense && transactionItem.carbon_footprint != null)
              //   Text(
              //     '+${transactionItem.carbon_footprint.toStringAsFixed(2)}kg CO2e',
              //     style: GoogleFonts.quicksand(
              //       fontWeight: FontWeight.w600, 
              //       fontSize: 13,
              //       color: Colors.black87,
              //     ),
              //   ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateExpenseTotal() {
    if (transactionItem.quantity != null && transactionItem.price != null) {
      return transactionItem.price * transactionItem.quantity;
    }
    return transactionItem.price ?? 0.0;
  }

  double _calculateIncomeAmount() {
    return transactionItem.amount ?? 0.0;
  }
}
