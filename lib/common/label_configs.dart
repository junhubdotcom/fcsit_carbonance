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
  // Food & Dining
  static const LabelConfig food = LabelConfig(
    text: 'Food',
    color: Color(0xFFFFC670),
    icon: Icons.local_pizza_sharp,
  );

  static const LabelConfig coffee = LabelConfig(
    text: 'Coffee',
    color: Color(0xFF8B4513),
    icon: Icons.local_cafe,
  );

  static const LabelConfig restaurant = LabelConfig(
    text: 'Restaurant',
    color: Color(0xFFFF6B6B),
    icon: Icons.restaurant,
  );

  // Transportation
  static const LabelConfig transport = LabelConfig(
    text: 'Transport',
    color: Color(0xFF4ECDC4),
    icon: Icons.directions_car,
  );

  static const LabelConfig fuel = LabelConfig(
    text: 'Fuel',
    color: Color(0xFFFFD93D),
    icon: Icons.local_gas_station,
  );

  static const LabelConfig parking = LabelConfig(
    text: 'Parking',
    color: Color(0xFF6C5CE7),
    icon: Icons.local_parking,
  );

  // Shopping
  static const LabelConfig shopping = LabelConfig(
    text: 'Shopping',
    color: Color(0xFFA8E6CF),
    icon: Icons.shopping_bag,
  );

  static const LabelConfig groceries = LabelConfig(
    text: 'Groceries',
    color: Color(0xFF81C784),
    icon: Icons.shopping_cart,
  );

  static const LabelConfig clothing = LabelConfig(
    text: 'Clothing',
    color: Color(0xFFFFB3BA),
    icon: Icons.checkroom,
  );

  // Entertainment
  static const LabelConfig entertainment = LabelConfig(
    text: 'Entertainment',
    color: Color(0xFFE1BEE7),
    icon: Icons.movie,
  );

  static const LabelConfig gaming = LabelConfig(
    text: 'Gaming',
    color: Color(0xFF9C27B0),
    icon: Icons.games,
  );

  // Bills & Utilities
  static const LabelConfig bills = LabelConfig(
    text: 'Bills',
    color: Color(0xFFFF9800),
    icon: Icons.receipt,
  );

  static const LabelConfig utilities = LabelConfig(
    text: 'Utilities',
    color: Color(0xFF2196F3),
    icon: Icons.electric_bolt,
  );

  // Health & Fitness
  static const LabelConfig health = LabelConfig(
    text: 'Health',
    color: Color(0xFF4CAF50),
    icon: Icons.local_hospital,
  );

  static const LabelConfig fitness = LabelConfig(
    text: 'Fitness',
    color: Color(0xFF00BCD4),
    icon: Icons.fitness_center,
  );

  // Income
  static const LabelConfig salary = LabelConfig(
    text: 'Salary',
    color: Color(0xFF4CAF50),
    icon: Icons.account_balance,
  );

  static const LabelConfig bonus = LabelConfig(
    text: 'Bonus',
    color: Color(0xFFFFD700),
    icon: Icons.star,
  );

  // Carbon Footprint Categories
  static const LabelConfig highCarbon = LabelConfig(
    text: 'High Carbon',
    color: Color(0xFFFF5722),
    icon: Icons.warning,
  );

  static const LabelConfig lowCarbon = LabelConfig(
    text: 'Low Carbon',
    color: Color(0xFF4CAF50),
    icon: Icons.eco,
  );

  static const LabelConfig sustainable = LabelConfig(
    text: 'Sustainable',
    color: Color(0xFF8BC34A),
    icon: Icons.forest,
  );

  // Additional Categories
  static const LabelConfig housing = LabelConfig(
    text: 'Housing',
    color: Color(0xFF3F51B5),
    icon: Icons.home,
  );

  static const LabelConfig debtRepayment = LabelConfig(
    text: 'Debt Repayment',
    color: Color(0xFFFF5722),
    icon: Icons.account_balance_wallet,
  );

  static const LabelConfig medical = LabelConfig(
    text: 'Medical',
    color: Color(0xFF4CAF50),
    icon: Icons.local_hospital,
  );

  static const LabelConfig tax = LabelConfig(
    text: 'Tax',
    color: Color(0xFF795548),
    icon: Icons.receipt_long,
  );

  // Get all available configs
  static List<LabelConfig> getAllConfigs() {
    return [
      food, coffee, restaurant,
      transport, fuel, parking,
      shopping, groceries, clothing,
      entertainment, gaming,
      bills, utilities,
      health, fitness,
      salary, bonus,
      highCarbon, lowCarbon, sustainable,
      housing, debtRepayment, medical, tax,
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
      return food; // Default to food if not found
    }
  }
} 