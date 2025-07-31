import 'package:flutter/material.dart';

class ItemHeader extends StatelessWidget {
  const ItemHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      
      children: [
        Expanded(flex: 2, child: Text('Name')),
        SizedBox(
          width: 5,
        ),
        Expanded(flex: 2, child: Text('Category')),
        SizedBox(
          width: 5,
        ),
        Expanded(flex: 1, child: Text('Qty')),
        SizedBox(
          width: 5,
        ),
        Expanded(flex: 2, child: Text('Price')),
      ],
    );
  }
}
