import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app3/pages/delivery_orders.dart';
import 'package:app3/pages/homepage.dart';
import 'package:app3/pages/messages.dart';
import 'package:app3/pages/notifications.dart';
import '../pages/cart.dart';

class NavigationController extends GetxController {
  final RxInt selectedIndex = 2.obs; // Start with home (index 2)
  final RxDouble navbarOffset = 0.0.obs;

  late final List<Widget> _screens;
  double _lastScrollPosition = 0.0;

  @override
  void onInit() {
    super.onInit();
    print('NavigationController onInit - selectedIndex: ${selectedIndex.value}');

    _screens = [
      const Notifications(),
      const Messages(),
      const Homepage(),
      const DeliveryOrders(),
      const Cart(),
    ];

    // Ensure selectedIndex starts at 2 (home)
    selectedIndex.value = 2;

    // Add a small delay to ensure the navbar initializes with the correct position
    Future.delayed(const Duration(milliseconds: 50), () {
      if (selectedIndex.value == 2) {
        // Trigger a rebuild to ensure correct positioning
        selectedIndex.refresh();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    print('NavigationController onReady - selectedIndex: ${selectedIndex.value}');

    // Force another refresh after the widget tree is fully built
    Future.delayed(const Duration(milliseconds: 100), () {
      selectedIndex.refresh();
    });
  }

  List<Widget> get screens => _screens;

  void changeIndex(int index) {
    print('NavigationController changeIndex - from ${selectedIndex.value} to $index');
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
      showNavbar();
    }
  }

  void handleScroll(double currentPosition, double maxScrollExtent) {
    if (maxScrollExtent < 150) {
      showNavbar();
      _lastScrollPosition = currentPosition;
      return;
    }

    double delta = currentPosition - _lastScrollPosition;

    if (delta < -5) {
      // Scroll up - show navbar immediately
      showNavbar();
    } else if (delta > 5 && currentPosition > 120) {
      // Scroll down after threshold - hide navbar
      hideNavbar();
    }

    _lastScrollPosition = currentPosition;
  }

  void hideNavbar() => navbarOffset.value = 100.0;
  void showNavbar() => navbarOffset.value = 0.0;
}