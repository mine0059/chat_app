import 'package:chat_app/chat/model/user_model.dart';
import 'package:flutter/material.dart';

import 'widgets/user_chat_profile.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chatId, required this.otherUser});

  final String chatId;
  final UserModel otherUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        title: UserChatProfile(widget: widget),
        titleSpacing: 0,
      ),
    );
  }
}
