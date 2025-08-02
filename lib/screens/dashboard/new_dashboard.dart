import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Mock Data Models
class DashboardData {
  final double totalIncome;
  final double totalExpense;
  final double totalCO2;
  final double balance;
  final List<ChartData> trendData;
  final List<CategoryData> categoryData;
  final List<String> recommendations;
  final Map<String, double> monthlyData;

  DashboardData({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalCO2,
    required this.balance,
    required this.trendData,
    required this.categoryData,
    required this.recommendations,
    required this.monthlyData,
  });
}

class ChartData {
  final String label;
  final double income;
  final double expense;
  final double co2;

  ChartData({
    required this.label,
    required this.income,
    required this.expense,
    required this.co2,
  });
}

class CategoryData {
  final String category;
  final double amount;
  final double co2;
  final Color color;
  final double percentage;

  CategoryData({
    required this.category,
    required this.amount,
    required this.co2,
    required this.color,
    required this.percentage,
  });
}

class NewDashboard extends StatefulWidget {
  @override
  _NewDashboardState createState() => _NewDashboardState();
}

class _NewDashboardState extends State<NewDashboard>
    with TickerProviderStateMixin {
  int _selectedPeriodIndex = 1; // Weekly
  int _selectedChartIndex = 0;
  late PageController _chartPageController;
  late TabController _tabController;

  // Mock Data
  late DashboardData dashboardData;

  @override
  void initState() {
    super.initState();
    _chartPageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockData();
  }

  void _loadMockData() {
    // Generate comprehensive mock data
    dashboardData = DashboardData(
      totalIncome: 8500.0,
      totalExpense: 3200.0,
      totalCO2: 245.6,
      balance: 5300.0,
      trendData: _generateTrendData(),
      categoryData: _generateCategoryData(),
      recommendations: [
        "Switch to public transport to reduce CO₂ by 15%",
        "Consider renewable energy providers",
        "Reduce meat consumption by 20%",
        "Use energy-efficient appliances",
        "Support local businesses",
        "Opt for digital receipts",
      ],
      monthlyData: {
        'Jan': 180.5,
        'Feb': 165.2,
        'Mar': 195.8,
        'Apr': 210.3,
        'May': 198.7,
        'Jun': 245.6,
      },
    );
  }

  List<ChartData> _generateTrendData() {
    return [
      ChartData(label: 'Mon', income: 1200, expense: 450, co2: 35.2),
      ChartData(label: 'Tue', income: 800, expense: 320, co2: 28.1),
      ChartData(label: 'Wed', income: 1500, expense: 580, co2: 42.3),
      ChartData(label: 'Thu', income: 900, expense: 380, co2: 31.5),
      ChartData(label: 'Fri', income: 2000, expense: 720, co2: 48.9),
      ChartData(label: 'Sat', income: 600, expense: 280, co2: 25.7),
      ChartData(label: 'Sun', income: 500, expense: 470, co2: 34.9),
    ];
  }

  List<CategoryData> _generateCategoryData() {
    return [
      CategoryData(
          category: 'Food',
          amount: 850,
          co2: 45.2,
          color: Colors.orange,
          percentage: 26.6),
      CategoryData(
          category: 'Transport',
          amount: 680,
          co2: 78.5,
          color: Colors.blue,
          percentage: 21.3),
      CategoryData(
          category: 'Shopping',
          amount: 520,
          co2: 32.1,
          color: Colors.purple,
          percentage: 16.3),
      CategoryData(
          category: 'Bills',
          amount: 480,
          co2: 28.9,
          color: Colors.red,
          percentage: 15.0),
      CategoryData(
          category: 'Entertainment',
          amount: 320,
          co2: 18.7,
          color: Colors.pink,
          percentage: 10.0),
      CategoryData(
          category: 'Others',
          amount: 350,
          co2: 42.2,
          color: Colors.grey,
          percentage: 10.9),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  SizedBox(height: 24),
                  _buildSummaryCards(),
                  SizedBox(height: 24),
                  _buildChartSection(),
                  SizedBox(height: 24),
                  _buildRecommendations(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Smart Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF74C95C),
                Color(0xFF4CAF50),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPeriodButton('Daily', 0),
          SizedBox(width: 12),
          _buildPeriodButton('Weekly', 1),
          SizedBox(width: 12),
          _buildPeriodButton('Monthly', 2),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, int index) {
    bool isSelected = _selectedPeriodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriodIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF4CAF50) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Color(0xFF4CAF50) : Colors.grey[300]!,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Overview',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildSummaryCard(
                    'Income',
                    'RM ${dashboardData.totalIncome.toStringAsFixed(0)}',
                    Icons.arrow_downward,
                    Colors.green)),
            SizedBox(width: 12),
            Expanded(
                child: _buildSummaryCard(
                    'Expense',
                    'RM ${dashboardData.totalExpense.toStringAsFixed(0)}',
                    Icons.arrow_upward,
                    Colors.red)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildSummaryCard(
                    'Balance',
                    'RM ${dashboardData.balance.toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.indigo)),
            SizedBox(width: 12),
            Expanded(
                child: _buildSummaryCard(
                    'CO₂ Footprint',
                    '${dashboardData.totalCO2.toStringAsFixed(1)} kg',
                    Icons.eco,
                    Colors.blue)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 300,
          child: PageView(
            controller: _chartPageController,
            onPageChanged: (index) {
              setState(() {
                _selectedChartIndex = index;
              });
            },
            children: [
              _buildTrendChart(),
              _buildCategoryChart(),
              _buildCO2Chart(),
            ],
          ),
        ),
        SizedBox(height: 16),
        _buildChartIndicators(),
      ],
    );
  }

  Widget _buildTrendChart() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Income vs Expense Trend',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: dashboardData.trendData.map((data) {
                double maxValue = dashboardData.trendData
                    .map((d) => math.max(d.income, d.expense))
                    .reduce(math.max);
                double incomeHeight = (data.income / maxValue) * 150;
                double expenseHeight = (data.expense / maxValue) * 150;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 20,
                      height: incomeHeight,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      width: 20,
                      height: expenseHeight,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      data.label,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 12,
                  height: 12,
                  color: Colors.green,
                  margin: EdgeInsets.only(right: 8)),
              Text('Income', style: GoogleFonts.poppins(fontSize: 12)),
              SizedBox(width: 20),
              Container(
                  width: 12,
                  height: 12,
                  color: Colors.red,
                  margin: EdgeInsets.only(right: 8)),
              Text('Expense', style: GoogleFonts.poppins(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense by Category',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: dashboardData.categoryData.length,
              itemBuilder: (context, index) {
                final category = dashboardData.categoryData[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.category,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                      Text(
                        'RM ${category.amount.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${category.percentage.toStringAsFixed(1)}%)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCO2Chart() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly CO₂ Emissions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: dashboardData.monthlyData.entries.map((entry) {
                double maxCO2 =
                    dashboardData.monthlyData.values.reduce(math.max);
                double height = (entry.value / maxCO2) * 150;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 25,
                      height: height,
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      entry.key,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _selectedChartIndex == index
                ? Color(0xFF4CAF50)
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Recommendations',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: dashboardData.recommendations.map((recommendation) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 6, right: 12),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _chartPageController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
