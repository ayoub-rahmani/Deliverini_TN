import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class EnhancedChatCacheService {
  static final Map<String, List<Message>> _messageCache = {};
  static final Map<String, StreamSubscription> _activeStreams = {};
  static final Map<String, DateTime> _lastUpdated = {};
  static final Map<String, StreamController<List<Message>>> _controllers = {};

  static const Duration _cacheExpiry = Duration(hours: 2);
  static const int _maxCachedChats = 10;

  static Stream<List<Message>> getMessagesWithInstantCache(String chatId) {
    print('💬 Getting messages for chat: $chatId');

    if (_controllers.containsKey(chatId)) {
      print('♻️ Reusing existing stream for $chatId');

      final cachedMessages = getCachedMessages(chatId);
      if (cachedMessages != null) {
        print('⚡ INSTANT: Delivering ${cachedMessages.length} cached messages to new listener');

        final newController = StreamController<List<Message>>();

        // 🔥 CRITICAL FIX: Send cached messages immediately (even if empty)
        Future.microtask(() {
          if (!newController.isClosed) {
            newController.add(cachedMessages);
          }
        });

        final subscription = _controllers[chatId]!.stream.listen(
              (messages) {
            if (!newController.isClosed) {
              newController.add(messages);
            }
          },
          onError: (error) {
            if (!newController.isClosed) {
              newController.addError(error);
            }
          },
          onDone: () {
            if (!newController.isClosed) {
              newController.close();
            }
          },
        );

        newController.onCancel = () {
          subscription.cancel();
        };

        return newController.stream;
      }

      return _controllers[chatId]!.stream;
    }

    print('🆕 Creating new stream for $chatId');
    final controller = StreamController<List<Message>>.broadcast();
    _controllers[chatId] = controller;

    _setupRealTimeUpdates(chatId, controller);
    return controller.stream;
  }

  static void _setupRealTimeUpdates(String chatId, StreamController<List<Message>> controller) {
    _activeStreams[chatId]?.cancel();

    final stream = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();

    _activeStreams[chatId] = stream.listen(
          (snapshot) {
        final messages = snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();

        print('🔄 Updated ${messages.length} messages for $chatId');

        // 🔥 CRITICAL: Always update cache, even with 0 messages
        _updateCache(chatId, messages);

        if (!controller.isClosed) {
          controller.add(messages);
        }
      },
      onError: (error) {
        print('❌ Stream error for $chatId: $error');
        if (!controller.isClosed) {
          controller.addError(error);
        }
      },
    );
  }

  static void _updateCache(String chatId, List<Message> messages) {
    if (_messageCache.length >= _maxCachedChats) {
      _cleanOldestCache();
    }
    _messageCache[chatId] = messages;
    _lastUpdated[chatId] = DateTime.now();
    print('💾 Cached ${messages.length} messages for $chatId');
  }

  static List<Message>? getCachedMessages(String chatId) {
    final lastUpdate = _lastUpdated[chatId];
    if (lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < _cacheExpiry &&
        _messageCache.containsKey(chatId)) {
      return _messageCache[chatId];
    }
    return null;
  }

  static void _cleanOldestCache() {
    if (_lastUpdated.isEmpty) return;

    String? oldestChatId;
    DateTime? oldestTime;

    _lastUpdated.forEach((chatId, time) {
      if (oldestTime == null || time.isBefore(oldestTime!)) {
        oldestTime = time;
        oldestChatId = chatId;
      }
    });

    if (oldestChatId != null) {
      _messageCache.remove(oldestChatId);
      _lastUpdated.remove(oldestChatId);
      _activeStreams[oldestChatId]?.cancel();
      _activeStreams.remove(oldestChatId);
      _controllers[oldestChatId]?.close();
      _controllers.remove(oldestChatId);
    }
  }

  static void disposeChat(String chatId) {
    print('🔌 Disposing chat: $chatId');
    _activeStreams[chatId]?.cancel();
    _activeStreams.remove(chatId);
    _controllers[chatId]?.close();
    _controllers.remove(chatId);
  }

  static void clearExpiredCache() {
    final now = DateTime.now();
    final expiredChats = <String>[];

    _lastUpdated.forEach((chatId, lastUpdate) {
      if (now.difference(lastUpdate) > _cacheExpiry) {
        expiredChats.add(chatId);
      }
    });

    for (final chatId in expiredChats) {
      _messageCache.remove(chatId);
      _lastUpdated.remove(chatId);
      _activeStreams[chatId]?.cancel();
      _activeStreams.remove(chatId);
      _controllers[chatId]?.close();
      _controllers.remove(chatId);
    }
  }
}
