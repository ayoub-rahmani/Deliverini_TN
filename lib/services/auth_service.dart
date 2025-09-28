import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_user.dart';
import 'notification_service.dart';

class AuthService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static AppUser? _currentUser;

  // Cache preferences instance
  static SharedPreferences? _prefs;

  // Initialize with false, will be updated during autoLogin
  static final ValueNotifier<bool> authStateNotifier = ValueNotifier<bool>(false);

  // Cache frequently used collections
  static final _usersCollection = _firestore.collection('users');
  static final _credentialsCollection = _firestore.collection('user_credentials');

  // Getters
  static AppUser? get currentUser => _currentUser;
  static String get currentUserId => _currentUser?.id ?? '';
  static bool get isLoggedIn => _currentUser != null;
  static bool get isClient => _currentUser?.userType == 'client';
  static bool get isDelivery => _currentUser?.userType == 'delivery';

  // Initialize preferences
  static Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Validate input
  static String? _validateUserType(String userType) {
    return (userType != 'client' && userType != 'delivery')
        ? 'نوع المستخدم غير صحيح'
        : null;
  }

  static String? _validateEmail(String email) {
    final trimmedEmail = email.toLowerCase().trim();
    if (trimmedEmail.isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmedEmail)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  static String? _validatePassword(String password) {
    return password.trim().isEmpty ? 'كلمة المرور مطلوبة' : null;
  }

  static String? _validateName(String name) {
    return name.trim().isEmpty ? 'الاسم مطلوب' : null;
  }

  // Initialize notifications safely
  static Future<void> _initializeNotifications() async {
    try {
      await NotificationService.initialize();
    } catch (e) {
      print('⚠️ Notification initialization failed: $e');
      // Don't fail auth operations if notifications fail
    }
  }

  // Sign up new user
  static Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String userType,
    bool rememberMe = false,
  }) async {
    try {
      // Validate inputs
      final userTypeError = _validateUserType(userType);
      final emailError = _validateEmail(email);
      final passwordError = _validatePassword(password);
      final nameError = _validateName(name);

      if (userTypeError != null) throw Exception(userTypeError);
      if (emailError != null) throw Exception(emailError);
      if (passwordError != null) throw Exception(passwordError);
      if (nameError != null) throw Exception(nameError);

      final trimmedEmail = email.toLowerCase().trim();
      final trimmedName = name.trim();

      // Check if email already exists (optimized query)
      final existingUser = await _credentialsCollection
          .where('email', isEqualTo: trimmedEmail)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw Exception('البريد الإلكتروني مستخدم بالفعل');
      }

      // Create user document
      final userDoc = _usersCollection.doc();
      final now = DateTime.now();

      final newUser = AppUser(
        id: userDoc.id,
        name: trimmedName,
        email: trimmedEmail,
        userType: userType,
        profileImage: userType == 'delivery' ? 'images/pp.png' : 'images/client.png',
        createdAt: now,
        isOnline: true,
        lastSeen: now,
      );

      // Use batch for better performance
      final batch = _firestore.batch();

      // Create user document
      batch.set(userDoc, newUser.toFirestore());

      // Create credentials document
      batch.set(_credentialsCollection.doc(userDoc.id), {
        'email': trimmedEmail,
        'password': password, // In production, hash this!
        'userId': userDoc.id,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Commit batch
      await batch.commit();

      _currentUser = newUser;

      // Initialize notifications
      await _initializeNotifications();

      // Save login state if needed
      if (rememberMe) {
        await _saveLoginState(userDoc.id, userType);
      }

      // Update auth state notifier
      authStateNotifier.value = true;

      print('✅ User signed up: $trimmedName ($userType)');
      return true;
    } catch (e) {
      print('❌ Sign up error: $e');
      _currentUser = null;
      authStateNotifier.value = false;
      rethrow;
    }
  }

  // Login existing user
  static Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Validate inputs
      final emailError = _validateEmail(email);
      final passwordError = _validatePassword(password);

      if (emailError != null) throw Exception(emailError);
      if (passwordError != null) throw Exception(passwordError);

      final trimmedEmail = email.toLowerCase().trim();

      // Find user credentials (optimized)
      final credentialsQuery = await _credentialsCollection
          .where('email', isEqualTo: trimmedEmail)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (credentialsQuery.docs.isEmpty) {
        throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }

      final credentialData = credentialsQuery.docs.first.data();
      final userId = credentialData['userId'] as String;

      // Get user data
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('المستخدم غير موجود');
      }

      _currentUser = AppUser.fromFirestore(userDoc);

      // Update online status (batch for performance)
      final batch = _firestore.batch();
      batch.update(_usersCollection.doc(userId), {
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      // Fix userType inconsistency if needed
      final credentialUserType = credentialData['userType'];
      if (credentialUserType != null && credentialUserType != _currentUser!.userType) {
        batch.update(_credentialsCollection.doc(userId), {
          'userType': _currentUser!.userType,
        });
        print('⚠️ Fixed userType inconsistency for user: $userId');
      }

      await batch.commit();

      // Initialize notifications
      await _initializeNotifications();

      // Save login state if needed
      if (rememberMe) {
        await _saveLoginState(userId, _currentUser!.userType);
      }

      // Update auth state notifier
      authStateNotifier.value = true;

      print('✅ User logged in: ${_currentUser!.name} (${_currentUser!.userType})');
      return true;
    } catch (e) {
      print('❌ Login error: $e');
      _currentUser = null;
      authStateNotifier.value = false;
      rethrow;
    }
  }

  // Auto login with remember me
  static Future<bool> autoLogin() async {
    try {
      await _initPrefs();
      final savedUserId = _prefs!.getString('remembered_user_id');

      if (savedUserId == null) {
        authStateNotifier.value = false;
        return false;
      }

      // Get user data
      final userDoc = await _usersCollection.doc(savedUserId).get();
      if (!userDoc.exists) {
        await _clearLoginState();
        authStateNotifier.value = false;
        return false;
      }

      _currentUser = AppUser.fromFirestore(userDoc);

      // Update online status
      await _usersCollection.doc(savedUserId).update({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      // Initialize notifications
      await _initializeNotifications();

      // Update auth state notifier
      authStateNotifier.value = true;

      print('✅ Auto login successful: ${_currentUser!.name} (${_currentUser!.userType})');
      return true;
    } catch (e) {
      print('❌ Auto login error: $e');
      await _clearLoginState();
      _currentUser = null;
      authStateNotifier.value = false;
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    print('🚪 Starting logout process...');
    print('Current user before logout: ${_currentUser?.name ?? 'null'}');
    print('Auth notifier value before: ${authStateNotifier.value}');

    try {
      if (_currentUser != null) {
        // Clear FCM token
        try {
          await NotificationService.clearFCMToken();
        } catch (e) {
          print('⚠️ Failed to clear FCM token: $e');
        }

        // Update online status
        await _usersCollection.doc(_currentUser!.id).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

      // Clear user data and state
      _currentUser = null;
      await _clearLoginState();

      // Update auth state notifier
      authStateNotifier.value = false;

      print('Current user after logout: ${_currentUser?.name ?? 'null'}');
      print('Auth notifier value after: ${authStateNotifier.value}');
      print('🚪 User logged out successfully');

    } catch (e) {
      print('❌ Logout error: $e');
      // Even if there's an error, clear the local state
      _currentUser = null;
      await _clearLoginState();
      authStateNotifier.value = false;

      print('Auth notifier value after error: ${authStateNotifier.value}');
    }
  }

  // Save login state for remember me
  static Future<void> _saveLoginState(String userId, String userType) async {
    try {
      await _initPrefs();
      await Future.wait([
        _prefs!.setString('remembered_user_id', userId),
        _prefs!.setString('remembered_user_type', userType),
      ]);
      print('💾 Login state saved for user: $userId ($userType)');
    } catch (e) {
      print('❌ Error saving login state: $e');
    }
  }

  // Clear login state
  static Future<void> _clearLoginState() async {
    try {
      await _initPrefs();
      await Future.wait([
        _prefs!.remove('remembered_user_id'),
        _prefs!.remove('remembered_user_type'),
        // Clear all shared preferences to be extra safe
        _prefs!.clear(),
      ]);
      print('🗑️ Login state cleared');
    } catch (e) {
      print('❌ Error clearing login state: $e');
    }
  }

  // Refresh current user data
  static Future<void> refreshCurrentUser() async {
    if (_currentUser == null) return;

    try {
      final userDoc = await _usersCollection.doc(_currentUser!.id).get();
      if (userDoc.exists) {
        _currentUser = AppUser.fromFirestore(userDoc);
        print('🔄 Current user data refreshed');
      }
    } catch (e) {
      print('❌ Error refreshing user data: $e');
    }
  }

  // Get users for chat (optimized)
  static Future<List<AppUser>> getChatUsers() async {
    try {
      final query = _usersCollection
          .where(FieldPath.documentId, isNotEqualTo: currentUserId);

      final snapshot = await query.get();

      final users = snapshot.docs
          .map((doc) => AppUser.fromFirestore(doc))
          .toList();

      // Sort efficiently
      users.sort((a, b) {
        // Online users first
        if (a.isOnline != b.isOnline) {
          return a.isOnline ? -1 : 1;
        }
        // Then by name
        return a.name.compareTo(b.name);
      });

      return users;
    } catch (e) {
      print('❌ Get chat users error: $e');
      return [];
    }
  }

  // Search users by name and type (optimized)
  static Future<List<AppUser>> searchUsers(String query, {String? userType}) async {
    try {
      if (query.isEmpty) return [];

      Query queryRef = _usersCollection;

      // Filter by user type if specified
      if (userType != null) {
        queryRef = queryRef.where('userType', isEqualTo: userType);
      }

      // Exclude current user
      if (_currentUser != null) {
        queryRef = queryRef.where(FieldPath.documentId, isNotEqualTo: _currentUser!.id);
      }

      final snapshot = await queryRef.get();
      final lowerQuery = query.toLowerCase();

      final users = snapshot.docs
          .map((doc) => AppUser.fromFirestore(doc))
          .where((user) => user.name.toLowerCase().contains(lowerQuery))
          .toList();

      // Sort efficiently
      users.sort((a, b) {
        if (a.isOnline != b.isOnline) {
          return a.isOnline ? -1 : 1;
        }
        return a.name.compareTo(b.name);
      });

      return users;
    } catch (e) {
      print('❌ Search users error: $e');
      return [];
    }
  }

  // Get current user info for UI
  static Map<String, String> getCurrentUserInfo() {
    if (_currentUser == null) {
      return {
        'id': '',
        'name': 'غير مسجل',
        'type': 'غير محدد',
        'email': '',
      };
    }

    return {
      'id': _currentUser!.id,
      'name': _currentUser!.name,
      'type': _currentUser!.userType == 'client' ? 'عميل' : 'عامل توصيل',
      'email': _currentUser!.email,
    };
  }

  // Verify current user type
  static String getCurrentUserType() => _currentUser?.userType ?? 'none';

  // Validate current user
  static Future<bool> validateCurrentUser() async {
    if (_currentUser == null) return false;

    try {
      final userDoc = await _usersCollection.doc(_currentUser!.id).get();
      if (!userDoc.exists) {
        await logout();
        return false;
      }

      final freshUser = AppUser.fromFirestore(userDoc);
      if (freshUser.userType != _currentUser!.userType) {
        print('⚠️ UserType changed from ${_currentUser!.userType} to ${freshUser.userType}');
        _currentUser = freshUser;

        // Update saved preferences if needed
        await _initPrefs();
        if (_prefs!.containsKey('remembered_user_id')) {
          await _saveLoginState(_currentUser!.id, _currentUser!.userType);
        }
      }

      return true;
    } catch (e) {
      print('❌ Error validating current user: $e');
      return false;
    }
  }
}