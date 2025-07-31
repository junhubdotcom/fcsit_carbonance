import 'package:flutter/material.dart';

class ImageRow extends StatelessWidget {
  List<String> imageList;
  ImageRow({required this.imageList, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: imageList.map((imagePath) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                fit: BoxFit.cover,
                imageList[0],
                height: 100,
                width: 100,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
