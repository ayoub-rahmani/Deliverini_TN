import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:app3/device/deviceutils.dart';
import 'package:app3/common/scroll_helper.dart';

class DeliveryNotifications extends StatefulWidget {
  const DeliveryNotifications({super.key});

  @override
  State<DeliveryNotifications> createState() => _DeliveryNotificationsState();
}

class _DeliveryNotificationsState extends State<DeliveryNotifications> with ScrollHelper {
  // Mock notifications data
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'not_001',
      'type': 'bonus',
      'title': 'مكافأة خاصة متاحة!',
      'message': 'أكمل 5 توصيلات إضافية اليوم واحصل على مكافأة 15 دينار',
      'time': DateTime.now().subtract(const Duration(minutes: 10)),
      'isRead': false,
      'priority': 'high',
      'icon': Icons.star,
      'color': Colors.amber,
      'actionText': 'ابدأ التوصيل',
    },
    {
      'id': 'not_002',
      'type': 'area',
      'title': 'منطقة عالية الطلب',
      'message': 'الطلب مرتفع في منطقة وسط المدينة. توجه هناك لفرص أكثر!',
      'time': DateTime.now().subtract(const Duration(minutes: 25)),
      'isRead': false,
      'priority': 'medium',
      'icon': Icons.location_on,
      'color': Colors.red,
      'actionText': 'عرض الخريطة',
    },
    {
      'id': 'not_003',
      'type': 'order',
      'title': 'تم إلغاء الطلب',
      'message': 'تم إلغاء الطلب ORD156 من قبل العميل. سيتم تعويضك بـ 2 دينار',
      'time': DateTime.now().subtract(const Duration(hours: 1)),
      'isRead': true,
      'priority': 'medium',
      'icon': Icons.cancel,
      'color': Colors.orange,
      'actionText': null,
    },
    {
      'id': 'not_004',
      'type': 'achievement',
      'title': 'إنجاز جديد!',
      'message': 'تهانينا! وصلت إلى 100 توصيلة هذا الشهر. حصلت على شارة "المحترف"',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': true,
      'priority': 'low',
      'icon': Icons.emoji_events,
      'color': Colors.purple,
      'actionText': 'عرض الإنجازات',
    },
    {
      'id': 'not_005',
      'type': 'system',
      'title': 'تحديث التطبيق',
      'message': 'إصدار جديد من التطبيق متوفر مع تحسينات على الأداء وميزات جديدة',
      'time': DateTime.now().subtract(const Duration(hours: 4)),
      'isRead': true,
      'priority': 'low',
      'icon': Icons.system_update,
      'color': Colors.blue,
      'actionText': 'تحديث الآن',
    },
    {
      'id': 'not_006',
      'type': 'payment',
      'title': 'تم إيداع الأرباح',
      'message': 'تم إيداع أرباح الأسبوع (287.5 دينار) في حسابك البنكي',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'priority': 'medium',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
      'actionText': 'عرض التفاصيل',
    },
    {
      'id': 'not_007',
      'type': 'weather',
      'title': 'تحذير طقس',
      'message': 'أمطار متوقعة هذا المساء. قد التوصيل وكن حذراً على الطريق',
      'time': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      'isRead': true,
      'priority': 'medium',
      'icon': Icons.add_alert,
      'color': Colors.blueGrey,
      'actionText': null,
    },
  ];

  int get _unreadCount => _notifications.where((n) => !n['isRead']).length;

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    HapticFeedback.lightImpact();
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    if (notification['actionText'] == null) return;

    HapticFeedback.lightImpact();

    switch (notification['type']) {
      case 'bonus':
      // Navigate to orders page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'جاري التوجه إلى صفحة الطلبات...',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
            backgroundColor: Colors.amber,
          ),
        );
        break;
      case 'area':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'فتح خرائط جوجل...',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        break;
      case 'achievement':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'عرض صفحة الإنجازات...',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
            backgroundColor: Colors.purple,
          ),
        );
        break;
      case 'system':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'جاري توجيهك إلى متجر التطبيقات...',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
            backgroundColor: Colors.blue,
          ),
        );
        break;
      case 'payment':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'عرض تفاصيل الأرباح...',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        break;
    }
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });
    HapticFeedback.lightImpact();
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Unread Count Badge (if any)
          if (_unreadCount > 0)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_unreadCount جديد',
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

          // Page Title
          Positioned(
            bottom: DeviceUtils.height(context) * 0.88 + 10,
            right: 30,
            child: const Text(
              'الإشعارات',
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
                child: _notifications.isEmpty ? _buildEmptyState() : _buildNotificationsList(),
              ),
            ),
          ),

          // Animated Notification Icon
          Positioned(
            bottom: DeviceUtils.height(context) * 0.88,
            left: DeviceUtils.width(context) * 0.09,
            child: RepaintBoundary(
              child: Lottie.asset(
                _unreadCount > 0
                    ? 'images/notification_active.json'
                    : 'images/notification_empty.json',
                width: DeviceUtils.width(context) * 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Column(
      children: [
        // Header with Mark All Read button
        if (_unreadCount > 0)
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'لديك $_unreadCount إشعارات جديدة',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSansArabic',
                    color: Colors.grey[600],
                  ),
                ),
                TextButton(
                  onPressed: _markAllAsRead,
                  child: Text(
                    'تحديد الكل كمقروء',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Notifications List
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ..._notifications.map((notification) => _buildNotificationCard(notification)).toList(),
                const SizedBox(height: 100), // Bottom padding for navbar
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'images/notification_empty.json',
            width: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'ستظهر هنا جميع الإشعارات والتحديثات المهمة',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'NotoSansArabic',
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final bool isUnread = !notification['isRead'];
    final Color cardColor = notification['color'];

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (_) => _deleteNotification(notification['id']),
      child: GestureDetector(
        onTap: () => _markAsRead(notification['id']),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isUnread ? cardColor.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread ? cardColor.withOpacity(0.3) : Colors.grey[300]!,
              width: isUnread ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isUnread ? 0.15 : 0.05),
                blurRadius: isUnread ? 15 : 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notification['icon'],
                        color: cardColor,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Priority Badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'NotoSansArabic',
                                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                    color: isUnread ? Colors.black : Colors.grey[700],
                                  ),
                                ),
                              ),
                              if (notification['priority'] == 'high')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'عاجل',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'NotoSansArabic',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Message
                          Text(
                            notification['message'],
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'NotoSansArabic',
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Time and Unread Indicator
                          Row(
                            children: [
                              Text(
                                _getTimeAgo(notification['time']),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'NotoSansArabic',
                                  color: Colors.grey[500],
                                ),
                              ),
                              if (isUnread) ...[
                                const SizedBox(width: 12),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Button (if available)
              if (notification['actionText'] != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () => _handleNotificationAction(notification),
                    style: TextButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      notification['actionText'],
                      style: const TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}