import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Indicator extends StatelessWidget {
  final String title;
  final String value;

  const Indicator({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style:
              GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
