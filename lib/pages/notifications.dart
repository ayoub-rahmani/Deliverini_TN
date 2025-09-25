import 'package:app3/device/deviceutils.dart';
import 'package:app3/common/widgets/notif.dart';
import 'package:app3/common/scroll_helper.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> with AutomaticKeepAliveClientMixin, ScrollHelper {
  @override
  bool get wantKeepAlive => true;

  // Static data for better performance - properly typed
  static const List<Map<String, Object>> _notifications = [
    {
      'title': 'طلب جديد',
      'content': 'لديك طلب جديد من أحمد محمد في انتظار التأكيد',
      'dateTime': '2024/01/15 - 14:30',
      'isRead': false
    },
    {
      'title': 'تم تأكيد الطلب',
      'content': 'تم تأكيد طلبك رقم #1234 وسيتم التوصيل خلال 30 دقيقة',
      'dateTime': '2024/01/15 - 14:15',
      'isRead': true
    },
    {
      'title': 'عرض خاص',
      'content': 'خصم 20% على جميع الوجبات اليوم فقط! لا تفوت الفرصة',
      'dateTime': '2024/01/15 - 13:00',
      'isRead': false
    },
    {
      'title': 'تقييم الطلب',
      'content': 'نرجو منك تقييم طلبك الأخير لمساعدتنا في تحسين الخدمة',
      'dateTime': '2024/01/15 - 12:30',
      'isRead': true
    },
    {
      'title': 'رسالة من المطعم',
      'content': 'شكراً لك على اختيار مطعمنا. نتطلع لخدمتك مرة أخرى',
      'dateTime': '2024/01/15 - 11:45',
      'isRead': true
    },
    {
      'title': 'تحديث التطبيق',
      'content': 'يتوفر تحديث جديد للتطبيق مع ميزات محسنة',
      'dateTime': '2024/01/14 - 20:15',
      'isRead': false
    },
    {
      'title': 'عرض محدود',
      'content': 'وجبة مجانية عند طلب 3 وجبات أو أكثر',
      'dateTime': '2024/01/14 - 18:30',
      'isRead': true
    },
    {
      'title': 'تذكير',
      'content': 'لا تنس استخدام كود الخصم الخاص بك قبل انتهاء صلاحيته',
      'dateTime': '2024/01/13 - 16:20',
      'isRead': true
    },
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isTablet = DeviceUtils.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: DeviceUtils.height(context),
        width: DeviceUtils.width(context),
        color: Colors.black,
        child: Stack(
          children: [
            // Header text
            Positioned(
              bottom: DeviceUtils.height(context) * 0.88 + 10,
              right: 30,
              child: const Text(
                "تنبيهات",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "NotoSansArabic",
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Main content container
            Positioned(
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)
                    ),
                  ),
                  width: DeviceUtils.width(context),
                  height: DeviceUtils.height(context) * 0.88,
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 20, bottom: 120),
                    itemCount: _notifications.length,
                    cacheExtent: 500,
                    separatorBuilder: (context, index) => Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      color: Colors.black,
                    ),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Notif(
                        title: notification['title'] as String,
                        content: notification['content'] as String,
                        dateTime: notification['dateTime'] as String,
                        isRead: notification['isRead'] as bool,
                      );
                    },
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: DeviceUtils.height(context) * 0.88,
              left: DeviceUtils.width(context) * 0.09,
              child: RepaintBoundary(
                child: Lottie.asset(
                  "images/notifications.json",
                  width: DeviceUtils.width(context) * 0.18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
