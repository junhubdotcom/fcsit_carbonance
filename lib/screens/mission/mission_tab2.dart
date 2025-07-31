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

  @override
  void initState() {
    super.initState();
    rewards = [
      RewardItem(0, "10% Google Cloud", "Discount voucher", "1000 points",
          Image.asset("assets/images/google.png", width: 45, height: 45), Colors.green[100]!),
      RewardItem(1, "WWF", "Donation", "150 points",
          Image.asset("assets/images/wwf.png", width: 45, height: 45), Colors.blueGrey[100]!),
      RewardItem(2, "10% Google Cloud", "Discount voucher", "1000 points",
          Image.asset("assets/images/google.png", width: 45, height: 45), Colors.green[100]!),
      RewardItem(3, "WWF", "Donation", "150 points",
          Image.asset("assets/images/wwf.png", width: 45, height: 45), Colors.blueGrey[100]!),
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
            _buildRewardsList(),
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
            Text("Green points", style: GoogleFonts.quicksand(fontSize: 15, height: 0)),
            Text("${_userData.totalPoints}", style: GoogleFonts.quicksand(fontSize: 18, height: 0)),
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
      children: filteredRewards.map((reward) => _buildRewardCard(reward)).toList(),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
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
                            style: GoogleFonts.quicksand(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text(reward.subtitle,
                            style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.normal)),
                        SizedBox(height: 6),
                        Text(reward.points,
                            style: GoogleFonts.quicksand(fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_userData.totalPoints < int.parse(reward.points.split(" ")[0])) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Not enough points!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      } else {
                        setState(() {
                          _userData.addPoints(-int.parse(reward.points.split(" ")[0]));
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
                      child: reward._isBought == false ? Icon(Icons.add, size: 24) : Icon(Icons.check, size: 24),
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
                reward.toggleBookmark();  // Use the new method
              });
            },
            child: Icon(
              reward.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: reward.isBookmarked ? Colors.blue : Colors.black,
              size: 30,
            ),
          ),
        ),
      ],
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
  bool _isBookmarked = false;  // Add this line

  RewardItem(this.index, this.title, this.subtitle, this.points, this.image, this.backgroundColor);

  // Add getter for bookmark status
  bool get isBookmarked => _isBookmarked;
  
  // Add method to toggle bookmark
  void toggleBookmark() {
    _isBookmarked = !_isBookmarked;
  }
}
