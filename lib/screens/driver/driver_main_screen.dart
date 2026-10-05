import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/driver_navigation_helper.dart';
import '../../widgets/badge_pill.dart';
import 'driver_active_ride_screen.dart';
import 'driver_delivery_success_dialog.dart';
import 'driver_profile_tab.dart';
import '../customer/complaints_screen.dart';
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

    // Separate Pickups and Deliveries
    final pickupOrders = allOrders
        .where(
          (o) =>
              o.status == OrderStatus.placed ||
              o.status == OrderStatus.driverAssigned ||
              o.status == OrderStatus.pickedUp,
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
          children: [
            const Text(
              'Driver Dispatch Console',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                  _isOnline ? 'Online • GPS Broadcasting' : 'Offline',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Switch(
            value: _isOnline,
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
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
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Live Support & Customer Chat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
              );
            },
          ),
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
      body: TabBarView(
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
    );
  }

  Widget _buildOrdersList({
    required BuildContext context,
    required StateService state,
    required List<LaundryOrder> orders,
    required bool isDeliveryPage,
    required String emptyMessage,
  }) {
    if (orders.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isPickup = !isDeliveryPage;

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
                      '${order.totalAmount.toStringAsFixed(0)} QAR',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),

                // Customer info & Phone dialer
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
                          fontSize: 13,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => DriverNavigationHelper.callPhone(
                        context,
                        order.customerPhone,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
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
                            Icon(Icons.call, size: 13, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              'Call',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
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
                                : 'Awaiting Departure',
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
                const SizedBox(height: 10),

                // Action Buttons Row
                Row(
                  children: [
                    if (!order.isDriverRideStarted) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            state.startDriverRide(order.id);
                            if (isPickup &&
                                order.status == OrderStatus.placed) {
                              state.updateOrderStatus(
                                order.id,
                                OrderStatus.driverAssigned,
                              );
                            } else if (isDeliveryPage &&
                                order.status == OrderStatus.readyForDelivery) {
                              state.updateOrderStatus(
                                order.id,
                                OrderStatus.outForDelivery,
                              );
                            }
                            DriverNavigationHelper.showMapChoiceSheet(
                              context,
                              address: order.address.formatted,
                              title: isPickup
                                  ? 'Navigate to Customer Pickup'
                                  : 'Navigate to Delivery',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 9,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.navigation, size: 14),
                          label: const Text(
                            'Start (GPS)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Tooltip(
                        message: 'Open Waze / Google Maps',
                        child: OutlinedButton.icon(
                          icon: const Icon(
                            Icons.map_outlined,
                            color: AppColors.primary,
                            size: 15,
                          ),
                          label: const Text(
                            'GPS Maps',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 9,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () =>
                              DriverNavigationHelper.showMapChoiceSheet(
                                context,
                                address: order.address.formatted,
                                title: 'Live Navigation',
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    if (isDeliveryPage &&
                        order.status == OrderStatus.outForDelivery) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            state.updateOrderStatus(
                              order.id,
                              OrderStatus.delivered,
                            );
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (dialogCtx) =>
                                  DriverDeliverySuccessDialog(
                                    order: order,
                                    earnedBonusQar: 1.0,
                                    onBackToDashboard: () {
                                      Navigator.pop(dialogCtx);
                                    },
                                  ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 9,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Text(
                            '😊',
                            style: TextStyle(fontSize: 13),
                          ),
                          label: const Text(
                            'Delivered',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DriverActiveRideScreen(order: order),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 9,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.open_in_new, size: 14),
                        label: const Text(
                          'Mission',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
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
}
