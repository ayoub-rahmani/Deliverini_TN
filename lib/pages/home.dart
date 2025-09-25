import 'package:app3/common/widgets/navbar.dart';
import 'package:app3/common/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(NavigationController());

    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/bg2.png"),
                  fit: BoxFit.cover,
                  opacity: 0.06,
                ),
              ),
              child: Obx(
                    () => controller.screens[controller.selectedIndex.value],
              ),
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: Navbar()),
        ],
      ),
    );
  }
}
