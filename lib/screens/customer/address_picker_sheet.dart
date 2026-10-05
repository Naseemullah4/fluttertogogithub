import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../theme/app_colors.dart';

class AddressPickerSheet extends StatefulWidget {
  final CustomerAddress currentAddress;
  final Function(CustomerAddress newAddress) onSaved;

  const AddressPickerSheet({
    super.key,
    required this.currentAddress,
    required this.onSaved,
  });

  @override
  State<AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends State<AddressPickerSheet> {
  late TextEditingController _buildingController;
  late TextEditingController _streetController;
  late TextEditingController _zoneController;
  late TextEditingController _apartmentController;
  late TextEditingController _cityController;
  bool _isGpsPinpointing = false;

  @override
  void initState() {
    super.initState();
    _buildingController = TextEditingController(text: widget.currentAddress.buildingNo);
    _streetController = TextEditingController(text: widget.currentAddress.streetNo);
    _zoneController = TextEditingController(text: widget.currentAddress.zoneNo);
    _apartmentController = TextEditingController(text: widget.currentAddress.apartmentRoom);
    _cityController = TextEditingController(text: widget.currentAddress.city);
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _streetController.dispose();
    _zoneController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _simulateGpsPinpoint() {
    setState(() => _isGpsPinpointing = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _isGpsPinpointing = false;
          _buildingController.text = '72';
          _streetController.text = 'Porto Arabia Boardwalk';
          _zoneController.text = '66';
          _apartmentController.text = '1802';
          _cityController.text = 'The Pearl, Doha';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 GPS location pinpointed: The Pearl, Doha'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery Address Onboarding',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: _isGpsPinpointing ? null : _simulateGpsPinpoint,
                  icon: _isGpsPinpointing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, size: 16),
                  label: const Text('GPS Auto-Pinpoint'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFE2E8F0),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.8,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueGrey.shade100,
                              Colors.teal.shade50,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pin_drop, color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'GPS Map Coordinates: 25.2854° N, 51.5310° E',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buildingController,
                    decoration: const InputDecoration(labelText: 'Building No *'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _zoneController,
                    decoration: const InputDecoration(labelText: 'Zone No *'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _streetController,
              decoration: const InputDecoration(labelText: 'Street Name / Number *'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _apartmentController,
                    decoration: const InputDecoration(labelText: 'Apt / Villa / Room No *'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City *'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final newAddr = CustomerAddress(
                    buildingNo: _buildingController.text.trim(),
                    streetNo: _streetController.text.trim(),
                    zoneNo: _zoneController.text.trim(),
                    apartmentRoom: _apartmentController.text.trim(),
                    city: _cityController.text.trim(),
                  );
                  widget.onSaved(newAddr);
                  Navigator.pop(context);
                },
                child: const Text('Save & Apply Address', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
