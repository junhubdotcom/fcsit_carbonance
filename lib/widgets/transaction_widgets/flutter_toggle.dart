import 'package:flutter/material.dart';

class FilterToggle extends StatefulWidget {
  List<bool> isSelected;
  Function(int) OnPressed;
  List<Widget> toggleWidget;
  FilterToggle(
      {required this.isSelected,
      required this.OnPressed,
      required this.toggleWidget,
      super.key});

  @override
  State<FilterToggle> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<FilterToggle> {
  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: widget.isSelected,
      onPressed: widget.OnPressed,
      borderRadius: BorderRadius.circular(10),
      selectedColor: Colors.white,
      color: Colors.black,
      fillColor: Colors.grey.shade600,
      constraints: const BoxConstraints(minHeight: 40, minWidth: 90),
      children: widget.toggleWidget,
    );
  }
}
