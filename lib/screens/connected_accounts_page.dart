import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/common/constants.dart';
import 'package:steadypunpipi_vhack/common/dummy_data.dart';
import 'package:steadypunpipi_vhack/models/bank_account.dart';
import 'package:steadypunpipi_vhack/widgets/account_widgets/account_tile.dart';
import 'package:steadypunpipi_vhack/widgets/account_widgets/connect_account_modal.dart';

class ConnectedAccountsPage extends StatefulWidget {
  const ConnectedAccountsPage({Key? key}) : super(key: key);

  @override
  State<ConnectedAccountsPage> createState() => _ConnectedAccountsPageState();
}

class _ConnectedAccountsPageState extends State<ConnectedAccountsPage> {
  List<BankAccount> connectedAccounts = List.from(DummyData.connectedAccounts);

  void _addNewAccount(BankAccount newAccount) {
    setState(() {
      connectedAccounts.add(newAccount);
    });
  }

  void _removeAccount(String accountId) {
    setState(() {
      connectedAccounts.removeWhere((account) => account.id == accountId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Connected Accounts',
          style: GoogleFonts.quicksand(
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        backgroundColor: AppConstants.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppConstants.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppConstants.primaryColor),
            onPressed: () {
              _showConnectAccountModal();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: connectedAccounts.isEmpty
                ? _buildEmptyState()
                : _buildAccountsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: AppConstants.primaryColor,
            size: 24,
          ),
          SizedBox(width: AppConstants.paddingSmall),
          Text(
            '${connectedAccounts.length} Connected Account${connectedAccounts.length != 1 ? 's' : ''}',
            style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
          Spacer(),
          Text(
            'Total: ${AppConstants.currency} ${_calculateTotalBalance().toStringAsFixed(2)}',
            style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: AppConstants.textSecondary,
          ),
          SizedBox(height: AppConstants.paddingLarge),
          Text(
            'No Connected Accounts',
            style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Connect your bank accounts to start tracking\nyour transactions and carbon footprint',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeMedium,
              color: AppConstants.textSecondary,
            ),
          ),
          SizedBox(height: AppConstants.paddingLarge),
          ElevatedButton.icon(
            onPressed: () => _showConnectAccountModal(),
            icon: Icon(Icons.add),
            label: Text('Connect Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingMedium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      itemCount: connectedAccounts.length,
      itemBuilder: (context, index) {
        final account = connectedAccounts[index];
        return AccountTile(
          account: account,
          onRemove: () => _removeAccount(account.id),
        );
      },
    );
  }

  double _calculateTotalBalance() {
    return connectedAccounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  void _showConnectAccountModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConnectAccountModal(
        onAccountConnected: _addNewAccount,
      ),
    );
  }
} 