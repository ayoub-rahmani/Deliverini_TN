import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../pages/auth_page.dart';
import '../pages/home.dart';
import '../ADelivGuy/d_nav_screen.dart';
import '../services/auth_service.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _authError;
  late AnimationController _logoAnimationController;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();

    AuthService.authStateNotifier.addListener(_onAuthChanged);
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoRotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5, // Half rotation
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    AuthService.authStateNotifier.removeListener(_onAuthChanged);
    _logoAnimationController.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {}); // Triggers rebuild on login/logout
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Add splash delay with animation
      await Future.delayed(const Duration(milliseconds: 800));

      // Try auto-login
      final success = await AuthService.autoLogin();

      if (success) {
        // Validate user data
        final isValid = await AuthService.validateCurrentUser();
        if (!isValid) {
          debugPrint('Auto-login validation failed');
          await AuthService.logout();
        } else {
          final user = AuthService.currentUser;
          debugPrint('Auto-login successful for ${user?.userType}');
        }
      }

      // Additional delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 200));

    } catch (e) {
      debugPrint('App initialization error: $e');
      _authError = e.toString();
      await AuthService.logout();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            AnimatedBuilder(
              animation: _logoAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoScaleAnimation.value,
                  child: Transform.rotate(
                    angle: _logoRotationAnimation.value * 3.14159, // Convert to radians
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Loading indicator
            const CircularProgressIndicator(
              color: Colors.orange,
              strokeWidth: 3,
            ),

            const SizedBox(height: 20),

            // Loading text
            const Text(
              'جاري التحميل...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'NotoSansArabic',
                fontWeight: FontWeight.w600,
              ),
            ),

            // Error display (if any)
            if (_authError != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'خطأ في التهيئة: $_authError',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'NotoSansArabic',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getHomeScreen() {
    final user = AuthService.currentUser;

    if (user == null) {
      debugPrint('No user found, showing auth page');
      return const AuthPage();
    }

    debugPrint('User found: ${user.name} (${user.userType})');

    // Use switch expression for cleaner code
    return switch (user.userType) {
      'delivery' => const DeliveryNavScreen(),
      'client' => const Home(),
      _ => _handleInvalidUserType(user.userType),
    };
  }

  Widget _handleInvalidUserType(String userType) {
    debugPrint('Invalid user type: $userType, showing auth page');
    // Clear invalid user state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService.logout();
    });
    return const AuthPage();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isLoading
          ? _buildLoadingScreen()
          : _getHomeScreen(),
    );
  }
}

// Optimized user debug widget (only in debug mode)
class UserDebugInfo extends StatelessWidget {
  const UserDebugInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (kDebugMode) {
      final user = AuthService.currentUser;
      if (user != null) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${user.name}\n${user.userType}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'NotoSansArabic',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }
}

// Route generator for better navigation handling
class AppRoutes {
  static const String auth = '/auth';
  static const String home = '/home';
  static const String delivery = '/delivery';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
        return _buildRoute(const AuthPage(), settings);
      case home:
        return _buildRoute(const Home(), settings);
      case delivery:
        return _buildRoute(const DeliveryNavScreen(), settings);
      default:
        return _buildRoute(const AuthPage(), settings);
    }
  }

  static PageRoute _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, _) => FadeTransition(
        opacity: animation,
        child: page,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}