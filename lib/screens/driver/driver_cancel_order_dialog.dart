import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import 'driver_photo_capture_sheet.dart';

class DriverCancelOrderDialog extends StatefulWidget {
  final LaundryOrder order;

  const DriverCancelOrderDialog({super.key, required this.order});

  static Future<bool?> show(BuildContext context, LaundryOrder order) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DriverCancelOrderDialog(order: order),
    );
  }

  @override
  State<DriverCancelOrderDialog> createState() => _DriverCancelOrderDialogState();
}

class _DriverCancelOrderDialogState extends State<DriverCancelOrderDialog> {
  // Category: 'customer' or 'company'
  String _selectedCategory = 'customer';
  String? _selectedReason;
  final TextEditingController _customDescriptionController =
      TextEditingController();

  // Required Proof
  String? _locationPhoto;
  String? _callLogPhoto;

  // Optional Proofs
  final List<String> _additionalPhotos = [];

  static const List<String> _customerReasons = [
    'Customer mistake',
    'Customer not answering the call',
    'Customer did not reply',
    'Wrong location',
    'Apartment number not mentioned',
    'Building number not mentioned',
    'Customer name not mentioned',
    'Other',
  ];

  static const List<String> _companyReasons = [
    'Cannot find the location',
    'Transportation problem',
    'Other',
  ];

  @override
  void dispose() {
    _customDescriptionController.dispose();
    super.dispose();
  }

  bool get _isOtherSelected => _selectedReason == 'Other';

  bool get _isReasonValid {
    if (_selectedReason == null) return false;
    if (_isOtherSelected && _customDescriptionController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  bool get _isProofComplete {
    return _locationPhoto != null && _callLogPhoto != null;
  }

  bool get _canSubmitCancellation => _isReasonValid && _isProofComplete;

  Future<void> _captureProof(String type) async {
    String title;
    String instruction;
    String key;

    switch (type) {
      case 'location':
        title = 'Photo of Location (Arrival Proof)';
        instruction =
            'Take a photo of the place/building entrance where you reached for this order.';
        key = 'location_proof';
        break;
      case 'call_log':
        title = 'Call Log Proof';
        instruction =
            'Capture screenshot or photo of your phone call log showing attempts to call the customer.';
        key = 'call_log';
        break;
      default:
        title = 'Additional Cancellation Proof';
        instruction =
            'Capture customer messages screenshot, building gate, or GPS evidence.';
        key = 'additional_proof';
    }

    final photo = await DriverPhotoCaptureSheet.capturePhoto(
      context,
      title: title,
      instruction: instruction,
      photoCategoryKey: key,
    );

    if (photo != null) {
      setState(() {
        if (type == 'location') {
          _locationPhoto = photo;
        } else if (type == 'call_log') {
          _callLogPhoto = photo;
        } else {
          _additionalPhotos.add(photo);
        }
      });
    }
  }

  void _confirmCancelOrder() {
    if (!_canSubmitCancellation) return;

    final state = context.read<StateService>();
    final categoryName = _selectedCategory == 'customer'
        ? 'Customer-Related'
        : 'Driver/Company-Related';

    state.cancelOrderWithProof(
      orderId: widget.order.id,
      reasonCategory: categoryName,
      reason: _selectedReason!,
      customDescription: _isOtherSelected
          ? _customDescriptionController.text.trim()
          : null,
      locationPhoto: _locationPhoto!,
      callLogPhoto: _callLogPhoto!,
      additionalPhotos: _additionalPhotos,
    );

    Navigator.pop(context, true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '❌ Order #${widget.order.orderNumber} successfully marked as Cancelled.',
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 720),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancel Order #${widget.order.orderNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Customer: ${widget.order.customerName} (${widget.order.customerPhone})',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
            ),

            // Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Cancellation Category & Reasons
                    const Text(
                      '1. Select Cancellation Reason Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Category Toggle Pills
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Customer-Related'),
                            selected: _selectedCategory == 'customer',
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedCategory = 'customer';
                                  _selectedReason = null;
                                });
                              }
                            },
                            selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _selectedCategory == 'customer'
                                  ? AppColors.primaryDark
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Driver / Company'),
                            selected: _selectedCategory == 'company',
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedCategory = 'company';
                                  _selectedReason = null;
                                });
                              }
                            },
                            selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _selectedCategory == 'company'
                                  ? AppColors.primaryDark
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Specific Reason Options List
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: (_selectedCategory == 'customer'
                                ? _customerReasons
                                : _companyReasons)
                            .map((reason) {
                          final isSelected = _selectedReason == reason;
                          return InkWell(
                            onTap: () {
                              setState(() => _selectedReason = reason);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.shade50
                                    : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 0.8,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      reason,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.primaryDark
                                            : const Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // If Other: Required Description Field
                    if (_isOtherSelected) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.edit_note, size: 16, color: Colors.orange),
                                SizedBox(width: 6),
                                Text(
                                  'Please describe the reason in a few words (Required *):',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _customDescriptionController,
                              maxLines: 2,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Explain why the order cannot be delivered...',
                                hintStyle: const TextStyle(fontSize: 12),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.amber.shade300),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),

                    // Section 2: Required Proof
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'REQUIRED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '2. Required Cancellation Proof',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Both photos are strictly required before company cancellation approval.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Required Proof 1: Photo of Location
                    DriverPhotoUploadTile(
                      title: '1. Photo of Location',
                      subtitle: 'Driver takes photo where they reached for order',
                      photoCategoryKey: 'location_proof',
                      uploadedPhotoName: _locationPhoto,
                      onTap: () => _captureProof('location'),
                    ),

                    // Required Proof 2: Call Log Proof
                    DriverPhotoUploadTile(
                      title: '2. Call Log Proof',
                      subtitle: 'Screenshot/photo of call log attempting to reach customer',
                      photoCategoryKey: 'call_log',
                      uploadedPhotoName: _callLogPhoto,
                      onTap: () => _captureProof('call_log'),
                    ),

                    const SizedBox(height: 14),

                    // Section 3: Optional Additional Proof
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'OPTIONAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Optional Additional Proof',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Screenshot of customer messages, building entrance, or GPS proof.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // List of added additional proofs
                    if (_additionalPhotos.isNotEmpty) ...[
                      Column(
                        children: _additionalPhotos.map((photo) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.attachment,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    photo,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _additionalPhotos.remove(photo);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    OutlinedButton.icon(
                      onPressed: () => _captureProof('additional'),
                      icon: const Icon(Icons.add_photo_alternate, size: 16),
                      label: const Text('Add Optional Proof Photo'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Submit Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Go Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _canSubmitCancellation ? _confirmCancelOrder : null,
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text(
                        'Submit Cancellation',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
