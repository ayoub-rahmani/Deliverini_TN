import 'package:app3/common/widgets/menu_card.dart';
import 'package:app3/device/deviceutils.dart';
import 'package:app3/pages/meal_details_popup.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 290,
      margin: EdgeInsets.only(top: 5, bottom: 15),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trending_items')
            .orderBy('rating', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          // If Firebase fails or no data, show original static content
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildOriginalTrending(context);
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return _buildOriginalTrending(context);
          }

          return ListView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: [
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                // Create a safe data map with properly formatted ingredients
                final safeData = Map<String, dynamic>.from(data);
                safeData['ingredients'] = _resolveIngredients(data);

                return GestureDetector(
                  onTap: () => MealDetailsPopup.show(context, safeData),
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    child: MenuCard(
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
                  ),
                );
              }).toList(),
              SizedBox(width: DeviceUtils.width(context) * 0.05),
            ],
          );
        },
      ),
    );
  }

  // Keep the exact original layout as fallback
  Widget _buildOriginalTrending(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      children: [
        Container(
          margin: EdgeInsets.only(right: 4),
          child: MenuCard(
            title: "ساندويتش شاورما",
            price: 9.9,
            rating: 5,
            resto: "LaMamma",
            imgUrl: "images/sandwich.jpg", // Updated to use consistent mapping
            isfreeDel: true,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 4),
          child: MenuCard(
            title: "ساندويتش شاورما",
            price: 13,
            rating: 4.5,
            resto: "LaMamma",
            imgUrl: "images/sandwich.jpg", // Updated to use consistent mapping
            isfreeDel: false,
            liked: true,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 4),
          child: MenuCard(
            title: "ساندويتش شاورما",
            price: 6.5,
            rating: 3.5,
            resto: "LaMamma",
            imgUrl: "images/sandwich.jpg", // Updated to use consistent mapping
            isfreeDel: false,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 4),
          child: MenuCard(
            title: "ساندويتش شاورما",
            price: 5.5,
            rating: 3.5,
            resto: "Mio Mondo",
            imgUrl: "images/sandwich.jpg", // Updated to use consistent mapping
            isfreeDel: true,
          ),
        ),
        SizedBox(width: DeviceUtils.width(context) * 0.05),
      ],
    );
  }
}