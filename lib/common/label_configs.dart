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
    color: Color(0xFF9FA8DA), // Light blue
    icon: Icons.home,
  );

  static const LabelConfig debtPayment = LabelConfig(
    text: 'Debt Payment',
    color: Color(0xFFFFAB91), // Light orange
    icon: Icons.account_balance_wallet,
  );

  static const LabelConfig medical = LabelConfig(
    text: 'Medical',
    color: Color(0xFFA5D6A7), // Light green
    icon: Icons.local_hospital,
  );

  static const LabelConfig transport = LabelConfig(
    text: 'Transport',
    color: Color(0xFF80DEEA), // Light cyan
    icon: Icons.directions_car,
  );

  static const LabelConfig utilities = LabelConfig(
    text: 'Utilities',
    color: Color(0xFF90CAF9), // Light blue
    icon: Icons.electric_bolt,
  );

  static const LabelConfig shopping = LabelConfig(
    text: 'Shopping',
    color: Color(0xFFE1BEE7), // Light purple
    icon: Icons.shopping_bag,
  );

  static const LabelConfig tax = LabelConfig(
    text: 'Tax',
    color: Color(0xFFBCAAA4), // Light brown
    icon: Icons.receipt_long,
  );

  // Income Categories
  static const LabelConfig salary = LabelConfig(
    text: 'Salary',
    color: Color(0xFF80CBC4), // Light teal
    icon: Icons.account_balance,
  );

  static const LabelConfig investment = LabelConfig(
    text: 'Investment',
    color: Color(0xFF9FA8DA), // Light indigo
    icon: Icons.trending_up,
  );

  static const LabelConfig freelance = LabelConfig(
    text: 'Freelance',
    color: Color(0xFFFFCC80), // Light amber
    icon: Icons.work,
  );

  static const LabelConfig scholarship = LabelConfig(
    text: 'Scholarship',
    color: Color(0xFFCE93D8), // Light purple
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