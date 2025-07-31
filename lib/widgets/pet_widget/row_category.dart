import 'package:flutter/material.dart';

class RowCategory extends StatelessWidget {
  final String rowTitle;
  final List<Map<String, dynamic>> items;
  final Function(String) onItemSelected;

  const RowCategory({
    required this.items,
    required this.rowTitle,
    required this.onItemSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.centerLeft, // Align the title to the left
            child: Text(
              rowTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items.map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CardWidget(
                  imageUrl: item['imageUrl'],
                  isUnlock: item['isUnlock'],
                  onItemSelected: (imageUrl) {
                    onItemSelected(imageUrl);
                  },
                ),
              ),
            );
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200],
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                // onViewMore();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Icon(IconData(0xf5d5, fontFamily: 'MaterialIcons'), color: Colors.black),
                  Text(
                    "View More",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CardWidget extends StatefulWidget {
  final String imageUrl;
  final bool isUnlock;
  final Function(String)? onItemSelected;

  const CardWidget({
    required this.imageUrl,
    required this.isUnlock,
    required this.onItemSelected,
    Key? key,
  }) : super(key: key);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isUnlock
          ? () {
              setState(() {
                isSelected = !isSelected;
                if (isSelected) {
                  // Add the imageUrl to the list if selected
                  widget.onItemSelected?.call(widget.imageUrl);
                } else {
                  // Pass null or handle deselection logic
                  widget.onItemSelected?.call('');
                }
              });
            }
          : null,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border:
                  isSelected ? Border.all(color: Colors.blue, width: 3) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                widget.imageUrl,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (!widget.isUnlock)
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
