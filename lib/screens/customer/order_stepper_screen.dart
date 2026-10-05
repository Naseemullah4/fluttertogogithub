import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/qr_code_card.dart';
import '../../widgets/badge_pill.dart';
import 'complaints_screen.dart';
import '../../widgets/uniwash_logo.dart';

class OrderStepperScreen extends StatelessWidget {
  final LaundryOrder order;

  const OrderStepperScreen({super.key, required this.order});

  static const List<Map<String, dynamic>> _stepperSteps = [
    {
      'status': OrderStatus.placed,
      'title': 'Order Placed',
      'desc': 'Order received and scheduled for driver pickup.',
    },
    {
      'status': OrderStatus.driverAssigned,
      'title': 'Driver Assigned & En-Route',
      'desc': 'Driver is heading to your location for collection.',
    },
    {
      'status': OrderStatus.pickedUp,
      'title': 'Picked Up / Received by Laundry',
      'desc': 'Items collected and verified at UniWash laundry facility.',
    },
    {
      'status': OrderStatus.inLaundry,
      'title': 'In Washing / Dry Cleaning / Pressing',
      'desc': 'Professional washing, solvent dry cleaning, and form pressing.',
    },
    {
      'status': OrderStatus.readyForDelivery,
      'title': 'Order Ready for Delivery',
      'desc': 'Garments packed, inspected, and waiting for delivery dispatch.',
    },
    {
      'status': OrderStatus.outForDelivery,
      'title': 'Out for Delivery',
      'desc': 'Driver is en-route to deliver your fresh garments.',
    },
    {
      'status': OrderStatus.delivered,
      'title': 'Delivered',
      'desc': 'Order completed. Enjoy your pristine clothes!',
    },
  ];

  void _showRatingDialog(BuildContext context, StateService state) {
    double laundryStars = 5.0;
    double driverStars = 5.0;
    final laundryNotes = TextEditingController();
    final driverNotes = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Rate Laundry & Driver', style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Laundry Quality & Cleanliness', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < laundryStars ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 28,
                      ),
                      onPressed: () => setState(() => laundryStars = index + 1.0),
                    );
                  }),
                ),
                TextField(
                  controller: laundryNotes,
                  decoration: const InputDecoration(hintText: 'Comments for laundry staff (optional)'),
                ),
                const SizedBox(height: 16),
                const Text('Driver & Pickup Experience', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < driverStars ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 28,
                      ),
                      onPressed: () => setState(() => driverStars = index + 1.0),
                    );
                  }),
                ),
                TextField(
                  controller: driverNotes,
                  decoration: const InputDecoration(hintText: 'Comments for driver (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () {
                state.rateOrder(
                  order.id,
                  laundryRating: laundryStars,
                  driverRating: driverStars,
                  laundryReview: laundryNotes.text,
                  driverReview: driverNotes.text,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⭐ Thank you for your review and feedback!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    // Look up freshest copy of order from state
    final currentOrder = state.orders.firstWhere((o) => o.id == order.id, orElse: () => order);
    final currentStep = currentOrder.status.stepIndex;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const UniWashLogo.badge(size: 26),
            const SizedBox(width: 8),
            Text('Order #${currentOrder.orderNumber}'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined),
            tooltip: 'Live Support & Chat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentOrder.status.color,
                    currentOrder.status.color.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: currentOrder.status.color.withValues(alpha: 0.3),
                    blurRadius: 12,
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
                      BadgePill(
                        label: 'LIVE TRACKER',
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        textColor: Colors.white,
                        icon: Icons.sensors,
                      ),
                      Text(
                        DateFormat('hh:mm a, dd MMM').format(currentOrder.createdAt),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(currentOrder.status.icon, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentOrder.status.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Step ${currentStep + 1} of 7 • ${currentOrder.laundryName}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order QR Code Card
            Center(
              child: QrCodeCard(
                data: currentOrder.qrCodePayload,
                title: 'Order Pickup QR Code',
                subtitle: 'Present this QR code to the driver upon garment collection.',
                size: 150,
              ),
            ),
            const SizedBox(height: 20),

            // Driver Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentOrder.assignedDriverName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Text(
                          currentOrder.assignedDriverPhone,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            SizedBox(width: 4),
                            Text('4.9 Rating (114 trips)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call, color: AppColors.success),
                    tooltip: 'Call Driver',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📞 Dialing ${currentOrder.assignedDriverPhone}...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                    tooltip: 'In-App Chat',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stepper Progression
            const Text(
              'Order Progress Stepper (7 States)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: List.generate(_stepperSteps.length, (index) {
                  final step = _stepperSteps[index];
                  final isDone = index < currentStep;
                  final isCurrent = index == currentStep;
                  final isLast = index == _stepperSteps.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? AppColors.success
                                  : isCurrent
                                      ? AppColors.primary
                                      : AppColors.surfaceMuted,
                              border: Border.all(
                                color: isCurrent ? AppColors.primary : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isCurrent ? Colors.white : AppColors.textMuted,
                                      ),
                                    ),
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 38,
                              color: isDone ? AppColors.success : AppColors.border,
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                                  color: isCurrent ? AppColors.primaryDark : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step['desc'],
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // Itemized Garment List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Itemized Garments & Services',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      if (currentOrder.isCountVerifiedByLaundry)
                        const BadgePill(
                          label: 'COUNT VERIFIED',
                          backgroundColor: Color(0xFFD1FAE5),
                          textColor: AppColors.success,
                          icon: Icons.verified,
                        ),
                    ],
                  ),
                  const Divider(height: 20),
                  ...currentOrder.items.map((item) {
                    final qty = item.verifiedQuantity ?? item.quantity;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(item.catalogItem.icon, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.catalogItem.itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  if (item.catalogItem.itemNameAr.isNotEmpty)
                                    Text(item.catalogItem.itemNameAr, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: AppColors.primary)),
                                  Text('${item.serviceType.displayName} (x$qty)', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          Text('${item.effectiveTotal.toStringAsFixed(0)} QAR', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery Fee', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      Text('${currentOrder.deliveryFee.toStringAsFixed(2)} QAR', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount Paid / Due', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(
                        '${currentOrder.totalAmount.toStringAsFixed(2)} QAR',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Review button if delivered or testing
            if (currentOrder.status == OrderStatus.delivered || currentOrder.laundryRating == null) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _showRatingDialog(context, state),
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Leave Laundry & Driver Review'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
