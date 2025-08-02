import '../models/bank_account.dart';

class DummyData {
  static final List<Bank> availableBanks = [
    Bank(
      id: 'arab_bank',
      name: 'Arab Bank',
      logo: 'assets/images/banks/arab_bank.png',
      supportedAccountTypes: ['Savings', 'Current', 'Credit'],
      isPopular: true,
    ),
    Bank(
      id: 'hsbc',
      name: 'HSBC',
      logo: 'assets/images/banks/hsbc.png',
      supportedAccountTypes: ['Savings', 'Current', 'Credit', 'Investment'],
      isPopular: true,
    ),
    Bank(
      id: 'sbi',
      name: 'SBI',
      logo: 'assets/images/banks/sbi.png',
      supportedAccountTypes: ['Savings', 'Current'],
      isPopular: false,
    ),
    Bank(
      id: 'maybank',
      name: 'Maybank',
      logo: 'assets/images/banks/maybank.png',
      supportedAccountTypes: ['Savings', 'Current', 'Credit'],
      isPopular: true,
    ),
    Bank(
      id: 'cimb',
      name: 'CIMB Bank',
      logo: 'assets/images/banks/cimb.png',
      supportedAccountTypes: ['Savings', 'Current', 'Credit'],
      isPopular: true,
    ),
    Bank(
      id: 'public_bank',
      name: 'Public Bank',
      logo: 'assets/images/banks/public_bank.png',
      supportedAccountTypes: ['Savings', 'Current'],
      isPopular: false,
    ),
    Bank(
      id: 'rhb',
      name: 'RHB Bank',
      logo: 'assets/images/banks/rhb.png',
      supportedAccountTypes: ['Savings', 'Current', 'Credit'],
      isPopular: false,
    ),
    Bank(
      id: 'hong_leong',
      name: 'Hong Leong Bank',
      logo: 'assets/images/banks/hong_leong.png',
      supportedAccountTypes: ['Savings', 'Current'],
      isPopular: false,
    ),
  ];

  static final List<String> accountTypes = [
    'Savings Account',
    'Current Account',
    'Credit Card',
    'Investment Account',
    'Business Account',
  ];

  static final List<BankAccount> connectedAccounts = [
    BankAccount(
      id: '1',
      bankName: 'Maybank',
      accountType: 'Savings Account',
      accountNumber: '****1234',
      balance: 12500.50,
      connectedAt: DateTime.now().subtract(Duration(days: 30)),
    ),
    BankAccount(
      id: '2',
      bankName: 'CIMB Bank',
      accountType: 'Current Account',
      accountNumber: '****5678',
      balance: 8450.75,
      connectedAt: DateTime.now().subtract(Duration(days: 15)),
    ),
    BankAccount(
      id: '3',
      bankName: 'HSBC',
      accountType: 'Credit Card',
      accountNumber: '****9012',
      balance: -1250.00,
      connectedAt: DateTime.now().subtract(Duration(days: 7)),
    ),
  ];
} 