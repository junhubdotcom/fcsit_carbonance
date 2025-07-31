import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp, DocumentReference;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/screens/transaction/filter.dart';
import 'package:steadypunpipi_vhack/screens/transaction/record_transaction.dart';
import 'package:steadypunpipi_vhack/screens/transaction/scanner.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/indicator.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/transaction_list.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool isLoading = true;
  DatabaseService _databaseService = DatabaseService();
  late List<Expense> transactionList;
  late List<DateTime> uniqueDates;
  // Color getCategoryColor(String category) {
  //   switch (category) {
  //     case 'Food':
  //       return Colors.redAccent;
  //     case 'Housing':
  //       return Colors.indigoAccent;
  //     case 'Debt Repayment':
  //       return Colors.deepOrangeAccent;
  //     case 'Medical':
  //       return Colors.greenAccent;
  //     case 'Transport':
  //       return Colors.blueAccent;
  //     case 'Utilities':
  //       return Colors.amberAccent;
  //     case 'Shopping':
  //       return Colors.purpleAccent;
  //     case 'Tax':
  //       return Colors.brown;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  void initData() async {
    await getAllExpenses();
    // DateTime targetDate = DateTime.parse("2025-04-04 00:00:00.000");
    // await getExpensesByDay(targetDate);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getAllExpenses() async {
    transactionList = await _databaseService.getAllExpenses();
    if (transactionList.isNotEmpty) {
      final Set<DateTime> dateSet = {};
      for (var transaction in transactionList) {
        Timestamp timestamp = transaction.dateTime;
        DateTime dateTime = timestamp.toDate();
        dateSet.add(DateTime(dateTime.year, dateTime.month,
            dateTime.day)); // Only keep the date part
      }
      uniqueDates = dateSet.toList()
        ..sort(
            (a, b) => b.compareTo(a)); // Sort unique dates in descending order
      // Debug print unique dates
    } else {
      print("No expenses found.");
    }
  }

  String displayMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  DateTime selectedMonth = DateTime.now();
  String formattedMonth = '';

  void selectMonth() {
    showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
      monthPickerDialogSettings: MonthPickerDialogSettings(
          headerSettings: PickerHeaderSettings(
              headerBackgroundColor: Colors.green.shade300,
              headerSelectedIntervalTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
              headerCurrentPageTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 23,
                  fontWeight: FontWeight.w600)),
          dialogSettings: PickerDialogSettings(
              dialogRoundedCornersRadius: 10,
              dialogBackgroundColor: Colors.white),
          dateButtonsSettings: PickerDateButtonsSettings(
              selectedMonthTextColor: Colors.white,
              unselectedMonthsTextColor: Colors.black,
              selectedMonthBackgroundColor: Colors.green.shade300),
          actionBarSettings: PickerActionBarSettings(
            confirmWidget: Text(
              'ok',
              style: TextStyle(color: Colors.black),
            ),
            cancelWidget: Text(
              'cancel',
              style: TextStyle(color: Colors.black),
            ),
          )),
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedMonth = date;
          formattedMonth = DateFormat('MMMM yyyy').format(selectedMonth);
          displayMonth = formattedMonth;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        buttonSize: Size(60, 60),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        overlayColor: Colors.black,
        childrenButtonSize: Size(70, 70),
        overlayOpacity: 0.4,
        spacing: 12,
        spaceBetweenChildren: 12,
        closeManually: false,
        children: [
          SpeedDialChild(
            child: Icon(
              Icons.edit,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RecordTransaction()));
            },
            shape: CircleBorder(),
            backgroundColor: Color(0xff92b977),
          ),
          SpeedDialChild(
            child: Icon(
              Icons.document_scanner_rounded,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Scanner()));
            },
            shape: CircleBorder(),
            backgroundColor: Color(0xff92b977),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          'Transaction',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Filter()));
                // showModalBottomSheet(
                //   isScrollControlled: true,
                //   context: context,
                //   builder: (context) => buildSheet(),
                // );
              },
              icon: Icon(Icons.filter_alt_outlined))
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : transactionList.isEmpty
              ? Center(child: Text('No transactions found.'))
              : Center(
                  child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Indicator(title: 'Income', value: 'RM 1000.00'),
                                SizedBox(
                                  height: 5,
                                ),
                                Indicator(
                                    title: 'Expenses', value: 'RM 900.00'),
                                SizedBox(
                                  height: 5,
                                ),
                                Indicator(
                                    title: 'Carbon Footprint',
                                    value: '500 CO2e'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Image.asset(
                              'assets/images/girl_tree.png',
                              // fit: BoxFit.cover,
                              width: MediaQuery.sizeOf(context).width * 0.50,
                              height: MediaQuery.sizeOf(context).height * 0.20,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 26,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          selectMonth();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0XFFE5ECDD),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)))),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                displayMonth,
                                style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                              Expanded(
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  size: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SearchBar(
                          leading: Icon(Icons.search),
                          hintText: 'Search',
                          constraints:
                              BoxConstraints(minHeight: 45, maxHeight: 45),
                          elevation: WidgetStatePropertyAll(0),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)))),
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                TransactionList(
                                  uniqueDates: uniqueDates,
                                ),
                              ],
                            )),
                      )
                    ],
                  ),
                )),
    );
  }

  // Widget buildSheet() {
  //   return StatefulBuilder(builder: (context, setStateSheet) {
  //     return Container(
  //         width: double.infinity,
  //         height: MediaQuery.of(context).size.height * 0.90,
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //           child: Column(mainAxisSize: MainAxisSize.max, children: [
  //             Row(
  //               mainAxisSize: MainAxisSize.max,
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 IconButton(
  //                   icon: Icon(Icons.close_rounded),
  //                   iconSize: 35,
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                 ),
  //               ],
  //             ),
  //             SmallTitle(title: "Date"),
  //             SmallTitle(title: "Category"),
  //             Wrap(
  //               alignment: WrapAlignment.start,
  //               spacing: 10,
  //               runSpacing: 5,
  //               children: categories.map((category) {
  //                 final isSelected = selectedCategories.contains(category);

  //                 return FilterChip(
  //                     // padding:
  //                     //     EdgeInsets.symmetric(horizontal: 13, vertical: 8),
  //                     label: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Icon(
  //                           getCategoryIcon(category),
  //                           size: 20,
  //                         ),
  //                         SizedBox(
  //                           width: 5,
  //                         ),
  //                         Text(category),
  //                       ],
  //                     ),
  //                     // avatar: Icon(
  //                     //   getCategoryIcon(category),
  //                     //   size: 20,
  //                     // ),
  //                     selected: isSelected,
  //                     showCheckmark: false,
  //                     onSelected: (bool selected) {
  //                       setStateSheet(() {
  //                         if (selected) {
  //                           selectedCategories.add(category);
  //                         } else {
  //                           selectedCategories.remove(category);
  //                         }
  //                       });
  //                     });
  //               }).toList(),
  //             ),
  //             SmallTitle(title: "Transaction Type"),
  //             SmallTitle(title: "Payment Method"),
  //             SmallTitle(title: "Amount Method"),
  //           ]),
  //         ));
  //   });
  // }
}
