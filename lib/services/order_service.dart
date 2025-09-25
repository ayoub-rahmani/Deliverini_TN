import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static int _orderCounter = 0;
  static bool _counterInitialized = false;

  // Generate a short, readable order ID (e.g., "1001", "1002", etc.)
  static Future<String> _generateShortOrderId() async {
    if (!_counterInitialized) {
      await _initializeCounter();
    }

    _orderCounter++;

    // Save the counter to Firestore for persistence
    await _firestore.collection('system').doc('orderCounter').set({
      'counter': _orderCounter,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Reset counter after 9999 to keep it manageable
    if (_orderCounter > 9999) {
      _orderCounter = 1000;
    }

    return _orderCounter.toString();
  }

  static Future<void> _initializeCounter() async {
    try {
      final doc = await _firestore.collection('system').doc('orderCounter').get();
      if (doc.exists) {
        _orderCounter = doc.data()?['counter'] ?? 1000;
      } else {
        _orderCounter = 1000; // Start from 1000
      }
      _counterInitialized = true;
    } catch (e) {
      _orderCounter = 1000 + Random().nextInt(100); // Fallback with some randomness
      _counterInitialized = true;
    }
  }

  static Future<String?> createOrder({
    required List<Map<String, dynamic>> cartItems,
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
    String? notes,
  }) async {
    try {
      double totalPrice = 0;
      List<Map<String, dynamic>> processedItems = [];

      for (var item in cartItems) {
        double price = item['price'] ?? 0.0;
        int quantity = item['quantity'] ?? 1;
        double itemTotal = price * quantity;

        // Add customization costs if any
        if (item.containsKey('customizations')) {
          for (var c in item['customizations']) {
            if (c['type'] == 'add') {
              itemTotal += (c['price'] ?? 0) * quantity;
            }
          }
        }
        totalPrice += itemTotal;

        // Convert customization format for order details popup
        Map<String, dynamic> processedItem = Map<String, dynamic>.from(item);

        if (item['isCustomized'] == true && item['customizations'] != null) {
          List<dynamic> customizations = item['customizations'];
          Map<String, dynamic> convertedCustomizations = {};

          for (var customization in customizations) {
            if (customization is Map<String, dynamic> && customization['ingredients'] != null) {
              Map<String, dynamic> ingredients = customization['ingredients'];
              ingredients.forEach((ingredient, amount) {
                if (amount == 0) {
                  convertedCustomizations[ingredient] = '-';
                } else if (amount == 2) {
                  convertedCustomizations[ingredient] = '++';
                }
              });
            }
          }

          processedItem['customizations'] = convertedCustomizations;
        }

        processedItems.add(processedItem);
      }

      // Generate short order ID
      final shortOrderId = await _generateShortOrderId();

      final orderData = {
        'customerName': customerName,
        'customerPhone': customerPhone,
        'deliveryAddress': deliveryAddress,
        'notes': notes ?? '',
        'items': processedItems,
        'totalPrice': totalPrice,
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
        'orderTime': FieldValue.serverTimestamp(),
        'estimatedDeliveryTime': DateTime.now().add(const Duration(minutes: 30)),
        'estimatedDelivery': '25-35 دقيقة',
        'hasCustomizedItems': cartItems.any((item) => item['isCustomized'] == true),
        'orderName': cartItems.isNotEmpty ? cartItems[0]['name'] : 'طلب غير محدد',
        'restaurant': 'LaMAMMA',
        'deliveryPerson': 'في انتظار التعيين',
        'assignedDeliveryId': null,
        'assignedDeliveryName': null,
        'image': cartItems.isNotEmpty ? cartItems[0]['image'] : 'images/pizza_order.png',
        'orderId': shortOrderId, // Use the short ID
        'deliveryFee': 2.5,
        'isCompleted': false, // New field to track completion
        'completedAt': null,
      };

      final orderRef = await _firestore.collection('orders').add(orderData);

      return shortOrderId; // Return the short ID instead of document ID
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Mark order as completed
  static Future<void> markOrderCompleted(String orderId) async {
    try {
      final orderQuery = await _firestore
          .collection('orders')
          .where('orderId', isEqualTo: orderId)
          .get();

      if (orderQuery.docs.isNotEmpty) {
        await orderQuery.docs.first.reference.update({
          'status': 'delivered',
          'isCompleted': true,
          'completedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error marking order as completed: $e');
    }
  }

  // Delete completed orders
  static Future<void> deleteCompletedOrders() async {
    try {
      final completedOrders = await _firestore
          .collection('orders')
          .where('isCompleted', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in completedOrders.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting completed orders: $e');
    }
  }

  // Delete specific order
  static Future<void> deleteOrder(String orderId) async {
    try {
      final orderQuery = await _firestore
          .collection('orders')
          .where('orderId', isEqualTo: orderId)
          .get();

      if (orderQuery.docs.isNotEmpty) {
        await orderQuery.docs.first.reference.delete();
      }
    } catch (e) {
      print('Error deleting order: $e');
    }
  }

  static Stream<QuerySnapshot> getOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  // Get only active (non-completed) orders
  static Stream<QuerySnapshot> getActiveOrdersStream() {
    return _firestore
        .collection('orders')
        .where('isCompleted', isEqualTo: false)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  static String getCustomizationSummary(Map<String, dynamic> item) {
    if (item['isCustomized'] != true) return '';

    final customizations = item['customizations'] as List<dynamic>? ?? [];
    final summaryParts = <String>[];

    for (int i = 0; i < customizations.length; i++) {
      final customization = customizations[i] as Map<String, dynamic>;
      final ingredients = customization['ingredients'] as Map<String, dynamic>? ?? {};

      final activeIngredients = <String>[];
      ingredients.forEach((ingredient, amount) {
        if (amount > 0) {
          activeIngredients.add(amount > 1 ? '$ingredient (${amount}x)' : ingredient);
        }
      });

      summaryParts.add(activeIngredients.isNotEmpty
          ? 'ساندويش ${i + 1}: ${activeIngredients.join(', ')}'
          : 'ساندويش ${i + 1}: بدون إضافات');
    }

    return summaryParts.join('\n');
  }
}