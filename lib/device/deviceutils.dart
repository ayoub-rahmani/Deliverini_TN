import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';

class DeviceUtils {
  // ------- Screen Dimensions -------

  /// Full screen width
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Full screen height
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Usable height without top & bottom safe areas
  static double usableHeight(BuildContext context) =>
      height(context) - statusBarHeight(context) - bottomBarHeight(context);

  /// Pixel ratio of the screen
  static double pixelRatio(BuildContext context) =>
      MediaQuery.of(context).devicePixelRatio;

  // ------- Orientation -------

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  // ------- Safe Areas (Insets) -------

  /// Status bar height (top safe area)
  static double statusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  /// Bottom bar height (gesture bar / nav bar)
  static double bottomBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  /// AppBar height
  static double appBarHeight() => kToolbarHeight;

  /// Total top bar height (status + app bar)
  static double totalTopBarHeight(BuildContext context) =>
      statusBarHeight(context) + kToolbarHeight;

  /// Safe area insets
  static EdgeInsets safeAreaInsets(BuildContext context) =>
      MediaQuery.of(context).padding;

  /// Is keyboard open
  static bool isKeyboardOpen(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom > 0;

  // ------- Device Type -------

  /// Check if the device is considered a tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  /// Approximate screen diagonal size in inches
  static double screenInches(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final widthInPixels = size.width * pixelRatio;
    final heightInPixels = size.height * pixelRatio;
    return sqrt(pow(widthInPixels, 2) + pow(heightInPixels, 2)) / 160;
  }

  // ------- Platform Checks -------

  static bool isAndroid() => Platform.isAndroid;

  static bool isIOS() => Platform.isIOS;

  static bool isFuchsia() => Platform.isFuchsia;

  static bool isLinux() => Platform.isLinux;

  static bool isMacOS() => Platform.isMacOS;

  static bool isWindows() => Platform.isWindows;
}
