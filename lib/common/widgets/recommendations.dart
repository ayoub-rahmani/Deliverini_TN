import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app3/common/widgets/recom_card.dart';
import 'package:app3/pages/meal_details_popup.dart';
import 'package:app3/device/deviceutils.dart';

class Recommendations extends StatelessWidget {
  const Recommendations({super.key});

  String _resolveImage(Map<String, dynamic> data) {
    if (data.containsKey('imgUrl') && (data['imgUrl'] as String).isNotEmpty) {
      return data['imgUrl'];
    }
    final name = data['name']?.toString().toLowerCase() ?? '';
    if (name.contains('بيتزا') || name.contains('pizza')) {
      return 'images/trendimage.png';
    } else if (name.contains('ساندويتش') || name.contains('شاورما')) {
      return 'images/meal.png';
    }
    return 'images/meal.png'; // Default image
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = DeviceUtils.width(context) * 0.07;

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recommendations') // Correct collection name used here
            .orderBy('rating', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('خطأ في التحميل'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('لا توجد عناصر مقترحة حالياً'));
          }

          return Container(
            margin: EdgeInsets.only(bottom: 100),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () => MealDetailsPopup.show(context, data),
                  child: RecomCard(
                    title: data['name'] ?? '',
                    price: data['price'] is int ? (data['price'] as int).toDouble() : (data['price'] ?? 0.0),
                    rating: (data['rating'] ?? 0).toDouble(),
                    resto: data['resto'] ?? '',
                    imgUrl: _resolveImage(data),
                    isfreeDel: (data['isfreeDel'] ?? false) == true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
