import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class AppStateManager extends ChangeNotifier {
  AppStateManager() {
   //   Initialize session when class is created
   initializeUserSession();
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isInitialized = false;

  // Initialize user session (runs once per app start)
  Future<void> initializeUserSession() async {
    if (_isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          "isOnline": true, // set online when signing in
          "provider": _getProvider(user),
          "lastSeen": FieldValue.serverTimestamp(),
          "createdAt": FieldValue.serverTimestamp(),
        });
      } else {
        // update online status for existing user
        await userDoc.update({
          "isOnline": true,
          "lastSeen": FieldValue.serverTimestamp(),
        });
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing session: $e');
      _isInitialized = true;
    }
  }


  //   detect which provider user used (google or email)
  String _getProvider (User user) {
    for (final info in user.providerData) {
      if (info.providerId == "google.com") return 'google';
      if (info.providerId == "password") return 'email';
    }
    return 'email';
  }

  bool get initialized => _isInitialized;
}

final appStateManagerProvider = ChangeNotifierProvider<AppStateManager>(
    (ref) {
      return AppStateManager();
    }
);