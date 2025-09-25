import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:app3/device/deviceutils.dart';
import 'package:app3/common/scroll_helper.dart'; // import the mixin
import '../services/order_service.dart';
import 'delivery_selection_page.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State createState() => _CartState();
}

class _CartState extends State<Cart> with ScrollHelper {  // Add the mixin here
  final CollectionReference _cartRef = FirebaseFirestore.instance.collection('cart');
  bool _isOrdering = false;
  Map<String, bool> _expandedItems = {};

  double _calculateSubtotal(List<Map<String, dynamic>> cartItems) {
    double subtotal = 0;
    for (var item in cartItems) {
      double price = item['price'] ?? 0.0;
      int quantity = item['quantity'] ?? 1;
      double itemTotal = price * quantity;

      if (item.containsKey('customizations')) {
        for (var c in item['customizations']) {
          if (c['type'] == 'add') {
            itemTotal += (c['price'] ?? 0) * quantity;
          }
        }
      }
      subtotal += itemTotal;
    }
    return subtotal;
  }

  Future _updateQuantity(String id, int quantity) async {
    if (quantity <= 0) {
      await _cartRef.doc(id).delete();
    } else {
      await _cartRef.doc(id).update({'quantity': quantity});
    }
    HapticFeedback.selectionClick();
  }

  Future _removeItem(String id) async {
    await _cartRef.doc(id).delete();
    HapticFeedback.lightImpact();
  }

  Future<void> _placeOrder(List<Map<String, dynamic>> cartItems) async {
    if (_isOrdering || cartItems.isEmpty) return;

    setState(() => _isOrdering = true);

    try {
      final orderId = await OrderService.createOrder(
        cartItems: cartItems,
        customerName: 'عميل',
        customerPhone: '+216 XX XXX XXX',
        deliveryAddress: 'شارع الحبيب بورقيبة، تونس',
        notes: 'طلب من التطبيق',
      );

      if (!mounted) return;

      if (orderId != null) {
        setState(() => _isOrdering = false);

        // Show as modal overlay - no page transition
        await showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          builder: (context) => DeliverySelectionPage(
            orderId: orderId,
            onDeliverySelected: () {
              Navigator.pop(context); // Close the modal
              _showSuccessDialog(orderId);
            },
          ),
        );
      } else {
        throw Exception('فشل في إنشاء الطلب');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء إرسال الطلب', style: TextStyle(fontFamily: 'NotoSansArabic')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isOrdering = false);
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'تم إرسال الطلب بنجاح!',
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'رقم الطلب',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    orderId,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تم تعيين عامل التوصيل وسيتم التواصل معك قريباً',
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'حسناً',
                style: TextStyle(
                  fontFamily: 'NotoSansArabic',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    final isTablet = DeviceUtils.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            bottom: DeviceUtils.height(context) * 0.88 + 10,
            right: 30,
            child: const Text(
              "السلة",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "NotoSansArabic",
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              child: Container(
                width: DeviceUtils.width(context),
                height: DeviceUtils.height(context) * 0.88,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _cartRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Colors.orange));
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return _buildEmptyCart(isTablet);
                    }
                    final cartItems = docs.map((doc) {
                      final data = doc.data()! as Map<String, dynamic>;
                      return {
                        'id': doc.id,
                        'name': data['name'] ?? '',
                        'price': data['price']?.toDouble() ?? 0.0,
                        'quantity': data['quantity'] ?? 1,
                        'image': data['image'] ?? 'images/meal.png',
                        'customizations': data['customizations'] ?? [],
                        'isCustomized': data['isCustomized'] ?? false,
                      };
                    }).toList();

                    final subtotal = _calculateSubtotal(cartItems);
                    final total = subtotal + 2.5;

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            child: _buildCartContent(isTablet, cartItems),
                          ),
                        ),
                        _buildFixedBottomSection(cartItems, subtotal, total),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: DeviceUtils.height(context) * 0.88,
            left: DeviceUtils.width(context) * 0.09,
            child: RepaintBoundary(
              child: Lottie.asset(
                "images/carticon.json",
                width: DeviceUtils.width(context) * 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(bool isTablet) {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RepaintBoundary(child: Center(child: Lottie.asset("images/cart.json"))),
          Text(
            "السّلة فارغة ! ",
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: const Color.fromARGB(255, 55, 55, 55),
              fontFamily: "NotoSansArabic",
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: DeviceUtils.height(context) * 0.15),
        ],
      ),
    );
  }

  // Replace the _buildCartContent method in your Cart class:

  Widget _buildCartContent(bool isTablet, List<Map<String, dynamic>> cartItems) {
    // No need for complex expansion logic - just display items as they are
    List<Map<String, dynamic>> displayItems = cartItems;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلبك من LaMAMMA',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontFamily: 'NotoSansArabic',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${displayItems.length} عنصر',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isTablet ? 14 : 12,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 15),
        ...displayItems.map((item) => _buildCartItem(item, isTablet)).toList(),
        const SizedBox(height: 120),
      ],
    );
  }

// Also update the _buildCartItem method to handle the new structure:

  Widget _buildCartItem(Map<String, dynamic> item, bool isTablet) {
    bool isCustomized = item['isCustomized'] ?? false;
    bool isSingleSandwich = item['isSingleSandwich'] ?? false;
    String itemKey = item['id'];
    bool isExpanded = _expandedItems[itemKey] ?? false;

    return GestureDetector(
      onTap: isCustomized ? () {
        setState(() {
          _expandedItems[itemKey] = !isExpanded;
        });
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
        width: double.infinity,
        height: isExpanded ? null : 80,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(95, 0, 0, 0),
              spreadRadius: 1,
              blurRadius: 15,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    if (isCustomized)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandedItems[itemKey] = !isExpanded;
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 18,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        item['image'],
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.restaurant, color: Colors.grey, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item['name'].toString().toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${item['price'].toStringAsFixed(3)} د.ت',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 161, 161, 161),
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isCustomized) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'مخصص',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.orange,
                                          fontFamily: 'NotoSansArabic',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // For single sandwiches, disable quantity controls and just show delete
                        if (isSingleSandwich) ...[
                          Container(
                            width: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '${item['quantity']}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _removeItem(item['id']),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red!),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                            ),
                          ),
                        ] else ...[
                          // Regular quantity controls for non-customized items
                          GestureDetector(
                            onTap: () => _updateQuantity(item['id'], item['quantity'] - 1),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.remove, size: 14),
                            ),
                          ),
                          Container(
                            width: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '${item['quantity']}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _updateQuantity(item['id'], item['quantity'] + 1),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add, size: 14, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _removeItem(item['id']),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red!),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (isExpanded && isCustomized)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildExpandedCustomizationDetails(
                        isSingleSandwich && item['customizations'] != null && item['customizations'].isNotEmpty
                            ? item['customizations'][0]
                            : item['customizations']?[0] ?? {}
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedCustomizationDetails(Map<String, dynamic> customization) {
    Map<String, dynamic> ingredients = customization['ingredients'] ?? {};
    List<Widget> ingredientWidgets = [];

    ingredients.forEach((ingredient, amount) {
      if (amount == 0) {
        ingredientWidgets.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    ingredient,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontFamily: 'NotoSansArabic',
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Text(' : ', style: TextStyle(color: Colors.black, fontSize: 12)),
                const Text(
                  'بدون',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (amount == 2) {
        ingredientWidgets.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    ingredient,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontFamily: 'NotoSansArabic',
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Text(' : ', style: TextStyle(color: Colors.black, fontSize: 12)),
                const Text(
                  'إضافي',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    if (ingredientWidgets.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد تخصيصات',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontFamily: 'NotoSansArabic',
          ),
        ),
      );
    }

    return Column(
      children: [
        const Text(
          'التخصيصات:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSansArabic',
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, // Reduced from 8 to 6
          runSpacing: 3, // Reduced from 4 to 3
          children: ingredientWidgets.map((widget) =>
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.4, // Max 40% of screen width
                ),
                child: widget,
              ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildFixedBottomSection(List<Map<String, dynamic>> cartItems, double subtotal, double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(95, 0, 0, 0),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(95, 0, 0, 0),
                  spreadRadius: 1,
                  blurRadius: 15,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(15),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المجموع الفرعي:', style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 14)),
                        Text('${subtotal.toStringAsFixed(3)} د.ت', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('رسوم التوصيل:', style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 14)),
                        Text('2.500 د.ت', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                    const Divider(height: 20, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المجموع الكلي:', style: TextStyle(fontSize: 16, fontFamily: 'NotoSansArabic', fontWeight: FontWeight.w700)),
                        Text('${total.toStringAsFixed(3)} د.ت', style: const TextStyle(fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _isOrdering ? null : () => _placeOrder(cartItems),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _isOrdering ? Colors.grey : Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(95, 0, 0, 0),
                    spreadRadius: 1,
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: _isOrdering
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                  'كماندي',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'NotoSansArabic', fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}