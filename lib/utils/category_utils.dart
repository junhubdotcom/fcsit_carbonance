import 'package:flutter/material.dart';
import 'package:steadypunpipi_vhack/common/label_configs.dart';

IconData getCategoryIcon(String category) {
  // Try to get from LabelConfigs first
  try {
    final config = LabelConfigs.getByText(category);
    return config.icon;
  } catch (e) {
    // Fallback to hardcoded values for backward compatibility
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Housing':
        return Icons.home;
      case 'Debt Payment':
      case 'Debt Repayment':
        return Icons.account_balance_wallet;
      case 'Medical':
        return Icons.local_hospital;
      case 'Transport':
        return Icons.directions_car;
      case 'Utilities':
        return Icons.electric_bolt;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Tax':
        return Icons.receipt_long;
      case 'Salary':
        return Icons.account_balance;
      case 'Investment':
        return Icons.trending_up;
      case 'Freelance':
        return Icons.work;
      case 'Scholarship':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}

Color getCategoryColor(String category) {
  // Try to get from LabelConfigs first
  try {
    final config = LabelConfigs.getByText(category);
    return config.color;
  } catch (e) {
    // Fallback to hardcoded values for backward compatibility
    switch (category) {
      case 'Food':
        return Colors.red.shade200;
      case 'Housing':
        return Colors.indigo.shade200;
      case 'Debt Payment':
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
      case 'Salary':
        return const Color(0xFF00BCD4); // Your new cyan color
      case 'Investment':
        return const Color(0xFF2196F3); // Blue
      case 'Freelance':
        return const Color(0xFFFF9800); // Orange
      case 'Scholarship':
        return const Color(0xFF9C27B0); // Purple
      default:
        return Colors.grey.shade200;
    }
  }
}
