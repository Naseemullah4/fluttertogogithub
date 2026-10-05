import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/driver.dart';
import '../../models/laundry.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uniwash_logo.dart';

class DriverFolderDialog extends StatefulWidget {
  final DriverModel driver;

  const DriverFolderDialog({super.key, required this.driver});

  static void show(BuildContext context, DriverModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => DriverFolderDialog(driver: driver),
    );
  }

  @override
  State<DriverFolderDialog> createState() => _DriverFolderDialogState();
}

class _DriverFolderDialogState extends State<DriverFolderDialog> {
  bool _isPasswordVisible = false;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(text: widget.driver.systemPassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _showPasswordResetDialog() {
    final editController = TextEditingController(text: widget.driver.systemPassword);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Driver System Password', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Updating password for ${widget.driver.fullName} (${widget.driver.userId}).', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 12),
            TextField(
              controller: editController,
              decoration: const InputDecoration(
                labelText: 'New System Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                final state = Provider.of<StateService>(context, listen: false);
                state.updateDriverPassword(widget.driver.id, editController.text.trim());
                setState(() {
                  _passwordController.text = editController.text.trim();
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Driver password updated successfully! Admin can provide this to driver.')),
                );
              }
            },
            child: const Text('Save & Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<StateService>(context);
    final dateFormat = DateFormat('yyyy-MM-dd');
    final driver = widget.driver;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 820),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_pin, color: AppColors.primary, size: 30),
                    ),
                    const Positioned(
                      bottom: -2,
                      right: -2,
                      child: UniWashLogo.badge(size: 22),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            driver.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(width: 8),
                          if (driver.starRating > 0) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                driver.starRating,
                                (i) => const Icon(Icons.star_rounded, color: Color(0xFFEAB308), size: 16),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (driver.hasBlueTag)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, color: Colors.white, size: 11),
                                  SizedBox(width: 3),
                                  Text('BLUE TAG', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          if (driver.hasGoldenBadge) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.workspace_premium, color: Colors.white, size: 11),
                                  SizedBox(width: 3),
                                  Text('GOLD BADGE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ],
                          if (driver.hasPremiumDiamondBadge) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.diamond_rounded, color: Colors.white, size: 11),
                                  SizedBox(width: 3),
                                  Text('DIAMOND', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: driver.warningStatus.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              driver.warningStatus.displayName,
                              style: TextStyle(color: driver.warningStatus.color, fontWeight: FontWeight.w800, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Assigned to: ${driver.assignedLaundryName} • Tel: ${driver.phone} • Tier: ${driver.tierBadgeTitle}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),

            // Scrollable Profile & Digital Document Folder
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Credentials Vault Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.vpn_key_rounded, color: Color(0xFF38BDF8), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'SYSTEM ACCESS CREDENTIALS (ADMIN RECOVERY VAULT)',
                                style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('DRIVER USER ID', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 4),
                                      SelectableText(
                                        driver.userId,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('DRIVER PASSWORD', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _isPasswordVisible ? driver.systemPassword : '••••••••••••',
                                              style: const TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'monospace'),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                              size: 16,
                                              color: Colors.white70,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                          ),
                                          const SizedBox(width: 6),
                                          IconButton(
                                            icon: const Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF38BDF8)),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            tooltip: 'Reset Password',
                                            onPressed: _showPasswordResetDialog,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '* If the driver forgets their password or cannot log in to the driver app, the administrator can retrieve or reset it here at any time.',
                            style: TextStyle(color: Colors.white60, fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Driver Milestones, Stars & Order Bonus Ledger
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.military_tech_rounded, color: Color(0xFF16A34A), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'DRIVER PERFORMANCE TIER & ORDER BONUS',
                                    style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w900, fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16A34A),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Current Bonus Rate: ${driver.bonusRatePerOrder.toStringAsFixed(2)} QAR / order',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFDCFCE7))),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Completed Trips', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                      Text('${driver.completedTrips} Orders', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFDCFCE7))),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Performance Stars', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                      Row(
                                        children: [
                                          Text('${driver.starRating} Stars ', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFFEAB308))),
                                          ...List.generate(driver.starRating, (i) => const Icon(Icons.star_rounded, size: 14, color: Color(0xFFEAB308))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFDCFCE7))),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Total Accumulated Bonus', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                      Text('${driver.totalBonusEarnings.toStringAsFixed(1)} QAR', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF16A34A))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '• 50 orders: ⭐ 1 Star (1.00 QAR/ord) | 100 orders: ⭐⭐ 2 Stars (1.50 QAR/ord) | 150 orders: ⭐⭐⭐ 3 Stars\n• 200 orders: 4 Stars + 🛡️ Blue Tag (2.00 QAR/ord) | 250 orders: 🥇 Golden Badge | 300+ orders: 💎 Diamond Badge (3.00 QAR/ord)',
                            style: TextStyle(fontSize: 10, color: Color(0xFF166534), height: 1.4, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick Stats Row
                    Row(
                      children: [
                        _buildStatBox('Trips Completed', '${driver.completedTrips}', Icons.local_shipping_outlined, const Color(0xFF0284C7)),
                        const SizedBox(width: 12),
                        _buildStatBox('Driver Rating', '${driver.rating} ★', Icons.star_rounded, const Color(0xFFEAB308)),
                        const SizedBox(width: 12),
                        _buildStatBox('Today Earnings', state.formatCurrency(driver.todayEarningsQar), Icons.payments_outlined, const Color(0xFF16A34A)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Digital Folder / Documents Cabinet
                    Row(
                      children: [
                        const Icon(Icons.folder_shared_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Driver Digital Folder & Legal Documents',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                          child: Text('Joined: ${dateFormat.format(driver.documents.joinedAt)}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDocumentItem(
                            title: 'Qatar ID / Resident ID Card',
                            fileName: driver.documents.qidDocumentName,
                            docNumber: 'QID: ${driver.qidPassportNumber}',
                            status: 'Verified & Active',
                            statusColor: AppColors.success,
                            icon: Icons.badge_outlined,
                          ),
                          const Divider(height: 1),
                          _buildDocumentItem(
                            title: 'Commercial Driving License',
                            fileName: driver.documents.drivingLicenseDocumentName,
                            docNumber: 'License: ${driver.licenseNumber}',
                            status: 'Valid (Expires 2029)',
                            statusColor: AppColors.success,
                            icon: Icons.drive_eta_outlined,
                          ),
                          const Divider(height: 1),
                          _buildDocumentItem(
                            title: 'Passport & Residency Visa',
                            fileName: '${driver.documents.passportDocumentName} • ${driver.documents.visaDocumentName}',
                            docNumber: 'Nationality: ${driver.documents.nationality}',
                            status: 'Verified',
                            statusColor: AppColors.success,
                            icon: Icons.menu_book_outlined,
                          ),
                          const Divider(height: 1),
                          _buildDocumentItem(
                            title: 'Vehicle Plate & Commercial Permit',
                            fileName: driver.documents.vehicleRegPlate,
                            docNumber: 'Inspection: Passed',
                            status: 'Inspected',
                            statusColor: const Color(0xFF0284C7),
                            icon: Icons.directions_car_filled_outlined,
                          ),
                          const Divider(height: 1),
                          _buildDocumentItem(
                            title: 'Signed Courier Service Contract',
                            fileName: driver.documents.signedContractDocumentName,
                            docNumber: 'UniWash Master Framework Agreement',
                            status: 'Legally Binding',
                            statusColor: const Color(0xFF7C3AED),
                            icon: Icons.draw_outlined,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Admin Warning Level Adjustment
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Operational Warning Escalation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text('Current: ${driver.warningStatus.displayName}', style: TextStyle(fontSize: 11, color: driver.warningStatus.color, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          DropdownButton<WarningLevel>(
                            value: driver.warningStatus,
                            underline: const SizedBox(),
                            onChanged: (newLevel) {
                              if (newLevel != null) {
                                state.setDriverWarning(driver.id, newLevel);
                                setState(() {});
                              }
                            },
                            items: WarningLevel.values.map((lvl) {
                              return DropdownMenuItem<WarningLevel>(
                                value: lvl,
                                child: Text(lvl.displayName, style: TextStyle(fontSize: 12, color: lvl.color, fontWeight: FontWeight.w700)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required String fileName,
    required String docNumber,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text('$fileName • $docNumber', style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 10),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, size: 18, color: Color(0xFF475569)),
            tooltip: 'Download File',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading file: $fileName')),
              );
            },
          ),
        ],
      ),
    );
  }
}
