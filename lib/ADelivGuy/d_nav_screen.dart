import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'd_navigation_controller.dart'; // Import your delivery navigation controller
import 'd_navbar.dart'; // Import your custom delivery navbar

class DeliveryNavScreen extends StatelessWidget {
  const DeliveryNavScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DeliveryNavigationController controller = Get.put(DeliveryNavigationController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: const DeliveryNavbar(), // Use your custom curved navbar
    );
  }
}