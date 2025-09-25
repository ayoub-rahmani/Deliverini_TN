import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:app3/device/deviceutils.dart';
import 'package:app3/common/scroll_helper.dart';

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

  // Mock user data
  final Map _profileData = {
    'name': 'محمد أحمد الخليفي',
    'phone': '+216 98 123 456',
    'email': 'mohamed.ahmed@email.com',
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
    'lifetimeEarnings': 12847.50,
    'thisMonthEarnings': 1247.85,
  };

  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'سريع البرق',
      'description': 'أكمل 50 توصيلة في وقت قياسي',
      'icon': Icons.flash_on,
      'color': Colors.yellow,
      'achieved': true,
    },
    {
      'title': 'المحترف',
      'description': 'وصل إلى 1000 توصيلة مكتملة',
      'icon': Icons.star,
      'color': Colors.purple,
      'achieved': true,
    },
    {
      'title': 'العميل المفضل',
      'description': 'حصل على تقييم 4.5+ لمدة شهر',
      'icon': Icons.favorite,
      'color': Colors.red,
      'achieved': true,
    },
    {
      'title': 'المثابر',
      'description': 'عمل 30 يوماً متواصلاً',
      'icon': Icons.emoji_events,
      'color': Colors.orange,
      'achieved': false,
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
          style: const TextStyle(fontFamily: 'NotoSansArabic'),
        ),
        backgroundColor: _isOnline ? Colors.green : Colors.red,
      ),
    );
  }

  void _editProfile() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'صفحة تحرير الملف الشخصي...',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
        ),
      ),
    );
  }

  void _viewEarningsHistory() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'عرض تاريخ الأرباح...',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
        ),
      ),
    );
  }

  void _contactSupport() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تواصل مع الدعم',
          style: TextStyle(
              fontFamily: 'NotoSansArabic', fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'كيف تريد التواصل معنا؟',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildSupportOption('واتساب', Icons.message, Colors.green),
            const SizedBox(height: 8),
            _buildSupportOption('مكالمة هاتفية', Icons.phone, Colors.blue),
            const SizedBox(height: 8),
            _buildSupportOption('البريد الإلكتروني', Icons.email, Colors.orange),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فتح $title...',
              style: const TextStyle(fontFamily: 'NotoSansArabic'),
            ),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(
              fontFamily: 'NotoSansArabic', fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'NotoSansArabic'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم تسجيل الخروج بنجاح',
                    style: TextStyle(fontFamily: 'NotoSansArabic'),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(fontFamily: 'NotoSansArabic', color: Colors.white),
            ),
          ),
        ],
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
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isOnline ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                      (_isOnline ? Colors.green : Colors.red).withOpacity(0.3),
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
              'ملفي الشخصي',
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
                child: _buildProfileContent(),
              ),
            ),
          ),
          // Animated Profile Icon
          Positioned(
            bottom: DeviceUtils.height(context) * 0.88,
            left: DeviceUtils.width(context) * 0.09,
            child: RepaintBoundary(
              child: Lottie.asset(
                'images/profile_delivery.json',
                width: DeviceUtils.width(context) * 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsOverview(),
          const SizedBox(height: 20),
          _buildLevelProgress(),
          const SizedBox(height: 20),
          _buildAchievements(),
          const SizedBox(height: 20),
          _buildSettingsSection(),
          const SizedBox(height: 20),
          _buildVehicleInfo(),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 35),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 4),
                    Text(
                      _profileData['currentLevel'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'NotoSansArabic',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < _profileData['rating'].floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${_profileData['rating']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildContactItem(Icons.phone, _profileData['phone'])),
              const SizedBox(width: 16),
              Expanded(child: _buildContactItem(Icons.email, _profileData['email'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائياتي',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'إجمالي التوصيلات',
                  '${_profileData['totalDeliveries']}',
                  Icons.delivery_dining,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'معدل الإنجاز',
                  '${_profileData['completionRate']}%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'وقت الاستجابة',
                  _profileData['responseTime'],
                  Icons.timer,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'عضو منذ',
                  _profileData['joinDate'],
                  Icons.calendar_today,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontFamily:
              value.contains('%') || value.contains('د') ? 'NotoSansArabic' : 'Poppins',
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'NotoSansArabic',
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المستوى الحالي: ${_profileData['currentLevel']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSansArabic',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(_profileData['nextLevelProgress'] * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _profileData['nextLevelProgress'],
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(Colors.purple),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'أكمل المزيد من التوصيلات للوصول للمستوى التالي',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'NotoSansArabic',
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الإنجازات',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
            _achievements.map((achievement) => _buildAchievementBadge(achievement)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(Map achievement) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement['achieved']
            ? achievement['color'].withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement['achieved']
              ? achievement['color'].withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            achievement['icon'],
            color: achievement['achieved'] ? achievement['color'] : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            achievement['title'],
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
              color: achievement['achieved'] ? achievement['color'] : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            achievement['description'],
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

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 16),
          _buildSettingItem('الإشعارات الفورية', 'تلقي إشعارات الطلبات الجديدة',
              Icons.notifications, _pushNotifications, (value) {
                setState(() {
                  _pushNotifications = value;
                });
              }),
          _buildSettingItem('الأصوات', 'تشغيل الأصوات والتنبيهات', Icons.volume_up,
              _soundEffects, (value) {
                setState(() {
                  _soundEffects = value;
                });
              }),
          _buildSettingItem('الاهتزاز', 'تفعيل الاهتزاز للتنبيهات', Icons.vibration,
              _vibration, (value) {
                setState(() {
                  _vibration = value;
                });
              }),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
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

  Widget _buildVehicleInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معلومات المركبة',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.motorcycle, color: Colors.orange, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profileData['vehicleModel'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _profileData['vehicle'],
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'رقم اللوحة: ${_profileData['licensePlate']}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _viewEarningsHistory,
                icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                label: const Text(
                  'تاريخ الأرباح',
                  style: TextStyle(fontFamily: 'NotoSansArabic', color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _contactSupport,
                icon: const Icon(Icons.support_agent, color: Colors.white),
                label: const Text(
                  'الدعم',
                  style: TextStyle(fontFamily: 'NotoSansArabic', color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text(
            'تسجيل الخروج',
            style: TextStyle(fontFamily: 'NotoSansArabic', color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
