import 'package:flutter/material.dart';

class ItemButton extends StatefulWidget {
  VoidCallback onPressed;
  IconData icon;
  ItemButton({required this.onPressed, required this.icon, super.key});

  @override
  State<ItemButton> createState() => _ItemButtonState();
}

class _ItemButtonState extends State<ItemButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: 45,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // borderRadius: BorderRadius.circular(5),
        color: Colors.black, // Background color
        // shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: widget.onPressed,
        icon: Icon(widget.icon),
        color: Colors.white, // Icon color
        iconSize: 20,
      ),
    );
  }
}
