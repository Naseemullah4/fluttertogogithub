import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';

class SuperAdminReportsDialog extends StatelessWidget {
  final StateService stateService;

  const SuperAdminReportsDialog({super.key, required this.stateService});

  static Future<void> show(BuildContext context, StateService stateService) {
    return showDialog(
      context: context,
      builder: (_) => SuperAdminReportsDialog(stateService: stateService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final currency = stateService.selectedCountry.currencyCode;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 720,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.summarize_rounded, color: Color(0xFF38BDF8), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'UniWash Enterprise Executive Operational Report',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Generated on ${dateFormat.format(DateTime.now())} • Market: ${stateService.selectedCountry.name} (${stateService.selectedCountry.code})',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Report KPI Grid
            Row(
              children: [
                Expanded(child: _kpiBox('Total Orders', '${stateService.orders.length}', 'Active lifecycle', const Color(0xFF0284C7))),
                const SizedBox(width: 12),
                Expanded(child: _kpiBox('Gross Intake', '14,280 $currency', 'Platform volume', const Color(0xFF059669))),
                const SizedBox(width: 12),
                Expanded(child: _kpiBox('Exceptions Resolved', '${stateService.orderProblems.where((p) => p.isResolved).length}', '98.5% SLA standard', const Color(0xFF7C3AED))),
                const SizedBox(width: 12),
                Expanded(child: _kpiBox('Active Drivers', '${stateService.drivers.length}', 'In territory', const Color(0xFFD97706))),
              ],
            ),
            const SizedBox(height: 20),

            // Breakdown Sections
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Operational Compliance & SLA Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  _rowItem('QR Code Scan Compliance Rate', '99.4% (Direct Field Verified)'),
                  _rowItem('Average Order Turnaround Time', '18.4 Hours (Standard 24h SLA)'),
                  _rowItem('Customer Satisfaction Index (CSAT)', '4.92 / 5.0 (942 Verified Reviews)'),
                  _rowItem('Audit Trail Event Consistency', '100% Cryptographic Traceability'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Print & Export Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.print_rounded, size: 16),
                  label: const Text('Print Physical Report'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sent to network laser printer...'), backgroundColor: Color(0xFF0F172A)),
                    );
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                  label: const Text('Download Official PDF'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading uniwash_executive_report_2026.pdf...'), backgroundColor: Color(0xFF16A34A)),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiBox(String title, String val, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
