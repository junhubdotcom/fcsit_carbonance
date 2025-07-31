import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListviewWidget extends StatelessWidget {

  final Widget asset;
  final String title;
  final String progress;
  final String unit;
  final int hexColor;
  final List rewards;

  const ListviewWidget({
    super.key,
    required this.asset,
    required this.title,
    required this.hexColor,
    required this.progress,
    required this.unit,
    required this.rewards,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          SizedBox(
            width: 40,
            child: asset),
      title: Text(
        title,
        style: GoogleFonts.quicksand(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Stack(
        alignment: Alignment.centerLeft,
        children: [
          LinearProgressIndicator(
            value: double.parse(progress.split('/')[0]) / double.parse(progress.split('/')[1]),
            minHeight: 18,
            backgroundColor: Color(0xFFF2F2F2),
            valueColor: AlwaysStoppedAnimation<Color>(Color(hexColor)),
            borderRadius: BorderRadius.circular(8),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.0),
            child: Text(
              "$progress $unit",
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      dense: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: rewards.map<Widget>((reward) {
          return Text(
            reward,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }
}