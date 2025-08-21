import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:steadypunpipi_vhack/common/constants.dart';
import 'package:steadypunpipi_vhack/models/finance_data.dart';
import 'package:steadypunpipi_vhack/models/transaction_model.dart';
import 'package:steadypunpipi_vhack/services/transaction_service.dart';

import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/dashboard_settings.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/date_selector.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/breakdown_section.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/loading.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/summary_section.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/tips_section.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/trend_section.dart';
import 'package:steadypunpipi_vhack/screens/dashboard/new_dashboard.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 1; // Default to "Weekly"
  final TransactionService _transactionService = TransactionService();

  List<TransactionModel> transactions = [];
  List<FinanceCO2Data> trendData = [];
  Map<String, dynamic> geminiData = {
    "insights": [""],
    "financeTips": [""],
    "environmentTips": [""],
  };

  bool isLoadingAI = false;

  List<String> sectionOrder = ["Summary", "Breakdown", "Trend", "Tips"];
  Map<String, bool> sectionVisibility = {
    "Summary": true,
    "Breakdown": true,
    "Trend": true,
    "Tips": true,
  };

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData(_selectedDate);
  }

  Future<void> _loadData(DateTime selectedDate) async {
    DateTime startDate;
    DateTime endDate;

    if (_selectedIndex == 0) {
      startDate = selectedDate;
      endDate = startDate.add(Duration(days: 1));
    } else if (_selectedIndex == 1) {
      startDate =
          selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      endDate = startDate.add(Duration(days: 7));
    } else {
      startDate = DateTime(selectedDate.year, selectedDate.month, 1);
      endDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    }

    var filteredTransactions =
        await _transactionService.fetchTransactions(startDate, endDate);
    var newTrendData = await _transactionService.processFCO2(
        filteredTransactions, getSelectedPeriod());
    print("📅 Loading transactions from $startDate to $endDate");
    print("🧾 Loaded ${filteredTransactions.length} transactions");

    if (!mounted) return;
    setState(() {
      _selectedDate = selectedDate;
      transactions = filteredTransactions;
      trendData = newTrendData;
    });

    _fetchAIInsights(startDate, endDate);
  }

  Future<void> _fetchAIInsights(DateTime startDate, DateTime endDate) async {
    setState(() {
      isLoadingAI = true;
    });

    final String period = getSelectedPeriod().toLowerCase();
    final String id = getInsightId(period, startDate);

    print("📅 Fetching AI insights for: $period");
    print("🆔 Document ID: $id");
    print(
        "📆 Date range: ${startDate.toIso8601String()} - ${endDate.toIso8601String()}");

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('InsightsSummary')
          .doc(id)
          .get();

      if (!snapshot.exists) {
        print("⚠️ No document found for $id");
      }

      final data = snapshot.data();

      if (data != null) {
        setState(() {
          geminiData = {
            "insights": (data["insights"] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
            "financeTips": (data["financeTips"] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
            "environmentTips": (data["environmentTips"] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
          };
        });
      } else {
        setState(() {
          geminiData = {
            "insights": ["No insights available."],
            "financeTips": [],
            "environmentTips": [],
          };
        });
      }
    } catch (e) {
      print("🚨 Error fetching insights: $e");
    } finally {
      if (!mounted) return;
      setState(() {
        isLoadingAI = false;
      });
    }
  }

  String getInsightId(String period, DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');

    if (period == "daily") return "daily_${y}-${m}-${d}";
    if (period == "weekly") return "weekly_${y}-${m}-${d}";
    return "monthly_${y}-${m}";
  }

  String getSelectedPeriod() {
    return _selectedIndex == 0
        ? "Daily"
        : _selectedIndex == 1
            ? "Weekly"
            : "Monthly";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: _openSettingsModal,
        ),
        title: Text(
          "Dashboard",
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewDashboardPage()),
              );
            },
            icon: Icon(Icons.science),
            tooltip: 'Try V1 Dashboard',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DateSelector(
              selectedIndex: _selectedIndex,
              onSelectionChanged: (newIndex, selectedDate) {
                setState(() {
                  _selectedIndex = newIndex;
                });
                _loadData(selectedDate);
              },
            ),
            ...sectionOrder
                .where((section) => sectionVisibility[section] ?? true)
                .map((section) {
              switch (section) {
                case "Summary":
                  return isLoadingAI
                      ? loadingSummary()
                      : SummarySection(
                          insights:
                              List<String>.from(geminiData["insights"] ?? []),
                          transactions: transactions,
                        );
                case "Breakdown":
                  return BreakdownSection(transactions: transactions);
                case "Trend":
                  return TrendSection(
                      data: trendData, title: getSelectedPeriod());
                case "Tips":
                  return isLoadingAI
                      ? loadingTips()
                      : TipsSection(
                          financeTips: List<String>.from(
                              geminiData["financeTips"] ?? []),
                          environmentTips: List<String>.from(
                              geminiData["environmentTips"] ?? []),
                        );
                default:
                  return SizedBox.shrink();
              }
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _openSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DashboardSettingsModal(
          initialSections: sectionOrder,
          onSave: (newOrder, newVisibility) {
            setState(() {
              sectionOrder = newOrder;
              sectionVisibility = newVisibility;
            });
          },
        );
      },
    );
  }
}
