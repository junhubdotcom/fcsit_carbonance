import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/widgets/mission_widgets/goalsquests.dart';

class MoreSusquest extends StatefulWidget {
  const MoreSusquest({super.key});

  @override
  State<MoreSusquest> createState() => _MoreSusquestState();
}

class _MoreSusquestState extends State<MoreSusquest> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financial Goals',
          style: GoogleFonts.quicksand(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildSusQuests(),
        ),
      ),
    );
  }

  Widget _buildSusQuests() {
    return GoalQuestsWidget(
      title: '',
      onSeeAllPressed: null,
      contents: [
        GoalQuestsCard(
          icon: Icon(Icons.train_rounded, size: 40),
          title: 'Public Transport Week',
          barColor: 0xFF36BB6D,
          bgColor: 0xFFDCE8D6,
          progress: '2 / 7',
          unit: 'days',
          rewards: ['30 exp', '30 points'],
        ),
        GoalQuestsCard(
          icon: Icon(Icons.train_rounded, size: 40),
          title: 'Public Transport Week',
          barColor: 0xFF36BB6D,
          bgColor: 0xFFDCE8D6,
          progress: '2 / 7',
          unit: 'days',
          rewards: ['30 exp', '30 points'],
        ),
        GoalQuestsCard(
          icon: Icon(Icons.train_rounded, size: 40),
          title: 'Public Transport Week',
          barColor: 0xFF36BB6D,
          bgColor: 0xFFDCE8D6,
          progress: '2 / 7',
          unit: 'days',
          rewards: ['30 exp', '30 points'],
        ),
        GoalQuestsCard(
          icon: Icon(Icons.train_rounded, size: 40),
          title: 'Public Transport Week',
          barColor: 0xFF36BB6D,
          bgColor: 0xFFDCE8D6,
          progress: '2 / 7',
          unit: 'days',
          rewards: ['30 exp', '30 points'],
        ),
        GoalQuestsCard(
          icon: Icon(Icons.train_rounded, size: 40),
          title: 'Public Transport Week',
          barColor: 0xFF36BB6D,
          bgColor: 0xFFDCE8D6,
          progress: '2 / 7',
          unit: 'days',
          rewards: ['30 exp', '30 points'],
        ),
        GoalQuestsCard(
          icon: Icon(Icons.train_rounded, size: 40),
          title: 'Public Transport Week',
          barColor: 0xFF36BB6D,
          bgColor: 0xFFDCE8D6,
          progress: '2 / 7',
          unit: 'days',
          rewards: ['30 exp', '30 points'],
        ),
      ],
    );
  }
}

