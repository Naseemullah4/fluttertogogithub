import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/stat_card.dart';
import '../common/order_detail_dialog.dart';

class SuperAdminLiveOrdersTab extends StatefulWidget {
  final bool isAr;

  const SuperAdminLiveOrdersTab({super.key, this.isAr = false});

  @override
  State<SuperAdminLiveOrdersTab> createState() => _SuperAdminLiveOrdersTabState();
}

class _SuperAdminLiveOrdersTabState extends State<SuperAdminLiveOrdersTab> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = widget.isAr;
    final allOrders = state.orders;

    // Filter calculations
    final liveOrders = allOrders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList();
    final inCollection = allOrders.where((o) => o.status == OrderStatus.driverAssigned || o.status == OrderStatus.pickedUp).length;
    final inLaundry = allOrders.where((o) => o.status == OrderStatus.inLaundry || o.status == OrderStatus.readyForDelivery).length;
    final inDelivery = allOrders.where((o) => o.status == OrderStatus.outForDelivery).length;

    final filtered = allOrders.where((o) {
      if (_statusFilter == 'live' && (o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled)) return false;
      if (_statusFilter == 'placed' && o.status != OrderStatus.placed) return false;
      if (_statusFilter == 'in_transit' && o.status != OrderStatus.driverAssigned && o.status != OrderStatus.pickedUp) return false;
      if (_statusFilter == 'laundry' && o.status != OrderStatus.inLaundry && o.status != OrderStatus.readyForDelivery) return false;
      if (_statusFilter == 'delivery' && o.status != OrderStatus.outForDelivery) return false;
      if (_statusFilter == 'delivered' && o.status != OrderStatus.delivered) return false;

      if (_searchQuery.isEmpty) return true;
      return o.orderNumber.toString().contains(_searchQuery) ||
          o.customerName.toLowerCase().contains(_searchQuery) ||
          o.customerPhone.contains(_searchQuery) ||
          o.assignedDriverName.toLowerCase().contains(_searchQuery) ||
          o.laundryName.toLowerCase().contains(_searchQuery) ||
          o.address.city.toLowerCase().contains(_searchQuery);
    }).toList();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Header & Real-time Metrics
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? 'مراقبة الطلبات الحية والمسار الكامل' : 'Live Order Tracking & Stage Pipeline',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr
                            ? 'تتبع حي لكل مرحلة: إنشاء الطلب ← إسناد السائق ← مسح QR ← الغسيل ← التوصيل'
                            : 'Real-time lifecycle monitoring: Order Created → QR Verified → Laundry Processing → Doorstep Delivery',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.radar_rounded, size: 16, color: Color(0xFF059669)),
                              const SizedBox(width: 6),
                              Text(
                                '${liveOrders.length} Orders In-Flight',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'جديد بانتظار السائق' : 'Pending Intake',
                        value: '${allOrders.where((o) => o.status == OrderStatus.placed).length}',
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'قيد الاستلام والتوصيل' : 'In Courier Transit',
                        value: '$inCollection',
                        icon: Icons.electric_moped_rounded,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'داخل المصابغ' : 'In Laundry Facility',
                        value: '$inLaundry',
                        icon: Icons.local_laundry_service_rounded,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'خرج للتسليم للعميل' : 'Out for Delivery',
                        value: '$inDelivery',
                        icon: Icons.delivery_dining_rounded,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search & Stage Filter Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                          decoration: InputDecoration(
                            hintText: isAr ? 'بحث بالرقم، العميل، الهاتف، السائق، المصبعة...' : 'Search Order #, customer, driver, laundry...',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Wrap(
                      spacing: 6,
                      children: [
                        _statusFilterButton('All (${allOrders.length})', 'all'),
                        _statusFilterButton('Live (${liveOrders.length})', 'live'),
                        _statusFilterButton('Courier Transit ($inCollection)', 'in_transit'),
                        _statusFilterButton('In Laundry ($inLaundry)', 'laundry'),
                        _statusFilterButton('Out for Delivery ($inDelivery)', 'delivery'),
                        _statusFilterButton('Delivered', 'delivered'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Orders Feed
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inbox_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(isAr ? 'لا توجد طلبات مطابقة' : 'No orders found matching filter criteria', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final order = filtered[idx];
                      return _buildOrderTrackingCard(context, state, order);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTrackingCard(BuildContext context, StateService state, LaundryOrder order) {
    final dateFormat = DateFormat('MMM dd, hh:mm a');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Order Number, Customer, Status, Created time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${order.orderNumber}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                    if (order.isUrgent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '🚨 URGENT RUSH',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                    const SizedBox(width: 10),
                    Text(
                      order.customerName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.customerPhone,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${order.address.city} • ${order.items.length} items',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    BadgePill(
                      label: order.status.displayName,
                      color: order.status.color,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
                      tooltip: 'View Full Order File',
                      onPressed: () => OrderDetailDialog.show(context, order),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Visual Stage Progress Stepper
            _buildVisualStageStepper(order),
            const SizedBox(height: 12),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Operational Metadata Strip: Driver, Laundry, QR Status, Proofs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Driver
                    Row(
                      children: [
                        const Icon(Icons.sports_motorsports_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Driver: ${order.assignedDriverName.isEmpty ? "Unassigned" : order.assignedDriverName}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: order.assignedDriverName.isEmpty ? AppColors.error : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Laundry
                    Row(
                      children: [
                        const Icon(Icons.local_laundry_service_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Facility: ${order.laundryName}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // QR Status Badge
                    Row(
                      children: [
                        Icon(
                          order.collectionQrScanned ? Icons.qr_code_scanner_rounded : Icons.qr_code_2_rounded,
                          size: 14,
                          color: order.collectionQrScanned ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.collectionQrScanned ? 'Pickup QR: Scanned' : 'Pickup QR: Pending',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: order.collectionQrScanned ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Proof Photo Status
                    Row(
                      children: [
                        Icon(
                          order.collectionProofPhoto != null ? Icons.photo_camera_rounded : Icons.camera_alt_outlined,
                          size: 14,
                          color: order.collectionProofPhoto != null ? const Color(0xFF16A34A) : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.collectionProofPhoto != null ? 'Proof: Uploaded' : 'Proof: None',
                          style: TextStyle(
                            fontSize: 11,
                            color: order.collectionProofPhoto != null ? const Color(0xFF16A34A) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Text(
                  'Created: ${dateFormat.format(order.createdAt)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualStageStepper(LaundryOrder order) {
    final stages = [
      {'title': 'Placed', 'done': true},
      {'title': 'Driver Assigned', 'done': order.assignedDriverId.isNotEmpty},
      {'title': 'Collected', 'done': order.status.stepIndex >= 2},
      {'title': 'In Laundry', 'done': order.status.stepIndex >= 3},
      {'title': 'Ready', 'done': order.status.stepIndex >= 4},
      {'title': 'Out for Delivery', 'done': order.status.stepIndex >= 5},
      {'title': 'Delivered', 'done': order.status == OrderStatus.delivered},
    ];

    return Row(
      children: List.generate(stages.length * 2 - 1, (i) {
        if (i.isOdd) {
          final prevDone = stages[i ~/ 2]['done'] as bool;
          return Expanded(
            child: Container(
              height: 3,
              color: prevDone ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
            ),
          );
        }

        final stage = stages[i ~/ 2];
        final isDone = stage['done'] as bool;
        return Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF16A34A) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              stage['title'] as String,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                color: isDone ? const Color(0xFF0F172A) : AppColors.textMuted,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _statusFilterButton(String label, String value) {
    final isSelected = _statusFilter == value;
    return InkWell(
      onTap: () => setState(() => _statusFilter = value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}
