import 'package:chat_app/chat/provider/provider.dart';
import 'package:chat_app/chat/screen/request_screen.dart';
import 'package:chat_app/core/services/route.dart';
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
    });
    super.initState();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(requestsProvider);
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
