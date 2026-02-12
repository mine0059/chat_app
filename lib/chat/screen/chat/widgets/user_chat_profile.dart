import 'package:chat_app/chat/provider/user_status_provider.dart';
import 'package:chat_app/chat/screen/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserChatProfile extends StatelessWidget {
  const UserChatProfile({super.key, required this.widget});

  final ChatScreen widget;

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ref, _) {
          final statusAsync = ref.watch(userStatusProvider(widget.otherUser.uid));

          return statusAsync.when(
              data: (isOnline) => Row(
                children: [
                  CircleAvatar(
                    backgroundImage: widget.otherUser.photoURL != null
                        ? NetworkImage(widget.otherUser.photoURL!)
                        : null,
                    child: widget.otherUser.photoURL == null
                        ? Text(widget.otherUser.name.isNotEmpty ? widget.otherUser.name[0].toLowerCase() : "U")
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.otherUser.name, style: TextStyle(fontSize: 16)),
                          // for typing indicator we will work some time later
                        ],
                      )
                  )
                ],
              ),
              error: (_, __) => Text(widget.otherUser.name),
              loading: () => Text(widget.otherUser.name)
          );
        }
    );
  }
}
