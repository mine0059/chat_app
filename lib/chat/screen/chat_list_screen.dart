import 'package:chat_app/chat/model/user_model.dart';
import 'package:chat_app/chat/provider/provider.dart';
import 'package:chat_app/chat/provider/user_status_provider.dart';
import 'package:chat_app/chat/screen/chat/chat_screen.dart';
import 'package:chat_app/chat/screen/request_screen.dart';
import 'package:chat_app/core/services/route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    // when screen loads, refresh chat and request providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(requestsProvider);
      ref.invalidate(chatsProvider);
    });
    super.initState();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(requestsProvider);
    ref.invalidate(chatsProvider);
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final asyncChats = ref.watch(chatsProvider);
    final pendingRequest = ref.watch(requestsProvider);
    final requestCount = pendingRequest.when(
        data: (request) => request.length,
        error: (error, stackTrace) => 0,
        loading: () => 0
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text('Chats', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
              onPressed: () => NavigationHelper.push(context, RequestScreen()),
              icon: Stack(
                children: [
                  Icon(Icons.notifications, size: 30,),
                  Positioned(
                    right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$requestCount',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      )
                  )
                ],
              )
          )
        ],
      ),
      body: asyncChats.when(
          loading: () => Center(
            child: CircularProgressIndicator(),
          ),
          data: (chats) {
            if (chats.isEmpty) {
              return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                          'No chats yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Go to users tab to send message requests',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
              );
            }

            return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];

                      // fetch other users details
                      return FutureBuilder(
                          future: _getOtherUser(chat.participants),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return SizedBox();

                            final otherUser = snapshot.data!;
                            final currentUserId = FirebaseAuth.instance.currentUser?.uid;

                            if (currentUserId == null) return SizedBox();

                            return ListTile(
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: otherUser.photoURL != null
                                        ? NetworkImage(otherUser.photoURL!)
                                        : null,
                                    child: otherUser.photoURL == null
                                        ? Text(otherUser.name.isNotEmpty ? otherUser.name[0].toLowerCase() : "U")
                                        : null,
                                  ),
                                  Positioned(
                                      bottom: 0,
                                      right: 2,
                                      child: Consumer(
                                          builder: (context, ref, _) {
                                            final statusAsync = ref.watch(userStatusProvider(otherUser.uid));
                                            return statusAsync.when(
                                                data: (isOnline) => CircleAvatar(
                                                  radius: 5,
                                                  backgroundColor: isOnline
                                                      ? Colors.green
                                                      : Colors.grey
                                                ),
                                                error: (_, __) => Text(otherUser.email),
                                                loading: () => Text(otherUser.email),
                                            );
                                          }
                                      )
                                  )
                                ],
                              ),
                              title: Text(otherUser.name),
                              subtitle: Text(
                                "You can now start to chat",
                                // style: TextStyle(
                                //
                                // ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => NavigationHelper.push(context, ChatScreen(chatId: chat.chatId, otherUser: otherUser)),
                            );
                          }
                      );
                    },
                ),

            );
          },
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load Chats',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(chatsProvider),
                  child: const Text("Retry"),
                )
              ],
            ),
          ),
      ),
    );
  }

  // helper method -> get details ot the other user in chat
  Future<UserModel?> _getOtherUser(List<String> participants) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return null;
    final otherUserId = participants.firstWhere((id) => id != currentUserId);
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(otherUserId)
          .get();

      return doc.exists ? UserModel.fromMap(doc.data()!) : null;
    } catch (e) {
      debugPrint('Error getting other user: $e');
      return null;
    }
  }
}
