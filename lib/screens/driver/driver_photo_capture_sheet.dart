import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DriverPhotoCaptureSheet extends StatefulWidget {
  final String title;
  final String instruction;
  final String photoCategoryKey;
  final bool isFrontCameraDefault;

  const DriverPhotoCaptureSheet({
    super.key,
    required this.title,
    required this.instruction,
    required this.photoCategoryKey,
    this.isFrontCameraDefault = false,
  });

  /// Static helper to open the interactive camera sheet and return the captured photo identifier
  static Future<String?> capturePhoto(
    BuildContext context, {
    required String title,
    required String instruction,
    required String photoCategoryKey,
    bool isFrontCameraDefault = false,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DriverPhotoCaptureSheet(
        title: title,
        instruction: instruction,
        photoCategoryKey: photoCategoryKey,
        isFrontCameraDefault: isFrontCameraDefault,
      ),
    );
  }

  @override
  State<DriverPhotoCaptureSheet> createState() => _DriverPhotoCaptureSheetState();
}

class _DriverPhotoCaptureSheetState extends State<DriverPhotoCaptureSheet>
    with SingleTickerProviderStateMixin {
  late bool _isFrontCamera;
  bool _isFlashOn = false;
  bool _isCaptured = false;
  bool _isShutterFlashing = false;
  late DateTime _captureTime;
  String? _capturedPhotoName;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _isFrontCamera = widget.isFrontCameraDefault;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerShutter() {
    setState(() {
      _isShutterFlashing = true;
    });

    Timer(const Duration(milliseconds: 180), () {
      if (mounted) {
        setState(() {
          _isShutterFlashing = false;
          _isCaptured = true;
          _captureTime = DateTime.now();
          final timestamp = _captureTime.millisecondsSinceEpoch;
          _capturedPhotoName = '${widget.photoCategoryKey}_proof_$timestamp.jpg';
        });
      }
    });
  }

  void _retakePhoto() {
    setState(() {
      _isCaptured = false;
      _capturedPhotoName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.primaryLight,
                                width: 0.8,
                              ),
                            ),
                            child: const Text(
                              'REQUIRED AUDIT PHOTO',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                  tooltip: 'Cancel',
                ),
              ],
            ),
          ),

          // Subtitle instruction
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.instruction,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Camera Viewfinder / Preview Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Base camera background
                    Container(
                      color: const Color(0xFF1E293B),
                    ),

                    if (!_isCaptured) ...[
                      // Viewfinder simulation
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CameraGridPainter(),
                        ),
                      ),

                      // Camera preview illustration & subject
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isFrontCamera
                                  ? Icons.face_retouching_natural
                                  : _getCategoryIcon(widget.photoCategoryKey),
                              size: 72,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isFrontCamera
                                  ? 'Driver Front Camera View'
                                  : 'Align target inside bracket',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _isFrontCamera
                                    ? '📷 Front Portrait Lens Active'
                                    : '📸 HD Rear Vehicle Lens Active',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Live Bracket Corners
                      const _ViewfinderBrackets(),

                      // Top camera controls
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Row(
                          children: [
                            // Flash toggle
                            GestureDetector(
                              onTap: () {
                                setState(() => _isFlashOn = !_isFlashOn);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _isFlashOn
                                        ? Colors.amber
                                        : Colors.white24,
                                  ),
                                ),
                                child: Icon(
                                  _isFlashOn
                                      ? Icons.flash_on
                                      : Icons.flash_off,
                                  color: _isFlashOn
                                      ? Colors.amber
                                      : Colors.white70,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Flip camera
                            GestureDetector(
                              onTap: () {
                                setState(() => _isFrontCamera = !_isFrontCamera);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Icon(
                                  Icons.flip_camera_ios,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Captured Image Preview Screen
                      _buildCapturedPreview(),
                    ],

                    // GPS & Timestamp Overlay HUD (Bottom Left of Camera)
                    Positioned(
                      bottom: 12,
                      left: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.gps_fixed,
                                  size: 12,
                                  color: Colors.greenAccent,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '25.2867° N, 51.5333° E • Doha, QA',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'ID: DRV-QA-8821',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Shutter flash white overlay
                    if (_isShutterFlashing)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Controls Area
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: _isCaptured
                ? Row(
                    children: [
                      // Retake button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _retakePhoto,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retake Photo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Confirm & Use button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context, _capturedPhotoName);
                          },
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text(
                            'Accept & Use Photo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // Shutter button
                      GestureDetector(
                        onTap: _triggerShutter,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt,
                                color: Color(0xFF0F172A),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap shutter to capture photo proof',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedPreview() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            _getCategoryColor(widget.photoCategoryKey).withValues(alpha: 0.35),
            const Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.success, width: 2.5),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(widget.photoCategoryKey),
                  size: 46,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: AppColors.success, size: 18),
                SizedBox(width: 6),
                Text(
                  'Photo Captured & Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _capturedPhotoName ?? 'proof_image.jpg',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Audit Watermark: ${_formatTime(_captureTime)} • QA-GPS Authenticated',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  IconData _getCategoryIcon(String key) {
    switch (key.toLowerCase()) {
      case 'selfie':
        return Icons.person_pin;
      case 'van':
        return Icons.local_shipping;
      case 'plate':
        return Icons.pin;
      case 'hanger':
        return Icons.dry_cleaning;
      case 'laundry':
      case 'laundry_setup':
        return Icons.local_laundry_service;
      case 'collection_proof':
        return Icons.inventory_2;
      case 'delivery_proof':
        return Icons.task_alt;
      case 'location_proof':
        return Icons.location_on;
      case 'call_log':
        return Icons.phone_in_talk;
      default:
        return Icons.camera_alt;
    }
  }

  Color _getCategoryColor(String key) {
    switch (key.toLowerCase()) {
      case 'selfie':
        return Colors.blue;
      case 'van':
        return Colors.teal;
      case 'plate':
        return Colors.amber;
      case 'hanger':
        return Colors.purple;
      case 'laundry':
      case 'laundry_setup':
        return Colors.cyan;
      case 'collection_proof':
        return Colors.indigo;
      case 'delivery_proof':
        return Colors.green;
      case 'location_proof':
        return Colors.red;
      case 'call_log':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }
}

class _ViewfinderBrackets extends StatelessWidget {
  const _ViewfinderBrackets();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Stack(
          children: [
            // Top Left
            Positioned(
              top: 0,
              left: 0,
              child: _bracketCorner(true, true),
            ),
            // Top Right
            Positioned(
              top: 0,
              right: 0,
              child: _bracketCorner(true, false),
            ),
            // Bottom Left
            Positioned(
              bottom: 0,
              left: 0,
              child: _bracketCorner(false, true),
            ),
            // Bottom Right
            Positioned(
              bottom: 0,
              right: 0,
              child: _bracketCorner(false, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bracketCorner(bool isTop, bool isLeft) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Colors.white, width: 2.5)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Colors.white, width: 2.5)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Colors.white, width: 2.5)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Colors.white, width: 2.5)
              : BorderSide.none,
        ),
      ),
    );
  }
}

class _CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    // Two vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );

    // Two horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A reusable Card widget to display a required photo tile with "Take Photo" or "Uploaded" status
class DriverPhotoUploadTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String photoCategoryKey;
  final String? uploadedPhotoName;
  final bool isRequired;
  final VoidCallback onTap;

  const DriverPhotoUploadTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.photoCategoryKey,
    required this.uploadedPhotoName,
    this.isRequired = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = uploadedPhotoName != null && uploadedPhotoName!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: hasPhoto ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasPhoto ? const Color(0xFF86EFAC) : AppColors.border,
          width: hasPhoto ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Thumbnail or Camera Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: hasPhoto
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasPhoto
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      hasPhoto ? Icons.check_circle : Icons.camera_alt,
                      color: hasPhoto ? AppColors.success : AppColors.primary,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (isRequired) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: hasPhoto
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                hasPhoto ? 'DONE' : 'REQUIRED',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: hasPhoto
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasPhoto
                            ? '✅ Verified: $uploadedPhotoName'
                            : subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: hasPhoto
                              ? const Color(0xFF166534)
                              : AppColors.textMuted,
                          fontWeight:
                              hasPhoto ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: hasPhoto
                        ? Colors.white
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasPhoto
                          ? const Color(0xFFBBF7D0)
                          : AppColors.primaryLight.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasPhoto ? Icons.edit : Icons.add_a_photo,
                        size: 13,
                        color: hasPhoto
                            ? const Color(0xFF15803D)
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasPhoto ? 'Retake' : 'Capture',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: hasPhoto
                              ? const Color(0xFF15803D)
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
