import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:app3/device/deviceutils.dart';
import 'package:app3/common/scroll_helper.dart';

class ActiveDelivery extends StatefulWidget {
  const ActiveDelivery({super.key});

  @override
  State<ActiveDelivery> createState() => _ActiveDeliveryState();
}

class _ActiveDeliveryState extends State<ActiveDelivery> with ScrollHelper {
  int _currentStep = 0;
  bool _hasActiveDelivery = true; // Toggle this to show empty state

  // Mock active delivery data
  final Map<String, dynamic> _activeOrder = {
    'id': 'ORD001',
    'restaurant': 'LaMAMMA',
    'restaurantAddress': 'شارع الحرية، تونس',
    'restaurantPhone': '+216 71 123 456',
    'customerName': 'أحمد محمد',
    'customerAddress': 'شارع الحبيب بورقيبة، تونس - الطابق الثالث، شقة 12',
    'customerPhone': '+216 98 765 432',
    'items': ['بيتزا مارغريتا', 'كوكا كولا'],
    'orderTotal': 25.750,
    'deliveryFee': 3.500,
    'estimatedTime': '15 دقيقة',
    'customerNotes': 'يرجى الاتصال عند الوصول للمبنى',
  };

  final List<String> _deliverySteps = [
    'التوجه للمطعم',
    'استلام الطلب',
    'التوجه للعميل',
    'تسليم الطلب',
  ];

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep < _deliverySteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeDelivery();
    }
  }

  void _completeDelivery() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'images/delivery_success.json', // Success animation
              width: 100,
              repeat: false,
            ),
            const SizedBox(height: 20),
            const Text(
              'تم التسليم بنجاح!',
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'أرباحك من هذا الطلب',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${_activeOrder['deliveryFee'].toStringAsFixed(3)} د.ت',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _hasActiveDelivery = false;
                  _currentStep = 0;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'متابعة',
                style: TextStyle(
                  fontFamily: 'NotoSansArabic',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _callCustomer() {
    HapticFeedback.selectionClick();
    // Simulate calling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'جاري الاتصال بـ ${_activeOrder['customerName']}...',
          style: const TextStyle(fontFamily: 'NotoSansArabic'),
        ),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  void _callRestaurant() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'جاري الاتصال بـ ${_activeOrder['restaurant']}...',
          style: const TextStyle(fontFamily: 'NotoSansArabic'),
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _openMaps() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'فتح خرائط جوجل...',
          style: TextStyle(fontFamily: 'NotoSansArabic'),
        ),
        backgroundColor: Colors.green,
      ),
    );
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
              'التوصيل النشط',
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
                child: _hasActiveDelivery ? _buildActiveDeliveryContent() : _buildNoActiveDelivery(),
              ),
            ),
          ),

          // Animated Delivery Icon
          Positioned(
            bottom: DeviceUtils.height(context) * 0.88,
            left: DeviceUtils.width(context) * 0.09,
            child: RepaintBoundary(
              child: Lottie.asset(
                _hasActiveDelivery ? 'images/delivery_active.json' : 'images/delivery_waiting.json',
                width: DeviceUtils.width(context) * 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveryContent() {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Stepper
          _buildProgressStepper(),

          const SizedBox(height: 24),

          // Current Task Card
          _buildCurrentTaskCard(),

          const SizedBox(height: 20),

          // Quick Actions
          _buildQuickActions(),

          const SizedBox(height: 20),

          // Order Details
          _buildOrderDetails(),

          const SizedBox(height: 100), // Bottom padding for navbar
        ],
      ),
    );
  }

  Widget _buildNoActiveDelivery() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'images/delivery_waiting.json', // Waiting animation
            width: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'لا يوجد توصيل نشط',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'اقبل طلباً من صفحة الطلبات المتاحة لبدء التوصيل',
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

  Widget _buildProgressStepper() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'حالة التوصيل',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: _deliverySteps.asMap().entries.map((entry) {
              int index = entry.key;
              String step = entry.value;
              bool isCompleted = index < _currentStep;
              bool isCurrent = index == _currentStep;

              return Row(
                children: [
                  // Step Circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? Colors.green
                          : isCurrent
                          ? Colors.blue[700]
                          : Colors.grey[300],
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : isCurrent
                        ? Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                        : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Step Text
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSansArabic',
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted
                            ? Colors.green
                            : isCurrent
                            ? Colors.blue[700]
                            : Colors.grey[600],
                      ),
                    ),
                  ),

                  // Line connecting steps
                  if (index < _deliverySteps.length - 1)
                    Container(
                      width: 2,
                      height: 40,
                      color: index < _currentStep ? Colors.green : Colors.grey[300],
                      margin: const EdgeInsets.only(right: 15),
                    ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTaskCard() {
    String currentTask = _deliverySteps[_currentStep];
    String taskDescription = _getTaskDescription(_currentStep);
    Color taskColor = _getTaskColor(_currentStep);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [taskColor.withOpacity(0.1), taskColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: taskColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: taskColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTaskIcon(_currentStep),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTask,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'NotoSansArabic',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      taskDescription,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'NotoSansArabic',
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: taskColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _getActionButtonText(_currentStep),
                style: const TextStyle(
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
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'اتصال بالعميل',
                  Icons.phone,
                  Colors.blue[700]!,
                  _callCustomer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'اتصال بالمطعم',
                  Icons.restaurant,
                  Colors.orange,
                  _callRestaurant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              'فتح الخريطة',
              Icons.map,
              Colors.green,
              _openMaps,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'NotoSansArabic',
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
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
            'تفاصيل الطلب',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Order ID
          _buildDetailRow('رقم الطلب:', _activeOrder['id']),

          // Restaurant Info
          const SizedBox(height: 12),
          _buildDetailRow('المطعم:', _activeOrder['restaurant']),
          _buildDetailRow('عنوان المطعم:', _activeOrder['restaurantAddress']),

          const Divider(height: 24),

          // Customer Info
          _buildDetailRow('العميل:', _activeOrder['customerName']),
          _buildDetailRow('عنوان العميل:', _activeOrder['customerAddress']),

          // Customer Notes
          if (_activeOrder['customerNotes'].isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _activeOrder['customerNotes'],
                    style: const TextStyle(
                      fontFamily: 'NotoSansArabic',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 24),

          // Financial Info
          _buildDetailRow('إجمالي الطلب:', '${_activeOrder['orderTotal'].toStringAsFixed(3)} د.ت'),
          _buildDetailRow('أرباحك:', '${_activeOrder['deliveryFee'].toStringAsFixed(3)} د.ت',
              valueColor: Colors.green[700]),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: value.contains('ORD') ? 'Poppins' : 'NotoSansArabic',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTaskDescription(int step) {
    switch (step) {
      case 0:
        return 'توجه إلى ${_activeOrder['restaurant']} لاستلام الطلب';
      case 1:
        return 'تأكد من استلام جميع العناصر من المطعم';
      case 2:
        return 'توجه إلى عنوان العميل: ${_activeOrder['customerName']}';
      case 3:
        return 'سلم الطلب للعميل واحصل على الدفع';
      default:
        return '';
    }
  }

  Color _getTaskColor(int step) {
    switch (step) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue[700]!;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTaskIcon(int step) {
    switch (step) {
      case 0:
        return Icons.restaurant;
      case 1:
        return Icons.check_box;
      case 2:
        return Icons.delivery_dining;
      case 3:
        return Icons.handshake;
      default:
        return Icons.circle;
    }
  }

  String _getActionButtonText(int step) {
    switch (step) {
      case 0:
        return 'وصلت للمطعم';
      case 1:
        return 'استلمت الطلب';
      case 2:
        return 'وصلت للعميل';
      case 3:
        return 'تم التسليم';
      default:
        return 'التالي';
    }
  }
}