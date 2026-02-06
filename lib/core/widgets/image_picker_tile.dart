import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/enum.dart';
import '../services/image_upload_service.dart';

class ImagePickerTile extends StatelessWidget {
  const ImagePickerTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imageSource,
    required this.completer,
    required this.context,
    required this.setFile,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ImagesSource imageSource;
  final Completer? completer;
  final BuildContext context;
  final Function setFile;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blueAccent.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Center(
            child: Icon(
              icon,
              color: Colors.blueAccent,
              size: 20,
            ),
          ),
        ),
      ),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      trailing: const Icon(
        Icons.arrow_right_outlined,
        size: 20,
        color: Colors.grey,
      ),
      onTap: () {
        ImgaeUploadService.imagePicker(
          imageSource,
          completer,
          context,
          setFile,
        );
      },
    );
  }
}
