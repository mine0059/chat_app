import 'package:flutter/material.dart';

import '../constants/enum.dart';


class CustomSnackBar extends StatelessWidget {
  const CustomSnackBar({
    super.key,
    required this.type,
    required this.message,
  });
  final SnackBarType type;
  final String message;

  void show(BuildContext context) {
    // Get the ScaffoldMessenger instance once and reuse it
    final ScaffoldMessengerState scaffoldMessenger =
    ScaffoldMessenger.of(context);

    // Clear any existing SnackBars before showing a new one
    scaffoldMessenger.clearSnackBars();

    // Show the SnackBar
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(
              snackbarTypeMap[type]![1] as IconData,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: snackbarTypeMap[type]![0] as Color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            scaffoldMessenger.clearSnackBars(); // Use the stored instance
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
