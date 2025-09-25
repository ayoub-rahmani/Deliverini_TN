import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/chat_user.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String get currentUserId => AuthService.currentUserId;

  // 🔥 SIMPLIFIED: Remove all complex caching and stream management
  Stream<List<Message>> getMessages(String chatId) {
    print('💬 Getting messages for chat: $chatId');

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => Message.fromFirestore(doc))
          .toList();

      print('🔄 Loaded ${messages.length} messages for $chatId');
      return messages;
    });
  }

  // Get or create chat room
  Future<String> getOrCreateChatRoom(String otherUserId) async {
    final chatId = generateChatId(currentUserId, otherUserId);

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      final chatRoom = ChatRoom(
        id: chatId,
        participants: [currentUserId, otherUserId],
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: '',
        unreadCount: {currentUserId: 0, otherUserId: 0},
      );

      await _firestore.collection('chats').doc(chatId).set(chatRoom.toFirestore());
      print('💬 Created new chat room: $chatId');
    }

    return chatId;
  }

  // Send message
  Future<void> sendMessage(String chatId, String receiverId, String message) async {
    try {
      final messageData = Message(
        id: '',
        senderId: currentUserId,
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
        isRead: false,
        chatId: chatId,
      );

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData.toFirestore());

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'lastMessageSenderId': currentUserId,
        'unreadCount.$receiverId': FieldValue.increment(1),
      });

      // Send notification
      final currentUser = AuthService.currentUser;
      if (currentUser != null) {
        await NotificationService.sendMessageNotification(
          receiverId: receiverId,
          senderName: currentUser.name,
          messageText: message,
          chatId: chatId,
        );
      }

      print('✅ Message sent successfully');
    } catch (e) {
      print('❌ Error sending message: $e');
      throw e;
    }
  }

  // Get chat users
  Future<List<ChatUser>> getChatUsers() async {
    try {
      final users = await AuthService.getChatUsers();
      return users.map((user) => user.toChatUser()).toList();
    } catch (e) {
      print('❌ Error getting chat users: $e');
      return <ChatUser>[];
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadMessages.docs.isEmpty) return;

      final batch = _firestore.batch();

      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$currentUserId': 0,
      });

      print('✅ Marked ${unreadMessages.docs.length} messages as read');
    } catch (e) {
      print('❌ Error marking messages as read: $e');
    }
  }

  // Public method to generate chat ID
  String generateChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Simplified dispose - no complex cleanup needed
  void disposeChat(String chatId) {
    print('🔌 Chat disposed: $chatId');
  }

  // Remove complex cache clearing
  static void clearExpiredCache() {
    print('🧹 Cache cleared');
  }
}