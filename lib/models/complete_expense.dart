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
    // Handle case where API returns two separate JSON objects
    // First object contains general details, second contains items
    if (json.containsKey('items')) {
      // Standard format with nested structure
      return CompleteExpense(
        generalDetails: Expense.fromJson(json['generalDetails']),
        items: (json['items'] as List)
            .map((itemJson) => ExpenseItem.fromJson(itemJson))
            .toList(),
      );
    } else {
      // Handle case where this is the items object
      // This should not happen in normal flow, but adding safety
      return CompleteExpense(
        generalDetails: Expense(), // Empty expense as fallback
        items: (json['items'] as List?)
                ?.map((itemJson) => ExpenseItem.fromJson(itemJson))
                .toList() ?? [],
      );
    }
  }

  // Factory method to create CompleteExpense from separate JSON objects
  factory CompleteExpense.fromSeparateJson(Map<String, dynamic> generalDetails, Map<String, dynamic> itemsData) {
    return CompleteExpense(
      generalDetails: Expense.fromJson(generalDetails),
      items: (itemsData['items'] as List)
          .map((itemJson) => ExpenseItem.fromJson(itemJson))
          .toList(),
    );
  }

  // Factory method to create CompleteExpense from scanned receipt data
  // This handles the case where items are actual ExpenseItem objects, not DocumentReferences
  factory CompleteExpense.fromScannedReceipt(Map<String, dynamic> generalDetails, List<ExpenseItem> scannedItems) {
    return CompleteExpense(
      generalDetails: Expense.fromJson(generalDetails),
      items: scannedItems,
    );
  }
}
