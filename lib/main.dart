import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:steadypunpipi_vhack/common/constants.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:steadypunpipi_vhack/screens/onboarding_screen.dart';
import 'route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load dotenv
  try {
    await dotenv.load(fileName: ".env");
    print('✅ DEBUG: .env file loaded successfully');
  } catch (e) {
    print('⚠️ DEBUG: .env file not found, using default values');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  Gemini.init(apiKey: AppConstants.GEMINI_API_KEY);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tab Navigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OnboardingScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = AppRoutes.pages;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: SizedBox(
        width: 70.0,
        height: 70.0,
        child: FloatingActionButton(
          onPressed: () {
            _onTabTapped(2);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          backgroundColor: Colors.green.shade400,
          child: Icon(
            Icons.pets,
            color: Color(0XFFE5ECDD),
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 60,
        color: Colors.grey[200],
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.attach_money,
                color: _currentIndex == 0 ? Colors.black : Colors.grey.shade600,
              ),
              onPressed: () {
                _onTabTapped(0); // Navigate to the TransactionPage
              },
            ),
            IconButton(
              icon: Icon(
                Icons.dashboard,
                color: _currentIndex == 1 ? Colors.black : Colors.grey.shade600,
              ),
              onPressed: () {
                _onTabTapped(1); // Navigate to the DashboardPage
              },
            ),
            SizedBox(width: 40), // Space for the FloatingActionButton
            IconButton(
              icon: Icon(
                Icons.flag,
                color: _currentIndex == 3 ? Colors.black : Colors.grey.shade600,
              ),
              onPressed: () {
                _onTabTapped(3); // Navigate to the MissionPage
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: _currentIndex == 4 ? Colors.black : Colors.grey.shade600,
              ),
              onPressed: () {
                _onTabTapped(4); // Navigate to the ProfilePage
              },
            ),
          ],
        ),
      ),
    );
  }
}
