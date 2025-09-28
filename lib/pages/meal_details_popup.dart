import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app3/device/deviceutils.dart';

import '../common/slide_notif.dart';
import 'meal_customization_page.dart'; // Import the customization page

class MealDetailsPopup {
  static Future show(BuildContext context, Map mealData) {
    final isTablet = DeviceUtils.isTablet(context);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => MealDetailsContent(
          mealData: mealData,
          scrollController: scrollController,
          isTablet: isTablet,
        ),
      ),
    );
  }
}

class MealDetailsContent extends StatefulWidget {
  final Map mealData;
  final ScrollController scrollController;
  final bool isTablet;

  const MealDetailsContent({
    required this.mealData,
    required this.scrollController,
    required this.isTablet,
    super.key,
  });

  @override
  State<MealDetailsContent> createState() => _MealDetailsContentState();
}

class _MealDetailsContentState extends State<MealDetailsContent> {
  int quantity = 1;
  bool _isAdding = false;

  void _showOrderTypeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'نوع الطلب',
            style: TextStyle(fontFamily: 'NotoSansArabic', fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'هل تريد طلب عادي أم مخصص؟',
            style: TextStyle(fontFamily: 'NotoSansArabic'),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _processNormalOrder();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'طلب عادي',
                      style: TextStyle(fontFamily: 'NotoSansArabic', color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateToCustomization();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'طلب مخصص',
                      style: TextStyle(fontFamily: 'NotoSansArabic', color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _processNormalOrder() async {
    if (_isAdding) return;

    setState(() => _isAdding = true);

    try {
      final cartCollection = FirebaseFirestore.instance.collection('cart');
      final mealId = widget.mealData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Create unique document ID for normal orders to avoid conflicts
      final docId = '${mealId}_normal_${DateTime.now().millisecondsSinceEpoch}';

      final orderData = {
        'id': docId,
        'name': widget.mealData['name'] ?? 'Unknown Meal',
        'price': (widget.mealData['price'] ?? 0.0).toDouble(),
        'quantity': quantity,
        'image': widget.mealData['imgUrl'] ?? 'images/meal.png',
        'ingredients': widget.mealData['ingredients'] ?? '',
        'calories': widget.mealData['calories'] ?? 320,
        'protein': widget.mealData['protein'] ?? 32,
        'fats': widget.mealData['fats'] ?? 20,
        'carbs': widget.mealData['carbs'] ?? 30,
        'isCustomized': false,
        'customizations': [],
        'timestamp': FieldValue.serverTimestamp(),
      };

      await cartCollection.doc(docId).set(orderData);

      if (mounted) {
        Navigator.of(context).pop();
        ToastService.success(
          context,
          'تمت إضافة الوجبة إلى السلة بنجاح',
          title: 'تم الحفظ',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ في إضافة الوجبة',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  void _navigateToCustomization() {
    List<String> ingredientsList;
    if (widget.mealData['ingredients'] is String) {
      // Split string ingredients by comma and trim whitespace
      ingredientsList = (widget.mealData['ingredients'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (widget.mealData['ingredients'] is List) {
      ingredientsList = List<String>.from(widget.mealData['ingredients']);
    } else {
      ingredientsList = [];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealCustomizationPage(
          mealName: widget.mealData['name'] ?? 'Unknown Meal',
          price: widget.mealData['price'] ?? 0.0,
          quantity: quantity,
          imageUrl: widget.mealData['imgUrl'] ?? 'images/meal.png',
          ingredients: ingredientsList,
        ),
      ),
    );
  }

  void _increment() => setState(() => quantity++);
  void _decrement() {
    if (quantity > 1) setState(() => quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.mealData;
    final deviceWidth = DeviceUtils.width(context);
    final deviceHeight = DeviceUtils.height(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(8),
      child: ListView(
        controller: widget.scrollController,
        children: [
          // Close button top left
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),

          // Big meal image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              meal['imgUrl'] ?? 'images/meal.png',
              width: double.infinity,
              height: deviceHeight * 0.25,
              fit: BoxFit.cover,
              cacheWidth: (deviceWidth * 3).toInt(), // good cache
              cacheHeight: (deviceHeight * 0.75).toInt(),
            ),
          ),

          const SizedBox(height: 16),

          // Meal Name big and bold
          Text(
            meal['name'] ?? 'اسم الوجبة',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: deviceWidth * 0.08,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              '${(meal['price'] ?? 0.0).toStringAsFixed(3)} د.ت',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: deviceWidth * 0.06,
                color: Colors.orange.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          // Ingredients title
          Text(
            "المكونات",
            style: TextStyle(
              fontFamily: 'NotoSansArabic_Condensed',
              fontSize: deviceWidth * 0.055,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          // Ingredients Text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.1),
            child: Text(
              meal['ingredients'] ?? 'لا توجد مكونات',
              style: TextStyle(
                fontFamily: 'NotoSansArabic_Condensed',
                fontSize: deviceWidth * 0.045,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),

          const SizedBox(height: 20),

          // Nutritional Info row, matching style from your menu
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _nutrientInfo(
                icon: 'images/calories.gif',
                label: '${meal['calories'] ?? 320} Kcal',
              ),
              SizedBox(width: deviceWidth * 0.02),
              _nutrientInfo(
                icon: 'images/meat.gif',
                label: '${meal['protein'] ?? 32} g Protein',
              ),
              SizedBox(width: deviceWidth * 0.02),
              _nutrientInfo(
                icon: 'images/fats.gif',
                label: '${meal['fats'] ?? 20} g Fats',
              ),
              SizedBox(width: deviceWidth * 0.02),
              _nutrientInfo(
                icon: 'images/carbs.png',
                label: '${meal['carbs'] ?? 30} g Carbs',
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Quantity selector with styled buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _decrement,
                child: _quantityButton(iconData: Icons.remove),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              GestureDetector(
                onTap: _increment,
                child: _quantityButton(iconData: Icons.add, isAdd: true),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Confirm Button
          GestureDetector(
            onTap: _isAdding ? null : _showOrderTypeDialog,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              decoration: BoxDecoration(
                gradient: _isAdding
                    ? null
                    : const LinearGradient(
                  colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                color: _isAdding ? Colors.grey : null,
                borderRadius: BorderRadius.circular(25),
                boxShadow: _isAdding
                    ? null
                    : [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isAdding
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'تأكيد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _nutrientInfo({required String icon, required String label}) {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Image.asset(icon, fit: BoxFit.contain),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _quantityButton({required IconData iconData, bool isAdd = false}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isAdd ? Colors.black : Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        iconData,
        color: isAdd ? Colors.white : Colors.black,
        size: 28,
      ),
    );
  }
}