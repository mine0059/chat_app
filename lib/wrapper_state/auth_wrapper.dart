import 'dart:async';

import 'package:chat_app/chat/screen/app_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state_manager.dart';

class AuthenticationWrapper extends ConsumerStatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  ConsumerState<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends ConsumerState<AuthenticationWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initializedSession();
  }

  Future<void> initializedSession() async {
    try {
      final appManager = ref.read(appStateManagerProvider);
      // Run session initialization with timeout (max 10s)
      await Future.any([
        appManager.initializeUserSession(),
        Future.delayed(
          const Duration(seconds: 10),
            () => throw TimeoutException('Session init timed out'),
        ),
      ]);

      if (mounted) {
        setState(() {
          _isInitialized = true; // move to home screen after init
        });
      }
    } catch (e) {
      debugPrint("Error initializing session: $e");
      if (mounted) {
        // still allow moving forward even if init fails
        setState(() {
          _isInitialized = true; // prevent infinite loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text("Setting up your account..."),
            ],
          ),
        ),
      );
    }
    return const AppMainScreen();
  }
}
