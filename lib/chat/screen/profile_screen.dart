import 'dart:async';
import 'dart:io';

import 'package:chat_app/chat/provider/provider.dart';
import 'package:chat_app/chat/provider/user_profile_provider.dart';
import 'package:chat_app/core/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth/screen/signin_screen.dart';
import '../../auth/service/google_service.dart';
import '../../core/extensions/format_to_mb.dart';
import '../../core/services/image_upload_service.dart';
import '../../core/widgets/custom_button.dart';
import '../provider/user_list_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? lastUserId;
  File? selectedFile;
  Completer? completer;
  String? fileName;
  int? fileSize;

  Future<void> setFile(File? pickedFile) async {
    if (pickedFile == null) return;
    final size = await pickedFile.length();
    setState(() {
      selectedFile = pickedFile;
      fileName = pickedFile.path.split('/').last;
      fileSize = size.formatToMegaByte();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load profile',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () {
                      notifier.refresh();
                    },
                    child: const Text("Retry"),
                )
              ],
            ),
          ),
          data: (profile) {
            return RefreshIndicator(
                onRefresh: () => notifier.refresh(),
                child: ListView(
                    padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: profile.photoUrl != null
                                ? NetworkImage(profile.photoUrl!)
                                : null,
                            child: profile.photoUrl == null
                                ? const Icon(Icons.person, size: 60)
                                : null,
                          ),
                          Positioned(
                            bottom: 5,
                            right: 8,
                              child: GestureDetector(
                                onTap: () async {
                                  await ImgaeUploadService.showFilePickerButtonSheet(
                                      context,
                                      completer,
                                      setFile
                                  );

                                  if (selectedFile == null) return;

                                  final success = await notifier.updateProfilePicture(selectedFile!);
                                  if (success && context.mounted) {
                                    showAppSnackbar(
                                        context: context,
                                        type: SnackbarType.success,
                                        description: "Profile picture change successfully!"
                                    );
                                  } else {
                                    showAppSnackbar(
                                        context: context,
                                        type: SnackbarType.error,
                                        description: "Fail to update profile picture"
                                    );
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.black,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              )
                          ),
                          // upload spinner overlay
                          if (profile.isUploading)
                            const Positioned.fill(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                )
                            )
                        ],
                      ),

                    ),
                    const SizedBox(height: 5),
                    Column(
                      children: [
                        Text(
                          profile.name ?? "No Name",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          profile.email ?? "No Email",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        Text(
                          "joined ${profile.createdAt != null
                              ? DateFormat("MMM d y").format(profile.createdAt!)
                              : DateFormat("MMM d y").format(DateTime.now())}",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomFilledButton(
                      label: 'Log out',
                      isFullWidth: true,
                      onPressed: () async {
                        final shouldLogout = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text('Logout'),
                              content: Text("Are you sure you want to logout"),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Logout'),
                                ),
                              ],
                            )
                        );
                        if (shouldLogout == true) {
                          await GoogleService.signOut();
                          // invalidate all providers
                          ref.invalidate(profileProvider);
                          ref.invalidate(userListNotifierProvider);
                          ref.invalidate(requestsProvider);
                          ref.invalidate(userProvider);
                          ref.invalidate(filteredUsersProvider);
                          ref.invalidate(searchQueryProvider);
                          if (context.mounted) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserLoginScreen()
                                )
                            );
                          }
                        }
                      },
                    )
                  ],
                )
            );
          },
      ),
    );
  }
}
