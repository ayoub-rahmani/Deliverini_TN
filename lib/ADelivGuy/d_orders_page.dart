import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:app3/device/deviceutils.dart';
import 'package:app3/common/scroll_helper.dart';

class DeliveryOrders extends StatefulWidget {
  const DeliveryOrders({super.key});

  @override
  State<DeliveryOrders> createState() => _DeliveryOrdersState();
}

class _DeliveryOrdersState extends State<DeliveryOrders> with ScrollHelper {
  bool _isOnline = true;

  // Mock data for available orders
  final List<Map<String, dynamic>> _availableOrders = [
    {
      'id': 'ORD001',
      'restaurant': 'LaMAMMA',
      'restaurantDistance': '0.8 km',
      'customerName': 'أحمد محمد',
      'customerAddress': 'شارع الحبيب بورقيبة، تونس',
      'customerDistance': '2.3 km',
      'totalDistance': '3.1 km',
      'estimatedTime': '15 دقيقة',
      'deliveryFee': 3.500,
      'items': ['بيتزا مارغريتا', 'كوكا كولا'],
      'customerNotes': 'الطابق الثالث - شقة رقم 12',
      'orderTotal': 25.750,
      'priority': 'high',
    },
    {
      'id': 'ORD002',
      'restaurant': 'Burger House',
      'restaurantDistance': '1.2 km',
      'customerName': 'فاطمة السالمي',
      'customerAddress': 'نهج قرطاج، أريانة',
      'customerDistance': '4.1 km',
      'totalDistance': '5.3 km',
      'estimatedTime': '25 دقيقة',
      'deliveryFee': 4.000,
      'items': ['برغر كلاسيك', 'بطاطس مقلية', 'عصير برتقال'],
      'customerNotes': '',
      'orderTotal': 18.500,
      'priority': 'medium',
    },
    {
      'id': 'ORD003',
      'restaurant': 'Sushi Master',
      'restaurantDistance': '2.1 km',
      'customerName': 'كريم بن عيسى',
      'customerAddress': 'شارع الاستقلال، صفاقس',
      'customerDistance': '1.8 km',
      'totalDistance': '3.9 km',
      'estimatedTime': '20 دقيقة',
      'deliveryFee': 5.500,
      'items': ['سوشي ميكس', 'حساء ميسو'],
      'customerNotes': 'يرجى الاتصال عند الوصول',
      'orderTotal': 45.200,
      'priority': 'high',
    },
  ];

  void _toggleOnlineStatus() {
    HapticFeedback.selectionClick();
    setState(() {
      _isOnline = !_isOnline;
    });
  }

  void _acceptOrder(Map<String, dynamic> order) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'قبول الطلب',
          style: TextStyle(fontFamily: 'NotoSansArabic', fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'هل تريد قبول طلب ${order['id']}؟',
              style: const TextStyle(fontFamily: 'NotoSansArabic'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'أرباحك من هذا الطلب',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${order['deliveryFee'].toStringAsFixed(3)} د.ت',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'NotoSansArabic', color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to active delivery page
              // Get.find<DeliveryNavigationController>().changeIndex(1);
              _showOrderAcceptedSnackBar(order);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'قبول',
              style: TextStyle(fontFamily: 'NotoSansArabic', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderAcceptedSnackBar(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم قبول الطلب ${order['id']} بنجاح!',
          style: const TextStyle(fontFamily: 'NotoSansArabic'),
        ),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'عرض التفاصيل',
          onPressed: () {
            // Navigate to active delivery
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Online Status Toggle
          Positioned(
            top: 60,
            right: 20,
            child: GestureDetector(
              onTap: _toggleOnlineStatus,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isOnline ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_isOnline ? Colors.green : Colors.red).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOnline ? 'متصل' : 'غير متصل',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'NotoSansArabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Page Title
          Positioned(
            bottom: DeviceUtils.height(context) * 0.88 + 10,
            right: 30,
            child: const Text(
              'الطلبات المتاحة',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'NotoSansArabic',
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Main Content Area
          Positioned(
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Container(
                width: DeviceUtils.width(context),
                height: DeviceUtils.height(context) * 0.88,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _isOnline ? _buildOrdersList() : _buildOfflineState(),
              ),
            ),
          ),

          // Animated Delivery Icon
          Positioned(
            bottom: DeviceUtils.height(context) * 0.88,
            left: DeviceUtils.width(context) * 0.09,
            child: RepaintBoundary(
              child: Lottie.asset(
                'images/delivery_bike.json', // Animated delivery bike/scooter
                width: DeviceUtils.width(context) * 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard('الطلبات المتاحة', '${_availableOrders.length}', Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('المسافة المتوسطة', '3.4 km', Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('الأرباح المتوقعة', '13.0 د.ت', Colors.green),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Orders List
          const Text(
            'اختر طلب للتوصيل:',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ..._availableOrders.map((order) => _buildOrderCard(order)).toList(),

          const SizedBox(height: 100), // Bottom padding for navbar
        ],
      ),
    );
  }

  Widget _buildOfflineState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'images/delivery_offline.json', // Animated offline state
            width: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'أنت غير متصل حالياً',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'قم بتفعيل حالة الاتصال لرؤية الطلبات المتاحة',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'NotoSansArabic',
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _toggleOnlineStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text(
              'الاتصال',
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'NotoSansArabic',
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    Color priorityColor = order['priority'] == 'high' ? Colors.red :
    order['priority'] == 'medium' ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with order ID and priority
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['id'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['priority'] == 'high' ? 'عاجل' :
                    order['priority'] == 'medium' ? 'متوسط' : 'عادي',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'NotoSansArabic',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Order Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Restaurant Info
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.restaurant, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['restaurant'],
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'المسافة: ${order['restaurantDistance']}',
                            style: TextStyle(
                              fontFamily: 'NotoSansArabic',
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Arrow Divider
                Row(
                  children: [
                    const SizedBox(width: 26),
                    Icon(Icons.arrow_downward, color: Colors.grey[400], size: 20),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Customer Info
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['customerName'],
                            style: const TextStyle(
                              fontFamily: 'NotoSansArabic',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            order['customerAddress'],
                            style: TextStyle(
                              fontFamily: 'NotoSansArabic',
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'المسافة: ${order['customerDistance']}',
                            style: TextStyle(
                              fontFamily: 'NotoSansArabic',
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Order Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'إجمالي المسافة:',
                            style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 12),
                          ),
                          Text(
                            order['totalDistance'],
                            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الوقت المتوقع:',
                            style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 12),
                          ),
                          Text(
                            order['estimatedTime'],
                            style: const TextStyle(fontFamily: 'NotoSansArabic', fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'أرباحك:',
                            style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 12),
                          ),
                          Text(
                            '${order['deliveryFee'].toStringAsFixed(3)} د.ت',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Customer Notes (if any)
                if (order['customerNotes'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ملاحظات العميل:',
                          style: TextStyle(
                            fontFamily: 'NotoSansArabic',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['customerNotes'],
                          style: const TextStyle(
                            fontFamily: 'NotoSansArabic',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Accept Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _acceptOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'قبول الطلب',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}