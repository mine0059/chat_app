import 'dart:async';
import 'dart:io';

import 'package:chat_app/chat/model/user_profile_model.dart';
import 'package:chat_app/chat/provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new
);

class ProfileNotifier extends AsyncNotifier<ProfileState> {
  @override
  Future<ProfileState> build() async {
    // react to auth change automatically
    final user = await ref.watch(authStateProvider.future);

    if (user == null) {
      return ProfileState();
    }

    return _loadUserData(user.uid);
  }

  // load user data from firestore
  Future<ProfileState> _loadUserData(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!doc.exists) {
      return ProfileState(userId: uid);
    }

    final data = doc.data()!;

    return ProfileState(
      photoUrl: data['photoURL'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
      userId: uid,
    );
  }

  // manual refresh
  Future<void> refresh() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadUserData(user.uid));
  }

  // upload profile picture
  Future<bool> updateProfilePicture(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    state = state.whenData(
          (data) => data.copyWith(isUploading: true),
    );

    try {
      final refStorage = FirebaseStorage.instance
          .ref()
          .child("profile_pictures/${user.uid}");

      await refStorage.putFile(file);
      final url = await refStorage.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({"photoURL": url});

      state = state.whenData(
            (data) => data.copyWith(
          photoUrl: url,
          isUploading: false,
        ),
      );

      return true;
    } catch (e, st) {
      debugPrint('Error during Profile picture upload: $e');
      debugPrint('Stack Trace: $st');
      state = state.whenData(
          (data) => data.copyWith(isUploading: false),
      );
      // state = AsyncError(e, st);
      return false;
    }
  }

  // // upload profile picture
  // Future<bool> updateProfilePicture() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return false;
  //
  //   final picker = ImagePicker();
  //   final picked = await picker.pickImage(source: ImageSource.gallery);
  //   if (picked == null) return false;
  //
  //   final file = File(picked.path);
  //
  //   state = state.whenData(
  //       (data) => data.copyWith(isUploading: true),
  //   );
  //
  //   try {
  //     final refStorage = FirebaseStorage.instance
  //         .ref()
  //         .child("profile_pictures/${user.uid}");
  //
  //     await refStorage.putFile(file);
  //     final url = await refStorage.getDownloadURL();
  //
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .update({"photoURL": url});
  //
  //     state = state.whenData(
  //         (data) => data.copyWith(
  //           photoUrl: url,
  //           isUploading: false,
  //         ),
  //     );
  //
  //     return true;
  //   } catch (e, st) {
  //     debugPrint('Error during Profile picture upload: $e');
  //     debugPrint('Stack Trace: $st');
  //     state = AsyncError(e, st);
  //     return false;
  //   }
  // }

  // late final StreamSubscription<User?> _authSubscription;
  // listen to firebase auth state changes
  // void _listenToAuthChanges() {
  //   _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
  //       (user) {
  //         if (user != null) {
  //           // user logged in load their data
  //           if (state.userId != user.uid) {
  //             //   only reload if its a different user
  //             loadUserData(user);
  //
  //           } else {
  //             // user logged out clear state
  //             state = ProfileState(isLoading: false);
  //           }
  //         }
  //       }
  //   );
  // }

  // load user data from firestore
  // Future<void> _loadUserData([User? user]) async {
  //   final currentUser = user ?? FirebaseAuth.instance.currentUser;
  //
  //   if (currentUser == null) {
  //     state = ProfileState(isLoading: false);
  //     return;
  //   }
  //   state = state.copyWith(isLoading: true);
  //
  //   try {
  //     final doc = await FirebaseFirestore
  //         .instance
  //         .collection("users")
  //         .doc(currentUser.uid)
  //         .get();
  //     if (doc.exists) {
  //       state = ProfileState(
  //         photoUrl: doc['photoURL'],
  //         name: doc['name'],
  //         email: doc['email'],
  //         createdAt: (doc['createdAt'] as Timestamp).toDate(),
  //         userId: currentUser.uid,
  //         isLoading: false,
  //       );
  //     } else {
  //       state = ProfileState(
  //         userId: currentUser.uid,
  //         isLoading: false,
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint('Error Loading userData: $e');
  //     state = ProfileState(userId: currentUser.uid, isLoading: false);
  //   }
  // }

  // void refresh() {
  //   loadUserData();
  // }

  // pick and upload new profile image
  // Future<bool> _updateProfilePicture() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return false;
  //   final picker = ImagePicker();
  //   final pickerFile = await picker.pickImage(source: ImageSource.gallery);
  //
  //   if (pickerFile == null) return false;
  //   state = state.copyWith(isUploading: true);
  //
  //   File file = File(pickerFile.path);
  //
  //   try {
  //     // upload to firebase storage
  //     final storageRef = FirebaseStorage.instance
  //         .ref()
  //         .child("profile_pictures")
  //         .child("${user.uid}.jpg");
  //
  //     await storageRef.putFile(file);
  //     final newUrl = await storageRef.getDownloadURL();
  //
  //     // update firestore
  //     await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
  //       {"photoURL": newUrl},
  //     );
  //     // update state
  //     state = state.copyWith(photoUrl: newUrl, isLoading: false);
  //
  //     return true;
  //   } catch (e) {
  //     state = state.copyWith(isUploading: false);
  //     debugPrint('Error during Profile picture upload: $e');
  //     return false;
  //   }
  // }

  // @override
  // void dispose() {
  //   _authSubscription.cancel();
  //   super.dispose();
  // }
}