import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/common/constants.dart';
import 'package:steadypunpipi_vhack/common/dummy_data.dart';
import 'package:steadypunpipi_vhack/models/bank_account.dart';

class ConsentForm extends StatefulWidget {
  final Bank bank;
  final VoidCallback onConsentGiven;
  final VoidCallback onBackPressed;

  const ConsentForm({
    Key? key,
    required this.bank,
    required this.onConsentGiven,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  State<ConsentForm> createState() => _ConsentFormState();
}

class _ConsentFormState extends State<ConsentForm> {
  bool _isLoading = false;
  bool _hasConsented = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBankInfo(),
                  SizedBox(height: AppConstants.paddingLarge),
                  _buildDataAccessInfo(),
                  SizedBox(height: AppConstants.paddingLarge),
                  _buildConsentSection(),
                  SizedBox(height: AppConstants.paddingLarge),
                  _buildConsentValidity(),
                ],
              ),
            ),
          ),
          SizedBox(height: AppConstants.paddingMedium),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBankInfo() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getBankColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Icon(
              Icons.account_balance,
              color: _getBankColor(),
              size: 24,
            ),
          ),
          SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bank.name,
                  style: GoogleFonts.quicksand(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
                Text(
                  'Connect your account securely',
                  style: GoogleFonts.quicksand(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataAccessInfo() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: AppConstants.infoColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppConstants.infoColor,
                size: 20,
              ),
              SizedBox(width: AppConstants.paddingSmall),
              Text(
                'Data Access Information',
                style: GoogleFonts.quicksand(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.infoColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Carbonance is a licensed Account Information Service Provider (AISP) requesting access to your account data.',
            style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeSmall,
              color: AppConstants.textPrimary,
            ),
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            'After authentication, we will automatically retrieve:',
            style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
          SizedBox(height: AppConstants.paddingSmall),
          _buildDataItem('Account details and balances'),
          _buildDataItem('Transaction history'),
          _buildDataItem('Account holder information'),
        ],
      ),
    );
  }

  Widget _buildConsentSection() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              SizedBox(width: AppConstants.paddingSmall),
              Text(
                'Security & Privacy',
                style: GoogleFonts.quicksand(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            'By providing consent, you agree to:',
            style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
          SizedBox(height: AppConstants.paddingSmall),
          _buildConsentItem('Allow Carbonance to access your account information'),
          _buildConsentItem('Share transaction data for carbon footprint calculation'),
          _buildConsentItem('Receive insights about your spending patterns'),
          SizedBox(height: AppConstants.paddingSmall),
          Container(
            padding: EdgeInsets.all(AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: AppConstants.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔒 Your data is protected:',
                  style: GoogleFonts.quicksand(
                    fontSize: AppConstants.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.successColor,
                  ),
                ),
                SizedBox(height: AppConstants.paddingExtraSmall),
                Text(
                  '• We never store your banking credentials\n• We cannot make transactions on your behalf\n• All data is encrypted and secure\n• Access is read-only',
                  style: GoogleFonts.quicksand(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.paddingExtraSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_right,
            color: AppConstants.infoColor,
            size: 16,
          ),
          SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.quicksand(
                fontSize: AppConstants.fontSizeSmall,
                color: AppConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.paddingExtraSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: AppConstants.successColor,
            size: 16,
          ),
          SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.quicksand(
                fontSize: AppConstants.fontSizeSmall,
                color: AppConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentValidity() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: AppConstants.warningColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: AppConstants.warningColor,
            size: 20,
          ),
          SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              'Your consent is valid for 90 days and can be withdrawn at any time in settings.',
              style: GoogleFonts.quicksand(
                fontSize: AppConstants.fontSizeSmall,
                color: AppConstants.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: _hasConsented,
              onChanged: (value) {
                setState(() {
                  _hasConsented = value ?? false;
                });
              },
              activeColor: AppConstants.primaryColor,
            ),
            Expanded(
              child: Text(
                'I understand and agree to the terms above',
                style: GoogleFonts.quicksand(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppConstants.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : widget.onBackPressed,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  side: BorderSide(color: AppConstants.textSecondary),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.quicksand(
                    color: AppConstants.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: (_isLoading || !_hasConsented) ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Provide Consent',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getBankColor() {
    switch (widget.bank.name.toLowerCase()) {
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

  void _submitForm() async {
    if (!_hasConsented) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call for consent
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    widget.onConsentGiven();
  }
} 