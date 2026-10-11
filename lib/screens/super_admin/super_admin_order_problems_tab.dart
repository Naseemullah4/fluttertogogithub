import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/order_problem.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/stat_card.dart';
import '../common/order_detail_dialog.dart';

class SuperAdminOrderProblemsTab extends StatefulWidget {
  final bool isAr;

  const SuperAdminOrderProblemsTab({super.key, this.isAr = false});

  @override
  State<SuperAdminOrderProblemsTab> createState() => _SuperAdminOrderProblemsTabState();
}

class _SuperAdminOrderProblemsTabState extends State<SuperAdminOrderProblemsTab> {
  String _searchQuery = '';
  String _statusFilter = 'unresolved'; // 'all', 'unresolved', 'resolved'
  ProblemSeverity? _severityFilter;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = widget.isAr;
    final problems = state.orderProblems;

    final unresolved = problems.where((p) => !p.isResolved).length;
    final criticalCount = problems.where((p) => !p.isResolved && p.severity == ProblemSeverity.critical).length;
    final highCount = problems.where((p) => !p.isResolved && p.severity == ProblemSeverity.high).length;

    final filtered = problems.where((p) {
      if (_statusFilter == 'unresolved' && p.isResolved) return false;
      if (_statusFilter == 'resolved' && !p.isResolved) return false;
      if (_severityFilter != null && p.severity != _severityFilter) return false;

      if (_searchQuery.isEmpty) return true;
      return p.orderNumber.toString().contains(_searchQuery) ||
          p.customerName.toLowerCase().contains(_searchQuery) ||
          p.description.toLowerCase().contains(_searchQuery) ||
          p.branchName.toLowerCase().contains(_searchQuery) ||
          p.type.title.toLowerCase().contains(_searchQuery);
    }).toList();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Banner & Metrics Header
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
                            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? 'مركز معالجة المشكلات والاستثناءات التشغيلية' : 'Order Problems & Operational Exceptions Hub',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr
                            ? 'معالجة فورية لأخطاء مسح QR، الصور المفقودة، تأخر السائقين، وتصحيح الحالات مع سجل تدقيق'
                            : 'Immediate resolution for QR anomalies, missing proofs, delays, and controlled state corrections with audit trail',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.build_circle_outlined, size: 16, color: Color(0xFF38BDF8)),
                      label: Text(
                        isAr ? 'أدوات التصحيح الإداري' : 'Quick Order Correction Tools',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showQuickCorrectionSelector(context, state),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Metrics
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'المشكلات المفتوحة' : 'Unresolved Exceptions',
                        value: '$unresolved Active',
                        icon: Icons.error_outline_rounded,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'أخطاء حرجة (Critical)' : 'Critical SLA Breaches',
                        value: '$criticalCount Cases',
                        icon: Icons.priority_high_rounded,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'أولوية عالية (High)' : 'High Priority',
                        value: '$highCount Cases',
                        icon: Icons.flag_rounded,
                        color: const Color(0xFFEA580C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'تمت تسويتها اليوم' : 'Resolved Today',
                        value: '${problems.where((p) => p.isResolved).length} Closed',
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Filter Bar
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
                            hintText: isAr ? 'بحث بالطلب، العميل، الفرع، نوع المشكلة...' : 'Search Order #, customer, branch, problem type...',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Wrap(
                      spacing: 6,
                      children: [
                        _statusFilterChip('Unresolved ($unresolved)', 'unresolved'),
                        _statusFilterChip('Resolved (${problems.where((p) => p.isResolved).length})', 'resolved'),
                        _statusFilterChip('All (${problems.length})', 'all'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Problem Cards Feed
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.task_alt_rounded, size: 48, color: Color(0xFF16A34A)),
                        const SizedBox(height: 8),
                        Text(
                          isAr ? 'لا توجد مشكلات معلقة تطابق المعايير' : 'No operational exceptions found matching criteria',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final prob = filtered[idx];
                      return _buildProblemCard(context, state, prob);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemCard(BuildContext context, StateService state, OrderProblem prob) {
    final dateFormat = DateFormat('MMM dd, hh:mm a');
    final matchingOrder = state.orders.firstWhere((o) => o.id == prob.orderId, orElse: () => state.orders.first);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: prob.isResolved ? const Color(0xFFE2E8F0) : prob.severity.color.withValues(alpha: 0.5),
          width: prob.isResolved ? 1.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Severity Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: prob.severity.bgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: prob.severity.color.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: prob.severity.color),
                      const SizedBox(width: 4),
                      Text(
                        prob.severity.label.toUpperCase(),
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: prob.severity.color),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            prob.type.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(4)),
                            child: Text('#${prob.orderNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          Text('• ${prob.customerName}', style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                          const Spacer(),
                          BadgePill(
                            label: prob.isResolved ? 'Resolved' : 'Action Required',
                            color: prob.isResolved ? const Color(0xFF16A34A) : prob.severity.color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        prob.description,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.storefront_rounded, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text('${prob.branchName} (${prob.countryCode})', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                          const SizedBox(width: 14),
                          const Icon(Icons.sensor_occupied_rounded, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text('Reported By: ${prob.reportedBy}', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                          const SizedBox(width: 14),
                          const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(dateFormat.format(prob.reportedAt), style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (prob.isResolved) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Resolved by ${prob.resolvedBy} at ${prob.resolvedAt != null ? dateFormat.format(prob.resolvedAt!) : ""}: ${prob.correctedAction} — "${prob.resolutionNotes}"',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF065F46), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Correction Actions Toolbox Strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                      icon: const Icon(Icons.sync_alt_rounded, size: 14, color: AppColors.primary),
                      label: const Text('Correct Status', style: TextStyle(fontSize: 11)),
                      onPressed: () => _showStatusCorrectionDialog(context, state, matchingOrder),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                      icon: const Icon(Icons.sports_motorsports_rounded, size: 14, color: Color(0xFFD97706)),
                      label: const Text('Reassign Driver', style: TextStyle(fontSize: 11)),
                      onPressed: () => _showDriverReassignDialog(context, state, matchingOrder),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 14, color: Color(0xFF7C3AED)),
                      label: const Text('Override QR State', style: TextStyle(fontSize: 11)),
                      onPressed: () => _showQrOverrideDialog(context, state, matchingOrder),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                      icon: const Icon(Icons.note_add_outlined, size: 14, color: Color(0xFF059669)),
                      label: const Text('Add Internal Note', style: TextStyle(fontSize: 11)),
                      onPressed: () => _showInternalNoteDialog(context, state, matchingOrder),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.open_in_new_rounded, size: 14),
                      label: const Text('Order Details', style: TextStyle(fontSize: 11)),
                      onPressed: () => OrderDetailDialog.show(context, matchingOrder),
                    ),
                    const SizedBox(width: 8),
                    if (!prob.isResolved)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        icon: const Icon(Icons.check, size: 14),
                        label: const Text('Mark Resolved', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => _showResolveDialog(context, state, prob),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return InkWell(
      onTap: () => setState(() => _statusFilter = value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // OPERATIONAL CORRECTION DIALOGS
  // ==========================================
  void _showResolveDialog(BuildContext context, StateService state, OrderProblem prob) {
    final actionCtrl = TextEditingController(text: 'Supervisor manually validated compliance');
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Resolve Exception: #${prob.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: actionCtrl, decoration: const InputDecoration(labelText: 'Action Performed')),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Supervisor Resolution Notes (Mandatory for Audit)',
                  hintText: 'e.g. Scanned physical bag sticker manually and confirmed garment count.',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
            onPressed: () {
              if (noteCtrl.text.trim().isEmpty) return;
              state.resolveOrderProblem(
                prob.id,
                action: actionCtrl.text.trim(),
                notes: noteCtrl.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Confirm & Close Exception'),
          ),
        ],
      ),
    );
  }

  void _showStatusCorrectionDialog(BuildContext context, StateService state, LaundryOrder order) {
    OrderStatus targetStatus = order.status;
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Correct Status for Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Status: ${order.status.displayName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                const SizedBox(height: 12),
                DropdownButtonFormField<OrderStatus>(
                  initialValue: targetStatus,
                  decoration: const InputDecoration(labelText: 'Target Override Status'),
                  items: OrderStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => targetStatus = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mandatory Operational Justification (Audit Logged)',
                    hintText: 'e.g. Courier phone battery depleted after collection; physical intake verified at facility.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                if (reasonCtrl.text.trim().isEmpty) return;
                state.correctOrderStatus(order.id, targetStatus, reason: reasonCtrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order status corrected and recorded in Audit Log'), backgroundColor: Color(0xFF16A34A)),
                );
              },
              child: const Text('Save & Audit Change'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDriverReassignDialog(BuildContext context, StateService state, LaundryOrder order) {
    String selectedDriverId = state.drivers.first.id;
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Reassign Driver: Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedDriverId,
                  decoration: const InputDecoration(labelText: 'Select Courier from Fleet'),
                  items: state.drivers.map((d) => DropdownMenuItem(value: d.id, child: Text('${d.fullName} (${d.userId})'))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedDriverId = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Reason for Reassignment (Audit Logged)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                if (reasonCtrl.text.trim().isEmpty) return;
                state.reassignOrderDriver(order.id, selectedDriverId, reason: reasonCtrl.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Reassign Driver'),
            ),
          ],
        ),
      ),
    );
  }

  void _showQrOverrideDialog(BuildContext context, StateService state, LaundryOrder order) {
    bool isScanned = true;
    final reasonCtrl = TextEditingController(text: 'Driver camera malfunction; supervisor verified barcode visually.');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Override QR State: #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Mark QR as Verified / Scanned'),
                  subtitle: const Text('Overrides missing scan requirement in workflow'),
                  value: isScanned,
                  onChanged: (val) => setDialogState(() => isScanned = val),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Supervisor Clearance Reason'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                if (reasonCtrl.text.trim().isEmpty) return;
                state.overrideOrderQrState(order.id, isScanned: isScanned, reason: reasonCtrl.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Apply Override'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInternalNoteDialog(BuildContext context, StateService state, LaundryOrder order) {
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Supervisor Internal Note: #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 480,
          child: TextField(
            controller: noteCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Internal Note',
              hintText: 'Note visible to Regional Admin and Super Admin only...',
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              if (noteCtrl.text.trim().isEmpty) return;
              state.addOrderInternalNote(order.id, noteCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  void _showQuickCorrectionSelector(BuildContext context, StateService state) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Super Admin Order Correction Tools', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Select an operational correction action to execute with audit tracking:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.sync_alt_rounded, color: AppColors.primary),
              title: const Text('Correct Order Workflow Status'),
              subtitle: const Text('Move order backward or forward in pipeline with reason log'),
              onTap: () {
                Navigator.pop(ctx);
                _showStatusCorrectionDialog(context, state, state.orders.first);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_motorsports_rounded, color: Color(0xFFD97706)),
              title: const Text('Reassign Delivery Courier / Van Fleet'),
              subtitle: const Text('Assign order to another available driver in territory'),
              onTap: () {
                Navigator.pop(ctx);
                _showDriverReassignDialog(context, state, state.orders.first);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF7C3AED)),
              title: const Text('Override QR Scanning Validation'),
              subtitle: const Text('Clear missing QR scan blocker for field personnel'),
              onTap: () {
                Navigator.pop(ctx);
                _showQrOverrideDialog(context, state, state.orders.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
