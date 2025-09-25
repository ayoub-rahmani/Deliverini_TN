import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:app3/device/deviceutils.dart';
import '../common/widgets/order_card.dart';
import '../services/order_service.dart';
import 'package:app3/common/scroll_helper.dart'; // import mixin

class DeliveryOrders extends StatefulWidget {
  const DeliveryOrders({super.key});

  @override
  State createState() => _DeliveryOrdersState();
}

class _DeliveryOrdersState extends State<DeliveryOrders> with ScrollHelper {
  late final Stream<QuerySnapshot> _ordersStream;

  @override
  void initState() {
    super.initState();
    _ordersStream = OrderService.getOrdersStream();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = DeviceUtils.width(context);
    final horizontalMargin = 0.0; // removed horizontal margin

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: horizontalMargin,
              right: horizontalMargin,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  height: DeviceUtils.height(context) * 0.88,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _ordersStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.orange),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'حدث خطأ في تحميل الطلبات',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'NotoSansArabic',
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final orders = snapshot.data!.docs;
                      if (orders.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset('images/cart.json'),
                              const SizedBox(height: 20),
                              Text(
                                'لا توجد طلبات حالياً',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'NotoSansArabic',
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final orderDoc = orders[index];
                          final orderData = orderDoc.data() as Map<String, dynamic>;

                          // full screen width
                          return SizedBox(
                            width: screenWidth,
                            child: OrderCard(
                              key: ValueKey(orderDoc.id),
                              image: orderData['image'] ?? 'images/pizza_order.png',
                              orderName: orderData['orderName'] ?? 'طلب غير محدد',
                              restaurant: orderData['restaurant'] ?? 'مطعم غير محدد',
                              deliveryPerson: orderData['deliveryPerson'] ?? 'عامل توصيل غير معروف',
                              orderId: orderData['orderId'] ?? orderDoc.id,
                              orderData: {
                                ...orderData,
                                'orderId': orderData['orderId'] ?? orderDoc.id,
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: DeviceUtils.height(context) * 0.873,
              left: 30,
              child: Lottie.asset(
                'images/deliveries.json',
                width: DeviceUtils.width(context) * 0.23,
              ),
            ),
            Positioned(
              bottom: DeviceUtils.height(context) * 0.88 + 10,
              right: 30,
              child: const Text(
                'كماندات',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NotoSansArabic',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
