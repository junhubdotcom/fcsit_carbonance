import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionButton extends StatefulWidget {
  Color textColor;
  Color backgroundColor;
  Color borderColor;
  String buttonText;
  VoidCallback onPressed;
  TransactionButton(
      {required this.textColor,
      required this.backgroundColor,
      required this.borderColor,
      required this.buttonText,
      required this.onPressed,
      super.key});

  @override
  State<TransactionButton> createState() => _TransactionButtonState();
}

class _TransactionButtonState extends State<TransactionButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 8),
          elevation: 0,
          backgroundColor: widget.backgroundColor,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: widget.borderColor, width: 1),
          ),
        ),
        onPressed: widget.onPressed,
        child: Text(widget.buttonText,
            style: GoogleFonts.quicksand(
                fontSize: 18,
                color: widget.textColor,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
