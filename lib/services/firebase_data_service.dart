import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize categories data
  static Future<void> initializeCategories() async {
    try {
      final categoriesRef = _firestore.collection('categories');

      // Check if categories already exist
      final snapshot = await categoriesRef.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('Categories already exist');
        return;
      }

      final categories = [
        {
          'name': 'بيتزا',
          'icon': 'local_pizza',
          'color': 'orange',
          'order': 1,
          'isActive': true,
        },
        {
          'name': 'ساندويتش',
          'icon': 'fastfood',
          'color': 'red',
          'order': 2,
          'isActive': true,
        },
        {
          'name': 'حلويات',
          'icon': 'cake',
          'color': 'pink',
          'order': 3,
          'isActive': true,
        },
        {
          'name': 'مشروبات',
          'icon': 'local_drink',
          'color': 'blue',
          'order': 4,
          'isActive': true,
        },
        {
          'name': 'سلطات',
          'icon': 'eco',
          'color': 'green',
          'order': 5,
          'isActive': true,
        },
        {
          'name': 'شوربة',
          'icon': 'soup_kitchen',
          'color': 'brown',
          'order': 6,
          'isActive': true,
        },
        {
          'name': 'معجنات',
          'icon': 'bakery_dining',
          'color': 'deepOrange',
          'order': 7,
          'isActive': true,
        },
        {
          'name': 'أخرى',
          'icon': 'restaurant_menu',
          'color': 'grey',
          'order': 8,
          'isActive': true,
        },
      ];

      for (var category in categories) {
        await categoriesRef.add(category);
      }

      print('Categories initialized successfully');
    } catch (e) {
      print('Error initializing categories: $e');
    }
  }

  // Initialize menu items data
  static Future<void> initializeMenuItems() async {
    try {
      final menuItemsRef = _firestore.collection('menu_items');

      // Check if menu items already exist
      final snapshot = await menuItemsRef.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('Menu items already exist');
        return;
      }

      final menuItems = [
        {
          'name': 'بيتزا مارغريتا',
          'price': 15.5,
          'rating': 4.5,
          'resto': 'LaMamma',
          'category': 'بيتزا',
          'description': 'بيتزا كلاسيكية مع الطماطم والجبن والريحان',
          'imgUrl': 'images/trendimage.png',
          'isfreeDel': true,
          'liked': false,
          'ingredients': ['طماطم', 'جبن موتزاريلا', 'ريحان', 'زيت زيتون'],
          'preparationTime': 25,
          'isAvailable': true,
        },
        {
          'name': 'ساندويتش شاورما دجاج',
          'price': 9.9,
          'rating': 5.0,
          'resto': 'LaMamma',
          'category': 'ساندويتش',
          'description': 'شاورما دجاج طازجة مع الخضروات والصوص الخاص',
          'imgUrl': 'images/meal.png',
          'isfreeDel': true,
          'liked': true,
          'ingredients': ['دجاج', 'خضروات', 'صوص', 'خبز'],
          'preparationTime': 15,
          'isAvailable': true,
        },
        {
          'name': 'كنافة نابلسية',
          'price': 12.0,
          'rating': 4.8,
          'resto': 'حلويات الشام',
          'category': 'حلويات',
          'description': 'كنافة نابلسية أصلية بالجبن والقطر',
          'imgUrl': 'images/meal.png',
          'isfreeDel': false,
          'liked': false,
          'ingredients': ['كنافة', 'جبن', 'قطر', 'فستق'],
          'preparationTime': 20,
          'isAvailable': true,
        },
        {
          'name': 'عصير برتقال طبيعي',
          'price': 4.5,
          'rating': 4.2,
          'resto': 'عصائر الصحة',
          'category': 'مشروبات',
          'description': 'عصير برتقال طازج 100% طبيعي',
          'imgUrl': 'images/meal.png',
          'isfreeDel': false,
          'liked': false,
          'ingredients': ['برتقال طازج'],
          'preparationTime': 5,
          'isAvailable': true,
        },
        {
          'name': 'سلطة يونانية',
          'price': 8.5,
          'rating': 4.3,
          'resto': 'سلطات البحر المتوسط',
          'category': 'سلطات',
          'description': 'سلطة يونانية تقليدية بالجبن الفيتا والزيتون',
          'imgUrl': 'images/meal.png',
          'isfreeDel': false,
          'liked': false,
          'ingredients': ['طماطم', 'خيار', 'جبن فيتا', 'زيتون', 'بصل'],
          'preparationTime': 10,
          'isAvailable': true,
        },
        {
          'name': 'شوربة العدس',
          'price': 6.0,
          'rating': 4.1,
          'resto': 'مطعم البيت',
          'category': 'شوربة',
          'description': 'شوربة عدس أحمر تقليدية مع الخضروات',
          'imgUrl': 'images/meal.png',
          'isfreeDel': false,
          'liked': false,
          'ingredients': ['عدس أحمر', 'جزر', 'بصل', 'بهارات'],
          'preparationTime': 15,
          'isAvailable': true,
        },
        {
          'name': 'مناقيش زعتر',
          'price': 3.5,
          'rating': 4.6,
          'resto': 'فرن البلد',
          'category': 'معجنات',
          'description': 'مناقيش زعتر طازجة من الفرن',
          'imgUrl': 'images/meal.png',
          'isfreeDel': true,
          'liked': false,
          'ingredients': ['عجين', 'زعتر', 'زيت زيتون'],
          'preparationTime': 12,
          'isAvailable': true,
        },
        {
          'name': 'وجبة مشكلة',
          'price': 18.0,
          'rating': 4.4,
          'resto': 'مطعم التنوع',
          'category': 'أخرى',
          'description': 'وجبة متنوعة تشمل أطباق مختلفة',
          'imgUrl': 'images/meal.png',
          'isfreeDel': true,
          'liked': false,
          'ingredients': ['أرز', 'دجاج', 'خضروات', 'سلطة'],
          'preparationTime': 30,
          'isAvailable': true,
        },
      ];

      for (var item in menuItems) {
        await menuItemsRef.add(item);
      }

      print('Menu items initialized successfully');
    } catch (e) {
      print('Error initializing menu items: $e');
    }
  }

  // Initialize trending items data
  static Future<void> initializeTrendingItems() async {
    try {
      final trendingItemsRef = _firestore.collection('trending_items');

      // Check if trending items already exist
      final snapshot = await trendingItemsRef.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('Trending items already exist');
        return;
      }

      final trendingItems = [
        {
          'name': 'ساندويتش شاورما مميز',
          'price': 11.5,
          'rating': 4.9,
          'resto': 'LaMamma',
          'category': 'ساندويتش',
          'description': 'شاورما مميزة مع إضافات خاصة',
          'imgUrl': 'images/trendimage.png',
          'isfreeDel': true,
          'liked': true,
          'orderCount': 150,
          'createdAt': FieldValue.serverTimestamp(),
          'trendingScore': 95,
        },
        {
          'name': 'بيتزا البيبروني',
          'price': 17.0,
          'rating': 4.7,
          'resto': 'بيتزا إكسبرس',
          'category': 'بيتزا',
          'description': 'بيتزا البيبروني الشهية',
          'imgUrl': 'images/trendimage.png',
          'isfreeDel': false,
          'liked': false,
          'orderCount': 120,
          'createdAt': FieldValue.serverTimestamp(),
          'trendingScore': 88,
        },
        {
          'name': 'برجر اللحم الفاخر',
          'price': 14.5,
          'rating': 4.6,
          'resto': 'برجر هاوس',
          'category': 'ساندويتش',
          'description': 'برجر لحم بقري فاخر مع البطاطس',
          'imgUrl': 'images/meal.png',
          'isfreeDel': true,
          'liked': true,
          'orderCount': 95,
          'createdAt': FieldValue.serverTimestamp(),
          'trendingScore': 82,
        },
        {
          'name': 'تيراميسو إيطالي',
          'price': 8.5,
          'rating': 4.8,
          'resto': 'حلويات روما',
          'category': 'حلويات',
          'description': 'تيراميسو إيطالي أصلي',
          'imgUrl': 'images/meal.png',
          'isfreeDel': false,
          'liked': false,
          'orderCount': 80,
          'createdAt': FieldValue.serverTimestamp(),
          'trendingScore': 79,
        },
        {
          'name': 'عصير المانجو الاستوائي',
          'price': 6.0,
          'rating': 4.4,
          'resto': 'عصائر الاستوائية',
          'category': 'مشروبات',
          'description': 'عصير مانجو استوائي منعش',
          'imgUrl': 'images/meal.png',
          'isfreeDel': false,
          'liked': true,
          'orderCount': 70,
          'createdAt': FieldValue.serverTimestamp(),
          'trendingScore': 75,
        },
      ];

      for (var item in trendingItems) {
        await trendingItemsRef.add(item);
      }

      print('Trending items initialized successfully');
    } catch (e) {
      print('Error initializing trending items: $e');
    }
  }

  // Initialize all data
  static Future<void> initializeAllData() async {
    await initializeCategories();
    await initializeMenuItems();
    await initializeTrendingItems();
    print('All data initialized successfully');
  }

  // Helper method to add a new menu item
  static Future<String?> addMenuItem(Map<String, dynamic> itemData) async {
    try {
      DocumentReference docRef = await _firestore.collection('menu_items').add(itemData);
      return docRef.id;
    } catch (e) {
      print('Error adding menu item: $e');
      return null;
    }
  }

  // Helper method to add a new trending item
  static Future<String?> addTrendingItem(Map<String, dynamic> itemData) async {
    try {
      DocumentReference docRef = await _firestore.collection('trending_items').add(itemData);
      return docRef.id;
    } catch (e) {
      print('Error adding trending item: $e');
      return null;
    }
  }

  // Helper method to add a new category
  static Future<String?> addCategory(Map<String, dynamic> categoryData) async {
    try {
      DocumentReference docRef = await _firestore.collection('categories').add(categoryData);
      return docRef.id;
    } catch (e) {
      print('Error adding category: $e');
      return null;
    }
  }
}