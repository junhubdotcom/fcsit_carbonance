import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Label extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  const Label({
    required this.color,
    required this.icon,
    required this.text,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      margin: EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(3)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
          ),
          Text(
            text,
            style: GoogleFonts.quicksand(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
