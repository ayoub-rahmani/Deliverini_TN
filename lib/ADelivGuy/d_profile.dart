import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app3/device/deviceutils.dart';
import 'package:app3/common/scroll_helper.dart';
import 'package:app3/services/auth_service.dart';
import 'package:get/get.dart';
import 'd_navigation_controller.dart';

class DeliveryProfile extends StatefulWidget {
  const DeliveryProfile({super.key});

  @override
  State createState() => _DeliveryProfileState();
}

class _DeliveryProfileState extends State<DeliveryProfile> with ScrollHelper {
  bool _isOnline = true;
  bool _pushNotifications = true;
  bool _soundEffects = true;
  bool _vibration = true;

  // Get real user data from AuthService
  Map<String, dynamic> get _profileData {
    final user = AuthService.currentUser;
    return {
      'name': user?.name ?? 'عامل توصيل',
      'email': user?.email ?? 'delivery@example.com',
      'rating': 4.8,
      'totalDeliveries': 1247,
      'completionRate': 98.5,
      'responseTime': '2.3 دقيقة',
      'joinDate': 'مارس 2023',
      'vehicle': 'دراجة نارية',
      'vehicleModel': 'Honda CB 125',
      'licensePlate': 'TUN 1234',
      'currentLevel': 'محترف',
      'nextLevelProgress': 0.75,
      'thisMonthEarnings': 1247.85,
    };
  }

  final List<Map<String, dynamic>> _quickStats = [
    {
      'title': 'اليوم',
      'value': '12',
      'subtitle': 'توصيلة',
      'icon': Icons.today,
      'color': Colors.blue,
    },
    {
      'title': 'هذا الأسبوع',
      'value': '87',
      'subtitle': 'توصيلة',
      'icon': Icons.date_range,
      'color': Colors.green,
    },
    {
      'title': 'الشهر الحالي',
      'value': '1247.85',
      'subtitle': 'دينار',
      'icon': Icons.account_balance_wallet,
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'تاريخ الأرباح',
      'subtitle': 'عرض تفصيلي لجميع أرباحك',
      'icon': Icons.trending_up,
      'color': Colors.green,
    },
    {
      'title': 'إحصائيات الأداء',
      'subtitle': 'تحليل مفصل للأداء والتقييمات',
      'icon': Icons.analytics,
      'color': Colors.blue,
    },
    {
      'title': 'معلومات المركبة',
      'subtitle': 'تعديل بيانات وثائق المركبة',
      'icon': Icons.motorcycle,
      'color': Colors.orange,
    },
    {
      'title': 'الدعم والمساعدة',
      'subtitle': 'تواصل معنا لأي استفسار',
      'icon': Icons.support_agent,
      'color': Colors.purple,
    },
  ];

  void _toggleOnlineStatus() {
    HapticFeedback.selectionClick();
    setState(() {
      _isOnline = !_isOnline;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isOnline ? 'أنت الآن متصل ومتاح للطلبات' : 'أنت الآن غير متصل',
          style: const TextStyle(fontFamily: 'NotoSansArabic', fontWeight: FontWeight.w600),
        ),
        backgroundColor: _isOnline ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleMenuTap(int index) {
    HapticFeedback.lightImpact();
    final item = _menuItems[index];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'فتح ${item['title']}...',
          style: const TextStyle(fontFamily: 'NotoSansArabic', fontWeight: FontWeight.w600),
        ),
        backgroundColor: item['color'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showLogoutDialog() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontFamily: 'NotoSansArabic',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'هل تريد تسجيل الخروج من حساب ${_profileData['name']}؟',
          style: const TextStyle(
            fontFamily: 'NotoSansArabic',
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleLogout(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      fontWeight: FontWeight.w600,
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

  Future<void> _handleLogout() async {
    Navigator.pop(context); // Close dialog
    HapticFeedback.heavyImpact();

    try {
      // Actually call AuthService.logout() - this will handle navigation via AuthWrapper
      await AuthService.logout();
      print('✅ Delivery profile logout completed');
    } catch (e) {
      print('❌ Logout error in delivery profile: $e');
      // Show error message if logout fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ أثناء تسجيل الخروج',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = DeviceUtils.width(context);
    final screenHeight = DeviceUtils.height(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 240,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue[700],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue[700]!, Colors.blue[600]!],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Online Status Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ملفي الشخصي',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'NotoSansArabic',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            GestureDetector(
                              onTap: _toggleOnlineStatus,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isOnline ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isOnline ? Colors.green : Colors.red).withOpacity(0.3),
                                      blurRadius: 6,
                                      spreadRadius: 1,
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
                                      _isOnline ? 'متصل' : 'غير متصل',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'NotoSansArabic',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Profile Info
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.blue,
                                size: 35,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _profileData['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'NotoSansArabic',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _profileData['currentLevel'],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'NotoSansArabic',
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      ...List.generate(5, (index) {
                                        return Icon(
                                          index < _profileData['rating'].floor()
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 14,
                                        );
                                      }),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_profileData['rating']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Quick Stats Row - Compressed
                        Row(
                          children: _quickStats.asMap().entries.map((entry) {
                            final stat = entry.value;
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: entry.key == 0 ? 0 : 4,
                                  left: entry.key == _quickStats.length - 1 ? 0 : 4,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      stat['value'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      stat['subtitle'],
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'NotoSansArabic',
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Performance Overview
                  _buildPerformanceCard(),
                  const SizedBox(height: 20),

                  // Settings Section
                  _buildSettingsCard(),
                  const SizedBox(height: 20),

                  // Menu Items
                  _buildMenuItems(),
                  const SizedBox(height: 20),

                  // Logout Button
                  _buildLogoutButton(),
                  const SizedBox(height: 100), // Bottom padding for navbar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نظرة عامة على الأداء',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              _buildPerformanceItem(
                'إجمالي التوصيلات',
                '${_profileData['totalDeliveries']}',
                Icons.delivery_dining,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildPerformanceItem(
                'معدل الإنجاز',
                '${_profileData['completionRate']}%',
                Icons.check_circle,
                Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Level Progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التقدم للمستوى التالي',
                      style: const TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      '${(_profileData['nextLevelProgress'] * 100).toInt()}%',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _profileData['nextLevelProgress'],
                    backgroundColor: Colors.purple.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.purple),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontFamily: value.contains('%') ? 'Poppins' : 'Poppins',
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'NotoSansArabic',
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الإعدادات',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildSettingItem(
            'الإشعارات الفورية',
            'تلقي إشعارات الطلبات الجديدة',
            Icons.notifications_outlined,
            _pushNotifications,
                (value) => setState(() => _pushNotifications = value),
          ),

          _buildSettingItem(
            'الأصوات',
            'تشغيل الأصوات والتنبيهات',
            Icons.volume_up_outlined,
            _soundEffects,
                (value) => setState(() => _soundEffects = value),
          ),

          _buildSettingItem(
            'الاهتزاز',
            'تفعيل الاهتزاز للتنبيهات',
            Icons.vibration,
            _vibration,
                (value) => setState(() => _vibration = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'NotoSansArabic',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'NotoSansArabic',
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.selectionClick();
              onChanged(newValue);
            },
            activeColor: Colors.blue[700],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == _menuItems.length - 1;

          return InkWell(
            onTap: () => _handleMenuTap(index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: isLast ? null : Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item['icon'], color: item['color'], size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontFamily: 'NotoSansArabic',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['subtitle'],
                          style: TextStyle(
                            fontFamily: 'NotoSansArabic',
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontFamily: 'NotoSansArabic',
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}