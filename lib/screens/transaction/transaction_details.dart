import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:steadypunpipi_vhack/main.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/screens/transaction/transaction_page.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/description.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/details_button.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/image_display_widget.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/item_container.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/small_title.dart';

class TransactionDetails extends StatefulWidget {
  String transactionId;
  bool isExpense;
  bool fromForm;
  TransactionDetails(
      {required this.transactionId,
      required this.isExpense,
      required this.fromForm,
      super.key});

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  bool isLoading = true;
  bool _isProcessing = false; // Add loading state
  DatabaseService db = DatabaseService();
  late dynamic transaction;
  List<ExpenseItem> expenseItems = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    await _fetchAndPrintExpenses(widget.transactionId);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchAndPrintExpenses(String transactionId) async {
    print("Fetching expenses...");
    if (widget.isExpense) {
      transaction = await db.getExpense(transactionId);
      /***If Print all items ***/
      if (transaction?.items != null && transaction!.items!.isNotEmpty) {
        for (final itemRef in transaction.items!) {
          try {
            DocumentSnapshot<ExpenseItem> snapshot = await itemRef.get();
            ExpenseItem? item = snapshot.data();
            expenseItems.add(item!);
          } catch (e) {
            print("Error fetching ExpenseItem (${itemRef.id}): $e");
          }
        }
      } else {
        print("Expense has no referenced items or is null.");
      }
    } else {
      transaction = await db.getIncome(transactionId);
      if (transaction != null) {
        print(transaction);
      } else {
        print("Income not found.");
      }
    }
  }

  double calculateTotalCost() {
    double totalCost = 0;
    for (int i = 0; i < expenseItems.length; i++) {
      totalCost += expenseItems[i].price;
    }
    return totalCost;
  }

  // double calculateTotalCarbonFootprint() {
  //   double totalCarbonFootprint = 0;
  //   for (int i = 0; i < expenseItems.length; i++) {
  //     totalCarbonFootprint += expenseItems[i].carbon_footprint;
  //   }
  //   return totalCarbonFootprint;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction Details',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 26),
                            decoration: BoxDecoration(
                                color: Color(0XFFE6E6E6),
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.isExpense
                                            ? transaction.transactionName != ""
                                                ? transaction.transactionName
                                                    .toString()
                                                : expenseItems.first.name
                                                    .toString()
                                            : transaction.transactionName,
                                        style: GoogleFonts.quicksand(
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.055)),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            widget.isExpense
                                                ? '-RM${calculateTotalCost().toStringAsFixed(2)}'
                                                : '+RM${transaction.amount.toStringAsFixed(2)}',
                                            style: GoogleFonts.quicksand(
                                                textStyle: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.04))),
                                        widget.isExpense
                                            ? Text(
                                                '+${transaction.carbonFootprint.toStringAsFixed(2)}kg C02e',
                                                style: GoogleFonts.quicksand(
                                                  textStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.035),
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    )
                                  ],
                                ),
                                Description(
                                    icon: Icons.wallet,
                                    text: transaction.paymentMethod),
                                Description(
                                    icon: Icons.watch_later,
                                    text: DateFormat('dd MMMM yyyy HH:mm')
                                        .format(transaction.dateTime.toDate())),
                                Description(
                                    icon: Icons.place,
                                    text: transaction.location.toString()),
                              ],
                            ),
                          ),
                          SmallTitle(title: "Item"),
                          widget.isExpense
                              ? ListView.builder(
                                  itemCount: expenseItems.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ItemContainer(
                                      transactionItem: expenseItems[index],
                                      isExpense: widget.isExpense,
                                    );
                                  },
                                )
                              : ItemContainer(
                                  transactionItem: transaction,
                                  isExpense: widget.isExpense,
                                ),
                          SmallTitle(
                              title: widget.isExpense
                                  ? "Receipt"
                                  : "Proof Of Income"),
                          ImageDisplayWidget(
                              imgPath: widget.isExpense ? "" : ""),
                          // ? transaction.receiptImagePath ?? ""
                          // : transaction.proofOfIncome ?? ""),

                          // Remove this column when it is income
                          widget.isExpense
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SmallTitle(title: "Image"),
                                    ImageDisplayWidget(
                                        imgPath:
                                            // transaction.additionalImagePath ??
                                            ""),
                                  ],
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: widget.fromForm
                      ? DetailsButton(
                          textColor: 0xff000000,
                          buttonColor: _isProcessing ? 0xff999999 : 0xff999974c95c, // Change color when processing
                          button_text: _isProcessing ? "Processing..." : "Done",
                          onPressed: () {
                            if (_isProcessing) return; // Don't process if already processing
                            if (!mounted) return; // Safety check
                            
                            setState(() {
                              _isProcessing = true; // Set processing state
                            });
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainScreen()),
                            );
                          })
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            DetailsButton(
                                textColor: 0xffe6e6e6,
                                buttonColor: 0xff999999,
                                button_text: "Delete",
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            DetailsButton(
                                textColor: 0xff000000,
                                buttonColor: 0xff999974c95c,
                                button_text: "Edit",
                                onPressed: () {})
                          ],
                        ),
                )
              ],
            ),
    );
  }
}
