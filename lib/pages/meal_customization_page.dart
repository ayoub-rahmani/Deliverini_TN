import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app3/device/deviceutils.dart';

class MealCustomizationPage extends StatefulWidget {
  final String mealName;
  final double price;
  final int quantity;
  final String imageUrl;
  final List ingredients;

  const MealCustomizationPage({
    Key? key,
    required this.mealName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.ingredients,
  }) : super(key: key);

  @override
  _MealCustomizationPageState createState() => _MealCustomizationPageState();
}

class _MealCustomizationPageState extends State<MealCustomizationPage> {
  late PageController _pageController;
  int _currentSandwichIndex = 0;
  late List<Map<String, dynamic>> _sandwichCustomizations;

  final List<String> _availableIngredients = [
    'بصل',
    'هريسة',
    'مايوناز',
    'خيار',
    'طماطم',
    'خس',
    'جزر مبشور',
    'ملح',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeCustomizations();
  }

  void _initializeCustomizations() {
    _sandwichCustomizations = List.generate(
      widget.quantity,
          (index) => {
        'sandwichNumber': index + 1,
        'ingredients': Map.fromIterable(
          _availableIngredients,
          key: (ingredient) => ingredient,
          value: (ingredient) => 1,
        ),
      },
    );
  }

  void _setIngredientLevel(String ingredient, int level) {
    setState(() {
      _sandwichCustomizations[_currentSandwichIndex]['ingredients'][ingredient] = level;
    });
  }

  // Replace the _finishCustomization method in MealCustomizationPage:

  void _finishCustomization() async {
    try {
      // Create a batch write to add all sandwiches at once
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (int i = 0; i < _sandwichCustomizations.length; i++) {
        final customization = _sandwichCustomizations[i];

        // Create a unique document reference for each sandwich
        final docRef = FirebaseFirestore.instance.collection('cart').doc();

        final orderData = {
          'name': '${widget.mealName} - ساندويش ${i + 1}',
          'price': widget.price,
          'quantity': 1, // Each sandwich is quantity 1
          'image': widget.imageUrl,
          'ingredients': widget.ingredients,
          'isCustomized': true,
          'isSingleSandwich': true, // Flag to identify individual sandwiches
          'sandwichIndex': i,
          'parentMealName': widget.mealName,
          'customizations': [customization], // Array with single customization
          'timestamp': FieldValue.serverTimestamp(),
        };

        batch.set(docRef, orderData);
      }

      // Commit all documents at once
      await batch.commit();

      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة الوجبة المخصصة إلى السلة', style: TextStyle(fontFamily: 'NotoSansArabic')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ في إضافة الوجبة', style: TextStyle(fontFamily: 'NotoSansArabic')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = DeviceUtils.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            bottom: DeviceUtils.height(context) * 0.9 + 10,
            right: 30,
            child: Text(
              "${widget.mealName}",
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "NotoSansArabic",
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),

          Positioned(
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              child: Container(
                width: DeviceUtils.width(context),
                height: DeviceUtils.height(context) * 0.9,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ساندويش ${_currentSandwichIndex + 1} من ${widget.quantity}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSansArabic',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentSandwichIndex = index;
                          });
                        },
                        itemCount: widget.quantity,
                        itemBuilder: (context, index) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Column(
                                children: [
                                  Container(
                                    height: 200,
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(95, 0, 0, 0),
                                          spreadRadius: 1,
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        widget.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.restaurant,
                                              size: 50, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'تخصيص المكونات',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NotoSansArabic',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ..._availableIngredients.map((ingredient) {
                                    int amount =
                                        _sandwichCustomizations[index]['ingredients'][ingredient] ?? 0;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
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
                                          padding: const EdgeInsets.all(16),
                                          color: Colors.white,
                                          child: Row(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () => _setIngredientLevel(ingredient, 0),
                                                    child: Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: amount == 0
                                                            ? const Color(0xFFE53E3E)
                                                            : Colors.grey[200],
                                                        borderRadius: BorderRadius.circular(10),
                                                        boxShadow: amount == 0
                                                            ? [
                                                          BoxShadow(
                                                            color: const Color(0xFFE53E3E)
                                                                .withOpacity(0.4),
                                                            spreadRadius: 2,
                                                            blurRadius: 8,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ]
                                                            : null,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '−',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                            color: amount == 0
                                                                ? Colors.white
                                                                : Colors.grey[600],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () => _setIngredientLevel(ingredient, 1),
                                                    child: Container(
                                                      width: 40,
                                                      height: 40,

                                                      decoration: BoxDecoration(
                                                        gradient: amount == 1
                                                            ? const LinearGradient(
                                                          colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                        ):null,
                                                        color: amount != 1
                                                            ? Colors.grey[200]
                                                            : null,
                                                        borderRadius: BorderRadius.circular(10),
                                                        boxShadow: amount == 1
                                                            ? [
                                                          BoxShadow(
                                                            color: const Color(0xFF2D3748)
                                                                .withOpacity(0.4),
                                                            spreadRadius: 2,
                                                            blurRadius: 8,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ]
                                                            : null,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '+',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                            color: amount == 1
                                                                ? Colors.white
                                                                : Colors.grey[600],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () => _setIngredientLevel(ingredient, 2),
                                                    child: Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: amount == 2
                                                            ? const Color(0xFF38A169)
                                                            : Colors.grey[200],
                                                        borderRadius: BorderRadius.circular(10),
                                                        boxShadow: amount == 2
                                                            ? [
                                                          BoxShadow(
                                                            color: const Color(0xFF38A169)
                                                                .withOpacity(0.4),
                                                            spreadRadius: 2,
                                                            blurRadius: 8,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ]
                                                            : null,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '++',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: amount == 2
                                                                ? Colors.white
                                                                : Colors.grey[600],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Text(
                                                  ingredient,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'NotoSansArabic',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.red[500],
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'إلغاء',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'NotoSansArabic',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          if (_currentSandwichIndex > 0)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'السابق',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'NotoSansArabic',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          if (_currentSandwichIndex > 0) const SizedBox(width: 12),

                          Expanded(
                            child: GestureDetector(
                              onTap: _currentSandwichIndex < widget.quantity - 1
                                  ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                                  : _finishCustomization,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _currentSandwichIndex < widget.quantity - 1 ? 'التالي' : 'تأكيد',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'NotoSansArabic',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
