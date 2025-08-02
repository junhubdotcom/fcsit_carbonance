import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fl_chart/fl_chart.dart';

class EnhancedDashboardPage extends StatefulWidget {
  const EnhancedDashboardPage({Key? key}) : super(key: key);

  @override
  _EnhancedDashboardPageState createState() => _EnhancedDashboardPageState();
}

class _EnhancedDashboardPageState extends State<EnhancedDashboardPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  int _currentChartIndex = 0;
  int _selectedPeriodIndex = 1; // Weekly by default
  DateTime _selectedDate = DateTime.now();

  // Mock data for different periods
  final Map<String, Map<String, dynamic>> mockData = {
    'daily': {
      'expenseBreakdown': [
        {
          'category': 'Food & Dining',
          'amount': 45.0,
          'color': Color(0xFF74C95C)
        },
        {
          'category': 'Transportation',
          'amount': 32.0,
          'color': Color(0xFF2196F3)
        },
        {'category': 'Shopping', 'amount': 28.0, 'color': Color(0xFFFF9800)},
        {
          'category': 'Entertainment',
          'amount': 18.0,
          'color': Color(0xFF9C27B0)
        },
        {'category': 'Utilities', 'amount': 12.0, 'color': Color(0xFF607D8B)},
      ],
      'incomeExpense': [
        {'day': 'Mon', 'income': 120, 'expense': 85},
        {'day': 'Tue', 'income': 0, 'expense': 92},
        {'day': 'Wed', 'income': 0, 'expense': 78},
        {'day': 'Thu', 'income': 0, 'expense': 105},
        {'day': 'Fri', 'income': 0, 'expense': 88},
        {'day': 'Sat', 'income': 0, 'expense': 125},
        {'day': 'Sun', 'income': 0, 'expense': 95},
      ],
      'carbonFootprint': [
        {'day': 'Mon', 'carbon': 12.5},
        {'day': 'Tue', 'carbon': 14.2},
        {'day': 'Wed', 'carbon': 11.8},
        {'day': 'Thu', 'carbon': 13.1},
        {'day': 'Fri', 'carbon': 15.6},
        {'day': 'Sat', 'carbon': 18.3},
        {'day': 'Sun', 'carbon': 16.7},
      ],
      'insights': [
        "Today's spending is 15% below average",
        "Carbon footprint reduced by 8% this week",
        "You're on track for monthly savings goal",
        "Consider walking for short trips to save more",
        "Great job on sustainable food choices!"
      ]
    },
    'weekly': {
      'expenseBreakdown': [
        {
          'category': 'Food & Dining',
          'amount': 320.0,
          'color': Color(0xFF74C95C)
        },
        {
          'category': 'Transportation',
          'amount': 245.0,
          'color': Color(0xFF2196F3)
        },
        {'category': 'Shopping', 'amount': 180.0, 'color': Color(0xFFFF9800)},
        {
          'category': 'Entertainment',
          'amount': 125.0,
          'color': Color(0xFF9C27B0)
        },
        {'category': 'Utilities', 'amount': 85.0, 'color': Color(0xFF607D8B)},
      ],
      'incomeExpense': [
        {'week': 'W1', 'income': 1200, 'expense': 950},
        {'week': 'W2', 'income': 0, 'expense': 875},
        {'week': 'W3', 'income': 0, 'expense': 920},
        {'week': 'W4', 'income': 0, 'expense': 780},
      ],
      'carbonFootprint': [
        {'week': 'W1', 'carbon': 85.2},
        {'week': 'W2', 'carbon': 78.9},
        {'week': 'W3', 'carbon': 82.1},
        {'week': 'W4', 'carbon': 76.5},
      ],
      'insights': [
        "Weekly expenses are 12% below budget",
        "Carbon emissions down 15% from last week",
        "Savings goal: 75% completed this week",
        "Transportation costs reduced by 20%",
        "Excellent progress on sustainability goals!"
      ]
    },
    'monthly': {
      'expenseBreakdown': [
        {
          'category': 'Food & Dining',
          'amount': 1250.0,
          'color': Color(0xFF74C95C)
        },
        {
          'category': 'Transportation',
          'amount': 980.0,
          'color': Color(0xFF2196F3)
        },
        {'category': 'Shopping', 'amount': 720.0, 'color': Color(0xFFFF9800)},
        {
          'category': 'Entertainment',
          'amount': 480.0,
          'color': Color(0xFF9C27B0)
        },
        {'category': 'Utilities', 'amount': 320.0, 'color': Color(0xFF607D8B)},
      ],
      'incomeExpense': [
        {'month': 'Jan', 'income': 4800, 'expense': 3750},
        {'month': 'Feb', 'income': 5200, 'expense': 3900},
        {'month': 'Mar', 'income': 4900, 'expense': 3650},
        {'month': 'Apr', 'income': 5500, 'expense': 3800},
        {'month': 'May', 'income': 5100, 'expense': 3950},
        {'month': 'Jun', 'income': 5300, 'expense': 3750},
      ],
      'carbonFootprint': [
        {'month': 'Jan', 'carbon': 320.5},
        {'month': 'Feb', 'carbon': 298.2},
        {'month': 'Mar', 'carbon': 315.8},
        {'month': 'Apr', 'carbon': 285.4},
        {'month': 'May', 'carbon': 295.1},
        {'month': 'Jun', 'carbon': 276.8},
      ],
      'insights': [
        "Monthly savings increased by 18%",
        "Carbon footprint 25% below national average",
        "Budget adherence: 92% success rate",
        "Green investments growing steadily",
        "Top 15% in sustainability ranking!"
      ]
    }
  };

  // Chart types with their titles and icons
  final List<ChartModel> chartModels = [
    ChartModel(
      title: "Expense Breakdown",
      subtitle: "Smart spending insights",
      icon: Icons.pie_chart_rounded,
      color: Color(0xFF74C95C),
      gradient: [Color(0xFF74C95C), Color(0xFF4CAF50)],
    ),
    ChartModel(
      title: "Income vs Expense",
      subtitle: "Financial health overview",
      icon: Icons.trending_up_rounded,
      color: Color(0xFF2196F3),
      gradient: [Color(0xFF2196F3), Color(0xFF1976D2)],
    ),
    ChartModel(
      title: "Carbon Footprint",
      subtitle: "Environmental impact",
      icon: Icons.eco_rounded,
      color: Color(0xFF4CAF50),
      gradient: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    ),
    ChartModel(
      title: "Goal Progress",
      subtitle: "Achievement tracking",
      icon: Icons.flag_rounded,
      color: Color(0xFFFF9800),
      gradient: [Color(0xFFFF9800), Color(0xFFF57C00)],
    ),
    ChartModel(
      title: "Savings Analysis",
      subtitle: "Wealth building insights",
      icon: Icons.savings_rounded,
      color: Color(0xFF9C27B0),
      gradient: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    ),
    ChartModel(
      title: "Achievements",
      subtitle: "Your sustainability wins",
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFFFD700),
      gradient: [Color(0xFFFFD700), Color(0xFFFFC107)],
    ),
  ];

  String get currentPeriod {
    switch (_selectedPeriodIndex) {
      case 0:
        return 'daily';
      case 1:
        return 'weekly';
      case 2:
        return 'monthly';
      default:
        return 'weekly';
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Test indicator to show this is the enhanced dashboard
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                color: Colors.red,
                child: Text(
                  "🎉 ENHANCED 3D CAROUSEL DASHBOARD IS RUNNING! 🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildHeader(),
              _buildChartCarousel(),
              _buildInsightsSection(),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dashboard",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                  ),
                  Text(
                    _getPeriodText(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF74C95C), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF74C95C).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildPeriodSelector(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
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
          });
          _fadeController.forward().then((_) {
            _fadeController.reset();
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Color(0xFF74C95C) : Color(0xFF999999),
              ),
              SizedBox(width: 6),
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Color(0xFF74C95C) : Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPeriodText() {
    switch (_selectedPeriodIndex) {
      case 0:
        return "Today's Overview";
      case 1:
        return "This Week's Summary";
      case 2:
        return "Monthly Analysis";
      default:
        return "This Week's Summary";
    }
  }

  Widget _buildChartCarousel() {
    return Container(
      height: 400,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentChartIndex = index;
          });
          _animationController.forward().then((_) {
            _animationController.reset();
          });
        },
        itemCount: chartModels.length,
        itemBuilder: (context, index) {
          final isActive = index == _currentChartIndex;
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: isActive ? _scaleAnimation.value : 0.92,
                child: Transform.rotate(
                  angle: isActive ? _rotationAnimation.value : 0,
                  child: _buildChartCard(index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChartCard(int index) {
    final chart = chartModels[index];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFFAFBFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: chart.color.withOpacity(0.15),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                chart.color.withOpacity(0.02),
              ],
            ),
          ),
          child: Column(
            children: [
              _buildChartHeader(chart),
              Expanded(
                child: _buildChartContent(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartHeader(ChartModel chart) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: chart.gradient,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              chart.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chart.title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                Text(
                  chart.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent(int index) {
    switch (index) {
      case 0:
        return _buildExpenseBreakdownChart();
      case 1:
        return _buildIncomeExpenseChart();
      case 2:
        return _buildCarbonFootprintChart();
      case 3:
        return _buildGoalProgressChart();
      case 4:
        return _buildSavingsChart();
      case 5:
        return _buildAchievementsChart();
      default:
        return Container();
    }
  }

  Widget _buildExpenseBreakdownChart() {
    final data = mockData[currentPeriod]!['expenseBreakdown']
        as List<Map<String, dynamic>>;
    return Container(
      padding: EdgeInsets.all(16),
      child: SfCircularChart(
        series: <CircularSeries>[
          DoughnutSeries<Map<String, dynamic>, String>(
            dataSource: data,
            pointColorMapper: (Map<String, dynamic> data, _) => data['color'],
            xValueMapper: (Map<String, dynamic> data, _) => data['category'],
            yValueMapper: (Map<String, dynamic> data, _) => data['amount'],
            innerRadius: '65%',
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart() {
    final data =
        mockData[currentPeriod]!['incomeExpense'] as List<Map<String, dynamic>>;
    return Container(
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data.fold(
                  0.0,
                  (max, item) => (item['income'].toDouble() >
                                  item['expense'].toDouble()
                              ? item['income'].toDouble()
                              : item['expense'].toDouble()) >
                          max
                      ? (item['income'].toDouble() > item['expense'].toDouble()
                          ? item['income'].toDouble()
                          : item['expense'].toDouble())
                      : max) *
              1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final labels = data.map((e) => e.keys.first).toList();
                  if (value.toInt() < labels.length) {
                    return Text(
                      labels[value.toInt()],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: item['income'].toDouble(),
                  color: Color(0xFF4CAF50),
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: item['expense'].toDouble(),
                  color: Color(0xFFF44336),
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCarbonFootprintChart() {
    final data = mockData[currentPeriod]!['carbonFootprint']
        as List<Map<String, dynamic>>;
    return Container(
      padding: EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final labels = data.map((e) => e.keys.first).toList();
                  if (value.toInt() < labels.length) {
                    return Text(
                      labels[value.toInt()],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(
                    entry.key.toDouble(), entry.value['carbon'].toDouble());
              }).toList(),
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

  Widget _buildGoalProgressChart() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: 0.78,
                  strokeWidth: 16,
                  backgroundColor: Color(0xFFF0F0F0),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                ),
              ),
              Column(
                children: [
                  Text(
                    "78%",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                  Text(
                    "Complete",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            "Monthly Goal",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsChart() {
    final List<Map<String, dynamic>> data = [
      {'category': 'Emergency', 'amount': 6000, 'color': Color(0xFF4CAF50)},
      {'category': 'Investment', 'amount': 8000, 'color': Color(0xFF2196F3)},
      {'category': 'Vacation', 'amount': 2000, 'color': Color(0xFFFF9800)},
      {'category': 'Home', 'amount': 5000, 'color': Color(0xFF9C27B0)},
    ];

    return Container(
      padding: EdgeInsets.all(16),
      child: SfCircularChart(
        series: <CircularSeries>[
          PieSeries<Map<String, dynamic>, String>(
            dataSource: data,
            pointColorMapper: (Map<String, dynamic> data, _) => data['color'],
            xValueMapper: (Map<String, dynamic> data, _) => data['category'],
            yValueMapper: (Map<String, dynamic> data, _) => data['amount'],
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsChart() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "15 Achievements",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFD700),
            ),
          ),
          Text(
            "Unlocked this month",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAchievementBadge("Carbon Saver", Icons.eco_rounded),
              _buildAchievementBadge(
                  "Budget Master", Icons.account_balance_wallet_rounded),
              _buildAchievementBadge(
                  "Green Warrior", Icons.local_florist_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String title, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInsightsSection() {
    final insights = mockData[currentPeriod]!['insights'] as List<dynamic>;
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFFFFD700),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Smart Insights",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: insights.take(3).map((insight) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 6, right: 8),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Color(0xFF74C95C),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          insight,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w500,
                            height: 1.3,
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
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${_currentChartIndex + 1} of ${chartModels.length}",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          Row(
            children: [
              _buildNavButton(
                Icons.arrow_back_ios_rounded,
                _currentChartIndex > 0,
                () {
                  if (_currentChartIndex > 0) {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                    );
                  }
                },
              ),
              SizedBox(width: 12),
              _buildNavButton(
                Icons.arrow_forward_ios_rounded,
                _currentChartIndex < chartModels.length - 1,
                () {
                  if (_currentChartIndex < chartModels.length - 1) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                    );
                  }
                },
              ),
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
          color: isEnabled ? Color(0xFF74C95C) : Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Color(0xFF74C95C).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Color(0xFFCCCCCC),
          size: 20,
        ),
      ),
    );
  }
}

// Data Models
class ChartModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  ChartModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}
