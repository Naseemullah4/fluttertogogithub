import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/audit_log.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/stat_card.dart';

class SuperAdminAuditLogsTab extends StatefulWidget {
  final bool isAr;

  const SuperAdminAuditLogsTab({super.key, this.isAr = false});

  @override
  State<SuperAdminAuditLogsTab> createState() => _SuperAdminAuditLogsTabState();
}

class _SuperAdminAuditLogsTabState extends State<SuperAdminAuditLogsTab> {
  String _searchQuery = '';
  AuditActionType? _actionFilter;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = widget.isAr;
    final logs = state.auditLogs;

    final filtered = logs.where((l) {
      if (_actionFilter != null && l.actionType != _actionFilter) return false;
      if (_searchQuery.isEmpty) return true;
      return l.performedBy.toLowerCase().contains(_searchQuery) ||
          l.entity.toLowerCase().contains(_searchQuery) ||
          l.entityId.toLowerCase().contains(_searchQuery) ||
          l.reason.toLowerCase().contains(_searchQuery) ||
          l.newValue.toLowerCase().contains(_searchQuery);
    }).toList();

    final dateFormat = DateFormat('yyyy-MM-dd • hh:mm:ss a');

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Header & Overview
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history_edu_rounded, color: AppColors.primary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? 'سجل التدقيق الإداري والامتثال الأمني' : 'Enterprise Audit Logs & Compliance Trail',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr
                            ? 'تسجيل غير قابل للتعديل لجميع العمليات الإدارية، تصحيح الحالات، وتعديلات الصلاحيات'
                            : 'Immutable audit ledger of administrative modifications, state overrides, assignments, and governance actions',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: Text(isAr ? 'تصدير السجل' : 'Export Audit CSV', style: const TextStyle(fontSize: 12)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Audit Trail exported to uniwash_audit_ledger.csv'), backgroundColor: Color(0xFF0F172A)),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Metrics
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'إجمالي الأحداث المسجلة' : 'Logged Events',
                        value: '${logs.length} Entries',
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'تعديلات الطلبات' : 'Order Corrections',
                        value: '${logs.where((l) => l.actionType == AuditActionType.orderStatusCorrected).length} Overrides',
                        icon: Icons.edit_note_rounded,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'إعادة إسناد السائقين' : 'Fleet Reassignments',
                        value: '${logs.where((l) => l.actionType == AuditActionType.orderDriverReassigned).length} Events',
                        icon: Icons.swap_horiz_rounded,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'إدارة المشرفين' : 'Admin Governance',
                        value: '${logs.where((l) => l.actionType == AuditActionType.adminCreated || l.actionType == AuditActionType.adminEdited).length} Changes',
                        icon: Icons.admin_panel_settings_rounded,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search & Filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                          decoration: InputDecoration(
                            hintText: isAr ? 'بحث بالمسؤول، الكيان، السبب، المعرف...' : 'Search operator, entity, reason, delta value...',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Logs Table Feed
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.manage_search_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(isAr ? 'لا توجد سجلات مطابقة للبحث' : 'No audit entries found matching search query', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final log = filtered[idx];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: log.actionType.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(log.actionType.icon, size: 16, color: log.actionType.color),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  log.actionType.title,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                  child: Text('${log.entity}: ${log.entityId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                ),
                                const Spacer(),
                                Text(
                                  dateFormat.format(log.timestamp),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Value Change Delta
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Text('From: ', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                                        Text(log.previousValue, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward, size: 12, color: AppColors.textMuted),
                                        const SizedBox(width: 8),
                                        const Text('To: ', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                                        Text(log.newValue, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Reason & Performed By
                            Row(
                              children: [
                                const Icon(Icons.comment_outlined, size: 13, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Reason: "${log.reason}"',
                                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF475569)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.person_pin_rounded, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  'By: ${log.performedBy} (${log.performedByRole})',
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
