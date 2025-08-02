import 'package:steadypunpipi_vhack/models/bank_account.dart';
import 'package:steadypunpipi_vhack/common/dummy_data.dart';

class AccountController {
  static final AccountController _instance = AccountController._internal();
  factory AccountController() => _instance;
  AccountController._internal();

  List<BankAccount> _connectedAccounts = List.from(DummyData.connectedAccounts);

  List<BankAccount> get connectedAccounts => List.unmodifiable(_connectedAccounts);

  void addAccount(BankAccount account) {
    _connectedAccounts.add(account);
    // TODO: Save to local storage or API
  }

  void removeAccount(String accountId) {
    _connectedAccounts.removeWhere((account) => account.id == accountId);
    // TODO: Remove from local storage or API
  }

  void updateAccount(BankAccount updatedAccount) {
    final index = _connectedAccounts.indexWhere((account) => account.id == updatedAccount.id);
    if (index != -1) {
      _connectedAccounts[index] = updatedAccount;
      // TODO: Update in local storage or API
    }
  }

  double get totalBalance {
    return _connectedAccounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  int get accountCount => _connectedAccounts.length;

  // Future methods for API integration
  Future<void> syncAccounts() async {
    // TODO: Implement API call to sync accounts
    await Future.delayed(Duration(seconds: 1)); // Simulate API call
  }

  Future<void> refreshBalances() async {
    // TODO: Implement API call to refresh account balances
    await Future.delayed(Duration(seconds: 1)); // Simulate API call
  }

  Future<bool> connectNewAccount(BankAccount account) async {
    // TODO: Implement API call to connect new account
    await Future.delayed(Duration(seconds: 2)); // Simulate API call
    addAccount(account);
    return true;
  }

  Future<bool> disconnectAccount(String accountId) async {
    // TODO: Implement API call to disconnect account
    await Future.delayed(Duration(seconds: 1)); // Simulate API call
    removeAccount(accountId);
    return true;
  }
} 