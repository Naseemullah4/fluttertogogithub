import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/laundry.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uniwash_logo.dart';

class LaundryProfileDialog extends StatefulWidget {
  final LaundryBranch laundry;

  const LaundryProfileDialog({super.key, required this.laundry});

  static void show(BuildContext context, LaundryBranch laundry) {
    showDialog(
      context: context,
      builder: (ctx) => LaundryProfileDialog(laundry: laundry),
    );
  }

  @override
  State<LaundryProfileDialog> createState() => _LaundryProfileDialogState();
}

class _LaundryProfileDialogState extends State<LaundryProfileDialog> {
  bool _isPasswordVisible = false;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(text: widget.laundry.systemPassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _showPasswordResetDialog() {
    final editController = TextEditingController(text: widget.laundry.systemPassword);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Laundry Branch Password', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Updating manager password for ${widget.laundry.name} (${widget.laundry.userId}).', style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
                state.updateLaundryPassword(widget.laundry.id, editController.text.trim());
                setState(() {
                  _passwordController.text = editController.text.trim();
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Laundry branch password updated successfully! Admin can provide this to manager.')),
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
    final laundry = widget.laundry;
    final stats = laundry.stats;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 860),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              children: [
                const UniWashLogo.badge(size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            laundry.name,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: laundry.warningStatus.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              laundry.warningStatus.displayName,
                              style: TextStyle(color: laundry.warningStatus.color, fontWeight: FontWeight.w800, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'CR: ${laundry.legalRegNumber} • Manager: ${laundry.managerName} • Tel: ${laundry.phone}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Generating official PDF audit report for ${laundry.name}...')),
                    );
                  },
                  icon: const Icon(Icons.print_rounded, size: 16),
                  label: const Text('Print Audit Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),

            // Scrollable Content
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
                              Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF38BDF8), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'BRANCH ACCESS CREDENTIALS (ADMIN RECOVERY VAULT)',
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
                                      const Text('BRANCH USER ID', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 4),
                                      SelectableText(
                                        laundry.userId,
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
                                      const Text('BRANCH PASSWORD', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _isPasswordVisible ? laundry.systemPassword : '••••••••••••',
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
                            '* If the branch manager or laundry staff forgets their login password, the administrator can retrieve or reset it here at any time.',
                            style: TextStyle(color: Colors.white60, fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SECTION: Daily Operational Counters (Daily kitna aya, kitna recved, kitna tayar)
                    Row(
                      children: [
                        const Icon(Icons.today_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Today\'s Operational Progress (Daily Breakdown)',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                          child: Text('Live Today Revenue: ${state.formatCurrency(stats.todayGrossRevenue)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _buildMetricCard('Orders Received', '${stats.todayReceived}', 'Incoming today', Icons.inbox_rounded, const Color(0xFF2563EB)),
                        const SizedBox(width: 10),
                        _buildMetricCard('In Washing / Processing', '${stats.todayInProcessing}', 'Washing & Dry Clean', Icons.local_laundry_service_rounded, const Color(0xFFD97706)),
                        const SizedBox(width: 10),
                        _buildMetricCard('Orders Ready (Tayar)', '${stats.todayReady}', 'Ready for pickup', Icons.check_circle_outline_rounded, const Color(0xFF16A34A)),
                        const SizedBox(width: 10),
                        _buildMetricCard('Delivered Today', '${stats.todayDelivered}', 'Dispatched to customer', Icons.task_alt_rounded, const Color(0xFF0D9488)),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // SECTION: Periodic Comparison (Weekly, Monthly, Yearly, Lifetime)
                    const Row(
                      children: [
                        Icon(Icons.timeline_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Periodic Lifetime Records (Weekly, Monthly, Yearly, Lifetime)',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                            ),
                            child: const Row(
                              children: [
                                Expanded(flex: 3, child: Text('Time Period', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF475569)))),
                                Expanded(flex: 3, child: Text('Orders Handled', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF475569)))),
                                Expanded(flex: 3, child: Text('Gross Earnings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF475569)))),
                                Expanded(flex: 3, child: Text('Commission (15%)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF475569)))),
                                Expanded(flex: 3, child: Text('Net Branch Payout', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF475569)))),
                              ],
                            ),
                          ),
                          _buildPeriodicRow('Today', stats.todayReceived, stats.todayGrossRevenue, state),
                          const Divider(height: 1),
                          _buildPeriodicRow('Weekly (Past 7 Days)', stats.weeklyOrders, stats.weeklyRevenue, state),
                          const Divider(height: 1),
                          _buildPeriodicRow('Monthly (This Month)', stats.monthlyOrders, stats.monthlyRevenue, state),
                          const Divider(height: 1),
                          _buildPeriodicRow('Yearly (Current Year)', stats.yearlyOrders, stats.yearlyRevenue, state),
                          const Divider(height: 1),
                          _buildPeriodicRow('Lifetime (Forever Retained)', stats.lifetimeOrders, stats.lifetimeRevenue, state, isLifetime: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // SECTION: Legal & Digital Documents Folder
                    Row(
                      children: [
                        const Icon(Icons.folder_shared_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Facility Legal Documents & Commercial Certificates',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                          child: Text('Reg: ${dateFormat.format(laundry.documents.registrationDate)}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
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
                            title: 'Ministry Commercial Registration (CR)',
                            fileName: laundry.documents.crCommercialRegDoc,
                            taxCard: laundry.documents.taxCardNumber,
                            status: 'Verified & Active',
                            statusColor: AppColors.success,
                            icon: Icons.domain_verification_outlined,
                          ),
                          const Divider(height: 1),
                          _buildDocumentItem(
                            title: 'Municipality Health & Industrial License',
                            fileName: laundry.documents.municipalityLicenseDoc,
                            taxCard: 'Inspected by Doha Municipality',
                            status: 'Approved',
                            statusColor: AppColors.success,
                            icon: Icons.health_and_safety_outlined,
                          ),
                          const Divider(height: 1),
                          _buildDocumentItem(
                            title: 'Civil Defense Fire Safety Certificate',
                            fileName: laundry.documents.civilDefenseCertificateDoc,
                            taxCard: 'Fire Extinguishers & Exit Sensors Certified',
                            status: 'Compliant',
                            statusColor: const Color(0xFF0284C7),
                            icon: Icons.fire_extinguisher_outlined,
                          ),
                          const Divider(height: 1),
                          _buildDocumentItem(
                            title: 'Owner QID / Resident Partner ID',
                            fileName: laundry.documents.ownerQidDoc,
                            taxCard: 'Qatar National ID Verified',
                            status: 'Verified',
                            statusColor: AppColors.success,
                            icon: Icons.badge_outlined,
                          ),
                          const Divider(height: 1),
                          _buildDocumentItem(
                            title: 'UniWash Master TM & Franchise Contract',
                            fileName: laundry.documents.signedContractDoc,
                            taxCard: '15% Commission • \$55/day penalty clause',
                            status: 'Signed Contract',
                            statusColor: const Color(0xFF7C3AED),
                            icon: Icons.gavel_rounded,
                          ),
                          const Divider(height: 1),
                          _buildDocumentItem(
                            title: 'Corporate Bank Account & IBAN Certificate',
                            fileName: laundry.documents.bankIbanCertificate,
                            taxCard: 'Automated Daily/Weekly Settlement',
                            status: 'Active IBAN',
                            statusColor: const Color(0xFF059669),
                            icon: Icons.account_balance_outlined,
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

  Widget _buildMetricCard(String title, String count, String subtitle, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Text(count, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
              ],
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF0F172A))),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodicRow(String period, int orders, double gross, StateService state, {bool isLifetime = false}) {
    final commission = gross * 0.15;
    final net = gross - commission;

    return Container(
      color: isLifetime ? const Color(0xFFEFF6FF) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              period,
              style: TextStyle(
                fontWeight: isLifetime ? FontWeight.w900 : FontWeight.w700,
                fontSize: 12,
                color: isLifetime ? const Color(0xFF1E40AF) : const Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '$orders orders',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              state.formatCurrency(gross),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              state.formatCurrency(commission),
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              state.formatCurrency(net),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isLifetime ? const Color(0xFF1E40AF) : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required String fileName,
    required String taxCard,
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
                Text('$fileName • $taxCard', style: const TextStyle(fontSize: 11, color: Colors.black54)),
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
            tooltip: 'Download Document',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading certified file: $fileName')),
              );
            },
          ),
        ],
      ),
    );
  }
}
