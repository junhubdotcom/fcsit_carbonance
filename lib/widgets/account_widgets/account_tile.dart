import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/common/constants.dart';
import 'package:steadypunpipi_vhack/models/bank_account.dart';

class AccountTile extends StatelessWidget {
  final BankAccount account;
  final VoidCallback onRemove;

  const AccountTile({
    Key? key,
    required this.account,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [AppConstants.boxShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          onTap: () {
            // TODO: Navigate to account details
          },
          child: Padding(
            padding: EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              children: [
                _buildBankIcon(),
                SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: _buildAccountInfo(),
                ),
                _buildBalanceInfo(),
                _buildActionButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: _getBankColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Icon(
        _getBankIcon(),
        color: _getBankColor(),
        size: 24,
      ),
    );
  }

  Widget _buildAccountInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          account.bankName,
          style: GoogleFonts.quicksand(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        SizedBox(height: AppConstants.paddingExtraSmall),
        Text(
          account.accountType,
          style: GoogleFonts.quicksand(
            fontSize: AppConstants.fontSizeSmall,
            color: AppConstants.textSecondary,
          ),
        ),
        SizedBox(height: AppConstants.paddingExtraSmall),
        Text(
          account.accountNumber,
          style: GoogleFonts.quicksand(
            fontSize: AppConstants.fontSizeSmall,
            color: AppConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceInfo() {
    final isNegative = account.balance < 0;
    final balanceColor = isNegative ? AppConstants.errorColor : AppConstants.successColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${isNegative ? '-' : ''}${AppConstants.currency} ${account.balance.abs().toStringAsFixed(2)}',
          style: GoogleFonts.quicksand(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.bold,
            color: balanceColor,
          ),
        ),
        SizedBox(height: AppConstants.paddingExtraSmall),
        Text(
          'Connected ${_getTimeAgo(account.connectedAt)}',
          style: GoogleFonts.quicksand(
            fontSize: AppConstants.fontSizeSmall,
            color: AppConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppConstants.textSecondary,
      ),
      onSelected: (value) {
        if (value == 'remove') {
          _showRemoveDialog(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: AppConstants.errorColor),
              SizedBox(width: AppConstants.paddingSmall),
              Text(
                'Remove Account',
                style: GoogleFonts.quicksand(
                  color: AppConstants.errorColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Account',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove ${account.bankName} account? This action cannot be undone.',
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.quicksand(color: AppConstants.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRemove();
            },
            child: Text(
              'Remove',
              style: GoogleFonts.quicksand(color: AppConstants.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBankColor() {
    switch (account.bankName.toLowerCase()) {
      case 'maybank':
        return Color(0xFFE60012);
      case 'cimb bank':
        return Color(0xFF1E3A8A);
      case 'hsbc':
        return Color(0xFFDB0007);
      case 'public bank':
        return Color(0xFF1E40AF);
      case 'rhb bank':
        return Color(0xFFDC2626);
      case 'hong leong bank':
        return Color(0xFF059669);
      case 'arab bank':
        return Color(0xFF7C3AED);
      case 'sbi':
        return Color(0xFF1E40AF);
      default:
        return AppConstants.primaryColor;
    }
  }

  IconData _getBankIcon() {
    switch (account.accountType.toLowerCase()) {
      case 'credit card':
        return Icons.credit_card;
      case 'savings account':
        return Icons.savings;
      case 'current account':
        return Icons.account_balance;
      case 'investment account':
        return Icons.trending_up;
      case 'business account':
        return Icons.business;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
