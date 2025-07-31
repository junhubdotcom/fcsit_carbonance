import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double opacity;

  const CircularButton({super.key, 
    required this.icon,
    required this.onPressed,
    this.opacity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
        backgroundColor: Colors.black.withOpacity(opacity),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}