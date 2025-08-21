import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/common/userdata.dart';

class MissionTab2 extends StatefulWidget {
  const MissionTab2({super.key});

  @override
  State<MissionTab2> createState() => _MissionTab2State();
}

class _MissionTab2State extends State<MissionTab2> {
  final UserData _userData = UserData();
  bool showBookmarkedOnly = false;
  String searchQuery = "";
  late List<RewardItem> rewards;
  late List<LoanItem> loans; // NEW: Add loans list

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
          Colors.green[100]!),
      RewardItem(
          1,
          "WWF",
          "Donation",
          "150 points",
          Image.asset("assets/images/wwf.png", width: 45, height: 45),
          Colors.blueGrey[100]!),
      RewardItem(
          2,
          "10% Google Cloud",
          "Discount voucher",
          "1000 points",
          Image.asset("assets/images/google.png", width: 45, height: 45),
          Colors.green[100]!),
      RewardItem(
          3,
          "WWF",
          "Donation",
          "150 points",
          Image.asset("assets/images/wwf.png", width: 45, height: 45),
          Colors.blueGrey[100]!),
    ];

    // NEW: Initialize loans
    loans = [
      LoanItem(
        0,
        "Eco Starter Loan",
        "Basic green loan for sustainability projects",
        "1000 points",
        "RM 5,000",
        "5.5%",
        Icons.eco,
        Colors.green[100]!,
        requiredLevel: 1,
        requiredPoints: 1000,
      ),
      LoanItem(
        1,
        "Sustainability Plus Loan",
        "Enhanced loan for eco-friendly initiatives",
        "2000 points",
        "RM 15,000",
        "4.2%",
        Icons.trending_up,
        Colors.blue[100]!,
        requiredLevel: 3,
        requiredPoints: 2000,
      ),
      LoanItem(
        2,
        "Green Premium Loan",
        "Premium loan for large environmental projects",
        "5000 points",
        "RM 50,000",
        "3.8%",
        Icons.diamond,
        Colors.purple[100]!,
        requiredLevel: 5,
        requiredPoints: 5000,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: _buildHeader(),
            ),
            SizedBox(height: 16),
            _buildSearchBar(),
            _buildFilterRow(),

            // Rewards Section
            _buildSectionHeader("Rewards & Discounts", Icons.card_giftcard),
            SizedBox(height: 8),
            _buildRewardsList(),

            SizedBox(height: 24),

            // Loans Section - More prominent
            _buildSectionHeader("Green Loans", Icons.account_balance),
            SizedBox(height: 8),
            _buildLoansSection(),
          ],
        ),
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

  Widget _buildRewardsList() {
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
                reward.toggleBookmark(); // Use the new method
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

  // NEW: Build section headers
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

  // NEW: Build loans section - more compact and prominent
  Widget _buildLoansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Unlock loans based on your sustainability progress",
          style: GoogleFonts.quicksand(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 12),
        ...loans.map((loan) => _buildLoanCard(loan)).toList(),
      ],
    );
  }

  // UPDATED: Build individual loan card - more compact and distinct
  Widget _buildLoanCard(LoanItem loan) {
    bool isEligible = _userData.totalPoints >= loan.requiredPoints &&
        _userData.level >= loan.requiredLevel;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        color: loan.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isEligible ? Colors.green[300]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      loan.icon,
                      color: Colors.green[600],
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan.title,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          loan.description,
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isEligible ? Colors.green[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isEligible ? "Available" : "Locked",
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color:
                            isEligible ? Colors.green[700] : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildLoanDetail("Amount", loan.amount),
                  ),
                  Expanded(
                    child: _buildLoanDetail("Interest", loan.interestRate),
                  ),
                  Expanded(
                    child: _buildLoanDetail("Cost", loan.pointsCost),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Level ${loan.requiredLevel} • ${loan.requiredPoints} points",
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isEligible ? () => _applyForLoan(loan) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isEligible ? Colors.green[600] : Colors.grey[300],
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isEligible ? "Apply" : "Locked",
                      style: GoogleFonts.quicksand(
                        color: isEligible ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // NEW: Handle loan application
  void _applyForLoan(LoanItem loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Apply for ${loan.title}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Loan Amount: ${loan.amount}"),
            Text("Interest Rate: ${loan.interestRate}"),
            Text("Points Required: ${loan.pointsCost}"),
            SizedBox(height: 16),
            Text(
              "Your eligibility:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("• Points: ${_userData.totalPoints}/${loan.requiredPoints} ✓"),
            Text("• Level: ${_userData.level}/${loan.requiredLevel} ✓"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Demo: Deduct points and show success
              setState(() {
                _userData.addPoints(-loan.requiredPoints);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Loan application submitted successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text("Confirm Application"),
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
  bool _isBookmarked = false; // Add this line

  RewardItem(this.index, this.title, this.subtitle, this.points, this.image,
      this.backgroundColor);

  // Add getter for bookmark status
  bool get isBookmarked => _isBookmarked;

  // Add method to toggle bookmark
  void toggleBookmark() {
    _isBookmarked = !_isBookmarked;
  }
}

// NEW: Loan item class
class LoanItem {
  final int index;
  final String title;
  final String description;
  final String pointsCost;
  final String amount;
  final String interestRate;
  final IconData icon;
  final Color backgroundColor;
  final int requiredLevel;
  final int requiredPoints;

  LoanItem(
    this.index,
    this.title,
    this.description,
    this.pointsCost,
    this.amount,
    this.interestRate,
    this.icon,
    this.backgroundColor, {
    required this.requiredLevel,
    required this.requiredPoints,
  });
}
