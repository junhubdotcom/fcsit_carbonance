import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/dashboard_data_service.dart';

class ModernDashboardPage extends StatefulWidget {
  const ModernDashboardPage({Key? key}) : super(key: key);

  @override
  _ModernDashboardPageState createState() => _ModernDashboardPageState();
}

class _ModernDashboardPageState extends State<ModernDashboardPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _rotationController;

  int _currentChartIndex = 0;
  int _selectedPeriodIndex = 1;
  String _currentPeriod = 'weekly';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    await DashboardDataService.loadData();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFFAFBFF),
        appBar: AppBar(
          title: Text(
            'Dashboard',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFFAFBFF),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF74C95C)),
              ),
              SizedBox(height: 16),
              Text(
                "Loading dashboard data...",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFFAFBFF),
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFAFBFF),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildPeriodSelector(),
              _buildChartSection(),
              _buildInsightsSection(),
              _buildNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildPeriodButton("Daily", 0, Icons.today_rounded),
          _buildPeriodButton("Weekly", 1, Icons.view_week_rounded),
          _buildPeriodButton("Monthly", 2, Icons.calendar_month_rounded),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String text, int index, IconData icon) {
    final isSelected = _selectedPeriodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriodIndex = index;
            switch (index) {
              case 0:
                _currentPeriod = 'daily';
                break;
              case 1:
                _currentPeriod = 'weekly';
                break;
              case 2:
                _currentPeriod = 'monthly';
                break;
            }
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF74C95C) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey[600]),
              SizedBox(width: 6),
              Text(text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 500,
      child: Stack(
        children: [
          // Fixed summary stats at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryCard(
                      "Total Spent",
                      "\$${DashboardDataService.getSummaryStats(_currentPeriod)['totalSpent'].toStringAsFixed(0)}",
                      Color(0xFFF44336)),
                  _buildSummaryCard(
                      "Carbon Saved",
                      "${DashboardDataService.getSummaryStats(_currentPeriod)['carbonSaved'].toStringAsFixed(1)} kg",
                      Color(0xFF4CAF50)),
                  _buildSummaryCard(
                      "Total Carbon",
                      "${DashboardDataService.getSummaryStats(_currentPeriod)['totalCarbon'].toStringAsFixed(1)} kg",
                      Color(0xFF2196F3)),
                ],
              ),
            ),
          ),
          // Chart preview indicators
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildChartIndicator(0, "Spending"),
                  SizedBox(width: 20),
                  _buildChartIndicator(1, "Carbon"),
                  SizedBox(width: 20),
                  _buildChartIndicator(2, "Trends"),
                ],
              ),
            ),
          ),
          // 3D Carousel with better preview
          Positioned(
            top: 130,
            left: 0,
            right: 0,
            child: Container(
              height: 370,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentChartIndex = index);
                  _rotationController
                      .forward()
                      .then((_) => _rotationController.reset());
                },
                itemCount: 3,
                itemBuilder: (context, index) {
                  final isActive = index == _currentChartIndex;
                  final offset = (index - _currentChartIndex) *
                      0.4; // 40% offset for better preview

                  return AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Perspective
                          ..translate(offset * 150, 0.0,
                              isActive ? 0.0 : -30.0) // X-axis position
                          ..rotateY(
                              isActive ? 0.0 : offset * 0.3) // Gentle rotation
                          ..scale(isActive ? 1.0 : 0.9), // Scale for depth
                        alignment: Alignment.center,
                        child: _buildChartContent(index),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartIndicator(int index, String title) {
    final isActive = _currentChartIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFF74C95C) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Color(0xFF74C95C) : Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        children: [
          _buildChartTitle(index),
          _buildChartDescription(index),
          Expanded(child: _buildChartByIndex(index)),
        ],
      ),
    );
  }

  Widget _buildChartDescription(int index) {
    final descriptions =
        DashboardDataService.getChartDescriptions(_currentPeriod);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Text(
        descriptions[index],
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Color(0xFF666666),
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildChartTitle(int index) {
    final titles = ["Spending Overview", "Carbon Impact", "Trends Analysis"];
    final colors = [Color(0xFF74C95C), Color(0xFF4CAF50), Color(0xFF2196F3)];

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Text(
        titles[index],
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors[index],
        ),
      ),
    );
  }

  Widget _buildChartByIndex(int index) {
    switch (index) {
      case 0:
        return _buildBeautifulPieChart();
      case 1:
        return _buildBeautifulLineChart();
      case 2:
        return _buildBeautifulProgressChart();
      default:
        return Container();
    }
  }

  Widget _buildBeautifulPieChart() {
    final spendingData = DashboardDataService.getSpendingData(_currentPeriod);

    return Container(
      padding: EdgeInsets.all(20),
      child: PieChart(
        PieChartData(
          sections: spendingData
              .map((section) => PieChartSectionData(
                    value: section.value,
                    color: section.color,
                    radius: section.radius,
                    title: section.title,
                    titleStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ))
              .toList(),
          centerSpaceRadius: 50,
          sectionsSpace: 3,
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(toY: 60, color: Color(0xFF4CAF50), width: 20)
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(toY: 80, color: Color(0xFFF44336), width: 20)
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(toY: 40, color: Color(0xFF4CAF50), width: 20)
          ]),
        ],
      ),
    );
  }

  Widget _buildBeautifulLineChart() {
    final carbonData = DashboardDataService.getCarbonData(_currentPeriod);

    return Container(
      padding: EdgeInsets.all(20),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Color(0xFFE0E0E0),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun'
                  ];
                  if (value.toInt() < days.length) {
                    return Text(
                      days[value.toInt()],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}kg',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: carbonData,
              isCurved: true,
              color: Color(0xFF4CAF50),
              barWidth: 4,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Color(0xFF4CAF50),
                    strokeWidth: 3,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Color(0xFF4CAF50).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeautifulProgressChart() {
    final trendsData = DashboardDataService.getTrendsData(_currentPeriod);

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Main trends circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: 0.8, // Fixed value for trends display
                  strokeWidth: 16,
                  backgroundColor: Color(0xFFF0F0F0),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                ),
              ),
              Column(
                children: [
                  Text(
                    "${trendsData['transactionCount']}",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  Text(
                    "Transactions",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          // Trends details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressDetail(
                  "Avg Spending",
                  "\$${trendsData['avgSpending'].toStringAsFixed(0)}",
                  Color(0xFF666666)),
              _buildProgressDetail(
                  "Top Category", trendsData['topCategory'], Color(0xFF2196F3)),
              _buildProgressDetail(
                  "Avg Carbon",
                  "${trendsData['avgCarbon'].toStringAsFixed(1)}kg",
                  Color(0xFFFF9800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetail(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsChart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC107)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child:
              Icon(Icons.emoji_events_rounded, size: 60, color: Colors.white),
        ),
        SizedBox(height: 20),
        Text("15 Achievements",
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFD700))),
        Text("Unlocked this month",
            style: GoogleFonts.poppins(fontSize: 14, color: Color(0xFF666666))),
      ],
    );
  }

  Widget _buildInsightsSection() {
    return Container(
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text("Smart Insights",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A))),
            ],
          ),
          SizedBox(height: 16),
          ..._buildChartSpecificInsights(_currentChartIndex),
        ],
      ),
    );
  }

  List<Widget> _buildChartSpecificInsights(int chartIndex) {
    final insights = DashboardDataService.getChartInsights(_currentPeriod);
    return insights[chartIndex]
        .map((insight) => _buildInsightItem(insight))
        .toList();
  }

  Widget _buildInsightItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: Color(0xFF74C95C), shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(text,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${_currentChartIndex + 1} of 3",
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666))),
          Row(
            children: [
              _buildNavButton(
                  Icons.arrow_back_ios_rounded, _currentChartIndex > 0, () {
                if (_currentChartIndex > 0)
                  _pageController.previousPage(
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic);
              }),
              SizedBox(width: 12),
              _buildNavButton(
                  Icons.arrow_forward_ios_rounded, _currentChartIndex < 2, () {
                if (_currentChartIndex < 2)
                  _pageController.nextPage(
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
      IconData icon, bool isEnabled, VoidCallback onPressed) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled ? Color(0xFF74C95C) : Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            color: isEnabled ? Colors.white : Color(0xFFCCCCCC), size: 20),
      ),
    );
  }
}
