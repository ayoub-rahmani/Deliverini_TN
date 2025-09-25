import 'package:cloud_firestore/cloud_firestore.dart';
// If you use options: import 'package:firebase_core/firebase_core.dart';

Future<void> populateRecommendations() async {
  final firestore = FirebaseFirestore.instance;
  final CollectionReference recommendations = firestore.collection('recommendations');

  // Example list of recommendations
  final List<Map<String, dynamic>> items = [
    {
      "id": "pizza-1",
      "name": "بيتزا مارغريتا",
      "price": 12.0,
      "rating": 5,
      "resto": "LaMamma",
      "imgUrl": "images/trendimage.png",
      "ingredients": "جبن - طماطم - زعتر",
      "isfreeDel": true,
    },
    {
      "id": "sandwich-1",
      "name": "ساندويتش شاورما",
      "price": 9.9,
      "rating": 5,
      "resto": "LaMamma",
      "imgUrl": "images/meal.png",
      "ingredients": "شاورما - بصل - خس - طماطم - مايونيز",
      "isfreeDel": false,
    },
    {
      "id": "pizza-2",
      "name": "بيتزا بالخضار",
      "price": 13.5,
      "rating": 4,
      "resto": "PizzaHouse",
      "imgUrl": "images/trendimage.png",
      "ingredients": "خضار مشكل - جبن - زيتون",
      "isfreeDel": false,
    },
    // Add as many as you want!
  ];

  for (final item in items) {
    await recommendations.doc(item["id"]).set(item);
    print("Added recommendation: ${item['id']}");
  }

  print("All recommendations added!");
}
