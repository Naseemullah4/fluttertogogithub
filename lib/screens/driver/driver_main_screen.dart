import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/driver_navigation_helper.dart';
import '../../widgets/badge_pill.dart';
import 'driver_active_ride_screen.dart';
import 'driver_profile_tab.dart';
import 'driver_start_duty_screen.dart';
import 'driver_collection_workflow_screen.dart';
import 'driver_laundry_arrival_screen.dart';
import 'driver_delivery_loading_screen.dart';
import 'driver_delivery_workflow_screen.dart';
import 'driver_cancel_order_dialog.dart';
import '../customer/complaints_screen.dart';
import '../common/order_detail_dialog.dart';
import '../../widgets/uniwash_logo.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOnline = true;
  bool _isOnBreak = false;

  void _simulateWhatsAppMessage(BuildContext context, LaundryOrder order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chat, color: Color(0xFF16A34A), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WhatsApp Message • ${order.customerName}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      Text(
                        order.customerPhone,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Quick Driver Messages (1-Tap Send):',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 10),
              ...[
                '🚗 Salam! I am your UniWash driver. I am on my way and ~5 mins away.',
                '📦 Salam! I have arrived outside your building for Order #${order.orderNumber}.',
                '🚪 Salam! Your clean laundry has been safely hung at your door.',
                '⏳ Salam! Please confirm your building gate access or intercom code.',
              ].map(
                (msg) => ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  leading: const Icon(Icons.send_rounded, color: Color(0xFF16A34A), size: 18),
                  title: Text(msg, style: const TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text('💬 WhatsApp sent to ${order.customerName}: "$msg"')),
                          ],
                        ),
                        backgroundColor: const Color(0xFF16A34A),
                        duration: const Duration(seconds: 3),
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final allOrders = state.orders;

    // Separate Pickups and Deliveries (Only orders assigned to driver by Admin)
    final pickupOrders = allOrders
        .where(
          (o) =>
              o.assignedDriverId.isNotEmpty &&
              (o.status == OrderStatus.driverAssigned ||
               o.status == OrderStatus.pickedUp),
        )
        .toList();

    final deliveryOrders = allOrders
        .where(
          (o) =>
              o.status == OrderStatus.readyForDelivery ||
              o.status == OrderStatus.outForDelivery,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 46,
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Center(
            child: UniWashLogo.badge(size: 34),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Driver Console',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _isOnline ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isOnline ? 'Online • GPS' : 'Offline',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _isOnline,
              activeTrackColor: AppColors.primary,
              activeThumbColor: Colors.white,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) {
                setState(() => _isOnline = val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isOnline
                          ? '🟢 Fleet status set to ONLINE'
                          : '🔴 Fleet status set to OFFLINE',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'Support Chat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
              );
            },
          ),
          const SizedBox(width: 58),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: [
            Tab(
              icon: const Icon(Icons.inventory_2_outlined),
              text: 'Pickups (${pickupOrders.length})',
            ),
            Tab(
              icon: const Icon(Icons.local_shipping_outlined),
              text: 'Deliveries (${deliveryOrders.length})',
            ),
            const Tab(
              icon: Icon(Icons.person_outline),
              text: 'Profile & Bonus',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDutyStatusBanner(context, state),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Pickups Queue (Collect from Customer -> Take to Laundry)
                _buildOrdersList(
                  context: context,
                  state: state,
                  orders: pickupOrders,
                  isDeliveryPage: false,
                  emptyMessage: 'No pickup missions pending at this moment.',
                ),

                // Tab 2: Deliveries Queue (Pick from Laundry -> Deliver to Customer)
                _buildOrdersList(
                  context: context,
                  state: state,
                  orders: deliveryOrders,
                  isDeliveryPage: true,
                  emptyMessage: 'No delivery orders ready from laundry right now.',
                ),

                // Tab 3: Profile & Stats
                const DriverProfileTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDutyStatusBanner(BuildContext context, StateService state) {
    final isOnDuty = state.isDriverOnDuty;
    final session = state.currentDutySession;

    if (!isOnDuty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.badge_outlined,
                color: AppColors.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Duty Shift Not Started',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '5 inspection photos & supplies check required before taking missions.',
                    style: TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DriverStartDutyScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Start Duty',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    if (_isOnBreak) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          children: [
            const Text('☕', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Shift Paused • On Rest Break (Timer active)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: Color(0xFF92400E)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _isOnBreak = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🟢 Welcome back! Driver shift resumed.'),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Resume Duty', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '🟢 On Duty • ${session?.startedAt != null ? "Started at ${DateFormat('hh:mm a').format(session!.startedAt)}" : "Active Shift"} • Verified: 20 Bags & 100 Tags',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: Colors.green.shade900,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() => _isOnBreak = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('☕ Break started. Driver missions temporarily paused.'),
                  backgroundColor: Color(0xFFB45309),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: const Text('☕ Break', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
            ),
          ),
          const SizedBox(width: 6),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DriverStartDutyScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text(
              'View Duty',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList({
    required BuildContext context,
    required StateService state,
    required List<LaundryOrder> orders,
    required bool isDeliveryPage,
    required String emptyMessage,
  }) {
    final isPickup = !isDeliveryPage;
    final pickedUpOrders = orders.where((o) => o.status == OrderStatus.pickedUp).toList();
    final readyOrders = orders.where((o) => o.status == OrderStatus.readyForDelivery).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Batch Action Banner for Pickups: Orders in van ready for laundry facility intake
        if (isPickup && pickedUpOrders.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${pickedUpOrders.length} Order(s) Collected in Van',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Scan all orders & take laundry intake photo to dispatch.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF3B82F6)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DriverLaundryArrivalScreen(orders: pickedUpOrders),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner, size: 14),
                  label: const Text(
                    'Handover',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Batch Action Banner for Deliveries: Ready orders at laundry waiting for van loading
        if (isDeliveryPage && readyOrders.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: AppColors.success,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${readyOrders.length} Order(s) Ready for Van Loading',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF14532D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Scan bundles into van & take 3 photos to begin deliveries.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DriverDeliveryLoadingScreen(orders: readyOrders),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_shipping, size: 14),
                  label: const Text(
                    'Load Van',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusDelivery,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ],

        if (orders.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDeliveryPage
                        ? Icons.delivery_dining_outlined
                        : Icons.inventory_2_outlined,
                    size: 54,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    emptyMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...orders.map((order) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: order.driverPingCount > 0
                      ? Colors.red.shade300
                      : AppColors.border,
                  width: order.driverPingCount > 0 ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => OrderDetailDialog.show(context, order),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Order #, Tag, and Total Amount
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    '#${order.orderNumber}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (order.isUrgent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDC2626),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.bolt, color: Colors.white, size: 11),
                                          SizedBox(width: 2),
                                          Text(
                                            '🚨 URGENT RUSH',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPickup
                                          ? Colors.blue.shade50
                                          : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isPickup
                                            ? Colors.blue.shade300
                                            : Colors.green.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      isPickup ? '📦 PICKUP' : '🚚 DELIVERY',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: isPickup
                                            ? Colors.blue.shade800
                                            : Colors.green.shade800,
                                      ),
                                    ),
                                  ),
                                  BadgePill(
                                    label: order.status.displayName,
                                    backgroundColor: order.status.color.withValues(
                                      alpha: 0.15,
                                    ),
                                    textColor: order.status.color,
                                    icon: order.status.icon,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.canViewPrice()
                                  ? '${order.totalAmount.toStringAsFixed(0)} QAR'
                                  : '${order.totalItemCount} Items',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18),

                        // Customer info & Contact actions (Call & WhatsApp)
                        Row(
                          children: [
                            const Icon(
                              Icons.person_pin,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${order.customerName} (${order.customerPhone})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            InkWell(
                              onTap: () => DriverNavigationHelper.callPhone(
                                context,
                                order.customerPhone,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.call, size: 12, color: Colors.green),
                                    SizedBox(width: 3),
                                    Text(
                                      'Call',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () => _simulateWhatsAppMessage(context, order),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFA5D6A7)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.chat, size: 12, color: Color(0xFF2E7D32)),
                                    SizedBox(width: 3),
                                    Text(
                                      'Chat',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Destination Address
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isPickup
                                  ? Icons.location_on_outlined
                                  : Icons.home_work_outlined,
                              size: 16,
                              color: isPickup ? AppColors.primary : Colors.teal,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${isPickup ? "Customer Pickup" : "Delivery Destination"}: ${order.address.formatted}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Laundry branch reference
                        Row(
                          children: [
                            const Icon(
                              Icons.storefront_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Laundry Branch: ${order.laundryName}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Urgent Laundry Ping Notice Banner
                        if (order.driverPingCount > 0) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.notification_important,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'URGENT: Laundry pinged you (${order.driverPingCount}x) to depart immediately!',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),

                        // Status line: Items count & Ride Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${order.totalItemCount} Items • Pay: ${order.paymentMethod.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textLight,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: order.isDriverRideStarted
                                    ? Colors.green.shade50
                                    : Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: order.isDriverRideStarted
                                      ? Colors.green.shade300
                                      : Colors.amber.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    order.isDriverRideStarted
                                        ? Icons.check_circle
                                        : Icons.timer,
                                    size: 13,
                                    color: order.isDriverRideStarted
                                        ? Colors.green.shade800
                                        : Colors.amber.shade900,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.isDriverRideStarted
                                        ? 'Ride Active'
                                        : 'Awaiting Action',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: order.isDriverRideStarted
                                        ? Colors.green.shade800
                                        : Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Action Buttons Row with Direct Workflow Integration
                        Row(
                          children: [
                            // Main Workflow Action Button
                            if (isPickup &&
                                order.status == OrderStatus.driverAssigned) ...[
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DriverCollectionWorkflowScreen(
                                          order: order,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.qr_code_scanner, size: 15),
                                  label: const Text(
                                    'Collect (4 Steps)',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ] else if (isPickup &&
                                order.status == OrderStatus.pickedUp) ...[
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DriverLaundryArrivalScreen(
                                          orders: [order],
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.statusLaundry,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.local_laundry_service,
                                    size: 15,
                                  ),
                                  label: const Text(
                                    'Handover Laundry',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ] else if (isDeliveryPage &&
                                order.status == OrderStatus.readyForDelivery) ...[
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DriverDeliveryLoadingScreen(
                                          orders: [order],
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.statusDelivery,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.local_shipping,
                                    size: 15,
                                  ),
                                  label: const Text(
                                    'Load Van (4 Steps)',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ] else if (isDeliveryPage &&
                                order.status == OrderStatus.outForDelivery) ...[
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DriverDeliveryWorkflowScreen(
                                          order: order,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Text('😊', style: TextStyle(fontSize: 14)),
                                  label: const Text(
                                    'Deliver (5 Steps)',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],

                            // GPS Maps Button
                            OutlinedButton.icon(
                              icon: const Icon(
                                Icons.map_outlined,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              label: const Text(
                                'GPS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () =>
                                  DriverNavigationHelper.showMapChoiceSheet(
                                context,
                                address: order.address.formatted,
                                title: isPickup
                                    ? 'Navigate to Pickup'
                                    : 'Navigate to Delivery',
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Cancel Order Button
                            OutlinedButton.icon(
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: AppColors.error,
                                size: 14,
                              ),
                              label: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                side: BorderSide(
                                  color: Colors.red.shade200,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => DriverCancelOrderDialog.show(
                                context,
                                order,
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Mission Details Screen launcher
                            IconButton(
                              icon: const Icon(Icons.open_in_new, size: 16),
                              tooltip: 'Open Ride Simulation',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DriverActiveRideScreen(order: order),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
