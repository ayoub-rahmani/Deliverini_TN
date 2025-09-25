import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app3/device/deviceutils.dart';
import 'package:app3/common/widgets/menu_card.dart';
import 'package:app3/pages/meal_details_popup.dart';
import 'package:app3/common/scroll_helper.dart';

import '../common/widgets/category_menu_card.dart';

class CategoriesPage extends StatefulWidget {
  final String? selectedCategory;

  const CategoriesPage({super.key, this.selectedCategory});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with ScrollHelper {
  String selectedCategory = 'الكل';
  List<String> categories = ['الكل'];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCategory != null) {
      selectedCategory = widget.selectedCategory!;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      QuerySnapshot categoriesSnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('order', descending: false)
          .get();

      List<String> loadedCategories = ['الكل'];
      for (var doc in categoriesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        loadedCategories.add(data['name'] ?? '');
      }

      setState(() {
        categories = loadedCategories;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _resolveIngredients(Map<String, dynamic> data) {
    final ingredients = data['ingredients'];
    if (ingredients == null) return 'لا توجد مكونات';

    if (ingredients is String) {
      return ingredients;
    } else if (ingredients is List) {
      return ingredients.join('، ');
    }
    return 'لا توجد مكونات';
  }

  String _resolveImage(Map<String, dynamic> data) {
    // First check if imgUrl exists and is not empty
    if (data.containsKey('imgUrl') && (data['imgUrl'] as String).isNotEmpty) {
      return data['imgUrl'];
    }

    // Get both category and name for comprehensive matching
    final category = data['category']?.toString().toLowerCase() ?? '';
    final name = data['name']?.toString().toLowerCase() ?? '';
    final searchText = '$category $name';

    // Pizza variations
    if (searchText.contains('بيتزا') || searchText.contains('pizza')) {
      return 'images/dropped-image.png';
    }

    // Sandwich/Fast food variations
    else if (searchText.contains('ساندويتش') || searchText.contains('شاورما') ||
        searchText.contains('sandwich') || searchText.contains('burger') ||
        searchText.contains('برغر') || searchText.contains('هوت دوغ')) {
      return 'images/sandwich.jpg';
    }

    // Desserts/Sweets variations
    else if (searchText.contains('حلويات') || searchText.contains('حلو') ||
        searchText.contains('كيك') || searchText.contains('تيراميسو') ||
        searchText.contains('cake') || searchText.contains('tiramisu') ||
        searchText.contains('dessert') || searchText.contains('sweet') ||
        searchText.contains('آيس كريم') || searchText.contains('ice cream') ||
        searchText.contains('شوكولا') || searchText.contains('chocolate')) {
      return 'images/cake.jpg';
    }

    // Beverages variations
    else if (searchText.contains('مشروبات') || searchText.contains('عصير') ||
        searchText.contains('شراب') || searchText.contains('drink') ||
        searchText.contains('juice') || searchText.contains('coffee') ||
        searchText.contains('قهوة') || searchText.contains('شاي') ||
        searchText.contains('tea') || searchText.contains('cola') ||
        searchText.contains('كولا') || searchText.contains('water')) {
      return 'images/drink.jpg';
    }

    // Salads variations
    else if (searchText.contains('سلطات') || searchText.contains('سلطة') ||
        searchText.contains('salad') || searchText.contains('سيزر') ||
        searchText.contains('caesar') || searchText.contains('خضار') ||
        searchText.contains('vegetable')) {
      return 'images/salade.jpg';
    }

    // Soups variations
    else if (searchText.contains('شوربة') || searchText.contains('حساء') ||
        searchText.contains('soup') || searchText.contains('شربة')) {
      return 'images/soupe.jpg';
    }

    // Bakery/Pastry variations
    else if (searchText.contains('معجنات') || searchText.contains('خبز') ||
        searchText.contains('فطير') || searchText.contains('bakery') ||
        searchText.contains('bread') || searchText.contains('pastry') ||
        searchText.contains('croissant') || searchText.contains('كرواسون')) {
      return 'images/bakery.jpg';
    }

    // Default fallback
    else {
      return 'images/autres.jpg';
    }
  }

  Stream<QuerySnapshot> _getMenuItemsStream() {
    if (selectedCategory == 'الكل') {
      return FirebaseFirestore.instance
          .collection('menu_items')
          .orderBy('rating', descending: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('menu_items')
          .where('category', isEqualTo: selectedCategory)
          .orderBy('rating', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = DeviceUtils.width(context);
    final screenHeight = DeviceUtils.height(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            // Main content container
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  height: screenHeight * 0.88,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Category filter buttons - Improved layout
                      Container(
                        height: 90,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                            : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          physics: const BouncingScrollPhysics(),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = category == selectedCategory;

                            return Container(
                              margin: const EdgeInsets.only(right: 15),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategory = category;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                      colors: [Colors.orange, Colors.deepOrange],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                        : null,
                                    color: !isSelected ? Colors.white : null,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : Colors.grey[300]!,
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                        : [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.grey[700],
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        fontFamily: 'NotoSansArabic',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Menu items grid
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _getMenuItemsStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                  'خطأ في التحميل',
                                  style: TextStyle(
                                    fontFamily: 'NotoSansArabic',
                                    fontSize: 18,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            }

                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(color: Colors.orange),
                              );
                            }

                            final docs = snapshot.data!.docs;

                            if (docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  'لا توجد عناصر في هذه الفئة',
                                  style: TextStyle(
                                    fontFamily: 'NotoSansArabic',
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            return GridView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data = docs[index].data() as Map<String, dynamic>;
                                final safeData = Map<String, dynamic>.from(data);
                                safeData['ingredients'] = _resolveIngredients(data);

                                return GestureDetector(
                                  onTap: () => MealDetailsPopup.show(context, safeData),
                                  child: CategoryMenuCard(
                                    title: data['name'] ?? '',
                                    price: data['price'] is int
                                        ? (data['price'] as int).toDouble()
                                        : (data['price'] ?? 0.0),
                                    rating: (data['rating'] ?? 0).toDouble(),
                                    resto: data['resto'] ?? '',
                                    imgUrl: _resolveImage(data),
                                    isfreeDel: (data['isfreeDel'] ?? false) == true,
                                    liked: data['liked'] ?? false,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Header with improved back button and title
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: screenWidth * 0.1,
                      height: screenWidth * 0.1,
                      child: Image.asset(
                        'images/backarrow2.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Text(
                    'الفئات',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansArabic',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.1), // Balance the back button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}