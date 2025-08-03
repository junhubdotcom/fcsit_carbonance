import 'package:flutter/material.dart';
import 'screens/dashboard/new_dashboard.dart';
import 'screens/profile.dart';
import 'screens/transaction/transaction_page.dart';
import 'screens/offset/offset_categories_screen.dart';
import 'screens/rewards/rewards_screen.dart';

class AppRoutes {
  static final List<Widget> pages = [
    TransactionPage(),
    NewDashboardPage(),
    OffsetCategoriesScreen(),
    RewardsScreen(),
    ProfilePage(),
  ];
}
