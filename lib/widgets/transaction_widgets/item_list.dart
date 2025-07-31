import 'package:flutter/material.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/record_transaction_dropdown.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/transaction_textfield.dart';

class ItemList extends StatefulWidget {
  final ExpenseItem item;
  final Function(String?) onNameChanged;
  final Function(String?) onPriceChanged;
  final Function(String?) onQuantityChanged;
  final Function(String?) onCategoryChanged;
  ItemList(
      {required this.item,
      required this.onNameChanged,
      required this.onPriceChanged,
      required this.onQuantityChanged,
      required this.onCategoryChanged,
      super.key});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: TransactionTextfield(
                onChanged: widget.onNameChanged,
                value: widget.item.name,
              )),
          SizedBox(width: 5),
          Expanded(
            flex: 2,
            child: RecordTransactionDropdown(
                value: widget.item.category,
                onChanged: widget.onCategoryChanged,
                items: [
                  "Food",
                  "Housing",
                  "Debt Repayment",
                  "Medical",
                  "Transport",
                  "Utilities",
                  "Shopping",
                  "Tax"
                ]),
          ),
          SizedBox(width: 5),
          Expanded(
              flex: 1,
              child: TransactionTextfield(
                onChanged: widget.onQuantityChanged,
                value: widget.item.quantity.toString(),
              )),
          SizedBox(width: 5),
          Expanded(
              flex: 2,
              child: TransactionTextfield(
                onChanged: widget.onPriceChanged,
                value: widget.item.price.toString(),
              )),
        ],
      ),
    );
  }
}
