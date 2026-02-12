import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  const MessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.timestamp,
    this.type = 'text',
    this.readBy,
    this.imageUrl,
    this.callType,
    this.callStatus,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
        messageId: map['messageId'] ?? '',
        senderId: map['senderId'] ?? '',
        senderName: map['senderName'] ?? '',
        message: map['message'] ?? '',
        timestamp: map['timestamp'] != null
            ? (map['timestamp'] is Timestamp
              ? (map['timestamp'] as Timestamp).toDate()
              : map['timestamp'] is DateTime
              ? map['timestamp'] as DateTime
              : null) // keep as null instead of DateTime.now()
            : null, // keep as null
        readBy: Map<String, DateTime>.from(
            (map['readBy'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(
                    key,
                    value is Timestamp
                      ? value.toDate()
                      : value is DateTime
                      ? value
                      : DateTime.now(),
                ),
            ) ?? {},
        ),
      type: map['type'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      callType: map['callType'] ?? '',
      callStatus: map['callStatus'] ?? ''
    );
  }

  /// convert back to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp!)
          : FieldValue.serverTimestamp(),
      'type': type,
      'imageUrl': imageUrl,
      'readBy': readBy?.map((k, v) => MapEntry(k, Timestamp.fromDate(v))),
      if (callType != null) 'callType': callType,
      if (callStatus != null) 'callStatus': callStatus,
    };
  }

  final String messageId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime? timestamp;
  final String type;
  final Map<String, DateTime>? readBy;
  final String? imageUrl;
  final String? callType;
  final String? callStatus;
}