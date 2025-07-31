import 'package:flutter/material.dart';
import 'package:steadypunpipi_vhack/common/userdata.dart';

class LeaderboardPosition {
  final int rank;
  final String name;
  final NetworkImage avatar;
  final int experience;
  final String title;

  LeaderboardPosition({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.experience,
    required this.title,
  });
}

class LeaderboardData {
  static List<LeaderboardPosition> getLeaderboard(UserData userData) {
    return [
      LeaderboardPosition(
        rank: 1,
        name: "Jun Wei",
        avatar: NetworkImage('https://i.pravatar.cc/150?img=3'),
        experience: 150000,
        title: "Eco King",
      ),
      LeaderboardPosition(
        rank: 2,
        name: "Ci En",
        avatar: NetworkImage('https://i.pravatar.cc/150?img=5'),
        experience: 6210,
        title: "Eco Warrior",
      ),
      LeaderboardPosition(
        rank: 3,
        name: "Joe Ying",
        avatar: NetworkImage('https://i.pravatar.cc/150?img=7'),
        experience: 3400,
        title: "Green Guardian",
      ),
      LeaderboardPosition(
        rank: userData.rank,
        name: userData.name,
        avatar: userData.avatarUrl,
        experience: userData.experience,
        title: userData.title,
      ),
    ]..sort((a, b) => a.rank.compareTo(b.rank));
  }
}