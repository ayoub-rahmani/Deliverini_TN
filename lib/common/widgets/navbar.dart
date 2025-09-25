import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../navigation_controller.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
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
    final controller = Get.find<NavigationController>();

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
        indicatorColor: Colors.orange[900]!,
        selectedIndex: controller.selectedIndex.value,
        backgroundColor: const Color(0xFF171717),
        onTap: controller.changeIndex,
        items: [
          _buildNavItem('images/notifications.svg', 0, controller),
          _buildNavItem('images/chat-dots.svg', 1, controller),
          _buildNavItem('images/home2.svg', 2, controller, isHome: true),
          _buildNavItem('images/delivery.svg', 3, controller),
          _buildNavItem('images/cart.svg', 4, controller),
        ],
      ),
    ));
  }

  Widget _buildNavItem(String asset, int index, NavigationController controller, {bool isHome = false}) {
    const double size = 30;
    return RepaintBoundary(
      child: SvgPicture.asset(
        asset,
        width: isHome ? size + 7 : size,
        height: isHome ? size + 7 : size,
        colorFilter: ColorFilter.mode(
          controller.selectedIndex.value == index ? Colors.orange[900]! : Colors.white,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}