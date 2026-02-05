import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthMethod {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if(email.isEmpty || password.isEmpty || name.isEmpty) {
        return "Please enter all fields";
      }

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile
      await cred.user!.updateDisplayName(name);

      //  Store user data with consistent field name
      await _fireStore.collection("users").doc(cred.user!.uid).set({
        "uid": cred.user!.uid,
        "name": name,
        "email": email,
        "photoURL": null,
        "isOnline": false, // set to true when user sign up
        "provider": 'email',
        "lastSeen": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
      });
      return "success";
    } catch (e) {
      debugPrint('SignUp User Error:: ${e.toString()}' );
      return e.toString();
    }
  }

  // Login with online status update
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if(email.isEmpty || password.isEmpty) {
        return "Please enter all fields";
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Update online status after login
      if (_auth.currentUser != null) {
        await _fireStore.collection('users').doc(_auth.currentUser!.uid).update(
          {'isOnline': true, 'lastSeen': FieldValue.serverTimestamp()},
        );
      }
      return "success";
    } catch (e) {
      debugPrint('Login User Error:: ${e.toString()}' );
      return e.toString();
    }
  }

 // LogOut in with online status update
 Future<void> singOut() async {
    if (_auth.currentUser != null) {
      // set offline before signing out
      await _fireStore.collection('users').doc(_auth.currentUser!.uid).update(
        {'isOnline': true, 'lastSeen': FieldValue.serverTimestamp()},
      );
    }
    await _auth.signOut();
 }
}

final authMethodProvider = Provider<AuthMethod>((ref) {
  return AuthMethod();
});
