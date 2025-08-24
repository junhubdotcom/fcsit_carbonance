import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/models/income.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/transaction_container.dart';

class TransactionList extends StatefulWidget {
  final List<DateTime> uniqueDates;
  final List<Expense>? filteredExpenses;
  final List<Income>? filteredIncomes;
  
  const TransactionList({
    super.key, 
    required this.uniqueDates,
    this.filteredExpenses,
    this.filteredIncomes,
  });

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
  void didUpdateWidget(TransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the filtered data has changed
    if (oldWidget.uniqueDates != widget.uniqueDates ||
        oldWidget.filteredExpenses != widget.filteredExpenses ||
        oldWidget.filteredIncomes != widget.filteredIncomes) {
      print('🔍 DEBUG: TransactionList data changed, updating...');
      setState(() {
        uniqueDates = widget.uniqueDates;
      });
    }
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
          filteredExpenses: widget.filteredExpenses,
          filteredIncomes: widget.filteredIncomes,
        );
      },
    );
  }
}

class _buildTransactionDay extends StatefulWidget {
  final DateTime date;
  final List<Expense>? filteredExpenses;
  final List<Income>? filteredIncomes;

  const _buildTransactionDay({
    required this.date,
    this.filteredExpenses,
    this.filteredIncomes,
  });

  @override
  State<_buildTransactionDay> createState() => _buildTransactionDayState();
}

class _buildTransactionDayState extends State<_buildTransactionDay> {
  bool isLoading = true;
  bool _isInitializing = false; // Flag to prevent multiple simultaneous initializations
  DatabaseService _databaseService = DatabaseService();
  String day = '';
  String month = '';
  late List<Expense> expenseList = [];
  late List<Income> incomeList = [];
  late List<Map<String, dynamic>> allTransactions = []; // Combined transactions
  
  // Summary values
  double dailyExpense = 0.0;
  double dailyIncome = 0.0;
  double dailyCarbon = 0.0;

  void initState() {
    super.initState();
    initData();
  }

  @override
  void didUpdateWidget(_buildTransactionDay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the filtered data has changed
    if (oldWidget.filteredExpenses != widget.filteredExpenses ||
        oldWidget.filteredIncomes != widget.filteredIncomes) {
      print('🔍 DEBUG: _buildTransactionDay data changed for date ${widget.date}, rebuilding...');
      // Use Future.microtask to avoid calling async method in sync context
      Future.microtask(() {
        if (mounted) {
          initData(); // Rebuild with new filtered data
        }
      });
    }
  }

  void initData() async {
    // Prevent multiple simultaneous initializations
    if (_isInitializing) {
      print('🔍 DEBUG: Already initializing, skipping...');
      return;
    }
    
    _isInitializing = true;
    
    try {
      day = DateFormat('dd').format(widget.date);
      month = DateFormat('MMMM').format(widget.date);
      
      print('🔍 DEBUG: Processing data for date: ${widget.date}');
      
      // Use filtered data if available, otherwise fetch from database
      if (widget.filteredExpenses != null && widget.filteredIncomes != null) {
        print('🔍 DEBUG: Using filtered data');
        expenseList = widget.filteredExpenses!.where((expense) {
          return _isSameDay(expense.dateTime.toDate(), widget.date);
        }).toList();
        
        incomeList = widget.filteredIncomes!.where((income) {
          return _isSameDay(income.dateTime.toDate(), widget.date);
        }).toList();
      } else {
        print('🔍 DEBUG: Fetching data from database');
        await getExpensesByDay(widget.date);
        await getIncomesByDay(widget.date);
      }
      
      print('🔍 DEBUG: Raw data - Expenses: ${expenseList.length}, Incomes: ${incomeList.length}');
      
      _combineAndSortTransactions();
      await _calculateSummaryValues();
      
      print('🔍 DEBUG: Processed - All transactions: ${allTransactions.length}');
      print('🔍 DEBUG: Summary - Income: $dailyIncome, Expense: $dailyExpense, Carbon: $dailyCarbon');
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> getExpensesByDay(DateTime targetDate) async {
    print('🔍 DEBUG: Fetching expenses for ${targetDate}');
    expenseList = await _databaseService.getExpensesByDay(targetDate);
    print('🔍 DEBUG: Found ${expenseList.length} expenses');
    
    // Debug each expense
    for (int i = 0; i < expenseList.length; i++) {
      final expense = expenseList[i];
      print('🔍 DEBUG: Expense $i - ID: ${expense.id}, Date: ${expense.dateTime}, Items: ${expense.items?.length ?? 0}');
    }
  }

  Future<void> getIncomesByDay(DateTime targetDate) async {
    print('🔍 DEBUG: Fetching incomes for ${targetDate}');
    incomeList = await _databaseService.getIncomesByDay(targetDate);
    print('🔍 DEBUG: Found ${incomeList.length} incomes');
    
    // Debug each income
    for (int i = 0; i < incomeList.length; i++) {
      final income = incomeList[i];
      print('🔍 DEBUG: Income $i - ID: ${income.id}, Date: ${income.dateTime}, Amount: ${income.amount}');
    }
  }

  void _combineAndSortTransactions() {
    allTransactions.clear();
    
    print('🔍 DEBUG: Combining transactions...');
    
    // Add expenses with type indicator
    for (final expense in expenseList) {
      allTransactions.add({
        'type': 'expense',
        'data': expense,
        'timestamp': expense.dateTime,
        'id': expense.id,
      });
      print('🔍 DEBUG: Added expense - ID: ${expense.id}, Date: ${expense.dateTime}');
    }
    
    // Add incomes with type indicator
    for (final income in incomeList) {
      allTransactions.add({
        'type': 'income',
        'data': income,
        'timestamp': income.dateTime,
        'id': income.id,
      });
      print('🔍 DEBUG: Added income - ID: ${income.id}, Date: ${income.dateTime}');
    }
    
    // Sort by timestamp (most recent first)
    allTransactions.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    
    print('🔍 DEBUG: Combined ${allTransactions.length} transactions');
  }

  Future<void> _calculateSummaryValues() async {
    print('🔍 DEBUG: Calculating summary values...');
    dailyExpense = await calculateDailyExpense();
    dailyIncome = await calculateDailyIncome();
    dailyCarbon = await calculateDailyCarbon();
    
    print('🔍 DEBUG: Summary calculated - Income: $dailyIncome, Expense: $dailyExpense, Carbon: $dailyCarbon');
  }

  Future<double> calculateDailyExpense() async {
    double total = 0.0;
    print('🔍 DEBUG: Calculating daily expense from ${expenseList.length} expenses');
    
    for (final expense in expenseList) {
      if (expense.items != null) {
        print('🔍 DEBUG: Processing expense ${expense.id} with ${expense.items!.length} items');
        for (final itemRef in expense.items!) {
          try {
            final snapshot = await itemRef.get();
            final item = snapshot.data() as ExpenseItem?;
            if (item != null) {
              print('🔍 DEBUG: Item - Name: ${item.name}, Price: ${item.price}, Quantity: ${item.quantity}');
              // Calculate total for this item (price * quantity)
              double itemTotal = item.price * (item.quantity ?? 1);
              total += itemTotal;
              print('🔍 DEBUG: Added item total: $itemTotal, Running total: $total');
            }
          } catch (e) {
            print("Error fetching item for expense: $e");
          }
        }
      }
    }
    print('🔍 DEBUG: Final daily expense total: $total');
    return total;
  }

  Future<double> calculateDailyIncome() async {
    double total = 0.0;
    print('🔍 DEBUG: Calculating daily income from ${incomeList.length} incomes');
    
    for (final income in incomeList) {
      try {
        if (income.amount != null && income.amount > 0) {
          total += income.amount!;
          print('🔍 DEBUG: Added income: ${income.amount}, Running total: $total');
        }
      } catch (e) {
        print("Error processing income: $e");
      }
    }
    print('🔍 DEBUG: Final daily income total: $total');
    return total;
  }

  Future<double> calculateDailyCarbon() async {
    double total = 0.0;
    print('🔍 DEBUG: Calculating daily carbon from ${expenseList.length} expenses');
    
    for (final expense in expenseList) {
      try {
        if (expense.carbonFootprint != null) {
          total += expense.carbonFootprint!;
          print('🔍 DEBUG: Added carbon: ${expense.carbonFootprint}, Running total: $total');
        }
      } catch (e) {
        print("Error processing carbon footprint: $e");
      }
    }
    print('🔍 DEBUG: Final daily carbon total: $total');
    return total;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                width: double.infinity,
                child: Row(
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
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              '+RM ${dailyIncome.toStringAsFixed(2)}',
                              style: GoogleFonts.quicksand(
                                  color: Color(0xff58c849),
                                  fontSize: MediaQuery.of(context).size.width * 0.035,
                                  fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '-RM ${dailyExpense.toStringAsFixed(2)}',
                              style: GoogleFonts.quicksand(
                                  color: Color(0xffcd5151),
                                  fontSize: MediaQuery.of(context).size.width * 0.035,
                                  fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '+${dailyCarbon.toStringAsFixed(1)}CO2e',
                              style: GoogleFonts.quicksand(
                                  fontSize: MediaQuery.of(context).size.width * 0.035,
                                  fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 25),
                    width: 2, // Keep the width fixed
                    height: allTransactions.isEmpty 
                        ? 100.0 // Minimum height when no transactions
                        : allTransactions.length * 90.0, // Height based on transaction count
                    color: Colors.grey.shade500,
                  ),
                  Expanded(
                    child: allTransactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No transactions for this day',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: allTransactions.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final transaction = allTransactions[index];
                              final transactionType = transaction['type'] as String;
                              final transactionId = transaction['id'] as String;
                              
                              print('🔍 DEBUG: Building transaction $index: type=$transactionType, id=$transactionId');
                              
                              if (transactionType == 'expense') {
                                return TransactionContainer(
                                  transactionId: transactionId,
                                  transactionType: 'expense',
                                );
                              } else {
                                // Handle income display
                                return TransactionContainer(
                                  transactionId: transactionId,
                                  transactionType: 'income',
                                );
                              }
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
