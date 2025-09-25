import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  const RoundedContainer({
    super.key,
    this.width = 10,
    this.height = 10,
    this.radius = 5,
    this.bgcolor = Colors.white,
    this.margin,
    this.padding,
    this.child,
    this.border,
  });

  final double width;
  final double height;
  final double radius;
  final Color bgcolor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 2),
      padding: padding,
      decoration: BoxDecoration(
        color: bgcolor,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}