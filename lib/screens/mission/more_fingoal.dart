import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/widgets/mission_widgets/goalsquests.dart';

class MoreFingoal extends StatefulWidget {
  const MoreFingoal({super.key});

  @override
  State<MoreFingoal> createState() => _MoreFingoalState();
}

class _MoreFingoalState extends State<MoreFingoal> {

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
          child: _buildFinancialGoals(),
        ),
      ),
    );
  }

    Widget _buildFinancialGoals() {
    return GoalQuestsWidget(
      title: '',
      onSeeAllPressed: null,
      contents: [
        GoalQuestsCard(
          icon: Image.asset('assets/images/Flag_of_Thailand.png', width: 40,),
          title: 'Trip to Thailand',
          barColor: 0xFFFFCF10,
          bgColor: 0xFFFFEDCA,
          progress: '956 / 1200',
          unit: 'MYR',
          rewards: ['12 exp'],
        ),
        GoalQuestsCard(
          icon: Image.asset('assets/images/Flag_of_Thailand.png', width: 40,),
          title: 'Trip to Thailand',
          barColor: 0xFFFFCF10,
          bgColor: 0xFFFFEDCA,
          progress: '956 / 1200',
          unit: 'MYR',
          rewards: ['12 exp'],
        ),
        GoalQuestsCard(
          icon: Image.asset('assets/images/Flag_of_Thailand.png', width: 40,),
          title: 'Trip to Thailand',
          barColor: 0xFFFFCF10,
          bgColor: 0xFFFFEDCA,
          progress: '956 / 1200',
          unit: 'MYR',
          rewards: ['12 exp'],
        ),
        GoalQuestsCard(
          icon: Image.asset('assets/images/Flag_of_Thailand.png', width: 40,),
          title: 'Trip to Thailand',
          barColor: 0xFFFFCF10,
          bgColor: 0xFFFFEDCA,
          progress: '956 / 1200',
          unit: 'MYR',
          rewards: ['12 exp'],
        ),
        GoalQuestsCard(
          icon: Image.asset('assets/images/Flag_of_Thailand.png', width: 40,),
          title: 'Trip to Thailand',
          barColor: 0xFFFFCF10,
          bgColor: 0xFFFFEDCA,
          progress: '956 / 1200',
          unit: 'MYR',
          rewards: ['12 exp'],
        ),
        GoalQuestsCard(
          icon: Image.asset('assets/images/Flag_of_Thailand.png', width: 40,),
          title: 'Trip to Thailand',
          barColor: 0xFFFFCF10,
          bgColor: 0xFFFFEDCA,
          progress: '956 / 1200',
          unit: 'MYR',
          rewards: ['12 exp'],
        ),
      ],
    );
  }
}

