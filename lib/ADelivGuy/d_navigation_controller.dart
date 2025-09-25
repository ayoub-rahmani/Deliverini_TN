import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/delivery_orders.dart';
import 'd_active_deliveries.dart';
import 'd_delivery_notifications.dart';
import 'd_earnings.dart';
import 'd_profile.dart';

class DeliveryNavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs; // Start on Orders page
  final RxDouble navbarOffset = 0.0.obs;

  late final List<Widget> screens;

  double lastScrollPosition = 0.0;

  @override
  void onInit() {
    super.onInit();

    screens = const [
      DeliveryOrders(), // Main orders screen
      ActiveDelivery(), // Active delivery screen
      Earnings(), // Earnings screen
      DeliveryNotifications(), // Notifications screen
      DeliveryProfile(), // Profile screen
    ];

    selectedIndex.value = 0;

    Future.delayed(const Duration(milliseconds: 50), () {
      if (selectedIndex.value == 0) selectedIndex.refresh();
    });
  }

  @override
  void onReady() {
    super.onReady();

    Future.delayed(const Duration(milliseconds: 100), () {
      selectedIndex.refresh();
    });
  }

  List<Widget> get screensList => screens;

  void changeIndex(int index) {
    if (selectedIndex.value != index) selectedIndex.value = index;
  }

  void handleScroll(double currentPosition, double maxScrollExtent) {
    if (maxScrollExtent < 150) {
      showNavbar();
      lastScrollPosition = currentPosition;
      return;
    }

    double delta = currentPosition - lastScrollPosition;

    if (delta < -5) {
      // Scroll up - show nav immediately
      showNavbar();
    } else if (delta > 5 && currentPosition > 120) {
      // Scroll down after threshold - hide nav
      hideNavbar();
    }

    lastScrollPosition = currentPosition;
  }

  void hideNavbar() {
    navbarOffset.value = 100.0;
  }

  void showNavbar() {
    navbarOffset.value = 0.0;
  }
}
