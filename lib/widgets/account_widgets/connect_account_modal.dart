import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/common/constants.dart';
import 'package:steadypunpipi_vhack/common/dummy_data.dart';
import 'package:steadypunpipi_vhack/models/bank_account.dart';
import 'package:steadypunpipi_vhack/widgets/account_widgets/bank_selector.dart';
import 'package:steadypunpipi_vhack/widgets/account_widgets/consent_form.dart';

class ConnectAccountModal extends StatefulWidget {
  final Function(BankAccount) onAccountConnected;

  const ConnectAccountModal({
    Key? key,
    required this.onAccountConnected,
  }) : super(key: key);

  @override
  State<ConnectAccountModal> createState() => _ConnectAccountModalState();
}

class _ConnectAccountModalState extends State<ConnectAccountModal> {
  int currentStep = 0;
  Bank? selectedBank;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.borderRadiusLarge),
          topRight: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildProgressIndicator(),
          Expanded(
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.borderRadiusLarge),
          topRight: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: AppConstants.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Connect Bank Account',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: Row(
        children: [
          _buildProgressStep(1, 'Select Bank', currentStep >= 0),
          _buildProgressLine(currentStep >= 1),
          _buildProgressStep(2, 'Provide Consent', currentStep >= 1),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int stepNumber, String title, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? AppConstants.primaryColor : AppConstants.backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? AppConstants.primaryColor : AppConstants.textSecondary,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      stepNumber.toString(),
                      style: GoogleFonts.quicksand(
                        color: AppConstants.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeSmall,
              color: isCompleted ? AppConstants.primaryColor : AppConstants.textSecondary,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Container(
      height: 2,
      width: 40,
      color: isCompleted ? AppConstants.primaryColor : AppConstants.backgroundColor,
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return BankSelector(
          banks: DummyData.availableBanks,
          onBankSelected: (bank) {
            setState(() {
              selectedBank = bank;
            });
            _nextStep();
          },
        );
      case 1:
        return ConsentForm(
          bank: selectedBank!,
          onConsentGiven: () {
            _connectAccount();
          },
          onBackPressed: () {
            setState(() {
              currentStep--;
            });
          },
        );
      default:
        return Container();
    }
  }

  void _nextStep() {
    setState(() {
      currentStep++;
    });
  }

  void _connectAccount() {
    if (selectedBank != null) {
      // Simulate API call to get account details
      final newAccount = BankAccount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bankName: selectedBank!.name,
        accountType: 'Savings Account', // This would come from API
        accountNumber: '****${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        balance: 0.0, // This would come from API
        connectedAt: DateTime.now(),
      );

      widget.onAccountConnected(newAccount);
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully connected ${selectedBank!.name} account!',
            style: GoogleFonts.quicksand(),
          ),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
} 