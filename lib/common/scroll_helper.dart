import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app3/common/navigation_controller.dart';

// Mixin to add scroll awareness to any scrollable widget
mixin ScrollHelper<T extends StatefulWidget> on State<T> {
  late ScrollController scrollController;
  final NavigationController navController = Get.find<NavigationController>();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    setupScrollListener();
  }

  void setupScrollListener() {
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;

      navController.handleScroll(
        scrollController.position.pixels,
        scrollController.position.maxScrollExtent,
      );
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}