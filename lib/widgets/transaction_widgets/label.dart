import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Label extends StatelessWidget {
  const Label({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      margin: EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
          color: Color(0xffffc670), borderRadius: BorderRadius.circular(3)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_pizza_sharp,
            size: 13,
          ),
          Text(
            'Food',
            style: GoogleFonts.quicksand(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
