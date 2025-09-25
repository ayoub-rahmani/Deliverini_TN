import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'curved_nav_painter.dart'; // Make sure you have this file

/// A beautiful and animated bottom navigation that may or may not be curved
/// and has a beautiful indicator around which the bottom nav is curved.
///
/// Update [selectedIndex] to change the selected item.
/// [selectedIndex] is required and must not be null.
class FixedDotCurvedBottomNav extends StatefulWidget {
  /// Animation curve of hiding animation and dot indicator moving between
  /// indices.
  final Curve animationCurve;

  /// Animation Duration of hiding animation and dot indicator moving between
  /// indices.
  final Duration animationDuration;

  /// Background color of the bottom navigation
  final Color backgroundColor;

  /// Color fo the dot indicator shown on the currently selected item
  final Color indicatorColor;

  /// Configures height of bottom navigation. The limitations of [height] are
  /// enforced through assertions.
  final double height;

  /// Configures the size of indicator
  final double indicatorSize;

  /// Configures currently selected / highlighted index
  final int selectedIndex;

  /// Defines the appearance of the buttons that are displayed in the bottom
  /// navigation bar. This should have at least two items and five at most.
  final List<Widget> items;

  /// Callback function that is invoked whenever an Item is tapped on by the user
  final ValueChanged<int>? onTap;

  /// [scrollController] is used to listen to when the user is scrolling the page
  /// and hided the bottom navigation
  final ScrollController? scrollController;

  /// Used to configure the borderRadius of the [DotCurvedBottomNav]. Defaults to 25.
  final double borderRadius;
  final EdgeInsets margin;

  /// Used to configure the margin around [DotCurvedBottomNav]. Increase it to make
  /// [DotCurvedBottomNav] float.
  final bool hideOnScroll;

  const FixedDotCurvedBottomNav({
    Key? key,
    required this.items,
    this.scrollController,
    this.hideOnScroll = false,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 600),
    this.backgroundColor = Colors.black,
    this.indicatorColor = Colors.white,
    this.height = 75.0,
    this.indicatorSize = 5,
    this.selectedIndex = 0,
    this.onTap,
    this.borderRadius = 25,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  })  : assert(items.length > 0),
        assert(selectedIndex >= 0 && selectedIndex < items.length),
        assert(height > 0 && height <= 75.0),
        assert(!hideOnScroll || scrollController != null,
        "You need to provide [scrollController] parameter to enable hide on scroll"),
        assert(borderRadius >= 0 && borderRadius <= 30),
        super(key: key);

  @override
  State<FixedDotCurvedBottomNav> createState() => _FixedDotCurvedBottomNavState();
}

class _FixedDotCurvedBottomNavState extends State<FixedDotCurvedBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late double _pos;
  bool _isInitialized = false;

  late final AnimationController _sliderController = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
    reverseDuration: widget.animationDuration,
  );

  @override
  void dispose() {
    super.dispose();
    widget.scrollController?.removeListener(_scrollListener);
    _animationController.dispose();
    _sliderController.dispose();
  }

  @override
  void didUpdateWidget(covariant FixedDotCurvedBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _buttonTap(widget.selectedIndex);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize position correctly for the painter
    _pos = widget.selectedIndex.toDouble();
    _animationController = AnimationController(
      vsync: this,
      value: widget.selectedIndex.toDouble(),
      lowerBound: 0,
      upperBound: widget.items.length.toDouble() - 1,
    );

    _animationController.addListener(() {
      setState(() => _pos = _animationController.value);
    });

    widget.scrollController?.addListener(_scrollListener);

    // Ensure proper initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _isInitialized = true;
        setState(() {
          _pos = widget.selectedIndex.toDouble();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sliderController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0,
              (widget.height + widget.margin.bottom) * _sliderController.value),
          child: Container(
            height: widget.height,
            margin: widget.margin,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: CurvedNavPainter(
                      startingLoc: _pos, // FIXED: Pass the raw position, let painter handle the calculation
                      itemsLength: widget.items.length,
                      color: widget.backgroundColor,
                      indicatorColor: widget.indicatorColor,
                      textDirection: Directionality.of(context),
                      indicatorSize: widget.indicatorSize,
                      borderRadius: widget.borderRadius,
                    ),
                    child: Container(),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: widget.height * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (int i = 0; i < widget.items.length; i++)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => _buttonTap(i),
                            child: widget.items[i],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _scrollListener() {
    if (_sliderController.isAnimating || widget.hideOnScroll == false) {
      return;
    }

    if (widget.scrollController?.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (_sliderController.isCompleted) {
        _sliderController.reverse();
      }
    } else if (widget.scrollController?.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if ((_sliderController.isCompleted || !_sliderController.isAnimating)) {
        _sliderController.forward();
      }
    }
  }

  void _buttonTap(int index) {
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
    _animationController.animateTo(index.toDouble(),
        duration: widget.animationDuration, curve: widget.animationCurve);
  }
}