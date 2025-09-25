import 'package:flutter/material.dart';

class CurvedNavPainter extends CustomPainter {
  Color color;
  late double loc;
  TextDirection textDirection;
  final double indicatorSize;
  final Color indicatorColor;
  double borderRadius;

  CurvedNavPainter({
    required double startingLoc,
    required int itemsLength,
    required this.color,
    required this.textDirection,
    this.indicatorColor = Colors.lightBlue,
    this.indicatorSize = 5,
    this.borderRadius = 25,
  }) {
    // FIXED: Calculate position to match spaceAround distribution
    // spaceAround creates equal space before first item, between items, and after last item
    // Each item gets: space + item_width + space
    // The space before/after is half the space between items

    if (itemsLength <= 1) {
      loc = 0.5; // Center if only one item
    } else {
      // Calculate the actual position considering spaceAround distribution
      // spaceAround divides available space into (itemsLength + 1) equal parts
      // Each item is positioned at: (index + 0.5) / itemsLength
      double itemPosition = (startingLoc + 0.5) / itemsLength;
      loc = itemPosition;
    }

    print('CurvedNavPainter - startingLoc: $startingLoc, itemsLength: $itemsLength, calculated loc: $loc');
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.fill;

    final height = size.height;
    final width = size.width;

    const s = 0.06;
    const depth = 0.24;
    final valleyWith = indicatorSize + 5;

    final path = Path()
    // top Left Corner
      ..moveTo(0, borderRadius)
      ..quadraticBezierTo(0, 0, borderRadius, 0)
      ..lineTo(loc * width - valleyWith * 2, 0)
      ..cubicTo(
        (loc + s * 0.20) * size.width - valleyWith,
        size.height * 0.05,
        loc * size.width - valleyWith,
        size.height * depth,
        (loc + s * 0.50) * size.width - valleyWith,
        size.height * depth,
      )
      ..cubicTo(
        (loc + s * 0.20) * size.width + valleyWith,
        size.height * depth,
        loc * size.width + valleyWith,
        0,
        (loc + s * 0.60) * size.width + valleyWith,
        0,
      )

    // top right corner
      ..lineTo(size.width - borderRadius, 0)
      ..quadraticBezierTo(width, 0, width, borderRadius)

    // bottom right corner
      ..lineTo(width, height - borderRadius)
      ..quadraticBezierTo(width, height, width - borderRadius, height)

    // bottom left corner
      ..lineTo(borderRadius, height)
      ..quadraticBezierTo(0, height, 0, height - borderRadius)
      ..close();

    canvas.drawPath(path, paint);

    // Draw the indicator circle at the correct position
    canvas.drawCircle(
        Offset(loc * width, indicatorSize), indicatorSize, circlePaint);

    // Debug: Draw a small red circle to verify position calculation
    // Set to false to remove debug circle in production
    if (false) {
      final debugPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          Offset(loc * width, indicatorSize + 15), 2, debugPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}