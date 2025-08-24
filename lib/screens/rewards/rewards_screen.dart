import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/common/userdata.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final UserData _userData = UserData();
  bool showBookmarkedOnly = false;
  String searchQuery = "";
  late List<RewardItem> rewards;
  late List<RewardItem> purchasedRewards;

  @override
  void initState() {
    super.initState();
    rewards = [
      RewardItem(
        0,
        "10% Google Cloud",
        "Discount voucher",
        "1000 points",
        Image.asset("assets/images/google.png", width: 45, height: 45),
        Colors.green[100]!,
      ),
      RewardItem(
        1,
        "WWF",
        "Donation",
        "150 points",
        Image.asset("assets/images/wwf.png", width: 45, height: 45),
        Colors.blueGrey[100]!,
      ),
      RewardItem(
        2,
        "10% Google Cloud",
        "Discount voucher",
        "1000 points",
        Image.asset("assets/images/google.png", width: 45, height: 45),
        Colors.green[100]!,
      ),
      RewardItem(
        3,
        "WWF",
        "Donation",
        "150 points",
        Image.asset("assets/images/wwf.png", width: 45, height: 45),
        Colors.blueGrey[100]!,
      ),
    ];

    // Initialize purchased rewards (demo data)
    purchasedRewards = [
      RewardItem(
        0,
        "10% Google Cloud",
        "Discount voucher",
        "1000 points",
        Image.asset("assets/images/gcloud.png", width: 45, height: 45),
        Colors.green[100]!,
      ),
      RewardItem(
        1,
        "10% Google Cloud",
        "Discount voucher",
        "1000 points",
        Image.asset("assets/images/gcloud.png", width: 45, height: 45),
        Colors.blue[100]!,
      ),
      RewardItem(
        2,
        "10% Google Cloud",
        "Discount voucher",
        "1000 points",
        Image.asset("assets/images/gcloud.png", width: 45, height: 45),
        Colors.purple[100]!,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove default back button
          title: Text(
            'Rewards',
            style: GoogleFonts.quicksand(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Colors.green[700],
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.green[600],
            tabs: [
              Tab(
                child: Text(
                  'Available',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'My Rewards',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Green Loans',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Available Rewards Tab
            _buildAvailableRewardsTab(),

            // My Rewards Tab
            _buildMyRewardsTab(),

            // Green Loans Tab
            _buildGreenLoansTab(),
          ],
        ),
      ),
    );
  }

  // Available Rewards Tab
  Widget _buildAvailableRewardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with points
          _buildHeader(),
          SizedBox(height: 16),

          // Search and filter
          _buildSearchBar(),
          _buildFilterRow(),
          SizedBox(height: 24),

          // Available Rewards Section
          _buildSectionHeader("Available Rewards", Icons.card_giftcard),
          SizedBox(height: 12),
          _buildAvailableRewards(),
        ],
      ),
    );
  }

  // My Rewards Tab
  Widget _buildMyRewardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Section
          _buildRewardsStats(),
          SizedBox(height: 24),

          // My Rewards Section
          _buildSectionHeader("My Purchased Rewards", Icons.inventory),
          SizedBox(height: 12),
          _buildMyRewards(),
        ],
      ),
    );
  }

  // Green Loans Tab
  Widget _buildGreenLoansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green Loans Section
          _buildSectionHeader("Green Loans", Icons.account_balance),
          SizedBox(height: 8),
          Text(
            "Access sustainable financing based on your environmental impact",
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          _buildIntegratedGreenLoansSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userData.name,
              style: GoogleFonts.caveat(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 9),
            Text("Green points",
                style: GoogleFonts.quicksand(fontSize: 15, height: 0)),
            Text("${_userData.totalPoints}",
                style: GoogleFonts.quicksand(fontSize: 18, height: 0)),
          ],
        ),
        Image.asset("assets/images/girl_tree.png", width: 192, height: 172),
      ],
    );
  }

  Widget _buildRewardsStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Rewards Summary",
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Total Purchased",
                "${purchasedRewards.length}",
                Icons.shopping_bag,
                Colors.blue[100]!,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                "Total Value",
                "${purchasedRewards.length * 1000} pts",
                Icons.monetization_on,
                Colors.green[100]!,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "This Month",
                "${(purchasedRewards.length * 0.3).round()}",
                Icons.calendar_today,
                Colors.orange[100]!,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                "Savings",
                "RM ${(purchasedRewards.length * 50).toString()}",
                Icons.savings,
                Colors.purple[100]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 50,
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: "Search",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("Bookmark only", style: GoogleFonts.quicksand(fontSize: 12)),
        Checkbox(
          value: showBookmarkedOnly,
          onChanged: (value) {
            setState(() {
              showBookmarkedOnly = value ?? false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green[600],
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  // Available Rewards Section
  Widget _buildAvailableRewards() {
    List<RewardItem> filteredRewards = rewards.where((reward) {
      final matchesBookmark = !showBookmarkedOnly || reward.isBookmarked;
      final matchesSearch = reward.title.toLowerCase().contains(searchQuery);
      return matchesBookmark && matchesSearch;
    }).toList();

    return Column(
      children:
          filteredRewards.map((reward) => _buildRewardCard(reward)).toList(),
    );
  }

  // My Rewards Section
  Widget _buildMyRewards() {
    return Column(
      children: purchasedRewards
          .map((reward) => _buildPurchasedRewardCard(reward))
          .toList(),
    );
  }

  // Integrated Green Loans Section
  Widget _buildIntegratedGreenLoansSection() {
    return Column(
      children: [
        // Credit & Eligibility Summary
        _buildCreditSummary(),
        SizedBox(height: 16),

        // Available Loans List
        _buildAvailableLoans(),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCreditSummary() {
    return Card(
      elevation: 2,
      color: Colors.green[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.credit_score,
                  color: Colors.green[600],
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  "Your Green Credit Score",
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCreditItem(
                      "Sustainability Score", "85%", Icons.trending_up),
                ),
                Expanded(
                  child:
                      _buildCreditItem("Carbon Saved", "2.3 tons", Icons.eco),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildCreditItem(
                      "Green Points", "${_userData.totalPoints}", Icons.star),
                ),
                Expanded(
                  child: _buildCreditItem(
                      "Level", "${_userData.level}", Icons.workspace_premium),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100]!,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.green[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Based on your carbon tracking and sustainable activities",
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.green[600]),
            SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableLoans() {
    List<LoanOption> loans = [
      LoanOption(
        "Solar Panel Loan",
        "Install solar panels for your home",
        "RM 25,000 - 100,000",
        "2.8% p.a.",
        "12-60 months",
        Icons.solar_power,
        Colors.orange[100]!,
        true, // Eligible
        "Level 3+ • 500+ pts",
      ),
      LoanOption(
        "Electric Vehicle Loan",
        "Purchase electric or hybrid vehicle",
        "RM 50,000 - 200,000",
        "3.2% p.a.",
        "36-84 months",
        Icons.electric_car,
        Colors.blue[100]!,
        true, // Eligible
        "Level 5+ • 1000+ pts",
      ),
      LoanOption(
        "Green Home Improvement",
        "Energy-efficient home upgrades",
        "RM 10,000 - 50,000",
        "3.5% p.a.",
        "12-36 months",
        Icons.home,
        Colors.green[100]!,
        false, // Not eligible
        "Level 7+ • 2000+ pts",
      ),
      LoanOption(
        "Carbon Offset Investment",
        "Invest in carbon offset projects",
        "RM 5,000 - 25,000",
        "2.5% p.a.",
        "12-24 months",
        Icons.forest,
        Colors.brown[100]!,
        true, // Eligible
        "Level 2+ • 300+ pts",
      ),
      LoanOption(
        "Sustainable Business Loan",
        "Start or expand green business",
        "RM 100,000 - 500,000",
        "4.0% p.a.",
        "60-120 months",
        Icons.business,
        Colors.purple[100]!,
        false, // Not eligible
        "Level 10+ • 5000+ pts",
      ),
    ];

    return Column(
      children: loans.map((loan) => _buildLoanCard(loan)).toList(),
    );
  }

  Widget _buildLoanCard(LoanOption loan) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: loan.isEligible ? Colors.green[300]! : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: loan.isEligible
                        ? Colors.green[100]!
                        : Colors.grey[100]!,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: loan.isEligible
                          ? Colors.green[300]!
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Icon(
                    loan.icon,
                    color: loan.isEligible
                        ? Colors.green[700]!
                        : Colors.grey[600]!,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.title,
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        loan.description,
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        loan.isEligible ? Colors.green[100]! : Colors.red[50]!,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: loan.isEligible
                          ? Colors.green[400]!
                          : Colors.red[300]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        loan.isEligible ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: loan.isEligible
                            ? Colors.green[700]!
                            : Colors.red[600]!,
                      ),
                      SizedBox(width: 4),
                      Text(
                        loan.isEligible ? "Eligible" : "Not Eligible",
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: loan.isEligible
                              ? Colors.green[700]!
                              : Colors.red[600]!,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildLoanDetail("Amount", loan.amount),
                      ),
                      Expanded(
                        child: _buildLoanDetail("Rate", loan.interestRate),
                      ),
                      Expanded(
                        child: _buildLoanDetail("Term", loan.term),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50]!,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: Colors.blue[600]),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Requirements: ${loan.requirements}",
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loan.isEligible
                    ? () {
                        _showLoanApplication(loan);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      loan.isEligible ? Colors.green[600] : Colors.grey[300],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: loan.isEligible ? 3 : 0,
                  shadowColor:
                      loan.isEligible ? Colors.green[200] : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      loan.isEligible ? Icons.rocket_launch : Icons.lock,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      loan.isEligible ? "Apply Now" : "Requirements Not Met",
                      style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  void _showLoanApplication(LoanOption loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLoanApplicationModal(loan),
    );
  }

  Widget _buildLoanApplicationModal(LoanOption loan) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(loan.icon, size: 24, color: Colors.grey[700]),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loan.title,
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Loan Details
            _buildApplicationDetail("Loan Amount", loan.amount),
            _buildApplicationDetail("Interest Rate", loan.interestRate),
            _buildApplicationDetail("Loan Term", loan.term),
            _buildApplicationDetail("Monthly Payment", "RM 1,200"),
            _buildApplicationDetail("Total Interest", "RM 8,640"),

            Spacer(),

            // Apply Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Application submitted for ${loan.title}!"),
                      backgroundColor: Colors.green[600],
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Submit Application",
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.green[600]),
            SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard(RewardItem reward) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.5),
          child: Card(
            margin: EdgeInsets.only(bottom: 12),
            color: reward.backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
              child: Row(
                children: [
                  SizedBox(width: 18),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: reward.image,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reward.title,
                            style: GoogleFonts.quicksand(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        Text(reward.subtitle,
                            style: GoogleFonts.quicksand(
                                fontSize: 12, fontWeight: FontWeight.normal)),
                        SizedBox(height: 6),
                        Text(reward.points,
                            style: GoogleFonts.quicksand(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_userData.totalPoints <
                          int.parse(reward.points.split(" ")[0])) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Not enough points!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      } else {
                        setState(() {
                          _userData.addPoints(
                              -int.parse(reward.points.split(" ")[0]));
                          reward._isBought = true;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Bought ${reward.title}"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        });
                      }
                    },
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(83),
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(82),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      padding: EdgeInsets.all(8),
                      child: reward._isBought == false
                          ? Icon(Icons.add, size: 24)
                          : Icon(Icons.check, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 9.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                reward.toggleBookmark();
              });
            },
            child: Icon(
              reward.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: reward.isBookmarked ? Colors.blue : Colors.black,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchasedRewardCard(RewardItem reward) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: reward.image,
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: reward.backgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    reward.title,
                    style: GoogleFonts.quicksand(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Using ${reward.title}"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      "Use Now",
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RewardItem {
  final int index;
  final String title;
  final String subtitle;
  final String points;
  final Widget image;
  final Color backgroundColor;
  bool _isBought = false;
  bool _isBookmarked = false;

  RewardItem(this.index, this.title, this.subtitle, this.points, this.image,
      this.backgroundColor);

  bool get isBookmarked => _isBookmarked;

  void toggleBookmark() {
    _isBookmarked = !_isBookmarked;
  }
}

class LoanOption {
  final String title;
  final String description;
  final String amount;
  final String interestRate;
  final String term;
  final IconData icon;
  final Color backgroundColor;
  final bool isEligible;
  final String requirements;

  LoanOption(
    this.title,
    this.description,
    this.amount,
    this.interestRate,
    this.term,
    this.icon,
    this.backgroundColor,
    this.isEligible,
    this.requirements,
  );
}
