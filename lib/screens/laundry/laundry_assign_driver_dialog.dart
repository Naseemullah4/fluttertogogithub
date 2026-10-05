import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../services/localization_service.dart';
import '../../theme/app_colors.dart';

class LaundryAssignDriverDialog extends StatelessWidget {
  final LaundryOrder order;

  const LaundryAssignDriverDialog({super.key, required this.order});

  static void show(BuildContext context, LaundryOrder order) {
    showDialog(
      context: context,
      builder: (_) => LaundryAssignDriverDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateService = context.watch<StateService>();
    final drivers = stateService.drivers;
    final isAr = stateService.currentLanguage == AppLanguage.ar;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 680),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.sports_motorsports_rounded, color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'تعيين سائق للطلب #${order.orderNumber}' : 'Assign Driver • Order #${order.orderNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          isAr 
                              ? 'حدد السائق لنقل الطلب مباشرة إلى لوحة تحكم السائق' 
                              : 'Select driver to shift mission to their mobile dispatch dashboard',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(height: 24),

            // Order Quick Summary Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Customer: ${order.customerName} • ${order.address.formatted}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${order.totalItemCount} Items',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              isAr ? 'السائقين المتاحين في الأسطول (${drivers.length})' : 'Available Fleet Drivers (${drivers.length})',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const SizedBox(height: 8),

            // Driver list
            Expanded(
              child: ListView.builder(
                itemCount: drivers.length,
                itemBuilder: (ctx, i) {
                  final driver = drivers[i];
                  final isCurrentlyAssigned = order.assignedDriverId == driver.id;
                  final activeOrdersForDriver = stateService.getOrdersForDriver(driver.id)
                      .where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled)
                      .length;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCurrentlyAssigned ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrentlyAssigned ? AppColors.primary : const Color(0xFFE2E8F0),
                        width: isCurrentlyAssigned ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar & Status Dot
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                              child: Text(
                                driver.fullName.substring(0, 1),
                                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: driver.isOnline ? AppColors.success : AppColors.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Driver Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    driver.fullName,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star, size: 11, color: Color(0xFFD97706)),
                                        const SizedBox(width: 2),
                                        Text(
                                          driver.rating.toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${driver.phone} • ${driver.documents.vehicleRegPlate}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '$activeOrdersForDriver active missions',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: activeOrdersForDriver > 2 ? AppColors.warning : AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${driver.completedTrips} lifetime completed',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Assign Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCurrentlyAssigned ? AppColors.success : AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            stateService.assignDriverToOrder(order.id, driver);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🚀 Order #${order.orderNumber} assigned to ${driver.fullName}! Shifted to driver console.'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          icon: Icon(isCurrentlyAssigned ? Icons.check : Icons.send_rounded, size: 14),
                          label: Text(
                            isCurrentlyAssigned ? 'Reassign' : 'Assign Now',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
