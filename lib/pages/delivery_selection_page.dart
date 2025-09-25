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
      // First, find the document by orderId field instead of document ID
      final orderQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('orderId', isEqualTo: widget.orderId)
          .get();

      if (orderQuery.docs.isEmpty) {
        throw Exception('Order not found');
      }

      // Update the found document
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
      print('Error assigning delivery person: $e'); // Add this for debugging
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
    const panelWidth = 0.65;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background overlay - ONLY fades
          FadeTransition(
            opacity: _controller,
            child: GestureDetector(
              onTap: _closePanel,
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Panel - ONLY slides from right
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: screenWidth * panelWidth,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 45, 20, 12),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delivery_dining,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'اختر عامل التوصيل',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'NotoSansArabic',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 38), // Balance the delivery icon
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.black))
                          : _deliveryPersons.isEmpty
                          ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_off, color: Colors.grey, size: 40),
                            SizedBox(height: 12),
                            Text(
                              'لا يوجد عمال توصيل متاحون',
                              style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 14),
                            ),
                          ],
                        ),
                      )
                          : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _deliveryPersons.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: _buildDeliveryPersonItem,
                      ),
                    ),
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(person['profileImage']),
                  backgroundColor: Colors.grey.shade200,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'NotoSansArabic',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        person['rating'].toStringAsFixed(1),
                        style: const TextStyle(fontSize: 11, fontFamily: 'Poppins'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${person['completedOrders']}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status indicator
            if (isSelected && _isAssigning)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.orange),
              )
            else if (isSelected)
              const Icon(Icons.check_circle, color: Colors.orange, size: 18)
            else
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 12),
          ],
        ),
      ),
    );
  }
}