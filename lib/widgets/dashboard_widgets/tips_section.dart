import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/expandable_card.dart';

class TipsSection extends StatelessWidget {
  final List<String> financeTips;
  final List<String> environmentTips;

  const TipsSection({required this.financeTips, required this.environmentTips});

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      title: "Tips",
      subtitle: "Smart moves for a better future",
      icon: Icons.tips_and_updates,
      tabs: const [
        Tab(text: "Finance"),
        Tab(text: "Environment"),
      ],
      tabViews: [
        _buildTipsList(financeTips, Icons.savings), // Finance Tab
        _buildTipsList(environmentTips, Icons.eco), // Environment Tab
      ],
    );
  }

  Widget _buildTipsList(List<String> tips, IconData icon) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  color: Colors.grey[700], size: 18), // Small, subtle icon
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tips[index],
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
