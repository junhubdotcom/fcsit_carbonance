import 'package:cloud_firestore/cloud_firestore.dart';

class Income {
  String name;
  String category;
  double amount;
  String paymentMethod;
  Timestamp dateTime;
  String? location; // Optional
  String? proofOfIncome; // Optional

  Income({
    this.name = '',
    this.category = 'Salary',
    this.amount = 0.00,
    this.paymentMethod = 'Cash', // Default method
    Timestamp? dateTime, // Allow null and set default
    this.location,
    this.proofOfIncome,
  }) : dateTime = dateTime ?? Timestamp.now(); // Default to now

  // Convert Income object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'dateTime': dateTime, // Convert DateTime to string
      'location': location,
      'proofOfIncome': proofOfIncome,
    };
  }

  // Create Income object from JSON
  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      name: json['name'] ?? '',
      category: json['category'] ?? 'Salary',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'Bank Transfer',
      dateTime: json['dateTime'] is Timestamp
          ? json['dateTime'] as Timestamp
          : Timestamp.now(),
      location: json['location'] ?? "None",
      proofOfIncome: json['proofOfIncome'],
    );
  }
}
