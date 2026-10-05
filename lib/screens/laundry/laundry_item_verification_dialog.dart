import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';

class LaundryItemVerificationDialog extends StatefulWidget {
  final LaundryOrder order;
  final StateService stateService;

  const LaundryItemVerificationDialog({
    super.key,
    required this.order,
    required this.stateService,
  });

  @override
  State<LaundryItemVerificationDialog> createState() => _LaundryItemVerificationDialogState();
}

class _LaundryItemVerificationDialogState extends State<LaundryItemVerificationDialog> {
  late List<int> _verifiedCounts;

  @override
  void initState() {
    super.initState();
    _verifiedCounts = widget.order.items.map((i) => i.verifiedQuantity ?? i.quantity).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 550),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item Verification Counter • #${widget.order.orderNumber}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const Text(
                        'Laundry staff manual garment count verification',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Inspect each received garment for stains/tears and adjust the count if physical pieces differ from customer basket.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(widget.order.items.length, (index) {
                final item = widget.order.items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Text(item.catalogItem.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.catalogItem.itemName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Text(
                              '${item.serviceType.displayName} • Customer reported: ${item.quantity}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle, size: 22, color: AppColors.textMuted),
                            onPressed: _verifiedCounts[index] > 0
                                ? () {
                                    setState(() => _verifiedCounts[index]--);
                                  }
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Text(
                              '${_verifiedCounts[index]}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryDark),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, size: 22, color: AppColors.primary),
                            onPressed: () {
                              setState(() => _verifiedCounts[index]++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    for (int i = 0; i < _verifiedCounts.length; i++) {
                      widget.stateService.verifyOrderItemQuantity(widget.order.id, i, _verifiedCounts[i]);
                    }
                    widget.stateService.finalizeItemVerification(widget.order.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Garment count item-by-item verified and synchronized!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified),
                  label: const Text('Approve & Lock Verified Garment Count'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
