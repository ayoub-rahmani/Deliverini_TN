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
    // Delay showing the navbar slightly to ensure DotCurvedBottomNav initializes correctly
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
      return const SizedBox.shrink(); // Return empty widget while waiting
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
        indicatorColor: Colors.blue[700]!, // Different color for delivery interface
        selectedIndex: controller.selectedIndex.value,
        backgroundColor: const Color(0xFF171717),
        onTap: controller.changeIndex,
        items: [
          _buildNavItem('images/delivery_orders.svg', 0, controller, isHome: true), // Main orders page
          _buildNavItem('images/delivery_active.svg', 1, controller),             // Active delivery
          _buildNavItem('images/earnings.svg', 2, controller),                    // Earnings
          _buildNavItem('images/notifications.svg', 3, controller),               // Notifications (reuse existing)
          _buildNavItem('images/delivery_profile.svg', 4, controller),           // Profile
        ],
      ),
    ));
  }

  Widget _buildNavItem(String asset, int index, DeliveryNavigationController controller, {bool isHome = false}) {
    const double size = 30;
    return RepaintBoundary(
      child: SvgPicture.asset(
        asset,
        width: isHome ? size + 7 : size,
        height: isHome ? size + 7 : size,
        colorFilter: ColorFilter.mode(
          controller.selectedIndex.value == index ? Colors.blue[700]! : Colors.white,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}