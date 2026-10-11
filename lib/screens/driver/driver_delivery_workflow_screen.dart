import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/driver_navigation_helper.dart';
import 'driver_cancel_order_dialog.dart';
import 'driver_completion_screen.dart';
import 'driver_photo_capture_sheet.dart';
import 'driver_qr_scanner_dialog.dart';

class DriverDeliveryWorkflowScreen extends StatefulWidget {
  final LaundryOrder order;

  const DriverDeliveryWorkflowScreen({super.key, required this.order});

  @override
  State<DriverDeliveryWorkflowScreen> createState() =>
      _DriverDeliveryWorkflowScreenState();
}

class _DriverDeliveryWorkflowScreenState
    extends State<DriverDeliveryWorkflowScreen> {
  late DateTime _deliveryStartTime;
  bool _isQrScanned = false;
  String? _deliveryProofPhoto;

  // Step 4 Delivery Location Options
  String? _selectedDeliveryLocation;
  final TextEditingController _otherLocationController =
      TextEditingController();

  static const List<String> _locationOptions = [
    'Directly to customer/owner',
    'Front of the door',
    'Reception',
    'Customer Service',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<StateService>();
    final currentOrder = state.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    // Step 1: System records delivery start time
    if (currentOrder.deliveryStartedAt == null) {
      _deliveryStartTime = DateTime.now();
      state.startIndividualOrderDelivery(widget.order.id);
    } else {
      _deliveryStartTime = currentOrder.deliveryStartedAt!;
    }

    _isQrScanned = currentOrder.deliveryQrScanned;
    _deliveryProofPhoto = currentOrder.deliveryProofPhoto;
    _selectedDeliveryLocation = currentOrder.deliveryLocation;
    if (currentOrder.deliveryLocationNote != null) {
      _otherLocationController.text = currentOrder.deliveryLocationNote!;
    }
  }

  @override
  void dispose() {
    _otherLocationController.dispose();
    super.dispose();
  }

  bool get _isOtherLocationSelected => _selectedDeliveryLocation == 'Other';

  bool get _isLocationValid {
    if (_selectedDeliveryLocation == null) return false;
    if (_isOtherLocationSelected &&
        _otherLocationController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  bool get _canCompleteDelivery =>
      _isQrScanned && _deliveryProofPhoto != null && _isLocationValid;

  void _scanDeliveryQr(LaundryOrder order) {
    showDialog(
      context: context,
      builder: (_) => DriverQrScannerDialog(
        order: order,
        title: 'Scan Order QR #${order.orderNumber}',
        buttonLabel: 'Verify & Confirm Delivery Match',
        onVerified: () {
          setState(() => _isQrScanned = true);
          final state = context.read<StateService>();
          state.verifyIndividualOrderDeliveryQr(order.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ QR code verified! Step 2 complete.'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  Future<void> _takeDeliveryProof() async {
    final photo = await DriverPhotoCaptureSheet.capturePhoto(
      context,
      title: 'Proof of Delivery',
      instruction:
          'Take a photo of the delivered garments at doorstep, reception, or with customer.',
      photoCategoryKey: 'delivery_proof',
    );

    if (photo != null) {
      setState(() => _deliveryProofPhoto = photo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📸 Delivery proof photo captured! Step 3 complete.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _completeDelivery() {
    if (!_canCompleteDelivery) return;

    final state = context.read<StateService>();
    final driver = state.currentDriver;
    final bonusEarned = driver.bonusRatePerOrder;

    state.completeIndividualOrderDelivery(
      orderId: widget.order.id,
      deliveryProofPhoto: _deliveryProofPhoto!,
      deliveryLocation: _selectedDeliveryLocation!,
      deliveryLocationNote: _isOtherLocationSelected
          ? _otherLocationController.text.trim()
          : null,
    );

    // Check if all delivery orders for today are now delivered
    final remainingDeliveries = state.orders.where(
      (o) =>
          o.assignedDriverId == driver.id &&
          (o.status == OrderStatus.outForDelivery ||
              o.status == OrderStatus.readyForDelivery),
    ).toList();

    if (remainingDeliveries.isEmpty) {
      // All orders completed! Show completion celebration screen
      Navigator.pop(context);
      DriverCompletionScreen.show(
        context,
        completedOrdersCount: 1,
        earnedBonusQar: bonusEarned,
      );
    } else {
      // Individual delivery completed dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('😊', style: TextStyle(fontSize: 34)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Order Delivered! 🎉',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Order #${widget.order.orderNumber} delivered to $_selectedDeliveryLocation.',
                style:
                    const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${bonusEarned.toStringAsFixed(bonusEarned % 1 == 0 ? 0 : 2)} QAR Driver Bonus Credited',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    Navigator.pop(context);
                  },
                  child: const Text('Back to Deliveries'),
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
    final order = state.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    final isDelivered = order.status == OrderStatus.delivered;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Deliver Order #${order.orderNumber}'),
        actions: [
          if (!isDelivered)
            TextButton.icon(
              onPressed: () async {
                final cancelled =
                    await DriverCancelOrderDialog.show(context, order);
                if (cancelled == true && context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(
                Icons.cancel_outlined,
                size: 16,
                color: AppColors.error,
              ),
              label: const Text(
                'Cancel Order',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Overview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Text(
                              '🚚 DELIVERY MISSION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '#${order.orderNumber}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        state.canViewPrice()
                            ? '${order.totalAmount.toStringAsFixed(0)} QAR'
                            : '${order.totalItemCount} Items',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${order.customerName} (${order.customerPhone})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call,
                            color: AppColors.success, size: 20),
                        tooltip: 'Call Customer',
                        onPressed: () => DriverNavigationHelper.callPhone(
                          context,
                          order.customerPhone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.home_work_outlined,
                        size: 16,
                        color: Colors.teal,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.address.formatted,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.navigation,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        tooltip: 'Open Maps Navigation',
                        onPressed: () =>
                            DriverNavigationHelper.showMapChoiceSheet(
                          context,
                          address: order.address.formatted,
                          title: 'Navigate to Delivery',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step 1: Start Order (Delivery time)
            _buildStepCard(
              stepNumber: 1,
              title: 'Step 1 — Start Order',
              subtitle:
                  'Delivery start time recorded: ${DateFormat('hh:mm:ss a • dd MMM yyyy').format(_deliveryStartTime)}',
              isDone: true,
              trailingWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'RECORDED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Step 2: Scan Order
            _buildStepCard(
              stepNumber: 2,
              title: 'Step 2 — Scan Order',
              subtitle: _isQrScanned
                  ? 'Delivery QR code verified with order payload'
                  : 'Driver scans the order QR code upon arrival',
              isDone: _isQrScanned,
              actionButton: OutlinedButton.icon(
                onPressed: () => _scanDeliveryQr(order),
                icon: Icon(
                  _isQrScanned ? Icons.check : Icons.qr_code_scanner,
                  size: 16,
                  color: _isQrScanned ? Colors.green : AppColors.primary,
                ),
                label: Text(_isQrScanned ? 'Re-scan QR' : 'Scan Order QR'),
              ),
            ),

            const SizedBox(height: 12),

            // Step 3: Delivery Proof Photo
            _buildStepCard(
              stepNumber: 3,
              title: 'Step 3 — Delivery Proof',
              subtitle: _deliveryProofPhoto != null
                  ? 'Delivery proof photo uploaded: $_deliveryProofPhoto'
                  : 'Driver takes a photo as proof that the order was delivered',
              isDone: _deliveryProofPhoto != null,
              actionButton: OutlinedButton.icon(
                onPressed: _takeDeliveryProof,
                icon: Icon(
                  _deliveryProofPhoto != null ? Icons.check : Icons.camera_alt,
                  size: 16,
                  color: _deliveryProofPhoto != null
                      ? Colors.green
                      : AppColors.primary,
                ),
                label: Text(
                  _deliveryProofPhoto != null
                      ? 'Retake Proof'
                      : 'Take Delivery Proof',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Step 4: Select Delivery Location
            _buildLocationSelectionCard(),

            const SizedBox(height: 28),

            // Step 5: Complete Delivery Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                    _canCompleteDelivery && !isDelivered ? _completeDelivery : null,
                icon: Icon(
                  isDelivered ? Icons.task_alt : Icons.check_circle,
                  size: 20,
                ),
                label: Text(
                  isDelivered
                      ? 'Order Status = Delivered (Complete)'
                      : 'Step 5 — Complete Delivery',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isDone,
    Widget? trailingWidget,
    Widget? actionButton,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? const Color(0xFF86EFAC) : AppColors.border,
          width: isDone ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.success : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '$stepNumber',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF475569),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              ?trailingWidget,
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDone ? const Color(0xFF166534) : AppColors.textMuted,
                fontWeight: isDone ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          if (actionButton != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: actionButton,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationSelectionCard() {
    final isDone = _isLocationValid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? const Color(0xFF86EFAC) : AppColors.border,
          width: isDone ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.success : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : const Text(
                          '4',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF475569),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Step 4 — Select Delivery Location',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDone ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isDone ? 'SELECTED' : 'REQUIRED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: isDone
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 38),
            child: Text(
              'The driver must select where the order was delivered:',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 12),

          // Radio option list
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: Column(
              children: _locationOptions.map((loc) {
                final isSelected = _selectedDeliveryLocation == loc;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedDeliveryLocation = loc);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.shade50
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.green.shade400
                            : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 16,
                          color: isSelected ? AppColors.success : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF14532D)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // If Other selected: description required
          if (_isOtherLocationSelected) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: TextField(
                controller: _otherLocationController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Describe delivery location (Required *)',
                  hintText: 'e.g. Handed to security guard at gate 2',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
