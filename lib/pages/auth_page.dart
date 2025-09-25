import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ADelivGuy/d_nav_screen.dart';
import '../services/auth_service.dart';
import 'home.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  // Single animation controller for better performance
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLogin = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  String _selectedUserType = "client";

  // Controllers with dispose management
  final _controllers = <TextEditingController>[];
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _controllers.addAll([_nameController, _emailController, _passwordController]);
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Validation helper
  String? _validateInputs() {
    if (_emailController.text.trim().isEmpty) {
      return "البريد الإلكتروني مطلوب";
    }
    if (_passwordController.text.trim().isEmpty) {
      return "كلمة المرور مطلوبة";
    }
    if (!_isLogin) {
      if (_nameController.text.trim().isEmpty) {
        return "الاسم مطلوب للتسجيل";
      }
      if (_selectedUserType.isEmpty) {
        return "اختر نوع المستخدم";
      }
    }
    return null;
  }

  Future<void> _handleAuth() async {
    // Validate inputs
    final validationError = _validateInputs();
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    if (!mounted) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final success = _isLogin
          ? await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        rememberMe: _rememberMe,
      )
          : await AuthService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        userType: _selectedUserType,
        rememberMe: _rememberMe,
      );

      if (!success || !mounted) return;

      // Small delay to ensure auth state is properly set
      await Future.delayed(const Duration(milliseconds: 100));

      // Validate user data
      if (!await AuthService.validateCurrentUser()) {
        _showErrorSnackBar("خطأ في التحقق من بيانات المستخدم");
        return;
      }

      final user = AuthService.currentUser;
      if (user == null) {
        _showErrorSnackBar("فشل في الحصول على بيانات المستخدم");
        return;
      }

      await _navigateToUserScreen(user.userType);
    } catch (e) {
      _showErrorSnackBar(e.toString());
      debugPrint('Auth error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToUserScreen(String userType) async {
    if (!mounted) return;

    final (targetScreen, routeName) = switch (userType) {
      "delivery" => (const DeliveryNavScreen(), "/delivery"),
      "client" => (const Home(), "/home"),
      _ => throw Exception("نوع مستخدم غير صحيح"),
    };

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => FadeTransition(
          opacity: animation,
          child: targetScreen,
        ),
        transitionDuration: const Duration(milliseconds: 400),
        settings: RouteSettings(name: routeName),
      ),
          (route) => false,
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'NotoSansArabic',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'NotoSansArabic',
          ),
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(String type, String title, IconData icon) {
    final isSelected = _selectedUserType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isLoading) return;
          HapticFeedback.selectionClick();
          setState(() => _selectedUserType = type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isSelected ? 15 : 8,
                offset: const Offset(0, 4),
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: isSelected ? Colors.orange : Colors.orange[700],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'NotoSansArabic',
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleAuthMode() {
    if (_isLoading) return;

    HapticFeedback.selectionClick();
    setState(() {
      _isLogin = !_isLogin;
      _rememberMe = false;
      _selectedUserType = "client";
    });

    // Clear controllers efficiently
    for (final controller in _controllers) {
      controller.clear();
    }
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'تذكرني',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'NotoSansArabic',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            if (_isLoading) return;
            HapticFeedback.selectionClick();
            setState(() => _rememberMe = !_rememberMe);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _rememberMe ? Colors.orange : Colors.transparent,
              border: Border.all(
                color: _rememberMe ? Colors.orange : Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _rememberMe
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
          shadowColor: Colors.orange.withOpacity(0.3),
          disabledBackgroundColor: Colors.orange.withOpacity(0.6),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'NotoSansArabic',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleAuthMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? 'ليس لديك حساب؟' : 'هل لديك حساب بالفعل؟',
          style: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'NotoSansArabic',
          ),
        ),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: _toggleAuthMode,
          child: Text(
            _isLogin ? 'إنشاء حساب' : 'تسجيل الدخول',
            style: const TextStyle(
              color: Colors.orange,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Container(
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

                  const SizedBox(height: 30),

                  // Title
                  Text(
                    _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب جديد',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: 'NotoSansArabic',
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    _isLogin
                        ? 'أدخل بياناتك للدخول'
                        : 'قم بإنشاء حساب خاص بك',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                      fontFamily: 'NotoSansArabic',
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name field (signup only)
                  if (!_isLogin)
                    _buildTextField(
                      controller: _nameController,
                      hint: 'الاسم الكامل',
                      icon: Icons.person,
                    ),

                  // User type selection (signup only)
                  if (!_isLogin)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'نوع المستخدم',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'NotoSansArabic',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              _buildUserTypeCard(
                                'client',
                                'عميل',
                                Icons.person,
                              ),
                              const SizedBox(width: 15),
                              _buildUserTypeCard(
                                'delivery',
                                'موصل',
                                Icons.delivery_dining,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Email field
                  _buildTextField(
                    controller: _emailController,
                    hint: 'البريد الإلكتروني',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  // Password field
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'كلمة المرور',
                    icon: Icons.lock,
                    isPassword: true,
                  ),

                  // Remember me checkbox
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: _buildRememberMeCheckbox(),
                  ),

                  // Auth button
                  _buildAuthButton(),

                  const SizedBox(height: 30),

                  // Toggle auth mode
                  _buildToggleAuthMode(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }}