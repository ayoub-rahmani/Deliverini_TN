import 'package:app3/pages/auth_page.dart';
import 'package:app3/pages/home.dart';
import 'package:app3/ADelivGuy/d_nav_screen.dart';
import 'package:app3/common/navigation_controller.dart';
import 'package:app3/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'utils/data_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return GetMaterialApp(
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(NavigationController());
      }),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
    // Listen to auth state changes
    AuthService.authStateNotifier.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    AuthService.authStateNotifier.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  Future<void> _initializeAuth() async {
    try {
      await AuthService.autoLogin();
    } catch (e) {
      print('Auto login failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {
        // This will trigger a rebuild when auth state changes
      });
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing
    if (_isInitializing) {
      return _buildLoadingScreen();
    }

    // Use ValueListenableBuilder to listen to auth state
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService.authStateNotifier,
      builder: (context, isLoggedIn, child) {
        print('🔄 AuthWrapper rebuild triggered');
        print('📊 Auth state: isLoggedIn = $isLoggedIn');
        print('👤 Current user: ${AuthService.currentUser?.name ?? 'null'}');
        print('🔗 Notifier value: ${AuthService.authStateNotifier.value}');

        if (isLoggedIn && AuthService.currentUser != null) {
          final userType = AuthService.currentUser!.userType;
          print('📱 Showing ${userType == 'delivery' ? 'DeliveryNavScreen' : 'Home'}');

          // Navigate to appropriate screen based on user type
          return userType == 'delivery'
              ? const DeliveryNavScreen()
              : const Home();
        }

        print('🔐 Showing AuthPage');
        return const AuthPage();
      },
    );
  }
}