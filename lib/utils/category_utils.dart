import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Food':
      return Icons.restaurant;
    case 'Housing':
      return Icons.home;
    case 'Debt Repayment':
      return Icons.money_off;
    case 'Medical':
      return Icons.healing;
    case 'Transport':
      return Icons.directions_car;
    case 'Utilities':
      return Icons.flash_on;
    case 'Shopping':
      return Icons.shopping_bag;
    case 'Tax':
      return Icons.receipt_long;
    default:
      return Icons.category;
  }
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'Food':
      return Colors.red.shade200;
    case 'Housing':
      return Colors.indigo.shade200;
    case 'Debt Repayment':
      return Colors.deepOrange.shade200;
    case 'Medical':
      return Colors.green.shade200;
    case 'Transport':
      return Colors.blue.shade200;
    case 'Utilities':
      return Colors.amber.shade200;
    case 'Shopping':
      return Colors.purple.shade200;
    case 'Tax':
      return Colors.brown.shade200;
    default:
      return Colors.grey.shade200;
  }
}
