import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';

class CompleteExpense {
  final Expense generalDetails;
  final List<ExpenseItem> items;

  CompleteExpense({required this.generalDetails, required this.items});

  Map<String, dynamic> toJson() {
    return {
      'generalDetails': generalDetails.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory CompleteExpense.fromJson(Map<String, dynamic> json) {
    return CompleteExpense(
      generalDetails: Expense.fromJson(json['generalDetails']),
      items: (json['items'] as List)
          .map((itemJson) => ExpenseItem.fromJson(itemJson))
          .toList(),
    );
  }
}
