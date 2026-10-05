import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/driver_navigation_helper.dart';
import 'driver_delivery_success_dialog.dart';
import 'driver_qr_scanner_dialog.dart';
import 'driver_report_issue_dialog.dart';
import '../customer/complaints_screen.dart';
import '../../widgets/uniwash_logo.dart';

class DriverActiveRideScreen extends StatefulWidget {
  final LaundryOrder order;

  const DriverActiveRideScreen({super.key, required this.order});

  @override
  State<DriverActiveRideScreen> createState() => _DriverActiveRideScreenState();
}

class _DriverActiveRideScreenState extends State<DriverActiveRideScreen> {
  bool _hasReached = false;
  final bool _isGpsBroadcasting = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final order = state.orders.firstWhere((o) => o.id == widget.order.id, orElse: () => widget.order);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const UniWashLogo.badge(size: 26),
            const SizedBox(width: 8),
            Text('Active Mission #${order.orderNumber}'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem_outlined, color: AppColors.error),
            tooltip: 'Report Issue / Breakdown',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => DriverReportIssueDialog(
                  onSubmit: (type, title, desc, attachment) {
                    state.submitTicket(
                      type: type,
                      title: title,
                      description: desc,
                      attachmentName: attachment,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚠️ Incident logged with regional dispatch.'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Chat with Customer / Support',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Map Simulation View
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFFE2E8F0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.navigation, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Turn-by-turn Navigation Simulation',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Destination: ${order.address.formatted}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                // GPS transmission indicator
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isGpsBroadcasting ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isGpsBroadcasting ? 'GPS Live Transmission: Active' : 'GPS Offline',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                // External GPS Navigation Launchers (Google Maps & Waze)
                Positioned(
                  bottom: 14,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => DriverNavigationHelper.openGoogleMaps(context, order.address.formatted),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1E293B),
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                          ),
                          icon: const Icon(Icons.map, color: Colors.blue, size: 18),
                          label: const Text('Google Maps', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => DriverNavigationHelper.openWaze(context, order.address.formatted),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1E293B),
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                          ),
                          icon: const Icon(Icons.directions_car, color: Colors.cyan, size: 18),
                          label: const Text('Waze Navigation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Driver Action Console
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              order.customerPhone,
                              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              icon: const Icon(Icons.call, color: AppColors.success),
                              tooltip: 'Call Customer',
                              onPressed: () => DriverNavigationHelper.callPhone(context, order.customerPhone),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              icon: const Icon(Icons.message, color: AppColors.primary),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Current Phase
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: order.status.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.status.displayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: order.status.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${order.totalItemCount} Garment Items',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pickup Address: ${order.address.formatted}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                    ),
                    if (order.specialInstructions.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Instructions: "${order.specialInstructions}"',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.primary),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Contextual Action Button based on flow state
                    _buildDriverActionButtons(context, state, order),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverActionButtons(BuildContext context, StateService state, LaundryOrder order) {
    if (order.status == OrderStatus.placed) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            state.startDriverRide(order.id);
            state.updateOrderStatus(order.id, OrderStatus.driverAssigned);
            DriverNavigationHelper.showMapChoiceSheet(
              context,
              address: order.address.formatted,
              title: 'Navigate to Customer Pickup Address',
            );
          },
          icon: const Icon(Icons.navigation),
          label: const Text('Start Ride to Customer (Open GPS)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      );
    }

    if (order.status == OrderStatus.driverAssigned) {
      if (!_hasReached) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                onPressed: () {
                  setState(() => _hasReached = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📍 Arrived at customer location! You can now call customer to announce arrival.')),
                  );
                },
                icon: const Icon(Icons.location_on),
                label: const Text('I Have Reached Customer Location', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => DriverNavigationHelper.showMapChoiceSheet(
                  context,
                  address: order.address.formatted,
                  title: 'Navigate to Customer',
                ),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open Waze / Google Maps Navigation'),
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => DriverNavigationHelper.callPhone(context, order.customerPhone),
                icon: const Icon(Icons.call, color: AppColors.success),
                label: Text('Call Customer to Announce Arrival (${order.customerPhone})', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DriverQrScannerDialog(
                      order: order,
                      onVerified: () {
                        state.updateOrderStatus(order.id, OrderStatus.pickedUp);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Garments collected and QR verified! Now dispatching to laundry.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Verify QR & Collect Order', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      }
    }

    if (order.status == OrderStatus.pickedUp) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusLaundry),
          onPressed: () {
            state.updateOrderStatus(order.id, OrderStatus.inLaundry);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🏢 Order Dispatched to Laundry facility! Awaiting staff count verification.'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          icon: const Icon(Icons.local_laundry_service),
          label: const Text('Order Dispatched to Laundry', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      );
    }

    if (order.status == OrderStatus.inLaundry) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: const [
            Icon(Icons.hourglass_top, color: AppColors.warning),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Laundry facility is currently washing, dry cleaning & pressing this order. You will receive an alert once marked Ready.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    if (order.status == OrderStatus.readyForDelivery) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDelivery),
          onPressed: () {
            state.startDriverRide(order.id);
            state.updateOrderStatus(order.id, OrderStatus.outForDelivery);
            DriverNavigationHelper.showMapChoiceSheet(
              context,
              address: order.address.formatted,
              title: 'Navigate to Delivery Address',
            );
          },
          icon: const Icon(Icons.delivery_dining),
          label: const Text('Start Delivery Ride to Customer (Open GPS)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      );
    }

    if (order.status == OrderStatus.outForDelivery) {
      if (!_hasReached) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDelivery),
                onPressed: () {
                  setState(() => _hasReached = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📍 Reached delivery destination! Please call customer to confirm handover.')),
                  );
                },
                icon: const Icon(Icons.location_on),
                label: const Text('I Have Reached Delivery Location', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => DriverNavigationHelper.showMapChoiceSheet(
                  context,
                  address: order.address.formatted,
                  title: 'Delivery Navigation',
                ),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open Waze / Google Maps Navigation'),
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => DriverNavigationHelper.callPhone(context, order.customerPhone),
                icon: const Icon(Icons.call, color: AppColors.success),
                label: Text('Call Customer to Confirm Arrival (${order.customerPhone})', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                onPressed: () {
                  state.updateOrderStatus(order.id, OrderStatus.delivered);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogCtx) => DriverDeliverySuccessDialog(
                      order: order,
                      earnedBonusQar: 1.0,
                      onBackToDashboard: () {
                        Navigator.pop(dialogCtx);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Complete Handover & Deliver Order', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      }
    }

    return const SizedBox();
  }
}
