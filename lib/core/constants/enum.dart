import 'package:flutter/material.dart';

enum SnackBarType { success, fail, information }

enum MediaType { image, video, audio }

enum ImagesSource { camera, gallery }


// Mapping of SnackBarType to [Color, IconData] pairs
const Map<SnackBarType, List<Object>> snackbarTypeMap =
<SnackBarType, List<Object>>{
  SnackBarType.success: <Object>[Colors.green, Icons.check_circle_outline],
  SnackBarType.fail: <Object>[Colors.redAccent, Icons.close],
  SnackBarType.information: <Object>[Colors.blue, Icons.info_outline],
};