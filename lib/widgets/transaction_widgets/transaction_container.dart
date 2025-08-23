import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/models/income.dart';
import 'package:steadypunpipi_vhack/screens/transaction/transaction_details.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';
import 'package:steadypunpipi_vhack/utils/category_utils.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/label.dart';

class TransactionContainer extends StatefulWidget {
  final String transactionId;
  final String transactionType; // 'expense' or 'income'

  const TransactionContainer({
    super.key,
    required this.transactionId,
    required this.transactionType,
  });

  @override
  State<TransactionContainer> createState() => _TransactionContainerState();
}

class _TransactionContainerState extends State<TransactionContainer> {
  final DatabaseService db = DatabaseService();
  bool isLoading = true;
  bool isMounted = false;
  dynamic transaction; // Can be either Expense or Income
  List<ExpenseItem> expenseItems = [];
  Income? income;

  @override
  void initState() {
    super.initState();
    isMounted = true;
    initData();
  }

  void initData() async {
    if (widget.transactionType == 'expense') {
      await _fetchExpenses(widget.transactionId);
    } else {
      await _fetchIncome(widget.transactionId);
    }
    
    if (isMounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  Future<void> _fetchExpenses(String transactionId) async {
    if (isLoading) {
      final fetchedTransaction = await db.getExpense(transactionId);
      if (fetchedTransaction != null) {
        transaction = fetchedTransaction; // This is now guaranteed to be an Expense
        
        if (transaction.items != null && transaction.items!.isNotEmpty) {
          for (final itemRef in transaction.items!) {
            try {
              DocumentSnapshot<ExpenseItem> snapshot = await itemRef.get();
              ExpenseItem? item = snapshot.data();
              if (item != null) expenseItems.add(item);
            } catch (e) {
              print("Error fetching ExpenseItem (${itemRef.id}): $e");
            }
          }
        } else {
          print("Expense has no referenced items or is null.");
        }
      } else {
        print("No expense found for ID: $transactionId");
      }
    }
  }

  Future<void> _fetchIncome(String transactionId) async {
    if (isLoading) {
      print('🔍 DEBUG: Fetching income with ID: $transactionId');
      income = await db.getIncome(transactionId);
      if (income != null) {
        income!.id = transactionId; // Ensure ID is set
        transaction = income; // Set transaction to income for consistency
        print('🔍 DEBUG: Income loaded - Name: ${income!.transactionName}, Amount: ${income!.amount}, Category: ${income!.category}');
      } else {
        print('🔍 DEBUG: No income found for ID: $transactionId');
      }
    }
  }

  List<String> getUniqueCategories() {
    final categorySet = <String>{};
    for (final item in expenseItems) {
      if (item.category != null && item.category.isNotEmpty) {
        categorySet.add(item.category);
      }
    }
    return categorySet.toList();
  }

  Widget buildCategoryLabels() {
    if (widget.transactionType == 'income') {
      // For income, show category label
      return Label(
        color: getCategoryColor(income?.category ?? 'Income'),
        icon: getCategoryIcon(income?.category ?? 'Income'),
        text: income?.category ?? 'Income',
      );
    } else {
      // For expenses, show multiple category labels
      final categories = getUniqueCategories();
      return Wrap(
        spacing: 6,
        runSpacing: 3,
        children: categories.map((category) {
          return Label(
            color: getCategoryColor(category),
            icon: getCategoryIcon(category),
            text: category,
          );
        }).toList(),
      );
    }
  }

  double calculateTotalCost() {
    if (widget.transactionType == 'income') {
      return income?.amount ?? 0.0;
    } else {
      double totalCost = 0;
      for (final item in expenseItems) {
        totalCost += item.price;
      }
      return totalCost;
    }
  }

  String getTransactionName() {
    if (widget.transactionType == 'income') {
      final name = income?.transactionName ?? 'Income';
      print('🔍 DEBUG: Income transaction name: "$name"');
      return name;
    } else {
      // For expenses, safely access transactionName
      if (transaction is Expense) {
        final dbName = (transaction as Expense).transactionName;
        final firstItemName = expenseItems.isNotEmpty ? expenseItems[0].name : '';
        
        print('🔍 DEBUG: Expense transaction name check:');
        print('🔍 DEBUG:   - Database transactionName: "$dbName"');
        print('🔍 DEBUG:   - First item name: "$firstItemName"');
        
        if (dbName != null && dbName.isNotEmpty) {
          print('🔍 DEBUG: ✅ Using database transactionName: "$dbName"');
          return dbName;
        } else if (firstItemName.isNotEmpty) {
          print('🔍 DEBUG: ⚠️ Database name empty, using first item name: "$firstItemName"');
          return firstItemName;
        } else {
          print('🔍 DEBUG: ❌ No name available, using fallback');
          return "No Transaction Name";
        }
      }
      return "No Transaction Name"; // Fallback
    }
  }

  String getPaymentMethod() {
    if (widget.transactionType == 'income') {
      return income?.paymentMethod ?? 'Unknown';
    } else {
      // For expenses, safely access paymentMethod
      if (transaction is Expense) {
        return (transaction as Expense).paymentMethod ?? 'Unknown';
      }
      return 'Unknown'; // Fallback
    }
  }

  double getCarbonFootprint() {
    if (widget.transactionType == 'income') {
      return 0.0; // Income typically has no carbon footprint
    } else {
      // For expenses, safely access carbonFootprint
      if (transaction is Expense) {
        return (transaction as Expense).carbonFootprint ?? 0.0;
      }
      return 0.0; // Fallback
    }
  }

  Color getAmountColor() {
    return widget.transactionType == 'income' 
        ? Color(0xff58c849) // Green for income
        : Color(0xffcd5151); // Red for expense
  }

  String getAmountPrefix() {
    return widget.transactionType == 'income' ? '+' : '-';
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetails(
                    transactionId: widget.transactionId,
                    isExpense: widget.transactionType == 'expense',
                    fromForm: false,
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xffe5ecdd), // Original color for expense
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Allow left side to take available space
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            getTransactionName(),
                            style: GoogleFonts.quicksand(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            getPaymentMethod(),
                            style: GoogleFonts.quicksand(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                        ],
                      ),
                  
                      SizedBox(width: 12),
                  
                      /// Right side: total amount and carbon emission
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${getAmountPrefix()}RM${calculateTotalCost().toStringAsFixed(2)}',
                            style: GoogleFonts.quicksand(
                              color: getAmountColor(),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (widget.transactionType == 'expense') // Only show carbon for expenses
                            Text(
                              '+${getCarbonFootprint().toStringAsFixed(2)}kg C02e',
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
                  buildCategoryLabels(),
                ],
                
              ),
            ),
          );
  }
}
