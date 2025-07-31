import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/details_button.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/record_transaction_dropdown.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/small_title.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/flutter_toggle.dart';

class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  // for toggle button
  List<List<bool>> toggleSelections = [
    [true, false, false],
    [true, false]
  ];

  void _handleToggle(int groupIndex, int selectedIndex) {
    setState(() {
      for (int i = 0; i < toggleSelections[groupIndex].length; i++) {
        toggleSelections[groupIndex][i] = (i == selectedIndex);
      }
      if (groupIndex == 0) {
        if (selectedIndex == 0) {
          _showDayPicker();
        } else if (selectedIndex == 1) {
          _showWeekPicker();
        } else {
          _showMonthPicker();
        }
      }
    });
  }

  DateTime selectedDate = DateTime.now();
  DateTime selectedWeekStart = DateTime.now();
  DateTime selectedWeekEnd = DateTime.now();
  DateTime selectedMonth = DateTime.now();
  String displayDate = " ";

  void _showDayPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text("Select a Day",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color: Colors.black)),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Text(
                  "Confrim",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  setState(() {
                    displayDate =
                        DateFormat('dd MMMM yyyy').format(selectedDate);
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWeekPicker() {
    List<DateTime> weekStartDates = [];
    DateTime currentDate = DateTime.now();

    // Find the Monday of the current week
    DateTime firstMonday = currentDate.subtract(Duration(
        days: (currentDate.weekday == 7) ? 6 : currentDate.weekday - 1));

    print('firstMonday$firstMonday');

    // Start from two years before
    DateTime startFrom = firstMonday.subtract(Duration(days: 365));
// Align startFrom to the nearest past Monday
    startFrom = startFrom.subtract(Duration(days: (startFrom.weekday - 1) % 7));

    // End at one year after
    DateTime endAt = firstMonday.add(Duration(days: 365));

    // Generate weeks from two years before to one year after
    for (DateTime date = startFrom;
        date.isBefore(endAt);
        date = date.add(Duration(days: 7))) {
      weekStartDates.add(date);
    }

    int daysDifference = firstMonday.difference(startFrom).inDays;
    int initialIndex = daysDifference ~/ 7;

    print("Initial Index:$initialIndex");

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(height: 10),
              // Title for the picker
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text("Select a Week",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color: Colors.black)),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: initialIndex),

                  itemExtent: 40, // Height of each item in the picker
                  onSelectedItemChanged: (index) {
                    setState(() {
                      // Update selected week start and end dates
                      selectedWeekStart = weekStartDates[index];
                      selectedWeekEnd =
                          selectedWeekStart.add(Duration(days: 6));
                    });
                  },
                  children: weekStartDates.map((date) {
                    DateTime weekEnd = date.add(Duration(days: 6));
                    return Center(
                      child: Text(
                          "${_formatDate(date)} - ${_formatDate(weekEnd)}"),
                    );
                  }).toList(),
                ),
              ),
              // Confirm button to close the picker
              CupertinoButton(
                child: Text(
                  "Confirm",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  setState(() {
                    displayDate =
                        "${_formatDate(selectedWeekStart)} - ${_formatDate(selectedWeekEnd)}";
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

// Helper function to format dates as "DD Month YYYY"
  String _formatDate(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)} ${date.year}";
  }

// Helper function to get month name from month number
  String _getMonthName(int month) {
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  void _showMonthPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text("Select a Month",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color: Colors.black)),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.monthYear,
                  initialDateTime: selectedDate,
                  onDateTimeChanged: (DateTime newMonth) {
                    setState(() {
                      selectedMonth = newMonth;
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Text(
                  "Confrim",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  setState(() {
                    displayDate = DateFormat('MMMM yyyy').format(selectedMonth);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final List<String> categories = [
    "Food",
    "Housing",
    "Debt Repayment",
    "Medical",
    "Transport",
    "Utilities",
    "Shopping",
    "Tax"
  ];

  final List<String> selectedCategories = [];

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood;
      case 'Housing':
        return Icons.home;
      case 'Debt Repayment':
        return Icons.money_off;
      case 'Medical':
        return Icons.local_hospital;
      case 'Transport':
        return Icons.directions_car;
      case 'Utilities':
        return Icons.lightbulb;
      case "Shopping":
        return Icons.shopping_bag;
      case 'Tax':
        return Icons.receipt_long;
      default:
        return Icons.category;
    }
  }

  String paymentMethodChosen = "Cash";
  List<String> paymentMethod = [
    "Cash",
    "E-Wallet",
    "Online-Banking",
    "Credit",
    "Debit"
  ];

  RangeValues values = const RangeValues(0, 1000);
  @override
  Widget build(BuildContext context) {
    RangeLabels labels =
        RangeLabels(values.start.toString(), values.end.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text("Filter",
            style: GoogleFonts.quicksand(
                textStyle:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallTitle(title: "Date"),
              FilterToggle(
                OnPressed: (index) => _handleToggle(0, index),
                isSelected: toggleSelections[0],
                toggleWidget: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Day")),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Week")),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Month")),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Wrap(
                children: [
                  Text(
                    "Selected Date: $displayDate",
                    style: GoogleFonts.quicksand(
                        fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              SmallTitle(title: "Category"),
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 10,
                runSpacing: 5,
                children: categories.map((category) {
                  final isSelected = selectedCategories.contains(category);

                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(getCategoryIcon(category), size: 20),
                        const SizedBox(width: 5),
                        Text(category),
                      ],
                    ),
                    selected: isSelected,
                    showCheckmark: true,
                    onSelected: (bool selected) {
                      setState(() {
                        selected
                            ? selectedCategories.add(category)
                            : selectedCategories.remove(category);
                      });
                    },
                  );
                }).toList(),
              ),

              // const SizedBox(height: 20), // Added spacing for readability

              SmallTitle(title: "Transaction Type"),
              FilterToggle(
                OnPressed: (index) => _handleToggle(1, index),
                isSelected: toggleSelections[1],
                toggleWidget: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Income")),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Expense")),
                ],
              ),

              SmallTitle(title: "Payment Method"),
              RecordTransactionDropdown(
                  value: paymentMethodChosen,
                  onChanged: (value) {
                    setState(() {
                      paymentMethodChosen = value!;
                    });
                  },
                  items: paymentMethod),
              SmallTitle(title: "Amount Method"),
              RangeSlider(
                activeColor: Colors.grey.shade700,
                min: 0,
                max: 1000,
                values: values,
                divisions: 100,
                labels: labels,
                onChanged: (newValues) {
                  setState(() {
                    values = newValues;
                  });
                },
              ),
              SizedBox(
                height: 50,
              ),
              Align(
                alignment: Alignment.center,
                child: DetailsButton(
                    textColor: 0xff000000,
                    buttonColor: 0xff74c95c,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    button_text: "Done"),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
