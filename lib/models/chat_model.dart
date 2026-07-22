import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCounts;

  ConversationModel({
    required this.id,
    required this.participants,
    this.lastMessage = '',
    this.lastMessageTime,
    this.unreadCounts = const {},
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ConversationModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      if (lastMessageTime != null) 'lastMessageTime': Timestamp.fromDate(lastMessageTime!),
      'unreadCounts': unreadCounts,
    };
  }
}

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final bool seen;
  final String? imageUrl;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    this.seen = false,
    this.imageUrl,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      seen: map['seen'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'timestamp': Timestamp.fromDate(timestamp),
      'seen': seen,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
