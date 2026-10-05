import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../theme/app_colors.dart';

class DriverDeliverySuccessDialog extends StatelessWidget {
  final LaundryOrder order;
  final double earnedBonusQar;
  final VoidCallback onBackToDashboard;

  const DriverDeliverySuccessDialog({
    super.key,
    required this.order,
    this.earnedBonusQar = 1.0,
    required this.onBackToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big Glowing Smile Face
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.amber.shade300, Colors.orange.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: 4,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '😊',
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Celebratory Heading
            const Text(
              'Order is Delivered!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Thanks for order complete! 🎉',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Bonus Card: "You have earned 1 Qatar Riyal"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
              ),
              child: Column(
                children: [
                  const Text(
                    'DISPATCH COMMISSION EARNED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF047857),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars, color: Color(0xFF059669), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'You have earned ${earnedBonusQar.toStringAsFixed(earnedBonusQar % 1 == 0 ? 0 : 2)} Qatar Riyal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Credited instantly to your driver wallet balance',
                    style: TextStyle(fontSize: 11, color: Color(0xFF047857)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Order receipt info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order Number:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text('#${order.orderNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Customer:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text(order.customerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery Time:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text(
                        '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} Local',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Back to Dashboard Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onBackToDashboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.dashboard_outlined),
                label: const Text(
                  'Back to Dashboard for New Order',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
