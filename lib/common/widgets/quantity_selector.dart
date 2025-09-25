import 'package:app3/device/deviceutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantitySelector extends StatefulWidget {
  final int initialValue;
  final void Function(int)? onChanged;
  final int minValue;
  final int maxValue;

  const QuantitySelector({
    super.key,
    this.initialValue = 1,
    this.onChanged,
    this.minValue = 1,
    this.maxValue = 99,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialValue.clamp(widget.minValue, widget.maxValue);
  }

  void increment() {
    if (quantity < widget.maxValue) {
      setState(() {
        quantity++;
      });
      HapticFeedback.selectionClick();
      widget.onChanged?.call(quantity);
    }
  }

  void decrement() {
    if (quantity > widget.minValue) {
      setState(() {
        quantity--;
      });
      HapticFeedback.selectionClick();
      widget.onChanged?.call(quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = DeviceUtils.width(context);
    final height = DeviceUtils.height(context);

    return RepaintBoundary(
      child: Container(
        width: width * 0.3,
        height: height * 0.09,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Quantity display box
            Container(
              height: height * 0.045,
              width: width * 0.18,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 121, 121, 121),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(30, 0, 0, 0),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: Text(
                    "$quantity",
                    key: ValueKey<int>(quantity),
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Minus button (left)
            Positioned(
              left: 0,
              child: GestureDetector(
                onTap: quantity > widget.minValue ? decrement : null,
                child: RepaintBoundary(
                  child: Container(
                    width: width * 0.11,
                    height: width * 0.11,
                    decoration: BoxDecoration(
                      color: quantity > widget.minValue
                          ? Colors.orange
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(width * 0.055),
                      boxShadow: quantity > widget.minValue ? const [
                        BoxShadow(
                          color: Color.fromARGB(30, 0, 0, 0),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      Icons.remove,
                      color: quantity > widget.minValue
                          ? Colors.white
                          : Colors.grey[500],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            // Plus button (right)
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: quantity < widget.maxValue ? increment : null,
                child: RepaintBoundary(
                  child: Container(
                    width: width * 0.11,
                    height: width * 0.11,
                    decoration: BoxDecoration(
                      color: quantity < widget.maxValue
                          ? Colors.orange
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(width * 0.055),
                      boxShadow: quantity < widget.maxValue ? const [
                        BoxShadow(
                          color: Color.fromARGB(30, 0, 0, 0),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      Icons.add,
                      color: quantity < widget.maxValue
                          ? Colors.white
                          : Colors.grey[500],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}