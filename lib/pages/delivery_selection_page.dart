import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class DeliverySelectionPage extends StatefulWidget {
  final String orderId;
  final VoidCallback onDeliverySelected;

  const DeliverySelectionPage({
    super.key,
    required this.orderId,
    required this.onDeliverySelected,
  });

  @override
  State<DeliverySelectionPage> createState() => _DeliverySelectionPageState();
}

class _DeliverySelectionPageState extends State<DeliverySelectionPage>
    with SingleTickerProviderStateMixin {
  bool _isAssigning = false;
  String? _selectedDeliveryId;
  List<Map<String, dynamic>> _deliveryPersons = [];
  bool _isLoading = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadDeliveryPersons();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveryPersons() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'delivery')
          .get();

      final List<Map<String, dynamic>> persons = [];

      for (final doc in snapshot.docs) {
        final userData = doc.data();

        final statsDoc = await FirebaseFirestore.instance
            .collection('delivery_stats')
            .doc(doc.id)
            .get();

        final stats = statsDoc.exists
            ? statsDoc.data()!
            : {'totalOrders': 0, 'rating': 5.0, 'completedOrders': 0};

        persons.add({
          'id': doc.id,
          'name': userData['name'] ?? 'غير محدد',
          'profileImage': userData['profileImage'] ?? 'images/pp.png',
          'isOnline': userData['isOnline'] ?? false,
          'rating': (stats['rating'] ?? 5.0).toDouble(),
          'completedOrders': stats['completedOrders'] ?? 0,
        });
      }

      persons.sort((a, b) {
        final ratingComparison = b['rating'].compareTo(a['rating']);
        return ratingComparison != 0 ? ratingComparison : b['completedOrders'].compareTo(a['completedOrders']);
      });

      if (mounted) {
        setState(() {
          _deliveryPersons = persons;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _assignDeliveryPerson(String deliveryPersonId, String deliveryPersonName) async {
    if (_isAssigning) return;

    setState(() {
      _isAssigning = true;
      _selectedDeliveryId = deliveryPersonId;
    });

    try {
      final orderQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('orderId', isEqualTo: widget.orderId)
          .get();

      if (orderQuery.docs.isEmpty) {
        throw Exception('Order not found');
      }

      await orderQuery.docs.first.reference.update({
        'assignedDeliveryId': deliveryPersonId,
        'assignedDeliveryName': deliveryPersonName,
        'deliveryPerson': deliveryPersonName,
        'status': 'assigned',
        'assignedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('delivery_stats')
          .doc(deliveryPersonId)
          .set({'totalOrders': FieldValue.increment(1)}, SetOptions(merge: true));

      final cartSnapshot = await FirebaseFirestore.instance.collection('cart').get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      HapticFeedback.lightImpact();

      if (mounted) {
        widget.onDeliverySelected();
        await _controller.reverse();
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error assigning delivery person: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في تعيين عامل التوصيل', style: TextStyle(fontFamily: 'NotoSansArabic')),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isAssigning = false;
          _selectedDeliveryId = null;
        });
      }
    }
  }

  Future<void> _closePanel() async {
    if (_isAssigning) return;
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    // Better proportional width - 70% for tablets, 80% for phones
    final panelWidth = screenWidth > 600 ? 0.7 : 0.8;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background overlay with better opacity
          FadeTransition(
            opacity: _controller,
            child: GestureDetector(
              onTap: _closePanel,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Panel with improved positioning
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: screenWidth * panelWidth,
                height: screenHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: Offset(-5, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Clean, minimal header
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          20,
                          statusBarHeight + 24,
                          20,
                          24
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFF5F5F5),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Close button
                          GestureDetector(
                            onTap: _closePanel,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.black87,
                                size: 20,
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Icon and title
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.delivery_dining,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'اختيار عامل التوصيل',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'NotoSansArabic',
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'اختر الأنسب لتوصيل طلبك',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontFamily: 'NotoSansArabic',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area with better spacing
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _isLoading
                            ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.orange,
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'جاري تحميل عمال التوصيل...',
                                style: TextStyle(
                                  fontFamily: 'NotoSansArabic',
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                            : _deliveryPersons.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_off_outlined,
                                  color: Colors.grey.shade400,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'لا يوجد عمال توصيل متاحون',
                                style: TextStyle(
                                  fontFamily: 'NotoSansArabic',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'يرجى المحاولة مرة أخرى لاحقاً',
                                style: TextStyle(
                                  fontFamily: 'NotoSansArabic',
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Instructions section
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 24, 0, 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'اختر عامل التوصيل المفضل لتوصيل طلبك',
                                      style: TextStyle(
                                        fontFamily: 'NotoSansArabic',
                                        fontSize: 13,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Delivery persons list
                            Expanded(
                              child: ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                itemCount: _deliveryPersons.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: _buildDeliveryPersonItem,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom safe area
                    SizedBox(height: bottomPadding + 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryPersonItem(BuildContext context, int index) {
    final person = _deliveryPersons[index];
    final isSelected = _selectedDeliveryId == person['id'];
    final isOnline = person['isOnline'] ?? false;

    return GestureDetector(
      onTap: _isAssigning ? null : () => _assignDeliveryPerson(person['id'], person['name']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: isSelected ? 8 : 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Enhanced avatar with online indicator
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isOnline ? Colors.green : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage(person['profileImage']),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 8,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Enhanced info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'NotoSansArabic',
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Status and stats row
                  Row(
                    children: [
                      // Online/Offline status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isOnline ? 'متاح' : 'غير متاح',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'NotoSansArabic',
                            color: isOnline ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              person['rating'].toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Completed orders
                  Text(
                    '${person['completedOrders']} طلب مكتمل',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'NotoSansArabic',
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Enhanced status indicator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: _buildStatusIcon(isSelected),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool isSelected) {
    if (isSelected && _isAssigning) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    } else if (isSelected) {
      return const Icon(
        Icons.check,
        color: Colors.white,
        size: 20,
      );
    } else {
      return Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey.shade400,
        size: 16,
      );
    }
  }
}