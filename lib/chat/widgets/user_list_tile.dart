import 'package:chat_app/chat/model/user_list_model.dart';
import 'package:chat_app/chat/model/user_model.dart';
import 'package:chat_app/chat/provider/user_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/custom_button.dart';

class UserListTile extends ConsumerWidget {
  const UserListTile({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userListState = ref.watch(userListNotifierProvider(user));
    final userListNotifer = ref.read(userListNotifierProvider(user).notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 50,
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? Text(user.name.isNotEmpty ? user.name[0].toLowerCase() : "U")
                : null,
        ),
        const SizedBox(width: 8),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                    "Offline",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTrailingWidget(context, ref, userListState, userListNotifer)
              ],
            )
        )
      ],
    );
  }

  Widget _buildTrailingWidget(
      BuildContext context,
      WidgetRef ref,
      AsyncValue<UserListTileState> state,
      UserListNotifier notifier,
      ) {
    return state.when(
        loading: () => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2,),
        ),
        data: (data) {
          if (data.areFriends) {
            return Row(
              children: [
                Expanded(
                  child: CustomFilledButton(
                      height: 40,
                      icon: Icon(Icons.person, color: Colors.blueAccent,),
                      useGradient: false,
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      label: 'Friends',
                      labelColor: Colors.blueAccent,
                      onPressed: () {
                        //Todo: (bottomsheet to unfriend or block)
                      }
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: CustomFilledButton(
                      height: 40,
                      icon: Icon(Icons.message),
                      label: 'Message',
                      onPressed: () {
                        //Todo: (Navigate to message page)
                      }
                  ),
                )
              ],
            );
          }

          if (data.requestStatus == 'pending') {
            return CustomFilledButton(
              icon: data.isRequestSender
                    ? Icon(Icons.pending)
                    : Icon(Icons.check),
                height: 40,
                isFullWidth: true,
                useGradient: false,
                backgroundColor: data.isRequestSender
                    ? Colors.yellow
                    : Colors.orange,
                label: data.isRequestSender
                    ? "Pending"
                    : 'Accept',
                onPressed: data.isRequestSender
                    ? null
                    : notifier.acceptRequest,
            );
          }

          return CustomFilledButton(
            isFullWidth: true,
            icon: Icon(Icons.person_add),
            height: 40,
            label: 'Add Friend',
            onPressed: notifier.sendRequest,
          );
        },
      error: (e, st) => const Icon(Icons.error, size: 18),
    );
  }
}
