import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import 'driver_photo_capture_sheet.dart';
import 'driver_qr_scanner_dialog.dart';

class DriverLaundryArrivalScreen extends StatefulWidget {
  final List<LaundryOrder> orders;

  const DriverLaundryArrivalScreen({super.key, required this.orders});

  @override
  State<DriverLaundryArrivalScreen> createState() =>
      _DriverLaundryArrivalScreenState();
}

class _DriverLaundryArrivalScreenState
    extends State<DriverLaundryArrivalScreen> {
  final Set<String> _scannedOrderIds = {};
  String? _laundryBatchPhoto;
  DateTime? _dispatchTime;
  bool _isDispatched = false;

  @override
  void initState() {
    super.initState();
    // Prepopulate any orders that already have laundryQrScanned = true
    for (final order in widget.orders) {
      if (order.laundryQrScanned) {
        _scannedOrderIds.add(order.id);
      }
    }
  }

  bool get _allOrdersScanned =>
      widget.orders.isNotEmpty &&
      _scannedOrderIds.length >= widget.orders.length;

  bool get _canDispatch => _allOrdersScanned && _laundryBatchPhoto != null;

  void _scanOrder(LaundryOrder order) {
    showDialog(
      context: context,
      builder: (_) => DriverQrScannerDialog(
        order: order,
        title: 'Scan Order #${order.orderNumber} Arrival QR',
        buttonLabel: 'Confirm Laundry Reception',
        onVerified: () {
          setState(() {
            _scannedOrderIds.add(order.id);
          });
          final state = context.read<StateService>();
          state.markOrderLaundryQrScanned(order.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Order #${order.orderNumber} scanned (${_scannedOrderIds.length}/${widget.orders.length})',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  Future<void> _takeLaundryPhoto() async {
    final photo = await DriverPhotoCaptureSheet.capturePhoto(
      context,
      title: 'Laundry Batch Received Photo',
      instruction:
          'Take ONE photo showing all received orders on the laundry intake table.',
      photoCategoryKey: 'laundry',
    );

    if (photo != null) {
      setState(() => _laundryBatchPhoto = photo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📸 Laundry received photo uploaded! Step 2 complete.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _dispatchToLaundry() {
    if (!_canDispatch) return;

    final state = context.read<StateService>();
    final orderIds = widget.orders.map((o) => o.id).toList();

    _dispatchTime = DateTime.now();
    state.dispatchOrdersToLaundry(
      orderIds: orderIds,
      batchPhotoName: _laundryBatchPhoto!,
    );

    setState(() => _isDispatched = true);

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
                Icons.local_laundry_service_rounded,
                color: AppColors.success,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Orders Dispatched to Laundry! 🏢',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.orders.length} orders successfully handed over to laundry staff at ${DateFormat('hh:mm a').format(_dispatchTime!)}.',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
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
                child: const Text('Return to Console'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Order Arrives at Laundry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statusLaundry.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: AppColors.statusLaundry,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Laundry Intake Facility',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.orders.length} collected order(s) arrived in van',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step 1: Scan All Orders
            _buildSectionHeader(
              step: 1,
              title: 'Step 1 — Scan All Orders',
              subtitle:
                  'Driver/laundry staff scans the QR code of EVERY order received.',
              statusBadge: Text(
                '${_scannedOrderIds.length}/${widget.orders.length} Scanned',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _allOrdersScanned ? Colors.green : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Orders list with individual scan buttons
            ...widget.orders.map((order) {
              final isScanned = _scannedOrderIds.contains(order.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isScanned ? const Color(0xFFF0FDF4) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isScanned ? const Color(0xFF86EFAC) : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isScanned ? Icons.check_circle : Icons.qr_code_scanner,
                      color: isScanned ? AppColors.success : AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${order.orderNumber} • ${order.customerName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${order.totalItemCount} items • ${order.address.formatted}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isScanned ? null : () => _scanOrder(order),
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: isScanned
                            ? Colors.green.shade100
                            : AppColors.primary,
                        foregroundColor:
                            isScanned ? Colors.green.shade800 : Colors.white,
                      ),
                      child: Text(isScanned ? 'Verified' : 'Scan QR'),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // Step 2: Laundry Photo
            _buildSectionHeader(
              step: 2,
              title: 'Step 2 — Laundry Photo',
              subtitle:
                  'After all orders have been scanned, take ONE photo showing all received orders.',
              statusBadge: _laundryBatchPhoto != null
                  ? const Text(
                      'Photo Uploaded',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 10),

            DriverPhotoUploadTile(
              title: 'Laundry Intake Batch Photo',
              subtitle: 'Photo of all scanned orders gathered at intake counter',
              photoCategoryKey: 'laundry',
              uploadedPhotoName: _laundryBatchPhoto,
              onTap: _allOrdersScanned
                  ? _takeLaundryPhoto
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '⚠️ Please scan all orders first before taking the batch photo.',
                          ),
                        ),
                      );
                    },
            ),

            const SizedBox(height: 20),

            // Step 3: Laundry Dispatch
            _buildSectionHeader(
              step: 3,
              title: 'Step 3 — Laundry Dispatch',
              subtitle:
                  'Mark orders as "Orders Dispatched to Laundry". System records dispatch time.',
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _canDispatch ? _dispatchToLaundry : null,
                icon: const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isDispatched
                      ? 'Orders Dispatched to Laundry (Done)'
                      : 'Orders Dispatched to Laundry',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusLaundry,
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

  Widget _buildSectionHeader({
    required int step,
    required String title,
    required String subtitle,
    Widget? statusBadge,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            ?statusBadge,
          ],
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
