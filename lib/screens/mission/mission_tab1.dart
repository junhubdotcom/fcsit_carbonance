import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/common/leaderboard_data.dart';
import 'package:steadypunpipi_vhack/screens/mission/more_fingoal.dart';
import 'package:steadypunpipi_vhack/screens/mission/more_susquest.dart';
import 'package:steadypunpipi_vhack/widgets/mission_widgets/goalsquests.dart';
import 'package:steadypunpipi_vhack/widgets/mission_widgets/toggle.dart';
import 'package:steadypunpipi_vhack/common/userdata.dart';
class MissionTab1 extends StatefulWidget {
  const MissionTab1({super.key});

  @override
  State<MissionTab1> createState() => _MissionTab1State();
}

class _MissionTab1State extends State<MissionTab1> {
  final UserData _userData = UserData(); // Initialize UserData

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDailyCheckIn(),
        SizedBox(height: 21),
        _buildFinancialGoals(),
        SizedBox(height: 15),
        _buildSustainableQuests(),
        SizedBox(height: 15),
        _buildLeaderboard(),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          height: 24
        ),
      ],
    );
  }

  Widget _buildDailyCheckIn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Check-in',
          style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              DashedCircularProgressBar.square(
                dimensions: 210,
                progress: (_userData.checkedInDays / 7) * 100,
                startAngle: 230,
                sweepAngle: 290,
                foregroundColor: Colors.green,
                backgroundColor: const Color(0xffeeeeee),
                foregroundStrokeWidth: 7,
                backgroundStrokeWidth: 7,
                foregroundGapSize: 15,
                foregroundDashSize: 24,
                backgroundGapSize: 15,
                backgroundDashSize: 24,
                animation: true,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 24),
                  Image.asset('assets/images/forest.png', width: 120),
                  SizedBox(height: 8),
                  Text("${_userData.totalPoints}",
                      style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 0)),
                  Text('points',
                      style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          height: 0)),
                ],
              )
            ],
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              if (_userData.isCheckedInToday == false) {
                setState(() {
                  _userData.checkIn();
                  _userData.addPoints(30);
                  _userData.updateCheckInStatus(true); 
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFFDCE8D6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_userData.isCheckedInToday == false ? 'Check In' : 'See you tomorrow!',
                style: GoogleFonts.quicksand(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  height: 0
                )
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialGoals() {
    return GoalQuestsWidget(
      title: 'Financial Goals',
      onSeeAllPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MoreFingoal()),
        );
      },
      contents: _userData.financialGoals.isNotEmpty 
          ? [
          GoalQuestsCard(
            icon: _userData.financialGoals.last.icon,
            title: _userData.financialGoals.last.name,
            barColor: 0xFFFFCF10,
            bgColor: 0xFFFFEDCA,
            progress: _userData.financialGoals.last.progressText,
            unit: _userData.financialGoals.last.unit,
            rewards: _userData.financialGoals.last.rewards,
          )
        ]
          : [],
    );
  }

  Widget _buildSustainableQuests() {
    return GoalQuestsWidget(
    title: 'Sustainable Quests',
      onSeeAllPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => MoreSusquest()));
      },
      contents: _userData.sustainableQuests.isNotEmpty 
          ? [
          GoalQuestsCard(
            icon: _userData.sustainableQuests.last.icon,
            title: _userData.sustainableQuests.last.name,
            barColor: 0xFF36BB6D,
            bgColor: 0xFFDCE8D6,
            progress: _userData.sustainableQuests.last.progressText,
            unit: _userData.sustainableQuests.last.unit,
            rewards: _userData.sustainableQuests.last.rewards,
          )
        ]
          : [],
    );
  }

  Widget _buildLeaderboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leaderboard',
          style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        _buildTitle(),
        _buildProgressBar(),
        SizedBox(height: 16),
        _buildLeaderboardCard(),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      _userData.title,
      style: GoogleFonts.caveat(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        height: 0
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    Text("${_userData.experience} exp", style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _userData.experience / 450,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.stars_rounded, size: 24),
          ],
        ),
        SizedBox(height: 4),
        Text("Get ${450 - _userData.experience} more exp to level up",
            style: GoogleFonts.quicksand(fontSize: 12, color: Colors.black)),
      ],
    );
  }

  Widget _buildLeaderboardCard() {
    final leaderboard = LeaderboardData.getLeaderboard(_userData);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedToggle(
            values: const ['Region', 'Global'],
            onToggleCallback: (value) {
              setState(() {
              });
            },
            buttonColor: const Color(0xFFFFC044),
            backgroundColor: const Color(0xFFFFF4DF),
            textColor: const Color(0xFF000000),
          ),
          const SizedBox(height: 12),
          Center(child: _buildTopPlayerProfile(leaderboard.first)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21.0),
            child: _buildLeaderboardList(leaderboard),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text("Show All",
                  style: GoogleFonts.quicksand(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPlayerProfile(LeaderboardPosition player) {
    return Column(
      children: [
        CircleAvatar(radius: 40, backgroundImage: player.avatar),
        const SizedBox(height: 8),
        Text(player.name,
            style: GoogleFonts.quicksand(
                fontSize: 18, fontWeight: FontWeight.bold)),
        Text(player.title, style: GoogleFonts.quicksand(color: Colors.black)),
        Text("${player.experience} exp",
            style: GoogleFonts.quicksand(
                fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardPosition> leaderboard) {
    return Column(
      children: leaderboard.map((player) => _buildLeaderboardRow(
        player,
        isTopRank: player.rank == 1,
        isCurrentUser: player.name == _userData.name,
      )).toList(),
    );
  }

  Widget _buildLeaderboardRow(LeaderboardPosition player,
      {bool isTopRank = false, bool isCurrentUser = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.amber[100] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text("${player.rank}",
              style: GoogleFonts.quicksand(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          CircleAvatar(radius: 16, backgroundImage: player.avatar),
          const SizedBox(width: 15),
          Expanded(
              child: Text(player.name,
                  style: GoogleFonts.quicksand(
                      fontSize: 15, fontWeight: FontWeight.bold))),
          if (isTopRank)
            const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Text("${player.experience} exp",
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
