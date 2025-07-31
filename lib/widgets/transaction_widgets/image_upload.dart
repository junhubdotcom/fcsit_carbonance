import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImageUpload extends StatefulWidget {
  List<Widget>? listTiles;
  String? imgPath;

  ImageUpload({required this.listTiles, this.imgPath, super.key});

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return SizedBox(
                height: 200,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  children: widget.listTiles!,
                ),
              );
            });
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            color: Color(0xffe6e6e6), borderRadius: BorderRadius.circular(10)),
        child: widget.imgPath != null && widget.imgPath!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(widget.imgPath!),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                Icons.add,
                size: 28,
              ),
      ),
    );
  }
}
