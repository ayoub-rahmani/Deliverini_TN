import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthDebug {
  static bool _isDebugMode = kDebugMode;

  static void log(String message, {String prefix = '🔍'}) {
    if (_isDebugMode) {
      print('$prefix [AUTH] $message');
    }
  }

  static void logError(String message, {dynamic error}) {
    if (_isDebugMode) {
      print('❌ [AUTH ERROR] $message');
      if (error != null) {
        print('   Details: $error');
      }
    }
  }

  static void logSuccess(String message) {
    if (_isDebugMode) {
      print('✅ [AUTH SUCCESS] $message');
    }
  }

  static void logWarning(String message) {
    if (_isDebugMode) {
      print('⚠️ [AUTH WARNING] $message');
    }
  }

  // Print current auth state
  static Future<void> printAuthState() async {
    if (!_isDebugMode) return;

    print('\n' + '='*50);
    print('🔍 CURRENT AUTH STATE');
    print('='*50);

    final user = AuthService.currentUser;
    if (user == null) {
      print('❌ No user logged in');
    } else {
      print('✅ User logged in:');
      print('   ID: ${user.id}');
      print('   Name: ${user.name}');
      print('   Email: ${user.email}');
      print('   Type: ${user.userType}');
      print('   Online: ${user.isOnline}');
      print('   Created: ${user.createdAt}');
    }

    // Check saved preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('remembered_user_id');
      final savedUserType = prefs.getString('remembered_user_type');

      print('\n📱 SAVED PREFERENCES:');
      print('   Remembered User ID: ${savedUserId ?? 'None'}');
      print('   Remembered User Type: ${savedUserType ?? 'None'}');
    } catch (e) {
      print('❌ Error reading preferences: $e');
    }

    print('='*50 + '\n');
  }

  // Validate auth consistency
  static Future<Map<String, dynamic>> validateAuthConsistency() async {
    final result = <String, dynamic>{
      'isValid': true,
      'issues': <String>[],
      'warnings': <String>[],
    };

    try {
      final user = AuthService.currentUser;

      if (user == null) {
        (result['issues'] as List<String>).add('No current user');
        result['isValid'] = false;
        return result;
      }

      // Check user type validity
      if (user.userType != 'client' && user.userType != 'delivery') {
        (result['issues'] as List<String>).add('Invalid user type: ${user.userType}');
        result['isValid'] = false;
      }

      // Check required fields
      if (user.id.isEmpty) {
        (result['issues'] as List<String>).add('Empty user ID');
        result['isValid'] = false;
      }

      if (user.name.isEmpty) {
        (result['issues'] as List<String>).add('Empty user name');
        result['isValid'] = false;
      }

      if (user.email.isEmpty) {
        (result['issues'] as List<String>).add('Empty user email');
        result['isValid'] = false;
      }

      // Check preferences consistency
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('remembered_user_id');
      final savedUserType = prefs.getString('remembered_user_type');

      if (savedUserId != null && savedUserId != user.id) {
        (result['warnings'] as List<String>).add('Saved user ID doesn\'t match current user');
      }

      if (savedUserType != null && savedUserType != user.userType) {
        (result['warnings'] as List<String>).add('Saved user type doesn\'t match current user');
      }

    } catch (e) {
      (result['issues'] as List<String>).add('Validation error: $e');
      result['isValid'] = false;
    }

    if (_isDebugMode) {
      print('\n🔍 AUTH VALIDATION RESULT:');
      print('   Valid: ${result['isValid']}');
      final issues = result['issues'] as List<String>;
      final warnings = result['warnings'] as List<String>;

      if (issues.isNotEmpty) {
        print('   Issues: $issues');
      }
      if (warnings.isNotEmpty) {
        print('   Warnings: $warnings');
      }
      print('');
    }

    return result;
  }

  // Clear all auth data (for debugging)
  static Future<void> clearAllAuthData() async {
    if (!_isDebugMode) return;

    try {
      await AuthService.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      logSuccess('All auth data cleared');
    } catch (e) {
      logError('Error clearing auth data', error: e);
    }
  }

  // Test navigation logic
  static String getExpectedRoute(String? userType) {
    switch (userType) {
      case 'delivery':
        return '/delivery';
      case 'client':
        return '/home';
      case null:
        return '/auth';
      default:
        return '/auth'; // fallback for invalid types
    }
  }

  // Monitor auth changes (call this in your app's main widget)
  static void startMonitoring() {
    if (!_isDebugMode) return;

    // You can implement a periodic check here if needed
    log('Auth monitoring started');
  }
}

// Extension to help with navigation debugging
extension NavigationDebug on NavigatorState {
  void debugPushReplacement(Route newRoute, {String? debugInfo}) {
    if (kDebugMode) {
      print('🔄 [NAVIGATION] Replacing route: ${debugInfo ?? newRoute.settings.name}');
    }
    pushReplacement(newRoute);
  }

  void debugPushAndRemoveUntil(Route newRoute, bool Function(Route) predicate, {String? debugInfo}) {
    if (kDebugMode) {
      print('🔄 [NAVIGATION] Push and remove until: ${debugInfo ?? newRoute.settings.name}');
    }
    pushAndRemoveUntil(newRoute, predicate);
  }
}