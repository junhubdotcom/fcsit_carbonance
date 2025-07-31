import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MissionTab3 extends StatefulWidget {
  const MissionTab3({super.key});

  @override
  State<MissionTab3> createState() => _MissionTab3State();
}

class _MissionTab3State extends State<MissionTab3> {
  final List<Color> borderColors = [
    Colors.red[100]!,
    Colors.yellow[100]!,
    Colors.green[100]!,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: List.generate(3, (index) => _buildRewardCard(
          imagePath: 'assets/images/gcloud.png',
          rewardText: '10% Google Cloud',
          borderColor: borderColors[index],
          onUseNow: () {
          },
        )),
      ),
    );
  }

  Widget _buildRewardCard({
    required String imagePath,
    required String rewardText,
    required Color borderColor,
    required VoidCallback onUseNow,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              child: Image.asset(
                imagePath,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: borderColor,
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
                    rewardText,
                    style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                    GestureDetector(
                    onTap: onUseNow,
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
