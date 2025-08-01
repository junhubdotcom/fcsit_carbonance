import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/common/constants.dart';
import 'package:steadypunpipi_vhack/common/userdata.dart';
import 'package:steadypunpipi_vhack/screens/connected_accounts_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserData _userData = UserData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              _buildStatsSection(),
              _buildSettingsSection(),
              _buildActivitySection(),
              SizedBox(height: AppConstants.paddingLarge), // Add bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      constraints: BoxConstraints(
        minHeight: 280, // Ensure minimum height for proper display
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingLarge,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFDCE8D6),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [AppConstants.boxShadow],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile Picture
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [AppConstants.boxShadow],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _userData.avatarUrl,
            ),
          ),
          SizedBox(height: AppConstants.paddingMedium),

          // User Name
          Text(
            _userData.name,
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppConstants.paddingSmall),

          // User Info
          Text(
            _userData.title,
            style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeMedium,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppConstants.paddingMedium),

          // Edit Profile Button
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.edit, size: 18, color: AppConstants.primaryColor),
            label: Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppConstants.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: EdgeInsets.all(AppConstants.paddingMedium),
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [AppConstants.boxShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.account_balance_wallet,
                title: 'Total Income',
                value: '${AppConstants.currency} 12,450',
                color: AppConstants.infoColor,
              ),
              _buildStatItem(
                icon: Icons.trending_down,
                title: 'Total Expenses',
                value: '${AppConstants.currency} 2,840',
                color: AppConstants.errorColor,
              ),
            ],
          ),
          SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.credit_card,
                title: 'Balance',
                value: '72%',
                color: AppConstants.warningColor,
              ),
              _buildStatItem(
                icon: Icons.eco,
                title: 'Carbon Footprint',
                value: '128 kg',
                color: AppConstants.successColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(AppConstants.paddingSmall),
        margin: EdgeInsets.symmetric(horizontal: AppConstants.paddingExtraSmall),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.quicksand(
                      fontSize: AppConstants.fontSizeSmall,
                      color: AppConstants.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingExtraSmall),
            Text(
              value,
              style: GoogleFonts.quicksand(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [AppConstants.boxShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          SizedBox(height: AppConstants.paddingMedium),
          _buildSettingItem(
            icon: Icons.account_circle_outlined,
            title: 'Account Settings',
            subtitle: 'Personal information, email',
            iconColor: AppConstants.primaryColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConnectedAccountsPage(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Budget alerts, transaction updates',
            iconColor: AppConstants.accentColor,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.security,
            title: 'Privacy & Security',
            subtitle: 'Face ID, password, data privacy',
            iconColor: AppConstants.secondaryColor,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.dark_mode_outlined,
            title: 'Appearance',
            subtitle: 'Dark mode, themes, font size',
            iconColor: AppConstants.infoColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(AppConstants.paddingSmall),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.quicksand(
          fontSize: AppConstants.fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.quicksand(
          fontSize: AppConstants.fontSizeSmall,
          color: AppConstants.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppConstants.textSecondary,
      ),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppConstants.backgroundColor,
      thickness: 1,
      height: 1,
    );
  }

  Widget _buildActivitySection() {
    return Container(
      margin: EdgeInsets.all(AppConstants.paddingMedium),
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [AppConstants.boxShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.quicksand(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: GoogleFonts.quicksand(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.paddingSmall),
          _buildActivityItem(
            icon: Icons.shopping_bag,
            title: 'Grocery Shopping',
            amount: '-${AppConstants.currency} 85.40',
            date: 'Today, 10:45 AM',
            color: AppConstants.errorColor,
          ),
          _buildActivityItem(
            icon: Icons.local_cafe,
            title: 'Coffee Shop',
            amount: '-${AppConstants.currency} 4.50',
            date: 'Yesterday, 8:30 AM',
            color: AppConstants.errorColor,
          ),
          _buildActivityItem(
            icon: Icons.account_balance,
            title: 'Salary Deposit',
            amount: '+${AppConstants.currency} 3,450.00',
            date: 'Apr 01, 2025',
            color: AppConstants.successColor,
          ),
          _buildActivityItem(
            icon: Icons.local_gas_station,
            title: 'Gas Station',
            amount: '-${AppConstants.currency} 45.30',
            date: 'Mar 30, 2025',
            color: AppConstants.errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String amount,
    required String date,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimary,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.quicksand(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.quicksand(
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}