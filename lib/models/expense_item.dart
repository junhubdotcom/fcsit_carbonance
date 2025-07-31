class ExpenseItem {
  String name;
  String category;
  int quantity;
  double price;
  double carbon_footprint;

  ExpenseItem(
      {this.name = '',
      this.category = 'Food',
      this.quantity = 0,
      this.price = 0.00,
      this.carbon_footprint = 0.00});

  // From JSON
  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      name: json['name'] ?? '',
      category: json['category'] ?? 'Food',
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      carbon_footprint: (json['carbon_footprint'] ?? 0).toDouble(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'price': price,
      'carbon_footprint': carbon_footprint,
    };
  }
}
