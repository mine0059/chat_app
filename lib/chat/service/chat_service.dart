import 'package:chat_app/chat/model/chat_model.dart';
import 'package:chat_app/chat/model/message_model.dart';
import 'package:chat_app/chat/model/message_request_model.dart';
import 'package:chat_app/chat/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/utils/chat_id.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Stream<List<UserModel>> getAllUsers() {
    if (currentUserId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .where((user) => user.uid != currentUserId)
              .toList(),
        );
  }

  // --------------- MESSAGE REQUEST --------------------
  Future<void> updateUserOnlineStatus(bool isOnline) async {
    if(currentUserId.isEmpty) return;
    try {
      await _firestore.collection('users')
          .doc(currentUserId)
          .update({
            "isOnline": isOnline,
            'lastSeen': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error during updating Online status: $e');
    }
  }

  // --------------- ARE USERS FRIENDS --------------------
  Future<bool> areUsersFriends(String userID1, userID2) async {
    final chatId = generateChatID(userID1, userID2);

    // only read from firestore if not cached
    final friendship = await _firestore
        .collection('friendships')
        .doc(chatId)
        .get();

    final exists = friendship.exists;
    return exists;
  }

  // --------------- MESSAGE REQUEST --------------------
  Future<String> sendMessageRequest({
    required String receiverId,
    required String receiverName,
    required String receiverEmail,
  }) async {
     try {
       final currentUser = _auth.currentUser!;
       final requestId = '${currentUserId}_$receiverId';

       //get photo url from firebase user collection
       final userDoc = await _firestore
            .collection('users')
            .doc(currentUserId)
            .get();

       String? userPhotoUrl;
       if (userDoc.exists) {
         final userModel = UserModel.fromMap(userDoc.data()!);
         userPhotoUrl = userModel.photoURL;
       }

       final exitingRequest = await _firestore
           .collection("messageRequests")
           .doc(requestId)
           .get();

       if (exitingRequest.exists && exitingRequest.data()?['status'] == 'pending') {
         return 'Request already sent';
       }

       final request = MessageRequestModel(
           id: requestId,
           senderId: currentUserId,
           receiverId: receiverId,
           senderName: currentUser.displayName ?? "user",
           senderEmail: currentUser.email ?? '',
           status: 'pending',
           createdAt: DateTime.now(),
           photoURL: userPhotoUrl,
       );

       await _firestore
          .collection("messageRequests")
          .doc(requestId)
          .set(request.toMap());

       return "success";
     } catch (e) {
       debugPrint('Error sending messageREQUEST:: $e');
       return e.toString();
     }
  }
  // get pending requests
  Stream<List<MessageRequestModel>> getPendingRequest() {
    if (currentUserId.isEmpty) return Stream.value([]);
    return _firestore
        .collection("messageRequests")
        .where("receiverId", isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageRequestModel.fromMap(doc.data()))
            .toList(),
        );
  }

  // --------------- Accept Message Request --------------------
  Future<String> acceptMessageRequest(String requestId, String senderId) async {
    try {
      final batch = _firestore.batch();

      // update request status
      batch.update(_firestore.collection("messageRequests").doc(requestId), {
        'status': "accepted",
      });

      // create friendship
      final friendshipId = generateChatID(currentUserId, senderId);
      batch.set(_firestore.collection('friendships').doc(friendshipId), {
        'participants': [currentUserId, senderId],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // create chat
      batch.set(_firestore.collection('chats').doc(friendshipId), {
        'chatId': friendshipId,
          'participants': [currentUserId, senderId],
          'lastMessage': '',
          'lastSenderId': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': {currentUserId:0, senderId: 0},
      });

      // system message
      // auto generate message with request is accepted
      final messageId = _firestore.collection('messages').doc().id;
      batch.set(_firestore.collection('messages').doc(messageId), {
        'messageId': messageId,
        'chatId': friendshipId,
        'senderId': 'system',
        'senderName': 'system',
        'message': 'Request has been accepted, you can now start chatting!',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system',
      });
      await batch.commit();
      return 'success';
    } catch (e) {
      debugPrint('Error while accepting message request: $e');
      return e.toString();
    }
  }

  // reject message request
  Future<String> rejectMessageRequest(
        String requestId, {
        bool deleteRequest = true,
      }) async {
    try {
      if (deleteRequest) {
        await _firestore.collection("messageRequests").doc(requestId).delete();
      } else {
        await _firestore.collection("messageRequests").doc(requestId).update({
          'status': 'rejected',
        });
      }
      return 'success';
    } catch (e) {
      debugPrint('Error while rejecting Request: $e');
      return e.toString();
    }
  }

  // --------------- CHAT --------------------
  // add caching for chat
  final Map<String, List<ChatModel>> _chatsCache = {};


  Stream<List<ChatModel>> getUserChats() {
    if (currentUserId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        // if you have user orderBy and where on same collection then you need to add a indexing
        .orderBy('lastMessageTime', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshots) {
          final docs = snapshots.docs
              .map((doc) => ChatModel.fromMap(doc.data()))
              .toList();
          return docs;
        });
  }

  Stream<List<MessageModel>> getChatMessages(String chatId, { int limit = 20, DocumentSnapshot? lastDocument, }) {
    Query query = _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.snapshots().map((snapshot) {
      final docs = snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      debugPrint('sizeofDoc2 ${docs.length}');
      return docs;
    });
  }

}