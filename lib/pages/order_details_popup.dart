import 'package:app3/device/deviceutils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsPopup {
  static void show(BuildContext context, Map<String, dynamic> orderData) {
    final isTablet = DeviceUtils.isTablet(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: DeviceUtils.height(context) * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'تفاصيل الطلب',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 22,
                  fontFamily: 'NotoSansArabic',
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Order basic info
                    _buildInfoSection(
                      'معلومات الطلب',
                      [
                        _buildInfoRow('رقم الطلب:', orderData['orderId']?.toString() ?? '#000000', isTablet),
                        _buildInfoRow('المطعم:', orderData['restaurant']?.toString() ?? 'غير محدد', isTablet),
                        _buildInfoRow('عامل التوصيل:', orderData['deliveryPerson']?.toString() ?? 'غير محدد', isTablet),
                        _buildInfoRow('الحالة:', _getStatusText(orderData['status']?.toString() ?? 'pending'), isTablet),
                        _buildInfoRow('وقت الطلب:', _formatTimestamp(orderData['orderTime']), isTablet),
                        _buildInfoRow('الوقت المتوقع:', orderData['estimatedDelivery']?.toString() ?? '25-35 دقيقة', isTablet),
                      ],
                      isTablet,
                    ),

                    const SizedBox(height: 20),

                    // Order items section
                    _buildOrderItemsSection(orderData, isTablet),

                    const SizedBox(height: 20),

                    // Customer info
                    _buildInfoSection(
                      'معلومات العميل',
                      [
                        _buildInfoRow('الاسم:', orderData['customerName']?.toString() ?? 'غير محدد', isTablet),
                        _buildInfoRow('الهاتف:', orderData['customerPhone']?.toString() ?? 'غير محدد', isTablet),
                        _buildInfoRow('العنوان:', orderData['deliveryAddress']?.toString() ?? 'غير محدد', isTablet),
                      ],
                      isTablet,
                    ),

                    const SizedBox(height: 20),

                    // Price summary
                    _buildPriceSummary(orderData, isTablet),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'غير محدد';

    try {
      DateTime dateTime;

      // Handle Firestore Timestamp
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      }
      // Handle milliseconds timestamp
      else if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      // Handle string timestamp
      else if (timestamp is String) {
        // If it's already formatted, return it
        if (timestamp.contains('/') || timestamp.contains('-')) {
          return timestamp;
        }
        // Try to parse as milliseconds
        final parsed = int.tryParse(timestamp);
        if (parsed != null) {
          dateTime = DateTime.fromMillisecondsSinceEpoch(parsed);
        } else {
          return timestamp;
        }
      }
      // Handle DateTime object
      else if (timestamp is DateTime) {
        dateTime = timestamp;
      }
      else {
        return 'غير محدد';
      }

      // Format as Arabic date
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'غير محدد';
    }
  }

  static Widget _buildInfoSection(String title, List<Widget> children, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.w700,
              color: Colors.orange[800],
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontFamily: 'NotoSansArabic',
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  static Widget _buildOrderItemsSection(Map<String, dynamic> orderData, bool isTablet) {
    // Get order items from the orderData
    final items = orderData['items'] as List<dynamic>? ?? [];

    // If no items array, create one from the basic order info
    if (items.isEmpty) {
      items.add({
        'name': orderData['orderName'] ?? 'طلب غير محدد',
        'quantity': 1,
        'price': _parsePrice(orderData['totalPrice']),
        'image': 'images/pizza_order.png',
      });
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'عناصر الطلب',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.w700,
              color: Colors.orange[800],
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 15),

          // List of order items
          ...items.map((item) => _buildOrderItem(item, isTablet)).toList(),
        ],
      ),
    );
  }

  static Widget _buildOrderItem(dynamic item, bool isTablet) {
    Map<String, dynamic> itemMap = {};

    try {
      if (item is Map<String, dynamic>) {
        itemMap = item;
      } else if (item is Map) {
        itemMap = Map<String, dynamic>.from(item);
      } else if (item is List<dynamic> && item.isNotEmpty) {
        final firstItem = item[0];
        if (firstItem is Map<String, dynamic>) {
          itemMap = firstItem;
        } else if (firstItem is Map) {
          itemMap = Map<String, dynamic>.from(firstItem);
        }
      }
    } catch (e) {
      itemMap = {};
    }

    final name = itemMap['name']?.toString() ?? 'عنصر غير محدد';
    final quantity = itemMap['quantity']?.toString() ?? '1';
    final price = _parsePrice(itemMap['price']).toStringAsFixed(1);

    dynamic customizationsData = itemMap['customizations'];
    List<Map<String, dynamic>> sandwichCustomizations = [];

    if (customizationsData is List) {
      for (var customization in customizationsData) {
        if (customization is Map<String, dynamic>) {
          sandwichCustomizations.add(customization);
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        fontFamily: 'NotoSansArabic',
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$price DT',
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 11,
                            fontFamily: 'NotoSansArabic',
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                        Text(
                          'الكمية: $quantity',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            fontFamily: 'NotoSansArabic',
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  image: const DecorationImage(
                    image: AssetImage('images/pizza_order.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          if (sandwichCustomizations.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...sandwichCustomizations.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> customization = entry.value;
              Map<String, dynamic> ingredients = customization['ingredients'] ?? {};

              List<Widget> customizationWidgets = [];
              ingredients.forEach((ingredient, amount) {
                if (amount == 0) {
                  customizationWidgets.add(
                    Text(
                      '$ingredient: بدون',
                      style: TextStyle(
                        fontSize: isTablet ? 11 : 9,
                        fontFamily: 'NotoSansArabic',
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                } else if (amount == 2) {
                  customizationWidgets.add(
                    Text(
                      '$ingredient: إضافي',
                      style: TextStyle(
                        fontSize: isTablet ? 11 : 9,
                        fontFamily: 'NotoSansArabic',
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                }
              });

              if (customizationWidgets.isEmpty) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ساندويش ${index + 1}:',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        fontFamily: 'NotoSansArabic',
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 3),
                    ...customizationWidgets.map((widget) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: widget,
                    )),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  static Widget _buildPriceSummary(Map<String, dynamic> orderData, bool isTablet) {
    final totalPrice = _parsePrice(orderData['totalPrice']);
    final deliveryFee = _parsePrice(orderData['deliveryFee'] ?? 2.0);
    final subtotal = totalPrice > deliveryFee ? totalPrice - deliveryFee : totalPrice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'ملخص الأسعار',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.w700,
              color: Colors.green[800],
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          _buildPriceRow('المجموع الفرعي:', '${subtotal.toStringAsFixed(1)} DT', isTablet),
          _buildPriceRow('رسوم التوصيل:', '${deliveryFee.toStringAsFixed(1)} DT', isTablet),
          const Divider(),
          _buildPriceRow('المجموع الكلي:', '${totalPrice.toStringAsFixed(1)} DT', isTablet, isTotal: true),
        ],
      ),
    );
  }

  static Widget _buildPriceRow(String label, String value, bool isTablet, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? (isTotal ? 16 : 14) : (isTotal ? 14 : 12),
              fontFamily: 'NotoSansArabic',
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? Colors.green[800] : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? (isTotal ? 16 : 14) : (isTotal ? 14 : 12),
              fontFamily: 'NotoSansArabic',
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? Colors.green[800] : Colors.grey[700],
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      try {
        return double.parse(price.replaceAll(RegExp(r'[^\d.]'), ''));
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  static String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'في انتظار التأكيد';
      case 'confirmed': return 'تم تأكيد الطلب';
      case 'preparing': return 'جاري التحضير';
      case 'on_way': return 'في الطريق إليك';
      case 'delivered': return 'تم التسليم';
      case 'cancelled': return 'تم الإلغاء';
      default: return 'غير محدد';
    }
  }
}
