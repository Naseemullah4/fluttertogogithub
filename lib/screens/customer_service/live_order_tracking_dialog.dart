import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/driver.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../utils/driver_navigation_helper.dart';
import '../../widgets/badge_pill.dart';
import 'customer_contact_dialog.dart';
import 'emergency_problem_solver_dialog.dart';

class LiveOrderTrackingDialog extends StatefulWidget {
  final LaundryOrder order;

  const LiveOrderTrackingDialog({super.key, required this.order});

  static Future<void> show(BuildContext context, LaundryOrder order) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => LiveOrderTrackingDialog(order: order),
    );
  }

  @override
  State<LiveOrderTrackingDialog> createState() => _LiveOrderTrackingDialogState();
}

class _LiveOrderTrackingDialogState extends State<LiveOrderTrackingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isAudioPinging = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerAudioPing(StateService state, DriverModel? driver) async {
    setState(() => _isAudioPinging = true);
    final driverId = driver?.id ?? widget.order.assignedDriverId;
    state.dispatchRadioPingToDriver(
      driverId,
      message: 'Urgent Dispatch Ping: Support Agent is monitoring Order #${widget.order.orderNumber}. Confirm location & ETA.',
      orderNumber: widget.order.orderNumber,
    );
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() => _isAudioPinging = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.satellite_alt_rounded, color: Color(0xFF38BDF8), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '📡 Audible Ping dispatched to Courier ${widget.order.assignedDriverName}. In-cab radio alert triggered!',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    // Fetch fresh order from state
    final order = state.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );
    final driver = state.drivers.cast<DriverModel?>().firstWhere(
          (d) => d?.id == order.assignedDriverId,
          orElse: () => null,
        );

    final currentLat = driver?.currentLat ?? (order.address.latitude != 0 ? order.address.latitude + 0.0082 : 25.2867);
    final currentLng = driver?.currentLng ?? (order.address.longitude != 0 ? order.address.longitude - 0.0064 : 51.5333);
    final plateNumber = driver?.documents.vehicleRegPlate ?? 'QA-88192 (UniWash Fleet)';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 780),
        child: Column(
          children: [
            // TOP HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A), // Dark High-Tech Navy
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.satellite_alt_rounded, color: Color(0xFF38BDF8), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Live Radar Tracking • Order #${order.orderNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(width: 10),
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(
                                    alpha: 0.2 + (_pulseAnimation.value * 0.25),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF10B981), width: 1),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF10B981)),
                                    SizedBox(width: 5),
                                    Text(
                                      'LIVE GPS TELEMETRY',
                                      style: TextStyle(
                                        color: Color(0xFF6EE7B7),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Real-Time WebSocket • Lat: ${currentLat.toStringAsFixed(4)}° N, Lng: ${currentLng.toStringAsFixed(4)}° E • 5G Hub Doha',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ROW 1: DRIVER & VEHICLE TELEMETRY CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.15),
                            child: const Icon(Icons.sports_motorsports_rounded, color: Color(0xFF0284C7), size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      order.assignedDriverName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (driver != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: driver.affiliation.color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          driver.affiliation.shortBadge,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: driver.affiliation.color,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                                    Text(
                                      '${driver?.rating ?? 4.9} ★',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.directions_car_filled_rounded, size: 14, color: Color(0xFF64748B)),
                                    const SizedBox(width: 4),
                                    Text(
                                      plateNumber,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    const Icon(Icons.phone_rounded, size: 14, color: Color(0xFF64748B)),
                                    const SizedBox(width: 4),
                                    Text(
                                      driver?.phone ?? '+974 5519 2841',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Dynamic ETA & Speed Badges
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF059669), width: 1),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.speed_rounded, size: 16, color: Color(0xFF059669)),
                                    SizedBox(width: 6),
                                    Text(
                                      '38 km/h • Heading NE',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Est. Arrival: ~11 Mins (2.4 km)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // RADAR SIMULATOR SCREEN
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1128), // Deep Radar Screen
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E293B)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Grid / Radar Circles
                          Center(
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: const Size(double.infinity, 220),
                                  painter: _RadarGridPainter(pulseValue: _pulseAnimation.value),
                                );
                              },
                            ),
                          ),

                          // Location Pins & Active Courier Position
                          Positioned(
                            left: 35,
                            top: 40,
                            child: _buildRadarPin(
                              icon: Icons.local_laundry_service_rounded,
                              label: 'Hub: ${order.laundryName}',
                              color: const Color(0xFF38BDF8),
                            ),
                          ),
                          Positioned(
                            right: 45,
                            bottom: 45,
                            child: _buildRadarPin(
                              icon: Icons.home_rounded,
                              label: 'Dest: ${order.customerName}',
                              color: const Color(0xFFF43F5E),
                            ),
                          ),

                          // LIVE COURIER VEHICLE (CENTER-LEFT PULSING)
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Positioned(
                                left: 160 + (_pulseAnimation.value * 25),
                                top: 85 - (_pulseAnimation.value * 12),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF10B981),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                            blurRadius: 12 * _pulseAnimation.value,
                                            spreadRadius: 4 * _pulseAnimation.value,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.electric_moped_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                                      ),
                                      child: Text(
                                        order.assignedDriverName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Realtime Telemetry Overlay Top Right
                          Positioned(
                            top: 12,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.wifi_rounded, size: 12, color: Color(0xFF38BDF8)),
                                  SizedBox(width: 4),
                                  Text(
                                    '5G LIVE • PING 18ms',
                                    style: TextStyle(
                                      color: Color(0xFFE2E8F0),
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.battery_charging_full_rounded, size: 12, color: Color(0xFF10B981)),
                                  SizedBox(width: 4),
                                  Text(
                                    '88%',
                                    style: TextStyle(
                                      color: Color(0xFFE2E8F0),
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // JOURNEY PIPELINE TRACKER
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.route_rounded, size: 18, color: Color(0xFF0F172A)),
                              const SizedBox(width: 8),
                              const Text(
                                'Order Journey & Live Milestone Progression',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              const Spacer(),
                              BadgePill(
                                label: order.status.displayName,
                                color: order.status.color,
                                backgroundColor: order.status.color.withValues(alpha: 0.12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildJourneyMilestones(order),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // DESTINATION & SPECIAL INSTRUCTIONS
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.pin_drop_rounded, size: 15, color: Color(0xFFEA580C)),
                                    SizedBox(width: 6),
                                    Text('Delivery Coordinates & Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.address.formatted,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                                ),
                                if (order.deliveryLocationNote != null && order.deliveryLocationNote!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Access: ${order.deliveryLocationNote}',
                                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.notes_rounded, size: 15, color: Color(0xFF0284C7)),
                                    SizedBox(width: 6),
                                    Text('Special Dispatch Instructions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.specialInstructions.isNotEmpty ? order.specialInstructions : 'No special delivery constraints recorded.',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM ACTION CONTROLS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // 1. Audio Ping Driver Alert
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isAudioPinging
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.ring_volume_rounded, size: 17),
                    label: Text(
                      _isAudioPinging ? 'Pinging In-Cab Radio...' : '📡 Ping Driver Audio Alert',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    onPressed: _isAudioPinging ? null : () => _triggerAudioPing(state, driver),
                  ),

                  // 2. Open Google Maps
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.map_rounded, size: 16, color: Color(0xFF16A34A)),
                    label: const Text('Google Maps', style: TextStyle(fontSize: 12)),
                    onPressed: () => DriverNavigationHelper.openGoogleMaps(context, order.address.formatted),
                  ),

                  // 3. Call Driver
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: Color(0xFF2563EB)),
                    label: const Text('Call Courier', style: TextStyle(fontSize: 12)),
                    onPressed: () => DriverNavigationHelper.callPhone(context, driver?.phone ?? order.customerPhone),
                  ),

                  // 4. Contact Customer (Omnichannel: Live Chat / WhatsApp / Email / Call)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF059669),
                      side: const BorderSide(color: Color(0xFF6EE7B7)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.forum_rounded, size: 16),
                    label: const Text('💬 Contact Customer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () => CustomerContactDialog.show(context, order),
                  ),

                  // 5. Emergency Problem Solver
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.build_circle_rounded, size: 17),
                    label: const Text('🛠️ Emergency Problem Solver', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    onPressed: () {
                      Navigator.pop(context);
                      EmergencyProblemSolverDialog.show(context, order);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarPin({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyMilestones(LaundryOrder order) {
    final steps = [
      {'title': 'Placed', 'status': OrderStatus.placed, 'icon': Icons.receipt_long_rounded},
      {'title': 'Assigned', 'status': OrderStatus.driverAssigned, 'icon': Icons.person_pin_rounded},
      {'title': 'Picked Up', 'status': OrderStatus.pickedUp, 'icon': Icons.local_shipping_rounded},
      {'title': 'In Laundry', 'status': OrderStatus.inLaundry, 'icon': Icons.local_laundry_service_rounded},
      {'title': 'Ready', 'status': OrderStatus.readyForDelivery, 'icon': Icons.check_box_rounded},
      {'title': 'Out for Delivery', 'status': OrderStatus.outForDelivery, 'icon': Icons.electric_moped_rounded},
      {'title': 'Delivered', 'status': OrderStatus.delivered, 'icon': Icons.task_alt_rounded},
    ];

    final currentStepIdx = order.status.stepIndex;

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepBefore = index ~/ 2;
          final isPast = stepBefore < currentStepIdx;
          return Expanded(
            child: Container(
              height: 3,
              color: isPast ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
            ),
          );
        }
        final stepIdx = index ~/ 2;
        final step = steps[stepIdx];
        final isCompleted = stepIdx <= currentStepIdx;
        final isCurrent = stepIdx == currentStepIdx;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? const Color(0xFF0284C7)
                    : isCompleted
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF1F5F9),
                border: Border.all(
                  color: isCompleted ? Colors.transparent : const Color(0xFFCBD5E1),
                ),
              ),
              child: Icon(
                step['icon'] as IconData,
                size: 14,
                color: isCompleted ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              step['title'] as String,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                color: isCurrent ? const Color(0xFF0284C7) : const Color(0xFF64748B),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _RadarGridPainter extends CustomPainter {
  final double pulseValue;

  _RadarGridPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintGrid = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final paintRadarPulse = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.12 + (pulseValue * 0.15))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw concentric circles
    canvas.drawCircle(center, 40, paintGrid);
    canvas.drawCircle(center, 80, paintGrid);
    canvas.drawCircle(center, 120 + (pulseValue * 20), paintRadarPulse);

    // Crosshairs
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paintGrid);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paintGrid);

    // Dynamic trajectory dashed line
    final routePaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(60, 60);
    path.quadraticBezierTo(center.dx, center.dy - 30, size.width - 80, size.height - 60);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarGridPainter oldDelegate) =>
      oldDelegate.pulseValue != pulseValue;
}
