import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/enum.dart';
import '../utils/image_picker_helper.dart';
import '../widgets/image_picker_tile.dart';

class ImgaeUploadService {
  /// Pick image from camera and gallery
  static void imagePicker(
      ImagesSource imageSource,
      Completer? completer,
      BuildContext context,
      Function setFile,
      ) async {
    if (imageSource == ImagesSource.gallery) {
      final pickedFile = await ImagePickerHelper.pickImageFromGallery();
      if (pickedFile == null) {
        return;
      }
      completer?.complete(pickedFile.path);
      if (!context.mounted) {
        return;
      }
      setFile(pickedFile);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } else if (imageSource == ImagesSource.camera) {
      final pickedFile = await ImagePickerHelper.takePictureFromCamera();
      if (pickedFile == null) {
        return;
      }

      completer?.complete(pickedFile.path);
      if (!context.mounted) {
        return;
      }
      setFile(pickedFile);

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // modal for selecting file source
  static Future showFilePickerButtonSheet(
      BuildContext context,
      Completer? completer,
      Function setFile,
      ) {
    return showModalBottomSheet(
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      context: context,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 14, 15, 20),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    width: 50,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: const Color(0xffE4E4E4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Align(
                            alignment: Alignment.topRight,
                            child: Icon(Icons.close, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Select Image Source',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ImagePickerTile(
                          title: 'Capture from Camera',
                          subtitle: 'Take a live snapshot',
                          // icon: Iconsax.camera,
                          icon: Icons.camera,
                          imageSource: ImagesSource.camera,
                          completer: completer,
                          context: context,
                          setFile: setFile,
                        ),
                        // const Divider(color: Color(0xffE4E4E4)),
                        Divider(color: Colors.grey[200]),
                        ImagePickerTile(
                          title: 'Upload from Gallery',
                          subtitle: 'Select image from gallery',
                          // icon: Iconsax.gallery,
                          icon: Icons.image,
                          imageSource: ImagesSource.gallery,
                          completer: completer,
                          context: context,
                          setFile: setFile,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
