import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CartItem extends StatefulWidget {
  const CartItem({
    super.key,
    required this.id,
    required this.image,
    required this.quantity,
    required this.name,
    required this.price,
    required this.onQuantityChanged,
    required this.onRemove,
    this.customizations,
    this.isCustomized = false,
    this.isExpanded = false,
    this.onExpansionChanged,
  });

  final String id;
  final String image;
  final int quantity;
  final String name;
  final double price;
  final void Function(String id, int quantity) onQuantityChanged;
  final void Function(String id) onRemove;
  final Map<String, String>? customizations;
  final bool isCustomized;
  final bool isExpanded;
  final void Function(String id)? onExpansionChanged;

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFF9400)),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.isCustomized ? () {
              widget.onExpansionChanged?.call(widget.id);
            } : null,
            child: Row(
              children: [
                Row(
                  children: [
                    if (widget.isCustomized)
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 12),
                        child: Icon(
                          widget.isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                          size: 24,
                          color: const Color(0xFFFF9400),
                        ),
                      ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(image: AssetImage(widget.image), fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name, style: const TextStyle(fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${widget.price.toStringAsFixed(3)} د.ت', style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'Poppins')),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuantityButton(
                      icon: widget.quantity == 1 ? Icons.delete_outline : Icons.remove,
                      color: widget.quantity == 1 ? Colors.red : Colors.grey,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (widget.quantity > 1) {
                          widget.onQuantityChanged(widget.id, widget.quantity - 1);
                        } else {
                          widget.onRemove(widget.id);
                        }
                      },
                    ),
                    Container(
                      width: 40,
                      child: Text('${widget.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      color: Colors.orange,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onQuantityChanged(widget.id, widget.quantity + 1);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.isExpanded && widget.customizations != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: _buildIngredientsGrid(),
            ),
        ],
      ),
    );
  }

  Widget _buildIngredientsGrid() {
    final customizations = widget.customizations!.entries
        .where((entry) => entry.value != '+')
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: customizations.map((entry) =>
          SizedBox(
            width: (MediaQuery.of(context).size.width - 120) / 2,
            child: _buildIngredientContainer(entry),
          ),
      ).toList(),
    );
  }

  Widget _buildIngredientContainer(MapEntry<String, String> entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '${entry.key}: ',
              style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            entry.value,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: entry.value == '-' ? Colors.red :
              entry.value == '++' ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
