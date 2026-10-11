import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/driver.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../services/localization_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badge_pill.dart';
import '../common/order_detail_dialog.dart';
import 'laundry_thermal_invoice_dialog.dart';

class LaundryDriversFleetTab extends StatelessWidget {
  const LaundryDriversFleetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final drivers = state.drivers;
    final isAr = state.currentLanguage == AppLanguage.ar;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sports_motorsports_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'سجل السائقين والطلبات المنفذة' : 'Driver Fleet Orders & Performance Record',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAr
                            ? 'متابعة عدد الطلبات لكل سائق، حالة الاتصال، وبدء الرحلات'
                            : 'Real-time order count per driver, trip tracking, completed missions & live pings',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${drivers.where((d) => d.isOnline).length} / ${drivers.length} Online',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Drivers Table / Cards List
          Expanded(
            child: ListView.builder(
              itemCount: drivers.length,
              itemBuilder: (ctx, idx) {
                final driver = drivers[idx];
                final driverOrders = state.getOrdersForDriver(driver.id);
                final completedCount = driverOrders.where((o) => o.status == OrderStatus.delivered).length;
                final activeCount = driverOrders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length;
                final totalEarned = driverOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Driver Avatar & Status Dot
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                            child: Text(
                              driver.fullName.substring(0, 1),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: driver.isOnline ? AppColors.success : AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Name, ID, Vehicle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  driver.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, size: 12, color: Color(0xFFD97706)),
                                      const SizedBox(width: 2),
                                      Text(
                                        driver.rating.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (driver.completedTrips >= 200)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('🌟 TOP RIDER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'ID: ${driver.userId} • Phone: ${driver.phone} • Vehicle: ${driver.documents.vehicleRegPlate}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 8),
                            // Counters row
                            Row(
                              children: [
                                _statPill('Assigned To Laundry', '${driverOrders.length} orders', const Color(0xFF0F172A)),
                                const SizedBox(width: 8),
                                _statPill('Active In Route', '$activeCount orders', activeCount > 0 ? AppColors.warning : AppColors.textMuted),
                                const SizedBox(width: 8),
                                _statPill('Completed Delivered', '$completedCount orders', AppColors.success),
                                const SizedBox(width: 8),
                                if (state.canViewPrice())
                                  _statPill('Delivered Value', state.formatCurrency(totalEarned), AppColors.primary)
                                else
                                  _statPill('Delivered Rate', '${driverOrders.isEmpty ? 100 : ((completedCount / driverOrders.length) * 100).toInt()}% Success', AppColors.primary),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Actions
                      Column(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            onPressed: () => _showDriverOrdersLedgerDialog(context, state, driver, driverOrders),
                            icon: const Icon(Icons.folder_shared_outlined, size: 16),
                            label: const Text('View All Orders', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🔔 Urgent Dispatch Alert sent to ${driver.fullName} (${driver.phone})!'),
                                  backgroundColor: AppColors.primaryDark,
                                ),
                              );
                            },
                            icon: const Icon(Icons.notifications_active_outlined, size: 14),
                            label: const Text('Alert Driver', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        '$title: $val',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }

  void _showDriverOrdersLedgerDialog(BuildContext context, StateService state, DriverModel driver, List<LaundryOrder> orders) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 680),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                        child: Text(driver.fullName.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Orders Handled by ${driver.fullName}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          Text('ID: ${driver.userId} • Phone: ${driver.phone} • Total: ${orders.length} orders recorded', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 20),

              Expanded(
                child: orders.isEmpty
                    ? const Center(child: Text('No orders assigned to this driver yet.'))
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (c, i) {
                          final o = orders[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: o.status.color.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(o.status.icon, color: o.status.color, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('Order #${o.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                          const SizedBox(width: 6),
                                          BadgePill(
                                            label: o.status.displayName,
                                            backgroundColor: o.status.color.withValues(alpha: 0.15),
                                            textColor: o.status.color,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text('${o.customerName} • ${o.address.city} • ${o.totalItemCount} items • ${dateFormat.format(o.createdAt)}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                if (state.canViewPrice())
                                  Text(state.formatCurrency(o.totalAmount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))
                                else
                                  Text('${o.totalItemCount} Items', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textMuted)),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 18),
                                  tooltip: 'View Order Details',
                                  onPressed: () => OrderDetailDialog.show(context, o),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.print_outlined, size: 18),
                                  tooltip: 'Print Invoice',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => LaundryThermalInvoiceDialog(order: o),
                                    );
                                  },
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
      ),
    );
  }
}
