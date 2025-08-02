import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/common/constants.dart';
import 'package:steadypunpipi_vhack/models/bank_account.dart';

class BankSelector extends StatefulWidget {
  final List<Bank> banks;
  final Function(Bank) onBankSelected;

  const BankSelector({
    Key? key,
    required this.banks,
    required this.onBankSelected,
  }) : super(key: key);

  @override
  State<BankSelector> createState() => _BankSelectorState();
}

class _BankSelectorState extends State<BankSelector> {
  String searchQuery = '';
  List<Bank> filteredBanks = [];

  @override
  void initState() {
    super.initState();
    filteredBanks = widget.banks;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          SizedBox(height: AppConstants.paddingMedium),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPopularBanks(),
                  SizedBox(height: AppConstants.paddingMedium),
                  _buildAllBanks(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: TextField(
        onChanged: _filterBanks,
        decoration: InputDecoration(
          hintText: 'Search for your bank...',
          hintStyle: GoogleFonts.quicksand(
            color: AppConstants.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppConstants.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingMedium,
          ),
        ),
        style: GoogleFonts.quicksand(),
      ),
    );
  }

  Widget _buildPopularBanks() {
    final popularBanks = filteredBanks.where((bank) => bank.isPopular).toList();
    
    if (popularBanks.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Banks',
          style: GoogleFonts.quicksand(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        SizedBox(height: AppConstants.paddingSmall),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.0,
            crossAxisSpacing: AppConstants.paddingSmall,
            mainAxisSpacing: AppConstants.paddingSmall,
          ),
          itemCount: popularBanks.length,
          itemBuilder: (context, index) {
            return _buildBankCard(popularBanks[index], true);
          },
        ),
      ],
    );
  }

  Widget _buildAllBanks() {
    final allBanks = filteredBanks.where((bank) => !bank.isPopular).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Banks',
          style: GoogleFonts.quicksand(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        SizedBox(height: AppConstants.paddingSmall),
        Column(
          children: allBanks.map((bank) => _buildBankListItem(bank)).toList(),
        ),
      ],
    );
  }

  Widget _buildBankCard(Bank bank, bool isPopular) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: AppConstants.backgroundColor,
          width: 1,
        ),
        boxShadow: [AppConstants.boxShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          onTap: () => widget.onBankSelected(bank),
          child: Padding(
            padding: EdgeInsets.all(AppConstants.paddingSmall),
            child: Row(
              children: [
                _buildBankIcon(bank),
                SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        bank.name,
                        style: GoogleFonts.quicksand(
                          fontSize: AppConstants.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (isPopular)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                          ),
                          child: Text(
                            'Popular',
                            style: GoogleFonts.quicksand(
                              fontSize: 10,
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppConstants.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankListItem(Bank bank) {
    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: AppConstants.backgroundColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          onTap: () => widget.onBankSelected(bank),
          child: Padding(
            padding: EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              children: [
                _buildBankIcon(bank),
                SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank.name,
                        style: GoogleFonts.quicksand(
                          fontSize: AppConstants.fontSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '${bank.supportedAccountTypes.length} account types',
                        style: GoogleFonts.quicksand(
                          fontSize: AppConstants.fontSizeSmall,
                          color: AppConstants.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppConstants.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankIcon(Bank bank) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getBankColor(bank.name).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Icon(
        Icons.account_balance,
        color: _getBankColor(bank.name),
        size: 16,
      ),
    );
  }

  Color _getBankColor(String bankName) {
    switch (bankName.toLowerCase()) {
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

  void _filterBanks(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredBanks = widget.banks;
      } else {
        filteredBanks = widget.banks
            .where((bank) =>
                bank.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
} 