import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class ChatCacheService {
  // In-memory cache - like keeping recent mail on your desk
  static final Map<String, List<Message>> _messageCache = {};
  static final Map<String, StreamSubscription> _activeStreams = {};
  static final Map<String, DateTime> _lastFetch = {};

  // Cache duration - how long to keep messages in memory
  static const Duration _cacheExpiry = Duration(minutes: 30);

  // Get messages with smart caching
  static Stream<List<Message>> getMessagesWithCache(String chatId) {
    // Check if we already have an active stream for this chat
    if (_activeStreams.containsKey(chatId)) {
      print('🔄 Reusing existing stream for $chatId');
      return _getStreamFromCache(chatId);
    }

    print('🆕 Creating new stream for $chatId');

    // Create new stream and cache it
    final stream = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs.map((doc) {
        return Message.fromFirestore(doc);
      }).toList();

      // Update cache
      _messageCache[chatId] = messages;
      _lastFetch[chatId] = DateTime.now();

      print('💾 Cached ${messages.length} messages for $chatId');
      return messages;
    });

    // Store the stream subscription
    _activeStreams[chatId] = stream.listen((_) {});

    return stream;
  }

  // Get cached messages if available
  static List<Message>? getCachedMessages(String chatId) {
    final lastFetch = _lastFetch[chatId];
    if (lastFetch != null &&
        DateTime.now().difference(lastFetch) < _cacheExpiry &&
        _messageCache.containsKey(chatId)) {

      print('⚡ Returning cached messages for $chatId');
      return _messageCache[chatId];
    }
    return null;
  }

  // Clean up when leaving chat
  static void disposeChat(String chatId) {
    print('🧹 Cleaning up chat $chatId');
    _activeStreams[chatId]?.cancel();
    _activeStreams.remove(chatId);
    // Keep messages in cache for quick return
  }

  // Get stream from cache
  static Stream<List<Message>> _getStreamFromCache(String chatId) {
    final cachedMessages = getCachedMessages(chatId);
    final controller = StreamController<List<Message>>(); // Use StreamController

    if (cachedMessages != null) {
      // Add cached data immediately
      controller.add(cachedMessages);
    }

    // Listen to the real-time stream and add events to the controller
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen(
          (snapshot) {
        final messages = snapshot.docs.map((doc) {
          return Message.fromFirestore(doc);
        }).toList();

        _messageCache[chatId] = messages;
        _lastFetch[chatId] = DateTime.now(); // Update last fetch time

        if (!controller.isClosed) {
          controller.add(messages);
        }
      },
      onError: (error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      },
      onDone: () {
        if (!controller.isClosed) {
          controller.close();
        }
      },
    );

    return controller.stream;
  }

  // Clear old cache periodically
  static void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _lastFetch.forEach((chatId, lastFetch) {
      if (now.difference(lastFetch) > _cacheExpiry) {
        expiredKeys.add(chatId);
      }
    });

    for (final key in expiredKeys) {
      _messageCache.remove(key);
      _lastFetch.remove(key);
      print('🗑️ Cleared expired cache for $key');
    }
  }
}
