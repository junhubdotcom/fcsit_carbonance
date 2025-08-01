class BankAccount {
  final String id;
  final String bankName;
  final String accountType;
  final String accountNumber;
  final double balance;
  final String currency;
  final bool isConnected;
  final DateTime connectedAt;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountType,
    required this.accountNumber,
    required this.balance,
    this.currency = 'MYR',
    this.isConnected = true,
    required this.connectedAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      bankName: json['bankName'],
      accountType: json['accountType'],
      accountNumber: json['accountNumber'],
      balance: json['balance'].toDouble(),
      currency: json['currency'] ?? 'MYR',
      isConnected: json['isConnected'] ?? true,
      connectedAt: DateTime.parse(json['connectedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'accountType': accountType,
      'accountNumber': accountNumber,
      'balance': balance,
      'currency': currency,
      'isConnected': isConnected,
      'connectedAt': connectedAt.toIso8601String(),
    };
  }
}

class Bank {
  final String id;
  final String name;
  final String logo;
  final List<String> supportedAccountTypes;
  final bool isPopular;

  Bank({
    required this.id,
    required this.name,
    required this.logo,
    required this.supportedAccountTypes,
    this.isPopular = false,
  });
} 