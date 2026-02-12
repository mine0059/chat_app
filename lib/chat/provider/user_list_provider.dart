import 'dart:async';

import 'package:chat_app/chat/model/user_model.dart';
import 'package:chat_app/chat/provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/user_list_model.dart';

final userListNotifierProvider = AsyncNotifierProvider.autoDispose.family<
    UserListNotifier, UserListTileState, UserModel
>(UserListNotifier.new);

class UserListNotifier extends AsyncNotifier<UserListTileState> {
  UserListNotifier(this.user);
  final UserModel user;

  @override
  FutureOr<UserListTileState> build() async {
    // final initial = UserListTileState();
    return _checkRelationship();
    // return initial;
  }

  // Check the status
  // Future<void> _checkRelationship() async {
  //   final chatService = ref.read(chatServiceProvider);
  //   final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  //   final friends = await chatService.areUsersFriends(currentUserId, user.uid);
  //
  //   if (friends) {
  //     state = AsyncData(
  //       state.requireValue.copyWith(
  //         areFriends: true,
  //         requestStatus: null,
  //         isRequestSender: false,
  //         pendingRequestId: null,
  //       )
  //     );
  //     return;
  //   }
  //
  //   final sendRequestId = '${currentUserId}_${user.uid}';
  //   final receiverRequestId = '${user.uid}_$currentUserId';
  //
  //   final sendRequestDoc = await FirebaseFirestore.instance
  //       .collection("messageRequests")
  //       .doc(sendRequestId)
  //       .get();
  //
  //   final receiverRequestDoc = await FirebaseFirestore.instance
  //       .collection("messageRequests")
  //       .doc(receiverRequestId)
  //       .get();
  //
  //   String? finalStatus;
  //   bool isSender = false;
  //   String? requestId;
  //
  //   if (sendRequestDoc.exists) {
  //     final sentStatus = sendRequestDoc['status'];
  //     if (sentStatus == 'pending') {
  //       finalStatus = 'pending';
  //       isSender = true;
  //       requestId = sendRequestId;
  //     }
  //   }
  //
  //   if (receiverRequestDoc.exists) {
  //     final receivedStatus = receiverRequestDoc['status'];
  //     if (receivedStatus == 'pending') {
  //       finalStatus = 'pending';
  //       isSender = false;
  //       requestId = receiverRequestId;
  //     }
  //   }
  //
  //   state = AsyncData(
  //       state.requireValue.copyWith(
  //         areFriends: false,
  //         requestStatus: finalStatus,
  //         isRequestSender: isSender,
  //         pendingRequestId: requestId,
  //       )
  //   );
  // }

  Future<UserListTileState> _checkRelationship() async {
    final chatService = ref.read(chatServiceProvider);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final friends =
    await chatService.areUsersFriends(currentUserId, user.uid);

    if (friends) {
      return UserListTileState(
        areFriends: true,
        requestStatus: null,
        isRequestSender: false,
        pendingRequestId: null,
      );
    }

    final sendRequestId = '${currentUserId}_${user.uid}';
    final receiverRequestId = '${user.uid}_$currentUserId';

    final sendDoc = await FirebaseFirestore.instance
        .collection("messageRequests")
        .doc(sendRequestId)
        .get();

    final receiveDoc = await FirebaseFirestore.instance
        .collection("messageRequests")
        .doc(receiverRequestId)
        .get();

    if (sendDoc.exists && sendDoc['status'] == 'pending') {
      return UserListTileState(
        requestStatus: 'pending',
        isRequestSender: true,
        pendingRequestId: sendRequestId,
      );
    }

    if (receiveDoc.exists && receiveDoc['status'] == 'pending') {
      return UserListTileState(
        requestStatus: 'pending',
        isRequestSender: false,
        pendingRequestId: receiverRequestId,
      );
    }

    return UserListTileState();
  }


  // send request
  Future<String> sendRequest() async {
    state = const AsyncLoading();

    final chatService = ref.read(chatServiceProvider);
    final result = await chatService.sendMessageRequest(
        receiverId: user.uid,
        receiverName: user.name,
        receiverEmail: user.email,
    );
    if (result == 'success') {
      state = AsyncData(
        state.requireValue.copyWith(
          requestStatus: 'pending',
          isRequestSender: true,
          pendingRequestId: '${FirebaseAuth.instance.currentUser!.uid}_${user.uid}',
        ),
      );
    }
    return result;
  }

  // accept request
  Future<String> acceptRequest() async {
    final current = state.value;
    if (current == null || current.pendingRequestId == null) return 'no-request';
    state = const AsyncLoading();
    final chatService = ref.read(chatServiceProvider);
    final result = await chatService.acceptMessageRequest(
        current.pendingRequestId!,
        user.uid,
    );

    if(result == 'success') {
      state = AsyncData(
        current.copyWith(
          areFriends: true,
          requestStatus: null,
          isRequestSender: false,
          pendingRequestId: null,
        )
      );
      // refresh providers
      ref.invalidate(requestsProvider);
      ref.invalidate(chatsProvider);
    }

    return result;
  }
}