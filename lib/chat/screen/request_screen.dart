import 'package:chat_app/chat/provider/provider.dart';
import 'package:chat_app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  @override
  void initState() {
    // refresh request list as soon as screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(requestsProvider);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(requestsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Message Requests"),
        actions: [
          IconButton(
              onPressed: () => ref.invalidate(requestsProvider),
              icon: Icon(Icons.refresh),
          )
        ],
      ),
      body: requestAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(),
          ),
          data: (requestList) {
            if (requestList.isEmpty) {
              return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      Text('No pending request'),
                    ],
                  )
              );
            }

            return ListView.builder(
                itemCount: requestList.length,
                itemBuilder: (context, index) {
                  final request = requestList[index];
                  return Card(
                    elevation: 0,
                    color: Colors.transparent,
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundImage: request.photoURL != null
                            ? NetworkImage(request.photoURL!)
                            : null,
                        child: request.photoURL != null
                            ? Icon(Icons.person, size: 30)
                            : null,
                      ),
                      title: Text(request.senderName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await ref.read(requestsProvider.notifier)
                                  .acceptRequest(request.id, request.senderId);
                              if (context.mounted) {
                                showAppSnackbar(
                                    context: context,
                                    type: SnackbarType.success,
                                    description: "Request accepted!",
                                );

                                // refresh all providers after accepting
                                ref.invalidate(userProvider);
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.check, color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              await ref.read(requestsProvider.notifier)
                                  .rejectRequest(request.id);
                              if (context.mounted) {
                                showAppSnackbar(
                                  context: context,
                                  type: SnackbarType.success,
                                  description: "Request rejected!",
                                );
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
            );
          },
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load RequestMessages: $error',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(requestsProvider),
                  child: const Text("Retry"),
                )
              ],
            ),
          ),
      ),
    );
  }
}
