import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsButton extends StatelessWidget {
  int textColor;
  int buttonColor;
  VoidCallback onPressed;
  String button_text;

  DetailsButton(
      {required this.textColor,
      required this.buttonColor,
      required this.onPressed,
      required this.button_text,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(buttonColor),
        ),
        child: Text(
          button_text,
          style: GoogleFonts.quicksand(
              color: Color(textColor),
              fontWeight: FontWeight.w900,
              fontSize: 15),
        ),
      ),
    );
  }
}
