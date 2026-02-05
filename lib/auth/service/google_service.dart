import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialize = false;

  static Future<void> initSignin() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(
        serverClientId: '56797707286-ukq7qmgqfnns291sul9fbvgs10g62i8b.apps.googleusercontent.com'
      );
    }
    isInitialize = true;
  }

  //  sign in with Google
  static Future<UserCredential> signInWithGoogle() async {
    try {
      initSignin();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;
      GoogleSignInClientAuthorization? authorization = await authorizationClient.authorizationForScopes(['email', 'profile']);

      final accessToken = authorization?.accessToken;

      if (accessToken == null) {
        final authorization2 = await authorizationClient.authorizationForScopes(['email', 'profile']);

        if (authorization2?.accessToken == null) {
          throw FirebaseAuthException(code: "error", message: "error");
        }
        authorization = authorization2;
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'photoURL': user.photoURL ?? '',
            "isOnline": true, // set online when signing in
            "provider": 'google',
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
      }
      return userCredential;
    } catch (e) {
      debugPrint('Google Service SignIn Error: $e');
      rethrow;
    }
  }

  //   sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Google service signing out Error: $e');
      rethrow;
    }
  }

  //   Get current User
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}