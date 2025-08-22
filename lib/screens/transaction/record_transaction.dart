import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:steadypunpipi_vhack/models/complete_expense.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/models/income.dart';
import 'package:steadypunpipi_vhack/screens/transaction/scanner.dart';
import 'package:steadypunpipi_vhack/screens/transaction/transaction_details.dart';
import 'package:steadypunpipi_vhack/services/carbon_service.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/Itembutton.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/details_button.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/image_upload.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/item_list.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/record_transaction_dropdown.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/item_header.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/small_title.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/transaction_button.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/transaction_textfield.dart';

class RecordTransaction extends StatefulWidget {
  // Expense? expense;
  CompleteExpense? completeExpense;
  RecordTransaction({this.completeExpense, super.key});

  @override
  State<RecordTransaction> createState() => _RecordTransactionState();
}

class _RecordTransactionState extends State<RecordTransaction> {
  late bool isExpense;
  late bool isMultipleItem;
  bool _isProcessing = false; // Add loading state

  // can be expense and also income, depends on the button that user clicked
  late dynamic transaction;
  late List<ExpenseItem> expenseItems;

  String expenseRefId = "";
  String incomeRefId = "";

  // String? receipt;
  // String? thing_image;
  // String? proofOfIncome;

  String category_dropdown_value = "Food";

  @override
  void initState() {
    super.initState();
    isExpense = true;
    
    // Debug: Check what completeExpense contains
    if (widget.completeExpense != null) {
      print('🔍 DEBUG: completeExpense received:');
      print('🔍 DEBUG: - generalDetails: ${widget.completeExpense!.generalDetails.transactionName}');
      print('🔍 DEBUG: - items count: ${widget.completeExpense!.items.length}');
      for (int i = 0; i < widget.completeExpense!.items.length; i++) {
        final item = widget.completeExpense!.items[i];
        print('🔍 DEBUG: - Item $i: ${item.name} (${item.category}) x${item.quantity} @RM${item.price}');
      }
    } else {
      print('🔍 DEBUG: No completeExpense provided');
    }
    
    transaction = isExpense
        ? widget.completeExpense?.generalDetails ?? Expense()
        : Income();
    
    // Initialize expenseItems from scanned receipt data
    if (widget.completeExpense != null && widget.completeExpense!.items.isNotEmpty) {
      // Use the scanned items from the receipt
      expenseItems = List<ExpenseItem>.from(widget.completeExpense!.items);
      print('🔍 DEBUG: Loaded ${expenseItems.length} scanned items from receipt');
      for (int i = 0; i < expenseItems.length; i++) {
        print('🔍 DEBUG: Item $i - Name: ${expenseItems[i].name}, Category: ${expenseItems[i].category}, Quantity: ${expenseItems[i].quantity}, Price: ${expenseItems[i].price}');
      }
      isMultipleItem = expenseItems.length > 1;
    } else {
      // Initialize with a single empty item if no scanned data
      expenseItems = [ExpenseItem(
        name: '',
        category: 'Food',
        quantity: 1,
        price: 0.0,
      )];
      isMultipleItem = false;
    }
    
    print('🔍 DEBUG: Final expenseItems count: ${expenseItems.length}, isMultipleItem: $isMultipleItem');
  }

  CarbonService carbonService = CarbonService();
  DatabaseService db = DatabaseService();

  Future pickImage(ImageSource source, bool isReceipt) async {
    try {
      XFile? image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      setState(() {
        if (isExpense) {
          if (isReceipt) {
            // receipt = image.path;
            transaction.receiptImagePath = image.path;
          } else {
            // thing_image = image.path;
            transaction.additionalImagePath = image.path;
          }
        } else {
          // proofOfIncome = image.path;
          transaction.proofOfIncome = image.path;
        }
      });
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
    Navigator.pop(context);
  }

  Future pickDateTime() async {
    DateTime? date = await pickDate();
    if (date == null) return;
    TimeOfDay? time = await pickTime();
    if (time == null) return;
    final newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      transaction.dateTime = Timestamp.fromDate(newDateTime);
    });
  }

  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: transaction.dateTime.toDate(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );

  Future<TimeOfDay?> pickTime() => showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: transaction.dateTime.toDate().hour,
        minute: transaction.dateTime.toDate().minute,
      ));

  Future<DocumentReference<Expense>> saveExpense(
      Expense expense, List<ExpenseItem> items) async {
    try {
      List<DocumentReference<ExpenseItem>> itemRefs = [];
      print("ExpenseItems: $items");
      for (ExpenseItem item in items) {
        final ref = await db.addExpenseItem(item);
        itemRefs.add(ref);
        print("ref: $ref");
      }

      expense.items = itemRefs;

      final expenseRef = await db.addExpense(expense);
      return expenseRef;
    } catch (e) {
      print("Error saving expense with items: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          'Record Transaction',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TransactionButton(
                        textColor: isExpense ? Colors.white : Colors.black,
                        backgroundColor:
                            isExpense ? Colors.grey.shade700 : Colors.white,
                        borderColor:
                            isExpense ? Colors.transparent : Colors.black,
                        buttonText: "Expense",
                        onPressed: () {
                          setState(() {
                            isExpense = true;
                            transaction =
                                widget.completeExpense?.generalDetails ??
                                    Expense();
                          });
                        }),
                    TransactionButton(
                        textColor:
                            isExpense == false ? Colors.white : Colors.black,
                        backgroundColor: isExpense == false
                            ? Colors.grey.shade700
                            : Colors.white,
                        borderColor: isExpense == false
                            ? Colors.transparent
                            : Colors.black,
                        buttonText: "Income",
                        onPressed: () {
                          setState(() {
                            isExpense = false;
                            transaction = Income();
                          });
                        }),
                  ],
                ),
              ),
              isExpense
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Checkbox(
                                activeColor: Colors.black,
                                value: isMultipleItem,
                                visualDensity: VisualDensity.compact,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    isMultipleItem = newValue!;
                                  });
                                }),
                            Text('Multiple Item',
                                style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600))),
                          ],
                        ),
                        isMultipleItem
                            ? Column(
                                children: [
                                  SmallTitle(title: "Transaction Name"),
                                  TransactionTextfield(
                                      value: transaction.transactionName,
                                      onChanged: (value) {
                                        transaction.transactionName = value!;
                                      }),
                                  SmallTitle(title: "Item"),
                                  ItemHeader(),
                                  ...expenseItems.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    ExpenseItem item = entry.value;
                                    return ItemList(
                                      key: ValueKey('item_$index'), // Add unique key
                                      item: item,
                                      onNameChanged: (value) {
                                        setState(() {
                                          item.name = value!;
                                        });
                                      },
                                      onCategoryChanged: (value) {
                                        setState(() {
                                          item.category = value!;
                                        });
                                      },
                                      onQuantityChanged: (value) {
                                        setState(() {
                                          item.quantity = int.tryParse(value!) ?? 1;
                                        });
                                      },
                                      onPriceChanged: (value) {
                                        setState(() {
                                          item.price = double.tryParse(value!) ?? 0.0;
                                        });
                                      },
                                    );
                                  }).toList(), // Convert to list
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ItemButton(
                                        onPressed: () {
                                          setState(() {
                                            // Create a completely new ExpenseItem instance
                                            final newItem = ExpenseItem(
                                              name: '',
                                              category: 'Food',
                                              quantity: 1,
                                              price: 0.0,
                                            );
                                            // Add to the list
                                            expenseItems.add(newItem);
                                            // Update the multiple item flag
                                            isMultipleItem = expenseItems.length > 1;
                                          });
                                        },
                                        icon: Icons.add,
                                      ),
                                      ItemButton(
                                        onPressed: () {
                                          setState(() {
                                            // Only remove if there's more than one item
                                            if (expenseItems.length > 1) {
                                              expenseItems.removeLast();
                                              // Update the multiple item flag
                                              isMultipleItem = expenseItems.length > 1;
                                            }
                                          });
                                        },
                                        icon: Icons.remove,
                                      )
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  SmallTitle(title: "Item"),
                                  ItemHeader(),
                                  ItemList(
                                    key: ValueKey('single_item'), // Add unique key
                                    item: expenseItems.first,
                                    onNameChanged: (value) {
                                      setState(() {
                                        expenseItems.first.name = value!;
                                      });
                                    },
                                    onCategoryChanged: (value) {
                                      setState(() {
                                        expenseItems.first.category = value!;
                                      });
                                    },
                                    onPriceChanged: (value) {
                                      setState(() {
                                        expenseItems.first.price =
                                            double.tryParse(value!) ?? 0.0;
                                      });
                                    },
                                    onQuantityChanged: (value) {
                                      setState(() {
                                        expenseItems.first.quantity =
                                            int.tryParse(value!) ?? 1;
                                      });
                                    },
                                  )
                                ],
                              ),
                      ],
                    )
                  : // Column for the income item
                  Column(
                      children: [
                        SmallTitle(title: "Income"),
                        Row(
                          children: [
                            Expanded(flex: 2, child: Text('Name')),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(flex: 2, child: Text('Category')),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(flex: 2, child: Text('Amount')),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: TransactionTextfield(
                                    onChanged: (value) {
                                      transaction.transactionName = value!;
                                    },
                                    value: transaction.transactionName,
                                  )),
                              SizedBox(width: 5),
                              Expanded(
                                flex: 2,
                                child: RecordTransactionDropdown(
                                    value: transaction.category,
                                    onChanged: (value) {
                                      transaction.category = value!;
                                    },
                                    items: [
                                      'Salary',
                                      'Investmemt',
                                      'Freelance',
                                      'Scholarship'
                                    ]),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                  flex: 2,
                                  child: TransactionTextfield(
                                      onChanged: (value) {
                                        transaction.amount =
                                            double.tryParse(value!) ?? 0;
                                      },
                                      value: transaction.amount.toString())),
                            ],
                          ),
                        ),
                      ],
                    ),

              SizedBox(
                height: 10,
              ),
              SmallTitle(title: 'Payment Method'),
              RecordTransactionDropdown(
                  value: transaction.paymentMethod,
                  onChanged: (value) => transaction.paymentMethod = value!,
                  items: [
                    'Cash',
                    'E-Wallet',
                    'Online Banking',
                    'Credit',
                    'Debit'
                  ]),
              SmallTitle(title: 'Time'),
              Container(
                height: 43,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.only(left: 10, right: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      shadowColor: Colors.transparent, // No shadow color
                      backgroundColor: Color(0xffe6e6e6)),
                  onPressed: () {
                    pickDateTime();
                  },
                  child: Text(
                      DateFormat('dd MMMM yyyy HH:mm')
                          .format(transaction.dateTime.toDate()),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16)),
                ),
              ),
              SmallTitle(title: 'Location'),
              TransactionTextfield(
                  value: transaction.location,
                  onChanged: (value) => transaction.location = value),
              SmallTitle(title: isExpense ? 'Receipt' : "Proof of Income"),
              ImageUpload(
                listTiles: [
                  ListTile(
                    leading: Icon(
                      Icons.add,
                    ),
                    title: Text(
                      'Add from Gallery',
                    ),
                    onTap: () {
                      pickImage(ImageSource.gallery, true);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.camera_alt,
                    ),
                    title: Text(
                      'Take Photo',
                    ),
                    onTap: () {
                      pickImage(ImageSource.camera, true);
                    },
                  ),
                  isExpense
                      ? ListTile(
                          leading: Icon(Icons.document_scanner_sharp),
                          title: Text('Scan Receipt'),
                          onTap: () {
                            Navigator.push(
                                context,
                                (MaterialPageRoute(
                                    builder: (context) => Scanner())));
                          },
                        )
                      : SizedBox()
                ],
                imgPath: isExpense
                    ? transaction.receiptImagePath
                    : transaction.proofOfIncome,
              ),
              //Image
              isExpense
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SmallTitle(title: 'Image'),
                        ImageUpload(listTiles: [
                          ListTile(
                            leading: Icon(
                              Icons.add,
                            ),
                            title: Text(
                              'Add from Gallery',
                            ),
                            onTap: () {
                              pickImage(ImageSource.gallery, false);
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.camera_alt,
                            ),
                            title: Text(
                              'Take Photo',
                            ),
                            onTap: () {
                              pickImage(ImageSource.camera, false);
                            },
                          ),
                        ], imgPath: transaction.additionalImagePath),
                      ],
                    )
                  : SizedBox(),

              SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.center,
                child: DetailsButton(
                    textColor: 0xff000000,
                    buttonColor: _isProcessing ? 0xff999999 : 0xff74c95c, // Change color when processing
                    button_text: _isProcessing ? "Processing..." : "Done",
                    onPressed: () async {
                      if (_isProcessing) return; // Don't process if already processing
                      if (!mounted) return; // Safety check
                      
                      setState(() {
                        _isProcessing = true; // Set processing state
                      });
                      
                      try {
                        if (isExpense) {
                          // Debug: Print current expense items
                          print('🔍 DEBUG: Saving ${expenseItems.length} expense items');
                          for (int i = 0; i < expenseItems.length; i++) {
                            print('🔍 DEBUG: Item $i - Name: ${expenseItems[i].name}, Category: ${expenseItems[i].category}, Quantity: ${expenseItems[i].quantity}, Price: ${expenseItems[i].price}');
                          }
                          
                          for (ExpenseItem item in expenseItems) {
                            if (item.name.isEmpty ||
                                item.category.isEmpty ||
                                item.quantity == 0 ||
                                item.price == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                duration: Duration(seconds: 1),
                                content: Text(
                                    "Please ensure that the item(s) are not empty."),
                                backgroundColor: Colors.red,
                              ));
                              setState(() {
                                _isProcessing = false; // Reset processing state on error
                              });
                              return;
                            }
                          }
                          await carbonService.generateCarbonApiJson(
                              transaction, expenseItems);
                          final expenseRef =
                              await saveExpense(transaction, expenseItems);
                          expenseRefId = expenseRef.id;
                        } else {
                          final incomeRef = await db.addIncome(transaction);
                          incomeRefId = incomeRef.id;
                        }

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransactionDetails(
                                      transactionId:
                                          isExpense ? expenseRefId : incomeRefId,
                                      isExpense: isExpense,
                                      fromForm: true,
                                    )));
                      } catch (e) {
                        print('Error processing transaction: $e');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 3),
                          content: Text("Error processing transaction: $e"),
                          backgroundColor: Colors.red,
                        ));
                        setState(() {
                          _isProcessing = false; // Reset processing state on error
                        });
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}