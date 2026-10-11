import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import 'driver_photo_capture_sheet.dart';
import 'driver_qr_scanner_dialog.dart';

class DriverDeliveryLoadingScreen extends StatefulWidget {
  final List<LaundryOrder> orders;

  const DriverDeliveryLoadingScreen({super.key, required this.orders});

  @override
  State<DriverDeliveryLoadingScreen> createState() =>
      _DriverDeliveryLoadingScreenState();
}

class _DriverDeliveryLoadingScreenState
    extends State<DriverDeliveryLoadingScreen> {
  final Set<String> _scannedOrderIds = {};
  bool _isLoadedIntoVan = false;

  // 3 Required Photos
  String? _bagHangerPhoto;
  String? _numberPlatePhoto;
  String? _laundryOrderPhoto;

  bool get _allOrdersScanned =>
      widget.orders.isNotEmpty &&
      _scannedOrderIds.length >= widget.orders.length;

  int get _uploadedPhotosCount {
    int count = 0;
    if (_bagHangerPhoto != null) count++;
    if (_numberPlatePhoto != null) count++;
    if (_laundryOrderPhoto != null) count++;
    return count;
  }

  bool get _canStartDelivery =>
      _allOrdersScanned &&
      _isLoadedIntoVan &&
      _uploadedPhotosCount == 3;

  void _scanOrderForLoading(LaundryOrder order) {
    showDialog(
      context: context,
      builder: (_) => DriverQrScannerDialog(
        order: order,
        title: 'Scan Order #${order.orderNumber} for Van Loading',
        buttonLabel: 'Verify & Mark Loaded',
        onVerified: () {
          setState(() {
            _scannedOrderIds.add(order.id);
            if (_allOrdersScanned) {
              _isLoadedIntoVan = true;
            }
          });
          final state = context.read<StateService>();
          state.markOrderLoadedForDelivery(order.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Order #${order.orderNumber} scanned for van (${_scannedOrderIds.length}/${widget.orders.length})',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  Future<void> _capturePhoto(String type) async {
    String title;
    String instruction;
    String key;

    switch (type) {
      case 'bag_hanger':
        title = 'Bag and Hanger Photo';
        instruction =
            'Take a clear photo showing laundry bags and hung garments inside van rack.';
        key = 'hanger';
        break;
      case 'plate':
        title = 'Vehicle Number Plate Photo';
        instruction =
            'Take a clear photo of the van number plate before leaving laundry.';
        key = 'plate';
        break;
      default:
        title = 'Laundry / Order Photo';
        instruction =
            'Take an overview photo of all loaded customer orders in the cargo space.';
        key = 'laundry';
    }

    final photo = await DriverPhotoCaptureSheet.capturePhoto(
      context,
      title: title,
      instruction: instruction,
      photoCategoryKey: key,
    );

    if (photo != null) {
      setState(() {
        if (type == 'bag_hanger') {
          _bagHangerPhoto = photo;
        } else if (type == 'plate') {
          _numberPlatePhoto = photo;
        } else {
          _laundryOrderPhoto = photo;
        }
      });
    }
  }

  void _dispatchVanAndBeginDeliveries() {
    if (!_canStartDelivery) return;

    final state = context.read<StateService>();
    final orderIds = widget.orders.map((o) => o.id).toList();

    state.completeVanLoadingAndDispatch(
      orderIds: orderIds,
      bagHangerPhoto: _bagHangerPhoto!,
      platePhoto: _numberPlatePhoto!,
      laundryPhoto: _laundryOrderPhoto!,
    );

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
                Icons.local_shipping_rounded,
                color: AppColors.success,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delivery Process Started! 🚚',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Van loaded with ${widget.orders.length} order(s). All 3 photos verified. GPS tracking active.',
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
                child: const Text('Open Deliveries Route'),
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
        title: const Text('Start Order Delivery (Loading)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview banner
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
                      color: AppColors.statusDelivery.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.electric_moped_rounded,
                      color: AppColors.statusDelivery,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Van Loading & Dispatch',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.orders.length} order(s) ready to load into delivery van',
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

            // Step 1: Start Delivery
            _buildSectionHeader(
              title: 'Step 1 — Start Delivery',
              subtitle: 'Driver selects Start Delivery to initiate van loading session.',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Step 2: Scan All Orders
            _buildSectionHeader(
              title: 'Step 2 — Scan All Orders',
              subtitle:
                  'Driver scans all orders that are being loaded for delivery.',
              trailing: Text(
                '${_scannedOrderIds.length}/${widget.orders.length} Scanned',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _allOrdersScanned ? Colors.green : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

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
                      onPressed:
                          isScanned ? null : () => _scanOrderForLoading(order),
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: isScanned
                            ? Colors.green.shade100
                            : AppColors.primary,
                        foregroundColor:
                            isScanned ? Colors.green.shade800 : Colors.white,
                      ),
                      child: Text(isScanned ? 'Loaded' : 'Scan Order'),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Step 3: Load Orders Into Van
            _buildSectionHeader(
              title: 'Step 3 — Load Orders Into Van',
              subtitle: 'Confirm that all scanned bundles are placed inside van.',
              trailing: Checkbox(
                value: _isLoadedIntoVan,
                activeColor: AppColors.success,
                onChanged: _allOrdersScanned
                    ? (val) => setState(() => _isLoadedIntoVan = val ?? false)
                    : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isLoadedIntoVan
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isLoadedIntoVan
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isLoadedIntoVan
                        ? Icons.check_circle
                        : Icons.info_outline,
                    color: _isLoadedIntoVan
                        ? AppColors.success
                        : AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isLoadedIntoVan
                          ? 'Orders successfully placed inside van cargo.'
                          : 'Please scan all orders above to confirm loading.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isLoadedIntoVan
                            ? const Color(0xFF166534)
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step 4: Required Photos (3)
            _buildSectionHeader(
              title: 'Step 4 — Required Photos (3)',
              subtitle:
                  'Driver must take all 3 photos before delivery departure.',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _uploadedPhotosCount == 3
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$_uploadedPhotosCount/3 UPLOADED',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: _uploadedPhotosCount == 3
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 1. Bag and hanger photo
            DriverPhotoUploadTile(
              title: '1. Bag and Hanger Photo',
              subtitle: 'Photo of the bags and hung garments inside van',
              photoCategoryKey: 'hanger',
              uploadedPhotoName: _bagHangerPhoto,
              onTap: () => _capturePhoto('bag_hanger'),
            ),

            // 2. Vehicle number plate photo
            DriverPhotoUploadTile(
              title: '2. Vehicle Number Plate Photo',
              subtitle: 'Photo of the vehicle license plate before leaving',
              photoCategoryKey: 'plate',
              uploadedPhotoName: _numberPlatePhoto,
              onTap: () => _capturePhoto('plate'),
            ),

            // 3. Laundry/order photo
            DriverPhotoUploadTile(
              title: '3. Laundry / Order Photo',
              subtitle: 'Overview photo of orders arranged for delivery',
              photoCategoryKey: 'laundry',
              uploadedPhotoName: _laundryOrderPhoto,
              onTap: () => _capturePhoto('laundry'),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _canStartDelivery
                    ? _dispatchVanAndBeginDeliveries
                    : null,
                icon: const Icon(Icons.navigation, size: 20),
                label: Text(
                  _canStartDelivery
                      ? 'Begin Deliveries Ride (Out for Delivery)'
                      : 'Complete Steps Above (${_scannedOrderIds.length}/${widget.orders.length} Scanned, $_uploadedPhotosCount/3 Photos)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusDelivery,
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
    required String title,
    required String subtitle,
    Widget? trailing,
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
            ?trailing,
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
