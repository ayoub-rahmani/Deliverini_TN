import 'package:app3/device/deviceutils.dart';
import 'package:app3/pages/conversation.dart';
import 'package:app3/models/chat_user.dart';
import 'package:app3/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../pages/order_details_popup.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.image,
    required this.orderName,
    required this.restaurant,
    required this.deliveryPerson,
    required this.orderId,
    required this.orderData,
  });

  final String image;
  final String orderName;
  final String restaurant;
  final String deliveryPerson;
  final String orderId;
  final Map<String, dynamic> orderData;

  @override
  Widget build(BuildContext context) {
    final isTablet = DeviceUtils.isTablet(context);
    final cardHeight = isTablet ? 180.0 : 150.0;
    final imageSize = isTablet ? 110.0 : 100.0;

    return RepaintBoundary(
      child: Container(
        height: cardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black.withOpacity(0.48),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3A000000),
              blurRadius: 18.90,
              offset: Offset(0, 0),
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Main content area
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Food image
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(image),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.48),
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),

                // Order details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDetailRow(
                          'الكماندة :',
                          orderName,
                          isTablet: isTablet,
                        ),
                        _buildDetailRow(
                          'المطعم :',
                          restaurant,
                          isTablet: isTablet,
                        ),
                        _buildDetailRow(
                          'عامل التوصيل :',
                          deliveryPerson,
                          isTablet: isTablet,
                        ),
                        _buildDetailRow(
                          'المعرف :',
                          orderId.length > 8 ? orderId.substring(0, 8) : '#00${orderId}',
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Action buttons
            Container(
              margin: EdgeInsets.only(top: 7),
              height: isTablet ? 40 : 35,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: _buildActionButton(
                      context,
                      'محادثة',
                      'images/chat_icon.png',
                      onTap: () => _navigateToChat(context),
                      isTablet: isTablet,
                    ),
                  ),
                  Flexible(
                    child: _buildActionButton(
                      context,
                      'تفاصيل',
                      'images/details_icon.png',
                      onTap: () => OrderDetailsPopup.show(context, orderData),
                      isTablet: isTablet,
                    ),
                  ),
                  Flexible(
                    child: _buildActionButton(
                      context,
                      'تبعني',
                      'images/track_icon.png',
                      onTap: () => _showTrackingInfo(context),
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {required bool isTablet}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.black,
              fontSize: isTablet ? 15 : 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,

            ),

            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 10)
        ,
        Text(
          label,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.black,
            fontSize: isTablet ? 16 : 14,
            fontFamily: 'NotoSansArabic',
            fontWeight: FontWeight.w600,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String text,
      String iconPath, {
        required VoidCallback onTap,
        required bool isTablet,
      }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(

        height: isTablet ? 32 : 28,
        width: isTablet ? DeviceUtils.width(context) * 0.25: DeviceUtils.width(context) * 0.25,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1, color: Colors.black),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: isTablet ? 18 : 16,
              height: isTablet ? 18 : 16,
              errorBuilder: (context, error, stackTrace) {
                IconData fallbackIcon;
                switch (iconPath) {
                  case 'images/chat_icon.png':
                    fallbackIcon = Icons.chat_bubble_outline;
                    break;
                  case 'images/details_icon.png':
                    fallbackIcon = Icons.info_outline;
                    break;
                  case 'images/track_icon.png':
                    fallbackIcon = Icons.location_on_outlined;
                    break;
                  default:
                    fallbackIcon = Icons.help_outline;
                }
                return Icon(
                  fallbackIcon,
                  size: isTablet ? 18 : 16,
                  color: Colors.black,
                );
              },
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: isTablet ? 14 : 12,
                fontFamily: 'NotoSansArabic',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context) async {
    try {
      final deliveryPersonUser = ChatUser(
        id: 'delivery_$orderId',
        name: deliveryPerson,
        profileImage: 'images/pp.png',
        isOnline: true,
        lastSeen: DateTime.now(),
      );

      final chatService = ChatService();
      final chatId = chatService.generateChatId(
        ChatService.currentUserId,
        deliveryPersonUser.id,
      );

      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => Conversation(
            chatId: chatId,
            otherUser: deliveryPersonUser,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );
    } catch (e) {
      print('Error navigating to delivery chat: $e');
    }
  }

  Future<void> _deleteOrder() async {
    try {
      // Find the document by orderId field
      var orderQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('orderId', isEqualTo: orderId)
          .get();

      if (orderQuery.docs.isNotEmpty) {
        await orderQuery.docs.first.reference.delete();
        return;
      }

      // If not found by orderId field, try document ID as fallback (for older orders)
      try {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .delete();
        return;
      } catch (e) {
        print('Order not found by document ID: $e');
      }

      // Last resort: search through all orders to find matching data
      final allOrdersQuery = await FirebaseFirestore.instance
          .collection('orders')
          .get();

      for (var doc in allOrdersQuery.docs) {
        final data = doc.data();
        if (data['orderId'] == orderId ||
            doc.id == orderId ||
            data['orderName'] == orderName) {
          await doc.reference.delete();
          return;
        }
      }

      print('Order not found: $orderId');

    } catch (e) {
      print('Error deleting order: $e');
    }
  }
  void _showTrackingInfo(BuildContext context) {
    final status = orderData['status']?.toString() ?? 'pending';
    final statusText = _getStatusText(status);
    final estimatedDelivery = orderData['estimatedDelivery']?.toString() ?? '25-35 دقيقة';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'تتبع الطلب',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
          textAlign: TextAlign.right,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'رقم الطلب: #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
              style: const TextStyle(
                fontFamily: 'NotoSansArabic',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            Text(
              'الحالة: $statusText',
              style: const TextStyle(
                fontFamily: 'NotoSansArabic',
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            Text(
              'الوقت المتوقع: $estimatedDelivery',
              style: const TextStyle(fontFamily: 'NotoSansArabic'),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            Text(
              'عامل التوصيل: $deliveryPerson',
              style: const TextStyle(fontFamily: 'NotoSansArabic'),
              textAlign: TextAlign.right,
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel button
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _deleteOrder();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم إلغاء الطلب',
                            style: TextStyle(fontFamily: 'NotoSansArabic'),
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Done button
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _deleteOrder();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم تسليم الطلب بنجاح!',
                            style: TextStyle(fontFamily: 'NotoSansArabic'),
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'تم',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'في انتظار التأكيد';
      case 'confirmed':
        return 'تم تأكيد الطلب';
      case 'preparing':
        return 'جاري التحضير';
      case 'on_way':
        return 'في الطريق إليك';
      case 'delivered':
        return 'تم التسليم';
      case 'cancelled':
        return 'تم الإلغاء';
      case 'assigned':
        return 'تم تعيين عامل التوصيل';
      default:
        return 'غير محدد';
    }
  }
}