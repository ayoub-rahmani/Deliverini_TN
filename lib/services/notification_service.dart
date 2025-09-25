import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_service.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Navigation callback for handling notification taps
  static Function(String chatId, String senderId)? onNotificationTap;

  static Future<void> initialize() async {
    print('🔔 Initializing enhanced notification service...');

    // Request permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('❌ User declined notification permission');
      return;
    }

    // Initialize local notifications with custom sound
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();

    // Save FCM token
    await _saveFCMToken();

    // Set up message handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle initial message if app was opened from notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    print('✅ Enhanced notification service initialized');
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'chat_messages',
      'رسائل الدردشة',
      description: 'إشعارات الرسائل الجديدة',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _saveFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      final userId = AuthService.currentUserId;

      if (token != null && userId.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'platform': Theme.of(Get.context!).platform.name,
        });
        print('💾 FCM token saved: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📱 Foreground message: ${message.notification?.title}');

    // Only show notification if not in the same chat
    final chatId = message.data['chatId'];
    final currentRoute = Get.currentRoute;

    if (currentRoute != '/conversation' || !currentRoute.contains(chatId)) {
      await _showLocalNotification(message);
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('🔕 Background message: ${message.notification?.title}');
    // System handles background notifications automatically
  }

  static void _handleNotificationTap(RemoteMessage message) {
    print('👆 Notification tapped: ${message.data}');
    final chatId = message.data['chatId'];
    final senderId = message.data['senderId'];

    if (chatId != null && senderId != null) {
      // Use callback if available, otherwise navigate directly
      if (onNotificationTap != null) {
        onNotificationTap!(chatId, senderId);
      } else {
        _navigateToChat(chatId, senderId);
      }
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('👆 Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      final chatId = data['chatId'];
      final senderId = data['senderId'];

      if (chatId != null && senderId != null) {
        _navigateToChat(chatId, senderId);
      }
    }
  }

  static void _navigateToChat(String chatId, String senderId) {
    // Navigate to conversation page
    // You'll need to implement this based on your navigation structure
    print('🚀 Navigating to chat: $chatId with sender: $senderId');

    // Example navigation using GetX
    // Get.toNamed('/conversation', arguments: {
    //   'chatId': chatId,
    //   'senderId': senderId,
    // });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final String title = message.notification?.title ?? 'رسالة جديدة';
    final String body = message.notification?.body ?? 'لديك رسالة جديدة';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'رسائل الدردشة',
      channelDescription: 'إشعارات الرسائل الجديدة',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Colors.orange,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      category: AndroidNotificationCategory.message,
      fullScreenIntent: false,
      autoCancel: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      categoryIdentifier: 'MESSAGE_CATEGORY',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> sendMessageNotification({
    required String receiverId,
    required String senderName,
    required String messageText,
    required String chatId,
  }) async {
    try {
      final receiverDoc = await _firestore.collection('users').doc(receiverId).get();
      final receiverData = receiverDoc.data();

      if (receiverData == null || !receiverData.containsKey('fcmToken')) {
        print('❌ No FCM token for user: $receiverId');
        return;
      }

      final fcmToken = receiverData['fcmToken'];

      // Truncate message for notification
      final displayMessage = messageText.length > 50
          ? '${messageText.substring(0, 50)}...'
          : messageText;

      // Queue notification for processing by Cloud Function
      await _firestore.collection('notifications').add({
        'to': fcmToken,
        'notification': {
          'title': senderName,
          'body': displayMessage,
          'icon': 'https://your-app-icon-url.com/icon.png',
        },
        'data': {
          'chatId': chatId,
          'senderId': AuthService.currentUserId,
          'type': 'chat_message',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'android': {
          'notification': {
            'sound': 'default',
            'color': '#FF9400',
            'channel_id': 'chat_messages',
            'priority': 'high',
            'visibility': 'public',
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'sound': 'default',
              'badge': 1,
              'alert': {
                'title': senderName,
                'body': displayMessage,
              },
            },
          },
        },
        'timestamp': FieldValue.serverTimestamp(),
        'processed': false,
      });

      print('📤 Notification queued for $receiverId');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  static Future<void> updateFCMToken() async {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      final userId = AuthService.currentUserId;
      if (userId.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': newToken,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        print('🔄 FCM token updated');
      }
    });
  }

  static Future<void> clearFCMToken() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': FieldValue.delete(),
        });
        print('🗑️ FCM token cleared');
      }
    } catch (e) {
      print('❌ Error clearing FCM token: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('🔕 Background message handled: ${message.notification?.title}');
}