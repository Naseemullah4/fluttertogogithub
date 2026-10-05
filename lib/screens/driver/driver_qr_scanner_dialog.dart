import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../theme/app_colors.dart';

class DriverQrScannerDialog extends StatefulWidget {
  final LaundryOrder order;
  final VoidCallback onVerified;

  const DriverQrScannerDialog({
    super.key,
    required this.order,
    required this.onVerified,
  });

  @override
  State<DriverQrScannerDialog> createState() => _DriverQrScannerDialogState();
}

class _DriverQrScannerDialogState extends State<DriverQrScannerDialog> {
  bool _isScanning = true;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    // Simulate camera scanning delay and recognition
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _isSuccess = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan Customer QR Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _isSuccess ? AppColors.success : AppColors.primary, width: 3),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isScanning) ...[
                    const Positioned.fill(
                      child: Center(
                        child: Text(
                          '📷 Align viewfinder with\nCustomer QR Code...',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                      ),
                    ),
                  ] else ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle, color: AppColors.success, size: 64),
                        SizedBox(height: 8),
                        Text(
                          'QR Verified!',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Order Identity Authenticated',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payload: ${widget.order.qrCodePayload}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSuccess
                    ? () {
                        widget.onVerified();
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('Confirm Item Collection'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
