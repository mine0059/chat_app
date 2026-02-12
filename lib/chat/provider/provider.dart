import 'dart:async';

import 'package:chat_app/chat/model/chat_model.dart';
import 'package:chat_app/chat/model/message_request_model.dart';
import 'package:chat_app/chat/model/user_model.dart';
import 'package:chat_app/chat/service/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// --------------- AUTH STATE --------------------
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// --------------- CHAT SERVICE --------------------
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

// --------------- USERS --------------------
class UserNotifier extends AsyncNotifier<List<UserModel>> {
  @override
  FutureOr<List<UserModel>> build() async {
    final service = ref.watch(chatServiceProvider);

    // listen to the stream and update state
    final subscription = service.getAllUsers().listen(
        (users) {
          if (state.hasValue || state.isLoading) {
            state = AsyncData(users);
          }
        },
        onError: (error, stackTrace) {
          if (state.hasValue || state.isLoading) {
            state = AsyncError(error, stackTrace);
          }
        }
    );

    ref.onDispose(() {
      subscription.cancel();
    });

    // Return initial empty list (will be updated by stream)
    return [];
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, List<UserModel>>(
  UserNotifier.new,
);

// --------------- REQUEST --------------------
class RequestNotifier extends AsyncNotifier<List<MessageRequestModel>> {
  @override
  FutureOr<List<MessageRequestModel>> build() {
    final service = ref.watch(chatServiceProvider);
    // listen to stream and update the state
    final subscription = service.getPendingRequest().listen(
        (request) {
          state = AsyncData(request);
        },
        onError: (error, stackTrace) {
          state = AsyncError(error, stackTrace);
        }
    );

    ref.onDispose(() {
      subscription.cancel();
    });

    // Return initial empty list (will be updated by stream)
    return [];
  }

  Future<void> acceptRequest(String requestId, String senderId) async {
    final service = ref.read(chatServiceProvider);
    await service.acceptMessageRequest(requestId, senderId);
  }

  Future<void> rejectRequest(String requestId) async {
    final service = ref.read(chatServiceProvider);
    await service.rejectMessageRequest(requestId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final requestsProvider = AsyncNotifierProvider<RequestNotifier, List<MessageRequestModel>>(
  RequestNotifier.new,
);

// --------------- AUTO REFRESH ON AUTH CHANGE --------------------
final autoRefreshProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(authStateProvider, (prev, next) {
    next.whenData((user) {
      if (user != null) {
        Future.delayed(Duration(milliseconds: 500), () {
          ref.invalidate(userProvider);
          ref.invalidate(requestsProvider);
        });
      }
    });
  });
});

// --------------- CHAT --------------------
class ChatsNotifier extends AsyncNotifier<List<ChatModel>> {
  @override
  FutureOr<List<ChatModel>> build() {
    final service = ref.watch(chatServiceProvider);
    // listen to stream and update the state
    final subscription = service.getUserChats().listen(
        (chats) {
          state = AsyncData(chats);
        },
        onError: (error, stackTrace) {
          state = AsyncError(error, stackTrace);
        }
    );

    ref.onDispose(() {
      subscription.cancel();
    });

    // Return initial empty list (will be updated by stream)
    return [];
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

}

final chatsProvider = AsyncNotifierProvider<ChatsNotifier, List<ChatModel>>(
  ChatsNotifier.new,
);

// --------------- SEARCH --------------------
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredUsersProvider = Provider<AsyncValue<List<UserModel>>>((ref) {
  final users = ref.watch(userProvider);
  final query = ref.watch(searchQueryProvider);
  return users.when(
    data: (list) {
      if (query.isEmpty) return AsyncValue.data(list);
      return AsyncValue.data(
        list
            .where(
            (u) =>
                u.name.toLowerCase().contains(query.toLowerCase()) ||
                u.email.toLowerCase().contains(query.toLowerCase()),
        )
            .toList(),
      );
    },
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    loading: () => AsyncValue.loading(),
  );
});
