import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'd_navigation_controller.dart';

class DeliveryNavScreen extends StatelessWidget {
  const DeliveryNavScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DeliveryNavigationController controller = Get.put(DeliveryNavigationController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'الطلبات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining),
              label: 'قيد التوصيل',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'الأرباح',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'الإشعارات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'ملفي',
            ),
          ],
        );
      }),
    );
  }
}
