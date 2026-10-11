import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../models/catalog_item.dart';
import '../../services/localization_service.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/super_search_bar.dart';
import '../common/order_detail_dialog.dart';
import 'laundry_item_verification_dialog.dart';
import 'laundry_thermal_invoice_dialog.dart';
import 'laundry_analytics_tab.dart';
import 'laundry_driver_onboard_dialog.dart';
import 'laundry_attachments_dialog.dart';
import 'laundry_drivers_fleet_tab.dart';
import '../customer/complaints_screen.dart';
import '../../widgets/uniwash_logo.dart';
import '../../widgets/bulk_qr_generator_dialog.dart';

class LaundryMainScreen extends StatefulWidget {
  const LaundryMainScreen({super.key});

  @override
  State<LaundryMainScreen> createState() => _LaundryMainScreenState();
}

class _LaundryMainScreenState extends State<LaundryMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _archiveSearchQuery = '';
  OrderStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = state.currentLanguage == AppLanguage.ar;
    final activeOrders = state.orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const UniWashLogo.badge(size: 38),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'بوابة إدارة المصبغة والمغسلة' : 'UniWash Laundry Web Portal 💻',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                ),
                Text(
                  'Pearl & Marina Branch (ID: LND-DOH-01) • ${state.selectedCountry.flag} ${state.selectedCountry.currencyCode}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Google Omnibar Super Search in AppBar
          Container(
            width: 380,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SuperSearchBar(
              hintText: isAr ? 'بحث الطلبات: رقم الطلب، الهاتف، العميل...' : 'Search orders: #, Mobile, Customer...',
              onOrderSelected: (order) => OrderDetailDialog.show(context, order),
            ),
          ),
          // Bulk QR Generator & Thermal Tag Printing Tool
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.qr_code_2_rounded, size: 16),
            label: Text(
              isAr ? 'طباعة الباركود والـ QR' : 'Bulk QR Generator 🏷️',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            onPressed: () => BulkQrGeneratorDialog.show(context),
          ),
          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.primary),
            tooltip: 'Onboard New Driver',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => LaundryDriverOnboardDialog(
                  onSubmit: (data) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('📄 Driver Application for ${data['name']} submitted to Regional Admin!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined, color: Color(0xFF475569)),
            tooltip: 'Support Desk',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
              );
            },
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            icon: const Icon(Icons.language, size: 15),
            label: Text(isAr ? 'English' : 'العربية', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
            onPressed: () => state.toggleLanguage(),
          ),
          const SizedBox(width: 14),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabs: [
            Tab(icon: const Icon(Icons.local_laundry_service), text: isAr ? 'الطلبات النشطة (${activeOrders.length})' : 'Active Orders Queue (${activeOrders.length})'),
            Tab(icon: const Icon(Icons.history_edu_rounded), text: isAr ? 'سجل الطلبات الدائم (${state.orders.length})' : 'Lifetime Order Archive (${state.orders.length})'),
            Tab(icon: const Icon(Icons.sports_motorsports_rounded), text: isAr ? 'سجل السائقين والطلبات (${state.drivers.length})' : 'Driver Fleet & Order Records (${state.drivers.length})'),
            Tab(icon: const Icon(Icons.analytics_outlined), text: isAr ? 'التقارير والأرباح' : 'Financials & Periodic Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Active Processing Orders Queue
          _buildActiveOrdersQueue(context, state, activeOrders),

          // TAB 2: Full Lifetime Order Archive & Search (Forever retained, searchable, printable)
          _buildLifetimeArchiveTab(context, state),

          // TAB 3: Driver Fleet Orders & Real-time Record
          const LaundryDriversFleetTab(),

          // TAB 4: Financial Analytics & Periodic Reports
          const LaundryAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersQueue(BuildContext context, StateService state, List<LaundryOrder> activeOrders) {
    final isAr = state.currentLanguage == AppLanguage.ar;

    if (activeOrders.isEmpty) {
      return const Center(child: Text('No active orders currently awaiting processing.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: activeOrders.length,
      itemBuilder: (context, index) {
        final order = activeOrders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Order #${order.orderNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 8),
                        BadgePill(
                          label: order.status.displayName,
                          backgroundColor: order.status.color.withValues(alpha: 0.15),
                          textColor: order.status.color,
                          icon: order.status.icon,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (!order.isAcceptedByLaundry) ...[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.check_circle_outline, size: 16),
                            label: Text(isAr ? 'قبول الطلب' : 'Accept Order', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                            onPressed: () {
                              state.acceptOrder(order.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✅ Order #${order.orderNumber} Accepted by Laundry!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, size: 13, color: Color(0xFF15803D)),
                                const SizedBox(width: 4),
                                Text(
                                  isAr ? 'تم قبول الطلب' : 'Accepted by Laundry',
                                  style: const TextStyle(color: Color(0xFF15803D), fontSize: 10, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => OrderDetailDialog.show(context, order),
                          icon: const Icon(Icons.visibility_outlined, size: 14),
                          label: const Text('View Record', style: TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.print_rounded, size: 14),
                          label: const Text('Print ESC/POS', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => LaundryThermalInvoiceDialog(order: order),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer: ${order.customerName} (${order.customerPhone})',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    if (state.canViewPrice())
                      Text(
                        state.formatCurrency(order.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          '${order.totalItemCount} Items • ${order.paymentMethod.toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF0F172A)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Address: ${order.address.formatted}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 10),

                // Driver Dispatch, Ride Status & Ping Nudge Console Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: order.assignedDriverId.isEmpty ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: order.assignedDriverId.isEmpty ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: order.assignedDriverId.isEmpty ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.sports_motorsports_rounded,
                          color: order.assignedDriverId.isEmpty ? AppColors.error : AppColors.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  order.assignedDriverId.isEmpty
                                      ? (isAr ? 'السائق: غير معين (بانتظار تعيين الإدارة)' : 'Driver: Awaiting Admin Assignment')
                                      : '${isAr ? "السائق المعين (من الإدارة)" : "Assigned Driver (Dispatched by Admin)"}: ${order.assignedDriverName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: order.assignedDriverId.isEmpty ? AppColors.error : const Color(0xFF14532D),
                                  ),
                                ),
                                if (order.assignedDriverPhone.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '(${order.assignedDriverPhone})',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            // Driver Ride Started or Waiting Indicator
                            if (order.assignedDriverId.isNotEmpty) ...[
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: (order.isDriverRideStarted || order.status == OrderStatus.pickedUp || order.status == OrderStatus.outForDelivery)
                                          ? AppColors.success
                                          : const Color(0xFFD97706),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    (order.isDriverRideStarted || order.status == OrderStatus.pickedUp || order.status == OrderStatus.outForDelivery)
                                        ? (isAr ? 'بدأ السائق الرحلة • جارِ التوصيل' : '🚀 Driver Started Ride • En-Route')
                                        : (isAr ? 'لم يبدأ السائق الرحلة بعد (في الانتظار)' : '⏳ Driver Has NOT Started Ride Yet (Waiting)'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: (order.isDriverRideStarted || order.status == OrderStatus.pickedUp || order.status == OrderStatus.outForDelivery)
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFFB45309),
                                    ),
                                  ),
                                  if (order.driverPingCount > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '🔔 Pinged ${order.driverPingCount}x',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFB91C1C)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ] else ...[
                              Text(
                                isAr ? 'يتم تعيين السائق مباشرة بواسطة إدارة المنصة وليس المصبغة' : 'Driver assignment is handled directly by Platform Admin, not Laundry.',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Urgent Ping Button (if driver assigned)
                      if (order.assignedDriverId.isNotEmpty) ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEF3C7),
                            foregroundColor: const Color(0xFF92400E),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFFDE68A)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            state.pingDriver(order.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.notifications_active, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text('🔔 Urgent Nudge sent to ${order.assignedDriverName}! (Ping #${order.driverPingCount})'),
                                  ],
                                ),
                                backgroundColor: const Color(0xFFB45309),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_active_outlined, size: 14),
                          label: Text(
                            isAr ? 'تنبيه السائق' : 'Urgent Ping',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            isAr ? 'الإدارة تُعيّن' : 'Admin Assigns',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Requirement Documents & Photos Bar
                InkWell(
                  onTap: () => LaundryAttachmentsDialog.show(context, order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.attach_file_rounded, size: 16, color: Color(0xFF2563EB)),
                            const SizedBox(width: 6),
                            Text(
                              '${order.attachments.length} ${isAr ? "مرفقات وصور ومستندات (JPG / PDF)" : "Requirement Documents & Photos (JPG / PDF)"}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Open & Upload Files',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, size: 11, color: Color(0xFF2563EB)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Itemized Garment List Preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Garments (${order.totalItemCount} items)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                          if (order.isCountVerifiedByLaundry)
                            const Text('✅ Verified by Laundry', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w800))
                          else
                            const Text('⚠️ Pending Count Verification', style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: order.items.map((item) {
                          final qty = item.verifiedQuantity ?? item.quantity;
                          return Chip(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            visualDensity: VisualDensity.compact,
                            label: Text('${item.catalogItem.icon} ${item.catalogItem.itemName} (${item.serviceType.displayName}) x$qty ${item.catalogItem.pricingUnit.unitName}'),
                            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Interactive Action Buttons
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => LaundryItemVerificationDialog(
                            order: order,
                            stateService: state,
                          ),
                        );
                      },
                      icon: const Icon(Icons.fact_check_outlined, size: 16),
                      label: const Text('Item Verification Counter'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: order.status == OrderStatus.readyForDelivery ? AppColors.success : AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showStatusAdvanceMenu(context, state, order),
                        icon: const Icon(Icons.sync_alt, size: 16),
                        label: Text(
                          order.status == OrderStatus.readyForDelivery ? 'Status: Ready for Delivery' : 'Advance Processing Status',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 2: Lifetime Order Records Archive
  Widget _buildLifetimeArchiveTab(BuildContext context, StateService state) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    // Filter orders by search query and optional status
    final filtered = state.orders.where((order) {
      if (_selectedStatusFilter != null && order.status != _selectedStatusFilter) {
        return false;
      }
      if (_archiveSearchQuery.trim().isEmpty) return true;
      final q = _archiveSearchQuery.trim().toLowerCase();
      return order.orderNumber.toString().contains(q) ||
          order.customerName.toLowerCase().contains(q) ||
          order.customerPhone.contains(q) ||
          order.assignedDriverName.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search archive by order #, phone, customer...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (val) => setState(() => _archiveSearchQuery = val),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<OrderStatus?>(
                value: _selectedStatusFilter,
                hint: const Text('Filter by Status'),
                onChanged: (s) => setState(() => _selectedStatusFilter = s),
                items: [
                  const DropdownMenuItem<OrderStatus?>(value: null, child: Text('All Statuses (Lifetime)')),
                  ...OrderStatus.values.map((st) {
                    return DropdownMenuItem<OrderStatus?>(
                      value: st,
                      child: Text(st.displayName, style: TextStyle(color: st.color, fontWeight: FontWeight.w700, fontSize: 12)),
                    );
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Total Count
          Text(
            'Showing ${filtered.length} permanently archived orders (100% lifetime record retained)',
            style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          // List
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No orders found matching search criteria.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: order.status.color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(order.status.icon, color: order.status.color, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: order.status.color.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          order.status.displayName,
                                          style: TextStyle(color: order.status.color, fontWeight: FontWeight.w700, fontSize: 10),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(dateFormat.format(order.createdAt), style: const TextStyle(fontSize: 11, color: Colors.black45)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Customer: ${order.customerName} (${order.customerPhone}) • Driver: ${order.assignedDriverName}',
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Address: ${order.address.formatted} • Items: ${order.items.length}',
                                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (state.canViewPrice())
                                  Text(
                                    state.formatCurrency(order.totalAmount),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${order.totalItemCount} Garments',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF0F172A)),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F172A),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => OrderDetailDialog.show(context, order),
                                      icon: const Icon(Icons.visibility_outlined, size: 14),
                                      label: const Text('View Record', style: TextStyle(fontSize: 11)),
                                    ),
                                    const SizedBox(width: 6),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => LaundryThermalInvoiceDialog(order: order),
                                        );
                                      },
                                      icon: const Icon(Icons.print_rounded, size: 14),
                                      label: const Text('Print', style: TextStyle(fontSize: 11)),
                                    ),
                                  ],
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

  void _showStatusAdvanceMenu(BuildContext context, StateService state, LaundryOrder order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advance Laundry Processing Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Text(
              'Real-time change will be broadcast instantaneously across customer, driver, and admin portals.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.local_laundry_service, color: AppColors.statusProcessing),
              title: const Text('In Washing / Dry Cleaning / Pressing', style: TextStyle(fontWeight: FontWeight.w700)),
              trailing: order.status == OrderStatus.inLaundry ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                state.updateOrderStatus(order.id, OrderStatus.inLaundry);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: AppColors.statusReady),
              title: const Text('Mark Order as Ready for Delivery', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Sends instant pickup notification to delivery driver & customer'),
              trailing: order.status == OrderStatus.readyForDelivery ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                state.updateOrderStatus(order.id, OrderStatus.readyForDelivery);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔔 Delivery driver alerted! Order is ready for pickup.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
