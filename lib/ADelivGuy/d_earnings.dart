import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:app3/device/deviceutils.dart';
import 'package:app3/common/scroll_helper.dart';

class Earnings extends StatefulWidget {
  const Earnings({super.key});

  @override
  State<Earnings> createState() => _EarningsState();
}

class _EarningsState extends State<Earnings> with ScrollHelper, TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 0; // 0: Today, 1: Week, 2: Month
  bool _showDetails = true;

  // Mock earnings data
  final Map<String, dynamic> _earningsData = {
    'today': {
      'total': 45.750,
      'deliveries': 8,
      'hours': 6.5,
      'averagePerOrder': 5.719,
      'orders': [
        {'id': 'ORD001', 'time': '09:30', 'amount': 3.500, 'restaurant': 'LaMAMMA'},
        {'id': 'ORD002', 'time': '10:45', 'amount': 4.000, 'restaurant': 'Burger House'},
        {'id': 'ORD003', 'time': '12:15', 'amount': 5.500, 'restaurant': 'Sushi Master'},
        {'id': 'ORD004', 'time': '13:30', 'amount': 3.500, 'restaurant': 'Pizza Corner'},
        {'id': 'ORD005', 'time': '15:20', 'amount': 6.250, 'restaurant': 'Taco Bell'},
        {'id': 'ORD006', 'time': '16:45', 'amount': 4.500, 'restaurant': 'KFC'},
        {'id': 'ORD007', 'time': '18:10', 'amount': 8.500, 'restaurant': 'Fine Dining'},
        {'id': 'ORD008', 'time': '19:30', 'amount': 10.000, 'restaurant': 'Premium Sushi'},
      ],
    },
    'week': {
      'total': 287.500,
      'deliveries': 52,
      'hours': 38.5,
      'averagePerOrder': 5.529,
      'days': [
        {'day': 'الأحد', 'amount': 45.750, 'deliveries': 8},
        {'day': 'الاثنين', 'amount': 52.250, 'deliveries': 9},
        {'day': 'الثلاثاء', 'amount': 38.500, 'deliveries': 7},
        {'day': 'الأربعاء', 'amount': 41.000, 'deliveries': 8},
        {'day': 'الخميس', 'amount': 35.750, 'deliveries': 6},
        {'day': 'الجمعة', 'amount': 48.250, 'deliveries': 9},
        {'day': 'السبت', 'amount': 26.000, 'deliveries': 5},
      ],
    },
    'month': {
      'total': 1247.850,
      'deliveries': 218,
      'hours': 162.5,
      'averagePerOrder': 5.724,
      'weeks': [
        {'week': 'الأسبوع 1', 'amount': 287.500, 'deliveries': 52},
        {'week': 'الأسبوع 2', 'amount': 325.750, 'deliveries': 58},
        {'week': 'الأسبوع 3', 'amount': 298.600, 'deliveries': 54},
        {'week': 'الأسبوع 4', 'amount': 336.000, 'deliveries': 54},
      ],
    },
  };

  final List<String> _periodLabels = ['اليوم', 'الأسبوع', 'الشهر'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedPeriod = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleDetails() {
    HapticFeedback.lightImpact();
    setState(() {
      _showDetails = !_showDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Page Title
          Positioned(
            bottom: DeviceUtils.height(context) * 0.88 + 10,
            right: 30,
            child: const Text(
              'أرباحي',
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
                child: _buildEarningsContent(),
              ),
            ),
          ),

          // Animated Money Icon
          Positioned(
            bottom: DeviceUtils.height(context) * 0.88,
            left: DeviceUtils.width(context) * 0.09,
            child: RepaintBoundary(
              child: Lottie.asset(
                'images/money_earnings.json', // Money/earnings animation
                width: DeviceUtils.width(context) * 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsContent() {
    return Column(
      children: [
        // Period Selector
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(25),
            ),
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
            tabs: _periodLabels.map((label) => Tab(text: label)).toList(),
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Summary Card
                  _buildSummaryCard(),

                  const SizedBox(height: 20),

                  // Quick Stats
                  _buildQuickStats(),

                  const SizedBox(height: 20),

                  // Details Toggle
                  GestureDetector(
                    onTap: _toggleDetails,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showDetails ? 'إخفاء التفاصيل' : 'عرض التفاصيل',
                            style: TextStyle(
                              fontFamily: 'NotoSansArabic',
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Details Section
                  if (_showDetails) ...[
                    const SizedBox(height: 20),
                    _buildDetailsSection(),
                  ],

                  const SizedBox(height: 100), // Bottom padding for navbar
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final data = _getCurrentPeriodData();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[600]!, Colors.green[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجمالي الأرباح - ${_periodLabels[_selectedPeriod]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'NotoSansArabic',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data['total'].toStringAsFixed(3)} د.ت',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'عدد التوصيلات',
                  '${data['deliveries']}',
                  Icons.delivery_dining,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _buildSummaryItem(
                  'ساعات العمل',
                  '${data['hours']}',
                  Icons.access_time,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _buildSummaryItem(
                  'متوسط الطلب',
                  '${data['averagePerOrder'].toStringAsFixed(2)} د.ت',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'NotoSansArabic',
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'هذا الأسبوع',
            '${_earningsData['week']['total'].toStringAsFixed(1)} د.ت',
            Colors.blue,
            Icons.calendar_view_week,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'هذا الشهر',
            '${_earningsData['month']['total'].toStringAsFixed(0)} د.ت',
            Colors.purple,
            Icons.calendar_month,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
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
              fontSize: 12,
              fontFamily: 'NotoSansArabic',
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    switch (_selectedPeriod) {
      case 0: // Today
        return _buildTodayDetails();
      case 1: // Week
        return _buildWeekDetails();
      case 2: // Month
        return _buildMonthDetails();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTodayDetails() {
    final orders = _earningsData['today']['orders'] as List;

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
            'طلبات اليوم',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...orders.map((order) => _buildOrderItem(order)).toList(),
        ],
      ),
    );
  }

  Widget _buildWeekDetails() {
    final days = _earningsData['week']['days'] as List;

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
            'تفاصيل الأسبوع',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...days.map((day) => _buildDayItem(day)).toList(),
        ],
      ),
    );
  }

  Widget _buildMonthDetails() {
    final weeks = _earningsData['month']['weeks'] as List;

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
            'تفاصيل الشهر',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...weeks.map((week) => _buildWeekItem(week)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['restaurant'],
                  style: const TextStyle(
                    fontFamily: 'NotoSansArabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${order['id']} - ${order['time']}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${order['amount'].toStringAsFixed(3)} د.ت',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(Map<String, dynamic> day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day['day'],
                  style: const TextStyle(
                    fontFamily: 'NotoSansArabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${day['deliveries']} توصيلة',
                  style: TextStyle(
                    fontFamily: 'NotoSansArabic',
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${day['amount'].toStringAsFixed(3)} د.ت',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekItem(Map<String, dynamic> week) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  week['week'],
                  style: const TextStyle(
                    fontFamily: 'NotoSansArabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${week['deliveries']} توصيلة',
                  style: TextStyle(
                    fontFamily: 'NotoSansArabic',
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${week['amount'].toStringAsFixed(3)} د.ت',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.purple,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCurrentPeriodData() {
    switch (_selectedPeriod) {
      case 0:
        return _earningsData['today'];
      case 1:
        return _earningsData['week'];
      case 2:
        return _earningsData['month'];
      default:
        return _earningsData['today'];
    }
  }
}