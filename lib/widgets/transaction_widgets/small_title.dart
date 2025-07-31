import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmallTitle extends StatelessWidget {
  String title;
  SmallTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style:
              GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
