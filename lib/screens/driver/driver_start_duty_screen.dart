import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/driver.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import 'driver_photo_capture_sheet.dart';

class DriverStartDutyScreen extends StatefulWidget {
  const DriverStartDutyScreen({super.key});

  @override
  State<DriverStartDutyScreen> createState() => _DriverStartDutyScreenState();
}

class _DriverStartDutyScreenState extends State<DriverStartDutyScreen> {
  // 5 Required Photos
  String? _selfiePhoto;
  String? _vanPhoto;
  String? _platePhoto;
  String? _hangerPhoto;
  String? _laundrySetupPhoto;

  // 2 Driver Supplies Confirmations (must select Yes or No for each)
  bool? _has20Bags;
  bool? _has100Tags;

  int get _uploadedPhotosCount {
    int count = 0;
    if (_selfiePhoto != null) count++;
    if (_vanPhoto != null) count++;
    if (_platePhoto != null) count++;
    if (_hangerPhoto != null) count++;
    if (_laundrySetupPhoto != null) count++;
    return count;
  }

  int get _answeredQuestionsCount {
    int count = 0;
    if (_has20Bags != null) count++;
    if (_has100Tags != null) count++;
    return count;
  }

  bool get _isReadyToStartDuty {
    return _uploadedPhotosCount == 5 && _answeredQuestionsCount == 2;
  }

  Future<void> _capture(
    String categoryKey,
    String title,
    String instruction, {
    bool isFrontCamera = false,
  }) async {
    final photo = await DriverPhotoCaptureSheet.capturePhoto(
      context,
      title: title,
      instruction: instruction,
      photoCategoryKey: categoryKey,
      isFrontCameraDefault: isFrontCamera,
    );

    if (photo != null) {
      setState(() {
        switch (categoryKey) {
          case 'selfie':
            _selfiePhoto = photo;
            break;
          case 'van':
            _vanPhoto = photo;
            break;
          case 'plate':
            _platePhoto = photo;
            break;
          case 'hanger':
            _hangerPhoto = photo;
            break;
          case 'laundry_setup':
            _laundrySetupPhoto = photo;
            break;
        }
      });
    }
  }

  void _submitStartDuty() {
    if (!_isReadyToStartDuty) return;

    final state = context.read<StateService>();
    final driver = state.currentDriver;

    final session = DriverDutySession(
      id: 'duty-${DateTime.now().millisecondsSinceEpoch}',
      driverId: driver.userId,
      driverName: driver.fullName,
      startedAt: DateTime.now(),
      selfiePhoto: _selfiePhoto!,
      vanPhoto: _vanPhoto!,
      platePhoto: _platePhoto!,
      hangerPhoto: _hangerPhoto!,
      laundrySetupPhoto: _laundrySetupPhoto!,
      has20Bags: _has20Bags!,
      has100Tags: _has100Tags!,
    );

    state.startDriverDuty(session);

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
                Icons.check_circle,
                color: AppColors.success,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Duty Shift Activated! 🚀',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Driver ${driver.fullName} (${driver.userId}) is now registered ON DUTY with full equipment verification.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  Navigator.pop(context);
                },
                child: const Text('Open Missions Console'),
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
    final driver = state.currentDriver;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Start Daily Duty Shift'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Profile & Vehicle Summary Card
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      driver.fullName.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${driver.userId} • ${driver.documents.vehicleRegPlate}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            'Assigned: ${driver.assignedLaundryName}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Progress Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isReadyToStartDuty
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isReadyToStartDuty
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isReadyToStartDuty
                        ? Icons.check_circle
                        : Icons.info_outline,
                    color: _isReadyToStartDuty
                        ? AppColors.success
                        : const Color(0xFFD97706),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isReadyToStartDuty
                              ? 'All Inspections Complete!'
                              : 'Inspection & Supplies Incomplete',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _isReadyToStartDuty
                                ? const Color(0xFF14532D)
                                : const Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Photos: $_uploadedPhotosCount/5 uploaded • Supplies: $_answeredQuestionsCount/2 confirmed',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: _isReadyToStartDuty
                                ? const Color(0xFF166534)
                                : const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Section 1: Required Photos
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '1. Required Start Duty Photos (5)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Every photo must be uploaded clearly to begin accepting collection or delivery orders.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),

            // Photo 1: Driver Selfie (Required)
            DriverPhotoUploadTile(
              title: 'Driver Selfie',
              subtitle: 'Front selfie in uniform before driving',
              photoCategoryKey: 'selfie',
              uploadedPhotoName: _selfiePhoto,
              onTap: () => _capture(
                'selfie',
                'Driver Selfie',
                'Please take a clear selfie showing your face and uniform before shift starts.',
                isFrontCamera: true,
              ),
            ),

            // Photo 2: Van Photo
            DriverPhotoUploadTile(
              title: 'Van Photo',
              subtitle: 'Full external photo of the laundry van',
              photoCategoryKey: 'van',
              uploadedPhotoName: _vanPhoto,
              onTap: () => _capture(
                'van',
                'Van Photo',
                'Take a clear wide-angle photo of the assigned delivery van.',
              ),
            ),

            // Photo 3: Vehicle Number Plate Photo
            DriverPhotoUploadTile(
              title: 'Vehicle Number Plate Photo',
              subtitle: 'Clear readable photo of vehicle license plate',
              photoCategoryKey: 'plate',
              uploadedPhotoName: _platePhoto,
              onTap: () => _capture(
                'plate',
                'Vehicle Number Plate Photo',
                'Ensure the registration numbers and Qatar logo are fully legible.',
              ),
            ),

            // Photo 4: Hanger Photo
            DriverPhotoUploadTile(
              title: 'Hanger Photo',
              subtitle: 'Photo of the available hangers inside van',
              photoCategoryKey: 'hanger',
              uploadedPhotoName: _hangerPhoto,
              onTap: () => _capture(
                'hanger',
                'Hanger Photo',
                'Take a photo showing clean metal & plastic hangers loaded on the rack.',
              ),
            ),

            // Photo 5: Laundry Photo
            DriverPhotoUploadTile(
              title: 'Laundry Photo',
              subtitle: 'Photo of the vehicle laundry cargo setup',
              photoCategoryKey: 'laundry_setup',
              uploadedPhotoName: _laundrySetupPhoto,
              onTap: () => _capture(
                'laundry_setup',
                'Laundry Photo',
                'Take a photo of the laundry / vehicle laundry cargo setup area.',
              ),
            ),

            const SizedBox(height: 22),

            // Section 2: Driver Supplies Confirmation
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '2. Driver Supplies Confirmation',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Select one option for each question to confirm inventory on board.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),

            // Question 1: Do you have 20 bags?
            _buildConfirmationQuestionCard(
              title: 'Do you have 20 bags?',
              subtitle: 'Standard UniWash heavy-duty laundry collection bags',
              currentSelection: _has20Bags,
              onChanged: (val) => setState(() => _has20Bags = val),
            ),

            const SizedBox(height: 12),

            // Question 2: Do you have 100 tags?
            _buildConfirmationQuestionCard(
              title: 'Do you have 100 tags?',
              subtitle: 'Heat-resistant tracking barcode tags for garment bundles',
              currentSelection: _has100Tags,
              onChanged: (val) => setState(() => _has100Tags = val),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isReadyToStartDuty ? _submitStartDuty : null,
                icon: const Icon(Icons.flash_on, size: 20),
                label: Text(
                  _isReadyToStartDuty
                      ? 'Confirm & Start Duty Shift'
                      : 'Complete All Requirements Above ($_uploadedPhotosCount/5 Photos, $_answeredQuestionsCount/2 Supplies)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: _isReadyToStartDuty ? 3 : 0,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationQuestionCard({
    required String title,
    required String subtitle,
    required bool? currentSelection,
    required ValueChanged<bool> onChanged,
  }) {
    final isAnswered = currentSelection != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAnswered ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAnswered ? const Color(0xFFCBD5E1) : AppColors.border,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isAnswered ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isAnswered ? 'ANSWERED' : 'REQUIRED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: isAnswered
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Radio option buttons: Yes / No
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onChanged(true),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: currentSelection == true
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: currentSelection == true
                            ? AppColors.success
                            : const Color(0xFFE2E8F0),
                        width: currentSelection == true ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          currentSelection == true
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 16,
                          color: currentSelection == true
                              ? AppColors.success
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Yes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: currentSelection == true
                                ? const Color(0xFF14532D)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => onChanged(false),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: currentSelection == false
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: currentSelection == false
                            ? AppColors.error
                            : const Color(0xFFE2E8F0),
                        width: currentSelection == false ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          currentSelection == false
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 16,
                          color: currentSelection == false
                              ? AppColors.error
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: currentSelection == false
                                ? const Color(0xFF7F1D1D)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
