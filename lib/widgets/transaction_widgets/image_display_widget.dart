import 'dart:io';

import 'package:flutter/material.dart';

class ImageDisplayWidget extends StatelessWidget {
  String imgPath;
  ImageDisplayWidget({required this.imgPath, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          color: Color(0xffe6e6e6), borderRadius: BorderRadius.circular(10)),
      child: imgPath != ""
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(imgPath!),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.image,
              size: 28,
            ),
    );
  }
}
