import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Description extends StatelessWidget {
  IconData icon;
  String text;

  Description({required this.icon, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: GoogleFonts.quicksand(
                fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
