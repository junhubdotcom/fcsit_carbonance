import 'package:flutter/material.dart';
import 'screens/dashboard/modern_dashboard.dart';
import 'screens/mission/mission.dart';
import 'screens/profile.dart';
import 'screens/transaction/transaction_page.dart';
import 'screens/pet/pet.dart';

class AppRoutes {
  static final List<Widget> pages = [
    TransactionPage(),
    ModernDashboardPage(),
    PetPage(),
    MissionPage(),
    ProfilePage(),
  ];
}
