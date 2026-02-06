import 'dart:developer';
import 'dart:io';

import 'package:chat_app/core/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../extensions/to_file.dart';
import '../extensions/to_file2.dart';

class ImagePickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();
  // Added build context might remove it letter if things did not work as planed with the CustomSnacbar

  static Future<PickedFileWithInfo?> pickImageFromGallery2(
      BuildContext context) async {
    final isGranted = await Permission.photos.isGranted;
    if (!isGranted) {
      await Permission.photos.request();
      showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: "You didn't allow access",
      );
    }

    final pickedFile =
    await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = await pickedFile.toFile();
      log(pickedFile.name.split(".").join(","));
      return PickedFileWithInfo(file: file, fileName: pickedFile.name);
    } else {
      return null;
    }
  }

  static Future<FilePickerResult?> pickFileFromGallery() =>
      FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ["pdf", "doc", "docx", "png", "jpg", "jpeg"]);

  static Future<File?> pickImageFromGallery() =>
      _imagePicker.pickImage(source: ImageSource.gallery).toFile();

  static Future<File?> takePictureFromCamera() =>
      _imagePicker.pickImage(source: ImageSource.camera).toFile();

  static Future<File?> pickVideoFromGallery() =>
      _imagePicker.pickVideo(source: ImageSource.gallery).toFile();

  static Future<FilePickerResult?> pickSinglePDFFileFromGallery() =>
      FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ["pdf"]);
}

class PickedFileWithInfo {
  PickedFileWithInfo({required this.file, required this.fileName});

  final File file;
  final String fileName;
}

PlatformFile? file;
