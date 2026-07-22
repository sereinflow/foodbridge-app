import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/models/chat_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthController _authController = Get.find<AuthController>();
  final _uuid = const Uuid();

  String get currentUserId => _authController.userModel.value?.uid ?? '';

  /// Generates a unique, deterministic conversation ID between two users.
  String getConversationId(String peerId) {
    final list = [currentUserId, peerId]..sort();
    return '${list[0]}_${list[1]}';
  }

  /// Streams the list of active conversations for the current user.
  Stream<List<ConversationModel>> streamConversations() {
    if (currentUserId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort in-memory by last message time descending
          list.sort((a, b) {
            if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
            if (a.lastMessageTime == null) return 1;
            if (b.lastMessageTime == null) return -1;
            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          });
          return list;
        });
  }

  /// Streams messages for a specific conversation.
  Stream<List<MessageModel>> streamMessages(String conversationId) {
    return _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Sends a message.
  Future<void> sendMessage({
    required String peerId,
    required String text,
    String? imageUrl,
  }) async {
    if (currentUserId.isEmpty || peerId.isEmpty) return;

    final conversationId = getConversationId(peerId);
    final messageId = _uuid.v4();
    final now = DateTime.now();

    final message = MessageModel(
      id: messageId,
      text: text,
      senderId: currentUserId,
      timestamp: now,
      seen: false,
      imageUrl: imageUrl,
    );

    final chatRef = _firestore.collection('chats').doc(conversationId);

    // Run transaction to create/update conversation metadata and add message
    await _firestore.runTransaction((transaction) async {
      final chatDoc = await transaction.get(chatRef);

      Map<String, dynamic> chatData;
      if (!chatDoc.exists) {
        chatData = {
          'participants': [currentUserId, peerId],
          'lastMessage': text.isNotEmpty ? text : 'image_shared'.tr,
          'lastMessageTime': Timestamp.fromDate(now),
          'unreadCounts': {
            peerId: 1,
            currentUserId: 0,
          },
        };
        transaction.set(chatRef, chatData);
      } else {
        final existingUnread = Map<String, int>.from(chatDoc.data()?['unreadCounts'] ?? {});
        existingUnread[peerId] = (existingUnread[peerId] ?? 0) + 1;
        existingUnread[currentUserId] = 0;

        transaction.update(chatRef, {
          'lastMessage': text.isNotEmpty ? text : 'image_shared'.tr,
          'lastMessageTime': Timestamp.fromDate(now),
          'unreadCounts': existingUnread,
        });
      }

      final msgRef = chatRef.collection('messages').doc(messageId);
      transaction.set(msgRef, message.toMap());
    });
  }

  /// Marks all unread messages from a peer in a conversation as seen.
  Future<void> markAsSeen(String conversationId, String peerId) async {
    if (currentUserId.isEmpty) return;

    // Reset unread count for current user
    final chatRef = _firestore.collection('chats').doc(conversationId);
    await _firestore.runTransaction((transaction) async {
      final chatDoc = await transaction.get(chatRef);
      if (chatDoc.exists) {
        final existingUnread = Map<String, int>.from(chatDoc.data()?['unreadCounts'] ?? {});
        existingUnread[currentUserId] = 0;
        transaction.update(chatRef, {'unreadCounts': existingUnread});
      }
    });

    // Mark sub-collection messages sent by peer as seen
    final messagesSnap = await chatRef
        .collection('messages')
        .where('senderId', isEqualTo: peerId)
        .where('seen', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messagesSnap.docs) {
      batch.update(doc.reference, {'seen': true});
    }
    await batch.commit();
  }

  /// Uploads a chat image to Firebase Storage and returns the download URL.
  Future<String?> uploadChatImage(XFile imageFile) async {
    try {
      final file = File(imageFile.path);
      final ref = _storage.ref().child('chats/$currentUserId/${_uuid.v4()}.jpg');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading chat image: $e");
      return null;
    }
  }

  /// Initiates picking and sending an image.
  Future<void> sendImageMessage(String peerId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile == null) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final imageUrl = await uploadChatImage(pickedFile);
    Get.back(); // close loading indicator

    if (imageUrl != null) {
      await sendMessage(peerId: peerId, text: '', imageUrl: imageUrl);
    } else {
      Get.snackbar("error".tr, "Failed to upload image. Please try again.");
    }
  }
}
