// Add this to your main.dart or create a separate file to initialize Firebase data
// Run this once to populate your Firebase collections

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DataInitializer {
  static Future<void> initializeFirebaseData() async {
    try {
      // Ensure Firebase is initialized
      await Firebase.initializeApp();

      print('Starting Firebase data initialization...');

      // Initialize categories
      await _initializeCategories();

      // Initialize menu items
      await _initializeMenuItems();

      // Initialize trending items
      await _initializeTrendingItems();

      print('Firebase data initialization completed successfully!');

    } catch (e) {
      print('Error initializing Firebase data: $e');
    }
  }

  static Future<void> _initializeCategories() async {
    final categoriesRef = FirebaseFirestore.instance.collection('categories');

    // Check if categories already exist
    final snapshot = await categoriesRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      print('Categories already exist, skipping...');
      return;
    }

    final categories = [
      {'name': 'بيتزا', 'icon': 'local_pizza', 'color': 'orange', 'order': 1, 'isActive': true},
      {'name': 'ساندويتش', 'icon': 'fastfood', 'color': 'red', 'order': 2, 'isActive': true},
      {'name': 'حلويات', 'icon': 'cake', 'color': 'pink', 'order': 3, 'isActive': true},
      {'name': 'مشروبات', 'icon': 'local_drink', 'color': 'blue', 'order': 4, 'isActive': true},
      {'name': 'سلطات', 'icon': 'eco', 'color': 'green', 'order': 5, 'isActive': true},
      {'name': 'شوربة', 'icon': 'soup_kitchen', 'color': 'brown', 'order': 6, 'isActive': true},
      {'name': 'معجنات', 'icon': 'bakery_dining', 'color': 'deepOrange', 'order': 7, 'isActive': true},
      {'name': 'أخرى', 'icon': 'restaurant_menu', 'color': 'grey', 'order': 8, 'isActive': true},
    ];

    for (var category in categories) {
      await categoriesRef.add(category);
    }

    print('Categories initialized: ${categories.length} items');
  }

  static Future<void> _initializeMenuItems() async {
    final menuItemsRef = FirebaseFirestore.instance.collection('menu_items');

    // Check if menu items already exist
    final snapshot = await menuItemsRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      print('Menu items already exist, skipping...');
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
        'calories': 320,
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
        'calories': 450,
      },
      {
        'name': 'ساندويتش شاورما لحم',
        'price': 11.5,
        'rating': 4.8,
        'resto': 'LaMamma',
        'category': 'ساندويتش',
        'description': 'شاورما لحم طازجة مع الإضافات',
        'imgUrl': 'images/meal.png',
        'isfreeDel': false,
        'liked': false,
        'ingredients': ['لحم', 'خضروات', 'صوص', 'خبز'],
        'preparationTime': 18,
        'isAvailable': true,
        'calories': 520,
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
        'calories': 380,
      },
      {
        'name': 'بقلاوة بالفستق',
        'price': 8.5,
        'rating': 4.6,
        'resto': 'حلويات الشام',
        'category': 'حلويات',
        'description': 'بقلاوة محشوة بالفستق الحلبي',
        'imgUrl': 'images/meal.png',
        'isfreeDel': false,
        'liked': true,
        'ingredients': ['عجين رقيق', 'فستق', 'قطر', 'سمن'],
        'preparationTime': 15,
        'isAvailable': true,
        'calories': 320,
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
        'calories': 110,
      },
      {
        'name': 'عصير المانجو',
        'price': 6.0,
        'rating': 4.4,
        'resto': 'عصائر الصحة',
        'category': 'مشروبات',
        'description': 'عصير مانجو استوائي منعش',
        'imgUrl': 'images/meal.png',
        'isfreeDel': false,
        'liked': true,
        'ingredients': ['مانجو طازج', 'ثلج'],
        'preparationTime': 5,
        'isAvailable': true,
        'calories': 140,
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
        'calories': 180,
      },
      {
        'name': 'سلطة الفتوش',
        'price': 7.5,
        'rating': 4.5,
        'resto': 'سلطات البحر المتوسط',
        'category': 'سلطات',
        'description': 'سلطة فتوش لبنانية مع الخبز المحمص',
        'imgUrl': 'images/meal.png',
        'isfreeDel': true,
        'liked': false,
        'ingredients': ['خس', 'طماطم', 'خيار', 'فجل', 'خبز محمص', 'سماق'],
        'preparationTime': 12,
        'isAvailable': true,
        'calories': 150,
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
        'calories': 200,
      },
      {
        'name': 'شوربة الدجاج',
        'price': 7.5,
        'rating': 4.3,
        'resto': 'مطعم البيت',
        'category': 'شوربة',
        'description': 'شوربة دجاج منزلية مع الخضروات',
        'imgUrl': 'images/meal.png',
        'isfreeDel': false,
        'liked': true,
        'ingredients': ['دجاج', 'جزر', 'كرفس', 'بصل', 'بقدونس'],
        'preparationTime': 20,
        'isAvailable': true,
        'calories': 180,
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
        'calories': 250,
      },
      {
        'name': 'مناقيش جبنة',
        'price': 4.5,
        'rating': 4.4,
        'resto': 'فرن البلد',
        'category': 'معجنات',
        'description': 'مناقيش جبنة طازجة ولذيذة',
        'imgUrl': 'images/meal.png',
        'isfreeDel': true,
        'liked': true,
        'ingredients': ['عجين', 'جبن', 'زيت زيتون'],
        'preparationTime': 12,
        'isAvailable': true,
        'calories': 280,
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
        'calories': 650,
      },
    ];

    for (var item in menuItems) {
      await menuItemsRef.add(item);
    }

    print('Menu items initialized: ${menuItems.length} items');
  }

  static Future<void> _initializeTrendingItems() async {
    final trendingItemsRef = FirebaseFirestore.instance.collection('trending_items');

    // Check if trending items already exist
    final snapshot = await trendingItemsRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      print('Trending items already exist, skipping...');
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
        'ingredients': ['دجاج', 'خضروات مشكلة', 'صوص مميز', 'خبز'],
        'preparationTime': 18,
        'isAvailable': true,
        'calories': 480,
      },
      {
        'name': 'بيتزا البيبروني الحارة',
        'price': 17.0,
        'rating': 4.7,
        'resto': 'بيتزا إكسبرس',
        'category': 'بيتزا',
        'description': 'بيتزا البيبروني الشهية مع الفلفل الحار',
        'imgUrl': 'images/trendimage.png',
        'isfreeDel': false,
        'liked': false,
        'orderCount': 120,
        'createdAt': FieldValue.serverTimestamp(),
        'trendingScore': 88,
        'ingredients': ['بيبروني', 'جبن موتزاريلا', 'فلفل حار', 'صوص طماطم'],
        'preparationTime': 25,
        'isAvailable': true,
        'calories': 350,
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
        'ingredients': ['لحم بقري', 'جبن', 'خس', 'طماطم', 'بطاطس'],
        'preparationTime': 20,
        'isAvailable': true,
        'calories': 680,
      },
      {
        'name': 'تيراميسو إيطالي',
        'price': 8.5,
        'rating': 4.8,
        'resto': 'حلويات روما',
        'category': 'حلويات',
        'description': 'تيراميسو إيطالي أصلي بالقهوة',
        'imgUrl': 'images/meal.png',
        'isfreeDel': false,
        'liked': false,
        'orderCount': 80,
        'createdAt': FieldValue.serverTimestamp(),
        'trendingScore': 79,
        'ingredients': ['بسكويت', 'قهوة', 'جبن ماسكاربوني', 'كاكاو'],
        'preparationTime': 25,
        'isAvailable': true,
        'calories': 420,
      },
      {
        'name': 'عصير المانجو الاستوائي',
        'price': 6.0,
        'rating': 4.4,
        'resto': 'عصائر الاستوائية',
        'category': 'مشروبات',
        'description': 'عصير مانجو استوائي منعش مع النعناع',
        'imgUrl': 'images/meal.png',
        'isfreeDel': false,
        'liked': true,
        'orderCount': 70,
        'createdAt': FieldValue.serverTimestamp(),
        'trendingScore': 75,
        'ingredients': ['مانجو طازج', 'نعناع', 'ثلج'],
        'preparationTime': 5,
        'isAvailable': true,
        'calories': 150,
      },
      {
        'name': 'سلطة السيزر',
        'price': 9.5,
        'rating': 4.5,
        'resto': 'سلطات العالم',
        'category': 'سلطات',
        'description': 'سلطة السيزر الكلاسيكية مع الدجاج المشوي',
        'imgUrl': 'images/meal.png',
        'isfreeDel': false,
        'liked': false,
        'orderCount': 65,
        'createdAt': FieldValue.serverTimestamp(),
        'trendingScore': 72,
        'ingredients': ['خس روماني', 'دجاج مشوي', 'جبن بارميزان', 'صوص السيزر'],
        'preparationTime': 15,
        'isAvailable': true,
        'calories': 320,
      },
      {
        'name': 'شوربة الفطر الكريمية',
        'price': 8.0,
        'rating': 4.3,
        'resto': 'مطعم الشوربات',
        'category': 'شوربة',
        'description': 'شوربة فطر كريمية غنية ولذيذة',
        'imgUrl': 'images/meal.png',
        'isfreeDel': false,
        'liked': true,
        'orderCount': 55,
        'createdAt': FieldValue.serverTimestamp(),
        'trendingScore': 68,
        'ingredients': ['فطر طازج', 'كريمة طبخ', 'بصل', 'زبدة', 'بهارات'],
        'preparationTime': 18,
        'isAvailable': true,
        'calories': 250,
      },
      {
        'name': 'فطيرة السبانخ',
        'price': 4.0,
        'rating': 4.4,
        'resto': 'فرن المعجنات',
        'category': 'معجنات',
        'description': 'فطيرة سبانخ طازجة مع البصل والليمون',
        'imgUrl': 'images/meal.png',
        'isfreeDel': true,
        'liked': false,
        'orderCount': 50,
        'createdAt': FieldValue.serverTimestamp(),
        'trendingScore': 65,
        'ingredients': ['عجين', 'سبانخ', 'بصل', 'ليمون', 'زيت زيتون'],
        'preparationTime': 15,
        'isAvailable': true,
        'calories': 220,
      },
    ];

    for (var item in trendingItems) {
      await trendingItemsRef.add(item);
    }

    print('Trending items initialized: ${trendingItems.length} items');
  }

  // Call this method once from your main app to initialize data
  static Future<void> runInitialization() async {
    print('🔥 Starting Firebase data initialization...');

    try {
      await initializeFirebaseData();
      print('✅ All data initialized successfully!');
    } catch (e) {
      print('❌ Error during initialization: $e');
    }
  }
}