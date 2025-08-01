import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/transaction_container.dart';

class TransactionList extends StatefulWidget {
  final List<DateTime> uniqueDates;
  const TransactionList({super.key, required this.uniqueDates});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  bool _isLoading = true;
  late List<DateTime> uniqueDates;

  @override
  void initState() {
    super.initState();
    uniqueDates = widget.uniqueDates;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.uniqueDates.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final date = widget.uniqueDates[index];
        return _buildTransactionDay(
          date: date,
        );
      },
    );
  }
}

class _buildTransactionDay extends StatefulWidget {
  final DateTime date;

  const _buildTransactionDay({
    required this.date,
  });

  @override
  State<_buildTransactionDay> createState() => _buildTransactionDayState();
}

class _buildTransactionDayState extends State<_buildTransactionDay> {
  bool isLoading = true;
  DatabaseService _databaseService = DatabaseService();
  late final String day;
  late final String month;
  late List<Expense> transactionList = [];

  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    day = DateFormat('dd').format(widget.date);
    month = DateFormat('MMMM').format(widget.date);
    await getExpensesByDay(widget.date);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getExpensesByDay(DateTime targetDate) async {
    transactionList = await _databaseService.getExpensesByDay(targetDate);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: GoogleFonts.quicksand(
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        month,
                        style: GoogleFonts.quicksand(
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '+RM 10.00',
                        style: GoogleFonts.quicksand(
                            color: Color(0xff58c849),
                            fontSize: MediaQuery.of(context).size.width * 0.040,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '-RM50.00',
                        style: GoogleFonts.quicksand(
                            color: Color(0xffcd5151),
                            fontSize: MediaQuery.of(context).size.width * 0.040,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '+26CO2e',
                        style: GoogleFonts.quicksand(
                            fontSize: MediaQuery.of(context).size.width * 0.040,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 25),
                    width: 2, // Keep the width fixed
                    height: transactionList.length * 90.0,
                    color: Colors.grey.shade500,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: transactionList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final Expense currentExpense = transactionList[index];
                        return TransactionContainer(
                          transactionId: currentExpense.id ?? "",
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              )
            ],
          );
  }
}
