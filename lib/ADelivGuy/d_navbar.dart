import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'd_navigation_controller.dart';

class DeliveryNavbar extends StatefulWidget {
  const DeliveryNavbar({super.key});

  @override
  State<DeliveryNavbar> createState() => _DeliveryNavbarState();
}

class _DeliveryNavbarState extends State<DeliveryNavbar> {
  bool _showNavbar = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _showNavbar = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryNavigationController>();

    if (!_showNavbar) {
      return const SizedBox.shrink();
    }

    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(0, controller.navbarOffset.value, 0),
      child: FixedDotCurvedBottomNav(
        animationDuration: const Duration(milliseconds: 150),
        animationCurve: Curves.fastOutSlowIn,
        height: 75,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        indicatorColor: Colors.blue[700]!,
        selectedIndex: controller.selectedIndex.value,
        backgroundColor: const Color(0xFF171717),
        onTap: controller.changeIndex,
        items: [
          _buildNavItem('delivery', 0, controller),              // Orders (using existing delivery.svg)
          _buildNavItem('chat-dots', 1, controller),            // Active delivery (reusing chat icon)
          _buildNavItem('home2', 2, controller, isHome: true),  // Earnings (center/home)
          _buildNavItem('notifications', 3, controller),        // Notifications
          _buildNavItem('cart', 4, controller),                 // Profile (reusing cart icon)
        ],
      ),
    ));
  }

  Widget _buildNavItem(String assetName, int index, DeliveryNavigationController controller, {bool isHome = false}) {
    const double size = 30;
    final isSelected = controller.selectedIndex.value == index;
    final color = isSelected ? Colors.blue[700]! : Colors.white;

    return RepaintBoundary(
      child: SvgPicture.asset(
        'images/$assetName.svg',
        width: isHome ? size + 7 : size,
        height: isHome ? size + 7 : size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        // Add error handling for missing SVGs
        placeholderBuilder: (context) => _buildIconFallback(assetName, size, isHome, color),
      ),
    );
  }

  // Fallback icons if SVGs fail to load
  Widget _buildIconFallback(String assetName, double size, bool isHome, Color color) {
    IconData iconData;
    switch (assetName) {
      case 'delivery':
        iconData = Icons.list_alt; // Orders
        break;
      case 'chat-dots':
        iconData = Icons.delivery_dining; // Active delivery
        break;
      case 'home2':
        iconData = Icons.attach_money; // Earnings
        break;
      case 'notifications':
        iconData = Icons.notifications; // Notifications
        break;
      case 'cart':
        iconData = Icons.person; // Profile
        break;
      default:
        iconData = Icons.help_outline;
    }

    return Icon(
      iconData,
      size: isHome ? size + 7 : size,
      color: color,
    );
  }
}