class TransactionModel {
  final String id;
  final DateTime date;
  final String category;
  final double amount;
  final String type;
  final double? carbonFootprint;
  final String description;

  TransactionModel({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.type,
    this.carbonFootprint,
    required this.description,
  });

  // Convert JSON Map to TransactionModel Object
  factory TransactionModel.fromJSON(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      type: map['type'],
      carbonFootprint: map['carbon_footprint'] != null
          ? (map['carbon_footprint'] as num).toDouble()
          : null,
      description: map['description'],
    );
  }

  // Convert TransactionModel Object to JSON Map
  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'category': category,
      'amount': amount,
      'type': type,
      'carbon_footprint': carbonFootprint,
      'description': description,
    };
  }
}
