import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/driver_navigation_helper.dart';
import 'driver_cancel_order_dialog.dart';
import 'driver_photo_capture_sheet.dart';
import 'driver_qr_scanner_dialog.dart';

class DriverCollectionWorkflowScreen extends StatefulWidget {
  final LaundryOrder order;

  const DriverCollectionWorkflowScreen({super.key, required this.order});

  @override
  State<DriverCollectionWorkflowScreen> createState() =>
      _DriverCollectionWorkflowScreenState();
}

class _DriverCollectionWorkflowScreenState
    extends State<DriverCollectionWorkflowScreen> {
  late DateTime _collectionStartTime;
  bool _isQrVerified = false;
  String? _proofPhotoName;

  @override
  void initState() {
    super.initState();
    final state = context.read<StateService>();
    final currentOrder = state.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    // Step 1: Automatically record order collection start time
    if (currentOrder.collectionStartedAt == null) {
      _collectionStartTime = DateTime.now();
      state.startOrderCollection(widget.order.id);
    } else {
      _collectionStartTime = currentOrder.collectionStartedAt!;
    }

    _isQrVerified = currentOrder.collectionQrScanned;
    _proofPhotoName = currentOrder.collectionProofPhoto;
  }

  void _scanOrderQr(LaundryOrder order) {
    showDialog(
      context: context,
      builder: (_) => DriverQrScannerDialog(
        order: order,
        title: 'Scan Order QR Code #${order.orderNumber}',
        buttonLabel: 'Verify & Confirm Match',
        onVerified: () {
          setState(() => _isQrVerified = true);
          final state = context.read<StateService>();
          state.verifyOrderCollectionQr(order.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ QR code verified with order ID! Step 2 complete.'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  Future<void> _takeCollectionProof() async {
    final photo = await DriverPhotoCaptureSheet.capturePhoto(
      context,
      title: 'Proof of Collection',
      instruction:
          'Take a photo of the laundry bags and tagged garments collected from customer.',
      photoCategoryKey: 'collection_proof',
    );

    if (photo != null) {
      setState(() => _proofPhotoName = photo);
      if (mounted) {
        final state = context.read<StateService>();
        state.uploadOrderCollectionProof(widget.order.id, photo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📸 Collection proof photo uploaded! Step 3 complete.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _completeCollection() {
    if (!_isQrVerified || _proofPhotoName == null) return;

    final state = context.read<StateService>();
    state.completeOrderCollection(widget.order.id);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Collection Completed!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Order #${widget.order.orderNumber} is now picked up and secured in your van.',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  Navigator.pop(context);
                },
                child: const Text('Back to Missions Console'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final order = state.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    final isCompleted = order.status == OrderStatus.pickedUp ||
        order.workflowStep == DriverWorkflowStep.collectionCompleted;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Collect Order #${order.orderNumber}'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final cancelled = await DriverCancelOrderDialog.show(context, order);
              if (cancelled == true && context.mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
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
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: const Text(
                              '📦 COLLECTION MISSION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
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
                  // Customer & Location
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
                        icon: const Icon(Icons.call, color: AppColors.success, size: 20),
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
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.primary,
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
                          title: 'Navigate to Customer Pickup',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step Timeline Progress Header
            const Text(
              'Required Collection Steps',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Complete all 4 verification steps to finish order collection.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),

            // Step 1: Collection Time (Automatically recorded)
            _buildStepCard(
              stepNumber: 1,
              title: 'Step 1 — Collection Time',
              subtitle:
                  'Automatically recorded: ${DateFormat('hh:mm:ss a • dd MMM yyyy').format(_collectionStartTime)}',
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

            // Step 2: Scan QR Code
            _buildStepCard(
              stepNumber: 2,
              title: 'Step 2 — Scan QR Code',
              subtitle: _isQrVerified
                  ? 'Order QR verified successfully with laundry system'
                  : 'Scan customer QR code to authenticate garments',
              isDone: _isQrVerified,
              actionButton: OutlinedButton.icon(
                onPressed: () => _scanOrderQr(order),
                icon: Icon(
                  _isQrVerified ? Icons.check : Icons.qr_code_scanner,
                  size: 16,
                  color: _isQrVerified ? Colors.green : AppColors.primary,
                ),
                label: Text(_isQrVerified ? 'Re-scan QR' : 'Scan QR Code'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isQrVerified ? Colors.green : AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Step 3: Proof of Collection
            _buildStepCard(
              stepNumber: 3,
              title: 'Step 3 — Proof of Collection',
              subtitle: _proofPhotoName != null
                  ? 'Proof uploaded: $_proofPhotoName'
                  : 'Driver takes a photo as proof that order was collected',
              isDone: _proofPhotoName != null,
              actionButton: OutlinedButton.icon(
                onPressed: _takeCollectionProof,
                icon: Icon(
                  _proofPhotoName != null ? Icons.check : Icons.camera_alt,
                  size: 16,
                  color: _proofPhotoName != null ? Colors.green : AppColors.primary,
                ),
                label: Text(
                  _proofPhotoName != null
                      ? 'Retake Proof'
                      : 'Take Proof Photo',
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _proofPhotoName != null
                        ? Colors.green
                        : AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Step 4: Complete Collection
            _buildStepCard(
              stepNumber: 4,
              title: 'Step 4 — Complete Collection',
              subtitle: isCompleted
                  ? 'Order collection has been marked completed'
                  : 'Enabled once QR code is scanned & proof photo uploaded',
              isDone: isCompleted,
              isFinalStep: true,
            ),

            const SizedBox(height: 28),

            // Step 4 Final Submission Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: (_isQrVerified &&
                        _proofPhotoName != null &&
                        !isCompleted)
                    ? _completeCollection
                    : (isCompleted
                        ? () => Navigator.pop(context)
                        : null),
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.inventory_2,
                  size: 20,
                ),
                label: Text(
                  isCompleted
                      ? 'Order Collection Completed (Done)'
                      : 'Mark Order Collection Completed',
                  style: const TextStyle(
                    fontSize: 14.5,
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

            const SizedBox(height: 20),
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
    bool isFinalStep = false,
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
}
