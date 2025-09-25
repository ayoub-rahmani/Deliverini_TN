import 'package:app3/device/deviceutils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../pages/category_page.dart';

class CategoryUnit extends StatelessWidget {
  const CategoryUnit({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('order', descending: false)
            .limit(8)
            .snapshots(),
        builder: (context, snapshot) {
          // If Firebase fails, show the original static categories
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildOriginalCategories(context);
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return _buildOriginalCategories(context);
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: docs.length + 2, // +2 for padding
            cacheExtent: 2000,
            itemBuilder: (context, index) {
              if (index == docs.length + 1) {
                return SizedBox(width: DeviceUtils.width(context) * 0.05);
              }
              if (index == 0) {
                return SizedBox(width: DeviceUtils.width(context) * 0.05);
              }

              final data = docs[index - 1].data() as Map<String, dynamic>;
              final categoryName = data['name'] ?? '';
              final categoryIcon = data['icon'] ?? 'restaurant';

              return RepaintBoundary(
                key: ValueKey('category_$index'),
                child: CategoryElement(
                  catImage: _getImageFromIcon(categoryIcon),
                  catTitle: categoryName,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoriesPage(
                          selectedCategory: categoryName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Keep the exact original layout as fallback
  Widget _buildOriginalCategories(BuildContext context) {
    final List<Map<String, dynamic>> originalCategories = [
      {'name': 'بيتزا', 'icon': 'local_pizza'},
      {'name': 'ساندويتش', 'icon': 'fastfood'},
      {'name': 'حلويات', 'icon': 'cake'},
      {'name': 'مشروبات', 'icon': 'local_drink'},
      {'name': 'سلطات', 'icon': 'eco'},
      {'name': 'شوربة', 'icon': 'soup_kitchen'},
      {'name': 'معجنات', 'icon': 'bakery_dining'},
      {'name': 'أخرى', 'icon': 'restaurant_menu'},
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: originalCategories.length + 2,
      cacheExtent: 2000,
      itemBuilder: (context, index) {
        if (index == originalCategories.length + 1) {
          return SizedBox(width: DeviceUtils.width(context) * 0.05);
        }
        if (index == 0) {
          return SizedBox(width: DeviceUtils.width(context) * 0.05);
        }

        final category = originalCategories[index - 1];

        return RepaintBoundary(
          key: ValueKey('category_$index'),
          child: CategoryElement(
            catImage: _getImageFromIcon(category['icon']),
            catTitle: category['name'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoriesPage(
                    selectedCategory: category['name'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getImageFromIcon(String iconName) {
    // Map Firebase icons to local images
    switch (iconName.toLowerCase()) {
      case 'local_pizza':
        return "images/dropped-image.png";
      case 'fastfood':
        return "images/sandwich.jpg";
      case 'cake':
        return "images/cake.jpg";
      case 'local_drink':
        return "images/drink.jpg";
      case 'eco':
        return "images/salade.jpg";
      case 'soup_kitchen':
        return "images/soupe.jpg";
      case 'bakery_dining':
        return "images/bakery.jpg";
      case 'restaurant_menu':
        return "images/autres.jpg";
      default:
        return "images/dropped-image.png";
    }
  }
}

class CategoryElement extends StatelessWidget {
  const CategoryElement({
    super.key,
    required this.catImage,
    required this.catTitle,
    this.onTap,
  });

  final String catImage;
  final String catTitle;
  final VoidCallback? onTap;

  // Static decoration to prevent rebuilds
  static const _decoration = BoxDecoration(
    boxShadow: [
      BoxShadow(
        blurRadius: 10,
        color: Color.fromARGB(50, 0, 0, 0),
        spreadRadius: 0.5,
      ),
    ],
    color: Colors.white,
    border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 0.5)),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.fromLTRB(0, 8, 16, 8),
        decoration: _decoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RepaintBoundary(
              child: Image.asset(
                catImage,
                width: 50,
                height: 50,
                // Aggressive image caching
                cacheWidth: 100,
                cacheHeight: 100,
                filterQuality: FilterQuality.low, // Faster rendering
              ),
            ),
            Text(
              catTitle,
              style: const TextStyle(
                fontFamily: "NotoSansArabic_Condensed",
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}