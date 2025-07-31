import 'package:flutter/material.dart';

class RecordTransactionDropdown extends StatefulWidget {
  final String value;
  final Function(String?) onChanged;
  final List<String> items;

  RecordTransactionDropdown(
      {required this.value,
      required this.onChanged,
      required this.items,
      super.key});

  @override
  State<RecordTransactionDropdown> createState() =>
      _RecordTransactionDropdownState();
}

class _RecordTransactionDropdownState extends State<RecordTransactionDropdown> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              filled: true,
              fillColor: Color(0xffe6e6e6),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none)),
          value: widget.value,
          style: TextStyle(
              fontWeight: FontWeight.w400, color: Colors.black, fontSize: 16),
          icon: Icon(Icons.arrow_drop_down),
          onChanged: widget.onChanged,
          items: widget.items
              .map((category) => DropdownMenuItem<String>(
                    child: Text(category),
                    value: category,
                  ))
              .toList()),
    );
  }
}
