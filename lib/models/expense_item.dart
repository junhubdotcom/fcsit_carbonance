class ExpenseItem {
  String name;
  String category;
  int quantity;
  double price;

  ExpenseItem(
      {this.name = '',
      this.category = 'Food',
      this.quantity = 0,
      this.price = 0.00,});

  // From JSON
  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      name: json['name'] ?? '',
      category: json['category'] ?? 'Food',
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'price': price,
    };
  }
}
