import 'package:flutter/material.dart';

class LabelConfig {
  final String text;
  final Color color;
  final IconData icon;

  const LabelConfig({
    required this.text,
    required this.color,
    required this.icon,
  });
}

class LabelConfigs {
  // Essential Categories
  static const LabelConfig housing = LabelConfig(
    text: 'Housing',
    color: Color(0xFF3F51B5),
    icon: Icons.home,
  );

  static const LabelConfig debtPayment = LabelConfig(
    text: 'Debt Payment',
    color: Color(0xFFFF5722),
    icon: Icons.account_balance_wallet,
  );

  static const LabelConfig medical = LabelConfig(
    text: 'Medical',
    color: Color(0xFF4CAF50),
    icon: Icons.local_hospital,
  );

  static const LabelConfig transport = LabelConfig(
    text: 'Transport',
    color: Color(0xFF4ECDC4),
    icon: Icons.directions_car,
  );

  static const LabelConfig utilities = LabelConfig(
    text: 'Utilities',
    color: Color(0xFF2196F3),
    icon: Icons.electric_bolt,
  );

  static const LabelConfig shopping = LabelConfig(
    text: 'Shopping',
    color: Color(0xFFA8E6CF),
    icon: Icons.shopping_bag,
  );

  static const LabelConfig tax = LabelConfig(
    text: 'Tax',
    color: Color(0xFF795548),
    icon: Icons.receipt_long,
  );

  // Income Categories
  static const LabelConfig salary = LabelConfig(
    text: 'Salary',
    color: Color(0xFF00BCD4), 
    icon: Icons.account_balance,
  );

  static const LabelConfig investment = LabelConfig(
    text: 'Investment',
    color: Color(0xFF2196F3),
    icon: Icons.trending_up,
  );

  static const LabelConfig freelance = LabelConfig(
    text: 'Freelance',
    color: Color(0xFFFF9800),
    icon: Icons.work,
  );

  static const LabelConfig scholarship = LabelConfig(
    text: 'Scholarship',
    color: Color(0xFF9C27B0),
    icon: Icons.school,
  );

  // Get all available configs
  static List<LabelConfig> getAllConfigs() {
    return [
      housing, debtPayment, medical, transport, utilities, shopping, tax,
      salary, investment, freelance, scholarship,
    ];
  }

  // Get config by text (case-insensitive)
  static LabelConfig getByText(String text) {
    final allConfigs = getAllConfigs();
    try {
      return allConfigs.firstWhere(
        (config) => config.text.toLowerCase() == text.toLowerCase(),
      );
    } catch (e) {
      return housing; // Default to housing if not found
    }
  }
} 