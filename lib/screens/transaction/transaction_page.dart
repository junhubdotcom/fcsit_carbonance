import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp, DocumentReference;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/income.dart';
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
  late List<Income> incomeList;
  late List<DateTime> uniqueDates;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double totalCarbonFootprint = 0.0;
  double dailyIncome = 0.0;
  double dailyExpense = 0.0;
  double dailyCarbonFootprint = 0.0;

  // Search functionality
  String searchQuery = '';
  List<Expense> filteredExpenses = [];
  List<Income> filteredIncomes = [];
  List<DateTime> filteredUniqueDates = [];
  late TextEditingController _searchController;
  
  // Month filtering functionality
  DateTime? selectedMonth; // Null initially to show empty dropdown
  String displayMonth = ''; // Empty initially
  String formattedMonth = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchController = TextEditingController();
    initData();
  }

 void initData() async {
  await getAllExpenses();
  await getAllIncomes();

  // ✅ Combine unique dates from both expenses and incomes
  final Set<DateTime> dateSet = {};

  for (var transaction in transactionList) {
    Timestamp timestamp = transaction.dateTime;
    DateTime dateTime = timestamp.toDate();
    dateSet.add(DateTime(dateTime.year, dateTime.month, dateTime.day));
  }

  for (var income in incomeList) {
    Timestamp timestamp = income.dateTime;
    DateTime dateTime = timestamp.toDate();
    dateSet.add(DateTime(dateTime.year, dateTime.month, dateTime.day));
  }

  uniqueDates = dateSet.toList()
    ..sort((a, b) => b.compareTo(a)); // Descending

  if (transactionList.isNotEmpty || incomeList.isNotEmpty) {
    await getTotal();
  }

  // Initialize filtered lists to show all transactions by default
  filteredExpenses = List.from(transactionList);
  filteredIncomes = List.from(incomeList);
  filteredUniqueDates = List.from(uniqueDates);

  if (mounted) {
    setState(() {
      isLoading = false;
    });
  }
  
  // Apply month filtering after data is loaded
  if (selectedMonth != null) {
    _applyMonthFilter();
  }
}


  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
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
   Future<void> getAllIncomes() async {
    incomeList = await _databaseService.getAllIncomes();
    if (incomeList.isNotEmpty) {
      final Set<DateTime> dateSet = {};
      for (var income in incomeList) {
        Timestamp timestamp = income.dateTime;
        DateTime dateTime = timestamp.toDate();
        dateSet.add(DateTime(dateTime.year, dateTime.month,
            dateTime.day)); // Only keep the date part
      }
      uniqueDates = dateSet.toList()
        ..sort(
            (a, b) => b.compareTo(a)); // Sort unique dates in descending order
      // Debug print unique dates
    } else {
      print("No incomes found.");
    }
  }

  Future<void> getTotal() async {
    totalIncome = getTotalIncome(incomeList);
    totalExpense = await getTotalExpense(transactionList);
    totalCarbonFootprint = getTotalCarbonFootprint(transactionList);

  }

  void selectMonth() {
    showMonthPicker(
      context: context,
      initialDate: selectedMonth ?? DateTime.now(),
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
          formattedMonth = DateFormat('MMMM yyyy').format(selectedMonth!);
          displayMonth = formattedMonth;
        });
        
        // Apply month filtering after month selection
        _applyMonthFilter();
        
        // Clear search when month changes
        if (searchQuery.isNotEmpty) {
          _searchController.clear();
          searchQuery = '';
        }
        
        print('🔍 DEBUG: Month selected: ${DateFormat('MMMM yyyy').format(selectedMonth!)}');
      }
    });
  }

  double getTotalIncome(List<Income> incomeList) {
  return incomeList.fold(0.0, (sum, e) => sum + (e.amount ?? 0));
}

Future<double> getTotalExpense(List<Expense> expenses) async {
  double total = 0.0;

  for (final expense in expenses) {
    for (final itemRef in expense.items) {
      try {
        final snapshot = await itemRef.get();
        final item = snapshot.data();
        if (item != null) {
          total += item.price ?? 0.0;
        }
      } catch (e) {
        print("Error fetching item from ${itemRef.id}: $e");
      }
    }
  }

  return total;
}


double getTotalCarbonFootprint(List<Expense> expenseList) {
  final double expenseCarbon = expenseList.fold(0.0, (sum, e) => sum + (e.carbonFootprint ?? 0));
  return expenseCarbon;
}

double getDailyIncome(List<Income> incomeList, DateTime date) {
  return incomeList
      .where((e) => _isSameDay(e.dateTime.toDate(), date))
      .fold(0.0, (sum, e) => sum + (e.amount ?? 0));
}

Future<double> getDailyExpense(List<Expense> expenses, DateTime date) async {
  double total = 0.0;

  for (final expense in expenses) {
    if (_isSameDay(expense.dateTime.toDate(), date)) {
      for (final itemRef in expense.items) {
        try {
          final snapshot = await itemRef.get();
          final item = snapshot.data();
          if (item != null) {
            total += item.price ?? 0.0;
          }
        } catch (e) {
          print("Error fetching item from ${itemRef.id}: $e");
        }
      }
    }
  }

  return total;
}


double getDailyCarbonFootprint(List<Expense> incomeList, List<Expense> expenseList, DateTime date) {
  final double incomeCarbon = incomeList
      .where((e) => _isSameDay(e.dateTime.toDate(), date))
      .fold(0.0, (sum, e) => sum + (e.carbonFootprint ?? 0));

  final double expenseCarbon = expenseList
      .where((e) => _isSameDay(e.dateTime.toDate(), date))
      .fold(0.0, (sum, e) => sum + (e.carbonFootprint ?? 0));

  return incomeCarbon + expenseCarbon;
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool _isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

// Month filtering functionality
void _applyMonthFilter() {
  print('🔍 DEBUG: Applying month filter for: ${selectedMonth != null ? DateFormat('MMMM yyyy').format(selectedMonth!) : "No month selected"}');
  
  setState(() {
    if (selectedMonth == null) {
      // No month selected, show all transactions
      filteredExpenses = List.from(transactionList);
      filteredIncomes = List.from(incomeList);
      print('🔍 DEBUG: No month selected, showing all transactions');
    } else {
      // Filter expenses by month
      filteredExpenses = transactionList.where((expense) {
        return _isSameMonth(expense.dateTime.toDate(), selectedMonth!);
      }).toList();
      
      // Filter incomes by month
      filteredIncomes = incomeList.where((income) {
        return _isSameMonth(income.dateTime.toDate(), selectedMonth!);
      }).toList();
      
      print('🔍 DEBUG: Month filter results - Expenses: ${filteredExpenses.length}, Incomes: ${filteredIncomes.length}');
    }
    
    // Update filtered unique dates based on month-filtered transactions
    final Set<DateTime> filteredDateSet = {};
    
    for (var transaction in filteredExpenses) {
      if (transaction.dateTime != null) {
        Timestamp timestamp = transaction.dateTime;
        DateTime dateTime = timestamp.toDate();
        filteredDateSet.add(DateTime(dateTime.year, dateTime.month, dateTime.day));
      }
    }
    
    for (var income in filteredIncomes) {
      if (income.dateTime != null) {
        Timestamp timestamp = income.dateTime;
        DateTime dateTime = timestamp.toDate();
        filteredDateSet.add(DateTime(dateTime.year, dateTime.month, dateTime.day));
      }
    }
    
    filteredUniqueDates = filteredDateSet.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending
      
    print('🔍 DEBUG: Month-filtered unique dates: ${filteredUniqueDates.length}');
  });
}

// Search functionality
void _filterTransactions(String query) {
  print('🔍 DEBUG: Searching for: "$query"');
  print('🔍 DEBUG: Total expenses: ${transactionList.length}, Total incomes: ${incomeList.length}');
  
  // Debug: Print all transaction names for inspection
  print('🔍 DEBUG: All expense names:');
  for (int i = 0; i < transactionList.length; i++) {
    final expense = transactionList[i];
    print('🔍 DEBUG: Expense $i: "${expense.transactionName}" (ID: ${expense.id})');
    print('🔍 DEBUG:   - Database transactionName: "${expense.transactionName}"');
    print('🔍 DEBUG:   - transactionName length: ${expense.transactionName?.length ?? 0}');
    print('🔍 DEBUG:   - transactionName is empty: ${expense.transactionName?.isEmpty ?? true}');
    print('🔍 DEBUG:   - transactionName is null: ${expense.transactionName == null}');
  }
  
  print('🔍 DEBUG: All income names:');
  for (int i = 0; i < incomeList.length; i++) {
    final income = incomeList[i];
    print('🔍 DEBUG: Income $i: "${income.transactionName}" (ID: ${income.id})');
    print('🔍 DEBUG:   - Database transactionName: "${income.transactionName}"');
    print('🔍 DEBUG:   - transactionName length: ${income.transactionName?.length ?? 0}');
    print('🔍 DEBUG:   - transactionName is empty: ${income.transactionName?.isEmpty ?? true}');
    print('🔍 DEBUG:   - transactionName is null: ${income.transactionName == null}');
  }
  
  setState(() {
    searchQuery = query;
    
    if (query.isEmpty) {
      // Show all transactions for the selected month when search is empty
      _applyMonthFilter(); // This will filter by month only
      print('🔍 DEBUG: Search cleared, showing all transactions for selected month');
    } else {
      // Filter by both search term AND month
      filteredExpenses = transactionList.where((expense) {
        final name = expense.transactionName?.toLowerCase() ?? '';
        final searchTerm = query.toLowerCase();
        final matchesSearch = name.contains(searchTerm);
        final matchesMonth = selectedMonth == null || _isSameMonth(expense.dateTime.toDate(), selectedMonth!);
        
        print('🔍 DEBUG: Checking expense "${expense.transactionName}":');
        print('🔍 DEBUG:   - Original name: "${expense.transactionName}"');
        print('🔍 DEBUG:   - Lowercase name: "$name"');
        print('🔍 DEBUG:   - Search term: "$searchTerm"');
        print('🔍 DEBUG:   - Search match: $matchesSearch');
        print('🔍 DEBUG:   - Month match: $matchesMonth');
        
        return matchesSearch && matchesMonth;
      }).toList();
      
      filteredIncomes = incomeList.where((income) {
        final name = income.transactionName?.toLowerCase() ?? '';
        final searchTerm = query.toLowerCase();
        final matchesSearch = name.contains(searchTerm);
        final matchesMonth = selectedMonth == null || _isSameMonth(income.dateTime.toDate(), selectedMonth!);
        
        print('🔍 DEBUG: Checking income "${income.transactionName}":');
        print('🔍 DEBUG:   - Original name: "${income.transactionName}"');
        print('🔍 DEBUG:   - Lowercase name: "$name"');
        print('🔍 DEBUG:   - Search term: "$searchTerm"');
        print('🔍 DEBUG:   - Search match: $matchesSearch');
        print('🔍 DEBUG:   - Month match: $matchesMonth');
        
        return matchesSearch && matchesMonth;
      }).toList();
      
      print('🔍 DEBUG: Combined search + month filter results - Expenses: ${filteredExpenses.length}, Incomes: ${filteredIncomes.length}');
      
      // Update filtered unique dates based on search + month filtered transactions
      final Set<DateTime> filteredDateSet = {};
      
      for (var transaction in filteredExpenses) {
        if (transaction.dateTime != null) {
          Timestamp timestamp = transaction.dateTime;
          DateTime dateTime = timestamp.toDate();
          filteredDateSet.add(DateTime(dateTime.year, dateTime.month, dateTime.day));
        }
      }
      
      for (var income in filteredIncomes) {
        if (income.dateTime != null) {
          Timestamp timestamp = income.dateTime;
          DateTime dateTime = timestamp.toDate();
          filteredDateSet.add(DateTime(dateTime.year, dateTime.month, dateTime.day));
        }
      }
      
      filteredUniqueDates = filteredDateSet.toList()
        ..sort((a, b) => b.compareTo(a)); // Descending
        
      print('🔍 DEBUG: Search + month filtered unique dates: ${filteredUniqueDates.length}');
    }
    
    print('🔍 DEBUG: Search query: "$searchQuery", Month: ${selectedMonth != null ? DateFormat('MMMM yyyy').format(selectedMonth!) : "No month selected"}');
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
        automaticallyImplyLeading: false, // Remove default back button
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
          : transactionList.isEmpty && incomeList.isEmpty
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
                                Indicator(title: 'Income', value: 'RM ${totalIncome.toStringAsFixed(2)}'),
                                SizedBox(
                                  height: 5,
                                ),
                                Indicator(
                                    title: 'Expenses', value: 'RM ${totalExpense.toStringAsFixed(2)}'),
                                SizedBox(
                                  height: 5,
                                ),
                                Indicator(
                                    title: 'Carbon Footprint',
                                    value: '${totalCarbonFootprint.toStringAsFixed(2)} CO2e'),
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
                        onLongPress: () {
                          // Reset to no month filter on long press
                          setState(() {
                            selectedMonth = null;
                            displayMonth = '';
                          });
                          _applyMonthFilter();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Month filter cleared'),
                              duration: Duration(seconds: 1),
                              backgroundColor: Colors.green,
                            ),
                          );
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
                                displayMonth.isEmpty ? 'Select Month' : displayMonth,
                                style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: displayMonth.isEmpty ? Colors.grey : Colors.black),
                              ),
                              Expanded(
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  size: 20,
                                  color: displayMonth.isEmpty ? Colors.grey : Colors.black,
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
                          hintText: 'Search transactions...',
                          constraints:
                              BoxConstraints(minHeight: 45, maxHeight: 45),
                          elevation: WidgetStatePropertyAll(0),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                          onChanged: _filterTransactions, // Add search functionality
                          controller: _searchController, // Use the managed controller
                          trailing: searchQuery.isNotEmpty ? [
                            IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterTransactions('');
                              },
                            )
                          ] : null,
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      //trasaction list
                      Expanded(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                // Month filter indicator
                                if (selectedMonth != null)
                                  Container(
                                    margin: EdgeInsets.only(bottom: 16),
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 98, 181, 75),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Filtered: ${DateFormat('MMMM yyyy').format(selectedMonth!)}',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedMonth = null;
                                              displayMonth = '';
                                            });
                                            _applyMonthFilter();
                                          },
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Show "no transactions found" message when search has no results
                                if (searchQuery.isNotEmpty && filteredExpenses.isEmpty && filteredIncomes.isEmpty)
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'No transactions found matching "$searchQuery"',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Try searching for a different term',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (selectedMonth != null && filteredExpenses.isEmpty && filteredIncomes.isEmpty)
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'No transactions found for ${DateFormat('MMMM yyyy').format(selectedMonth!)}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Try selecting a different month',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  TransactionList(
                                    uniqueDates: filteredUniqueDates.isNotEmpty ? filteredUniqueDates : uniqueDates,
                                    filteredExpenses: filteredExpenses.isNotEmpty ? filteredExpenses : transactionList,
                                    filteredIncomes: filteredIncomes.isNotEmpty ? filteredIncomes : incomeList,
                                  ),
                              ],
                            )),
                      )
                    ],
                  ),
                )),
    );
  }

}
