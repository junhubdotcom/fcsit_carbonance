import 'package:flutter/material.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';

class TransactionTextfield extends StatelessWidget {
  String? value;
  final Function(String?) onChanged;
  List<ExpenseItem> itemModels = [
    ExpenseItem(),
  ];

  TransactionTextfield({this.value, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: TextFormField(
          onChanged: onChanged,
          initialValue: value,
          style: TextStyle(
              fontWeight: FontWeight.w400, color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xffe6e6e6),
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          )),
    );
  }
}
