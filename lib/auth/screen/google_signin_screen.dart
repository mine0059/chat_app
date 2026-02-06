import 'package:chat_app/chat/screen/app_main_screen.dart';
import 'package:chat_app/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

import '../../core/utils/utils.dart';
import '../../core/services/route.dart';
import '../service/google_service.dart';

class GoogleSigninScreen extends StatefulWidget {
  const GoogleSigninScreen({super.key});

  @override
  State<GoogleSigninScreen> createState() => _GoogleSigninScreenState();
}

class _GoogleSigninScreenState extends State<GoogleSigninScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userCredential = await GoogleService.signInWithGoogle();
      if(!mounted) return;
      if (userCredential != null) {
        if (!mounted) return;
        // Navigation to the next screen if success
        NavigationHelper.pushReplacement(context, AppMainScreen());
        // Sign-in successful
        debugPrint('User signed in: ${userCredential.user?.displayName}');
      }
    } catch (e) {
      if(!mounted) return;
      showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: 'Google Login failed'
      );
      debugPrint('Sign in error $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomFilledButton(
      isLoading: _isLoading,
      label: 'Sign up with Google',
      isFullWidth: true,
      useGradient: false,
      onPressed: _signInWithGoogle,
      backgroundColor: Colors.grey[200],
      labelColor: Colors.black54,
    );
          // return SizedBox(
          //   width: double.maxFinite,
          //   child: ElevatedButton(
          //     onPressed: _signInWithGoogle,
          //     style: ElevatedButton.styleFrom(
          //         elevation: 0,
          //         backgroundColor: Colors.grey,
          //         padding: EdgeInsets.symmetric(
          //           horizontal: 20,
          //           vertical: 12,
          //         ),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(8),
          //         )
          //     ),
          //     child: _isLoading ? const CircularProgressIndicator() : Text(
          //       'Sign in with Google',
          //       style: TextStyle(
          //         fontSize: 20,
          //         color: Colors.black,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // );
  }
}
