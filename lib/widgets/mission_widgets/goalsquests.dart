import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/widgets/mission_widgets/listview.dart';

class GoalQuestsWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;
  final List<GoalQuestsCard> contents;

  const GoalQuestsWidget({
    super.key,
    required this.title,
    this.onSeeAllPressed,
    required this.contents,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onSeeAllPressed != null && title.isNotEmpty) 
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 9),
            GestureDetector(
              onTap: onSeeAllPressed,
              child: const Icon(Icons.arrow_forward, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: contents.map((quest) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: quest,
          )).toList(),
        ),
      ],
    );
  }
}

class GoalQuestsCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final int barColor;
  final int bgColor;
  final String progress;
  final String unit;
  final List<String> rewards;

  const GoalQuestsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.barColor,
    required this.bgColor,
    required this.progress,
    required this.unit,
    required this.rewards,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(bgColor),
      child: ListviewWidget(
        asset: icon,
        title: title,
        hexColor: barColor,
        progress: progress,
        unit: unit,
        rewards: rewards,
      ),
    );
  }
}