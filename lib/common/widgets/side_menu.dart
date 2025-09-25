import 'package:app3/device/deviceutils.dart';
import 'package:app3/services/auth_service.dart';
import 'package:app3/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  static const List<Map<String, String>> _menuItems = [
    {'icon': 'images/setting.png', 'title': 'Account Settings'},
    {'icon': 'images/location_black.png', 'title': 'My Delivery Location'},
    {'icon': 'images/favourite.png', 'title': 'Favorites'},
    {'icon': 'images/contact.png', 'title': 'Contact us'},
    {'icon': 'images/news.png', 'title': 'News'},
  ];

  void _showLogoutDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final userInfo = AuthService.getCurrentUserInfo();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontFamily: 'NotoSansArabic',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'هل تريد تسجيل الخروج من حساب ${userInfo['name']}؟\n(${userInfo['type']})',
          style: const TextStyle(
            fontFamily: 'NotoSansArabic',
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleLogout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.pop(context); // Close dialog
    Navigator.pop(context); // Close side menu

    HapticFeedback.heavyImpact();

    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false,
    );


    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => FadeTransition(
          opacity: animation,
          child: const AuthPage(),
        ),
        transitionDuration: const Duration(milliseconds: 300),
        settings: const RouteSettings(name: '/auth'),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = DeviceUtils.height(context);
    final screenWidth = DeviceUtils.width(context);
    final statusBarHeight = DeviceUtils.statusBarHeight(context);
    final isTablet = DeviceUtils.isTablet(context);
    final userInfo = AuthService.getCurrentUserInfo();

    final menuWidth = isTablet ? screenWidth * 0.5 : screenWidth * 0.85;
    final profileImageSize = isTablet ? 94.0 : 74.0;
    final fontSize = isTablet ? 20.0 : 18.0;
    final iconSize = isTablet ? 30.0 : 26.0;

    final profileImage = userInfo['type'] == 'عامل توصيل'
        ? 'images/pp.png'
        : 'images/client.png';

    return Material(
      color: Colors.transparent,
      child: Container(
        width: menuWidth,
        height: screenHeight,
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x20000000),
              blurRadius: 15,
              offset: Offset(3, 0),
              spreadRadius: 3,
            )
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: statusBarHeight + 20,
                right: 20,
                left: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: isTablet ? 50.0 : 44.0,
                      height: isTablet ? 50.0 : 44.0,
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.orange[900],
                        size: isTablet ? 30.0 : 24.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Profile section
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: profileImageSize + 20,
                  height: profileImageSize + 20,
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: OvalBorder(),
                    shadows: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: profileImageSize,
                      height: profileImageSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(profileImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  userInfo['name']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isTablet ? 28 : 24,
                    fontFamily: 'NotoSansArabic',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                _UserTypeBadge(
                  userType: userInfo['type']!,
                  fontSize: isTablet ? 16.0 : 14.0,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Menu items
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  children: [
                    ...List.generate(_menuItems.length, (index) {
                      final item = _menuItems[index];
                      return _MenuItem(
                        item: item,
                        iconSize: iconSize,
                        fontSize: fontSize,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).pop();
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                    _LogoutButton(
                      iconSize: iconSize,
                      fontSize: fontSize,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            ),

            // Decorative gradient line
            Container(
              margin: const EdgeInsets.fromLTRB(30, 0, 30, 40),
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.orange[900]!.withOpacity(0.3),
                    Colors.orange[900]!.withOpacity(0.7),
                    Colors.orange[900]!,
                    Colors.orange[900]!,
                    Colors.orange[900]!.withOpacity(0.7),
                    Colors.orange[900]!.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.15, 0.3, 0.45, 0.55, 0.7, 0.85, 1.0],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTypeBadge extends StatelessWidget {
  final String userType;
  final double fontSize;

  const _UserTypeBadge({
    required this.userType,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivery = userType == 'عامل توصيل';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDelivery ? Colors.blue[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDelivery ? Colors.blue[200]! : Colors.green[200]!,
        ),
      ),
      child: Text(
        userType,
        style: TextStyle(
          color: isDelivery ? Colors.blue[700] : Colors.green[700],
          fontSize: fontSize,
          fontFamily: 'NotoSansArabic',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final Map<String, String> item;
  final double iconSize;
  final double fontSize;
  final VoidCallback onTap;

  const _MenuItem({
    required this.item,
    required this.iconSize,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNewsItem = item['title'] == 'News';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: Image.asset(
                  item['icon']!,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      size: iconSize,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: isNewsItem
                    ? Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'News   ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: fontSize,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '(Soon)',
                        style: TextStyle(
                          color: const Color(0xFF930000),
                          fontSize: fontSize,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                    : Text(
                  item['title']!,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: fontSize,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final VoidCallback onTap;

  const _LogoutButton({
    required this.iconSize,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.logout,
              size: iconSize,
              color: Colors.red[600],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: fontSize,
                  fontFamily: 'NotoSansArabic',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}