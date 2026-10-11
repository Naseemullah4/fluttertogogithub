import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../services/localization_service.dart';
import '../../theme/app_colors.dart';

class AdminAssignDriverDialog extends StatelessWidget {
  final LaundryOrder order;

  const AdminAssignDriverDialog({super.key, required this.order});

  static void show(BuildContext context, LaundryOrder order) {
    showDialog(
      context: context,
      builder: (_) => AdminAssignDriverDialog(order: order),
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
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Dispatch Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'إدارة التعيين: تعيين سائق #${order.orderNumber}' : 'Admin Dispatch • #${order.orderNumber}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isAr
                            ? 'الطلب وصل مباشرة إلى الإدارة - حدد السائق لنقله للسائق'
                            : 'Direct Admin routing • Select driver to dispatch mission',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  splashRadius: 20,
                  onPressed: () => Navigator.pop(context),
                ),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_pin_circle_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Customer: ${order.customerName} (${order.customerPhone})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: order.status.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.status.displayName,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: order.status.color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.address.formatted,
                          style: const TextStyle(fontSize: 11, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${order.totalItemCount} Items • ${stateService.formatCurrency(order.totalAmount)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'أسطول السائقين المتاحين (${drivers.length})' : 'Available Fleet Drivers (${drivers.length})',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                Text(
                  isAr ? 'التعيين بواسطة الإدارة حصراً' : 'Dispatched strictly by Admin',
                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
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
                                driver.fullName.isNotEmpty ? driver.fullName.substring(0, 1) : 'D',
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

                        // Admin Assign Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCurrentlyAssigned ? AppColors.success : const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            stateService.assignDriverToOrder(order.id, driver);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🚀 Admin assigned Order #${order.orderNumber} to ${driver.fullName}! Dispatched to driver app.'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          icon: Icon(isCurrentlyAssigned ? Icons.check : Icons.send_rounded, size: 14),
                          label: Text(
                            isCurrentlyAssigned ? (isAr ? 'معين مسبقاً' : 'Reassign') : (isAr ? 'تعيين السائق' : 'Assign Driver'),
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
