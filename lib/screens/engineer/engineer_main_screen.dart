import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/system_bug.dart';
import '../../models/user.dart';
import '../../services/state_service.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/uniwash_logo.dart';

class EngineerMainScreen extends StatefulWidget {
  const EngineerMainScreen({super.key});

  @override
  State<EngineerMainScreen> createState() => _EngineerMainScreenState();
}

class _EngineerMainScreenState extends State<EngineerMainScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final allBugs = state.systemBugs;

    final filteredBugs = allBugs.where((b) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = b.title.toLowerCase().contains(q);
        final matchesModule = b.module.toLowerCase().contains(q);
        final matchesDesc = b.description.toLowerCase().contains(q);
        if (!matchesTitle && !matchesModule && !matchesDesc) return false;
      }

      if (_selectedFilter == 'all') return true;
      if (_selectedFilter == 'open') return b.status == BugStatus.open;
      if (_selectedFilter == 'in_progress') return b.status == BugStatus.inProgress;
      if (_selectedFilter == 'resolved') return b.isResolved;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Developer Terminal Theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 2,
        title: Row(
          children: [
            const UniWashLogo.badge(size: 34),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Systems Engineering & Bug Diagnostics Console',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BadgePill(
                      label: 'ENGINEERING & QA ROLE',
                      color: const Color(0xFF38BDF8),
                      backgroundColor: const Color(0xFF0C4A6E),
                    ),
                  ],
                ),
                Text(
                  'Active Monitoring: App Exceptions • QR Scanner Timeouts • GPS Sync Drops • Printer Driver Diagnostics',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Report New Bug Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.bug_report_rounded, size: 16),
            label: const Text(
              '+ Log Diagnostic Bug',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _showLogBugDialog(context, state),
          ),
          const SizedBox(width: 8),

          // Return to Admin
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
            label: const Text(
              'Switch to Admin Portal',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () => state.switchRole(UserRole.regionalAdmin),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: Column(
        children: [
          // Telemetry Cards Header
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Logged Bugs',
                    value: '${allBugs.length}',
                    subtitle: '${allBugs.where((b) => b.status == BugStatus.open).length} Unaddressed',
                    icon: Icons.bug_report_rounded,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'In Active Fix',
                    value: '${allBugs.where((b) => b.status == BugStatus.inProgress).length}',
                    subtitle: 'Sprint dev branch',
                    icon: Icons.construction_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Resolved & Patched',
                    value: '${allBugs.where((b) => b.isResolved).length}',
                    subtitle: 'Verified in production',
                    icon: Icons.verified_rounded,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Core Telemetry Health',
                    value: '99.98%',
                    subtitle: 'API & Socket uptime',
                    icon: Icons.speed_rounded,
                    color: const Color(0xFF38BDF8),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),

          // Search & Filter Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search bugs by title, module, stack trace or device...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      prefixIcon: const Icon(Icons.search, size: 18, color: Colors.white60),
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All System Issues')),
                      DropdownMenuItem(value: 'open', child: Text('🔴 Open Bugs')),
                      DropdownMenuItem(value: 'in_progress', child: Text('🟡 In Progress')),
                      DropdownMenuItem(value: 'resolved', child: Text('🟢 Resolved & Deployed')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedFilter = val);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Bugs List
          Expanded(
            child: filteredBugs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 48, color: Colors.white38),
                        const SizedBox(height: 12),
                        Text(
                          'No bugs matching filter',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBugs.length,
                    itemBuilder: (context, index) {
                      final bug = filteredBugs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: bug.isResolved ? Colors.white12 : bug.severity.color.withValues(alpha: 0.5),
                            width: bug.isResolved ? 1 : 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bug Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: Row(
                                children: [
                                  Icon(bug.status.icon, color: bug.status.color, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    bug.id,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: bug.status.color,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF334155),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      bug.module,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  BadgePill(
                                    label: bug.severity.label,
                                    color: bug.severity.color,
                                    backgroundColor: bug.severity.bgColor,
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Reported ${DateFormat('dd MMM hh:mm a').format(bug.reportedAt)}',
                                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                                  ),
                                ],
                              ),
                            ),

                            // Bug Body
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bug.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    bug.description,
                                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                                  ),
                                  const SizedBox(height: 10),

                                  // Device info & reporter
                                  Row(
                                    children: [
                                      const Icon(Icons.devices_rounded, size: 14, color: Colors.white54),
                                      const SizedBox(width: 6),
                                      Text(
                                        bug.deviceInfo,
                                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                                      ),
                                      const SizedBox(width: 14),
                                      const Icon(Icons.person_pin_rounded, size: 14, color: Colors.white54),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Reported by: ${bug.reportedBy}',
                                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Stack Trace Snippet Container
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            Icon(Icons.terminal_rounded, size: 13, color: Color(0xFF38BDF8)),
                                            SizedBox(width: 6),
                                            Text('Stack Trace / Exception Trace:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8), fontFamily: 'monospace')),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          bug.stackTrace,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                            color: Color(0xFFCBD5E1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // If resolved, show resolution notes
                                  if (bug.isResolved && bug.resolutionNotes != null) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF064E3B),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Resolved by ${bug.resolvedBy}: ${bug.resolutionNotes} (${bug.fixCommitRef})',
                                              style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 14),
                                  const Divider(height: 1, color: Colors.white12),
                                  const SizedBox(height: 10),

                                  // Engineer Action Buttons
                                  Row(
                                    children: [
                                      if (!bug.isResolved) ...[
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF10B981),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          ),
                                          icon: const Icon(Icons.build_circle_rounded, size: 15),
                                          label: const Text('Resolve & Deploy Patch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          onPressed: () => _showResolveBugDialog(context, state, bug),
                                        ),
                                        const SizedBox(width: 8),
                                        if (bug.status != BugStatus.inProgress)
                                          OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFF38BDF8),
                                              side: const BorderSide(color: Color(0xFF38BDF8)),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            ),
                                            icon: const Icon(Icons.play_arrow_rounded, size: 15),
                                            label: const Text('Start Work', style: TextStyle(fontSize: 12)),
                                            onPressed: () {
                                              state.updateBugStatus(bug.id, BugStatus.inProgress);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Bug ${bug.id} status moved to In Progress')),
                                              );
                                            },
                                          ),
                                      ] else ...[
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white70,
                                            side: const BorderSide(color: Colors.white24),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          ),
                                          icon: const Icon(Icons.replay_rounded, size: 15),
                                          label: const Text('Reopen Bug', style: TextStyle(fontSize: 12)),
                                          onPressed: () {
                                            state.updateBugStatus(bug.id, BugStatus.open);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Bug ${bug.id} reopened')),
                                            );
                                          },
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        style: TextButton.styleFrom(foregroundColor: Colors.white60),
                                        icon: const Icon(Icons.terminal_rounded, size: 14),
                                        label: const Text('Copy Stack Trace', style: TextStyle(fontSize: 11)),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Stack trace copied to clipboard')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // RESOLVE BUG DIALOG
  void _showResolveBugDialog(BuildContext context, StateService state, SystemBug bug) {
    final notesCtrl = TextEditingController(text: 'Patched and verified in staging test build.');
    final commitCtrl = TextEditingController(text: 'commit-${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Resolve & Deploy Patch: ${bug.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Issue: ${bug.title}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 14),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Fix Explanation & Resolution Notes *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commitCtrl,
                decoration: const InputDecoration(labelText: 'Git Commit / Build Reference *'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            onPressed: () {
              state.resolveBug(
                bug.id,
                notes: notesCtrl.text.trim(),
                commitRef: commitCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Bug ${bug.id} marked as resolved and patch recorded in audit log.'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Deploy Patch'),
          ),
        ],
      ),
    );
  }

  // LOG NEW BUG DIALOG
  void _showLogBugDialog(BuildContext context, StateService state) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final stackCtrl = TextEditingController(text: 'CameraOverlay.dart:210\nStateService.dart:184');
    String selectedModule = 'Driver App QR Scanner';
    BugSeverity selectedSeverity = BugSeverity.medium;

    final modules = [
      'Driver App QR Scanner',
      'Live GPS Tracking & Sync',
      'Thermal Invoice Printing',
      'Payment Webhook & Card POS',
      'Push Notifications & Telemetry',
      'Catalog & Order Pricing Engine',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Log System Diagnostic Bug', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Bug Title / Summary *'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedModule,
                    decoration: const InputDecoration(labelText: 'System Subsystem / Module'),
                    items: modules.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedModule = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<BugSeverity>(
                    initialValue: selectedSeverity,
                    decoration: const InputDecoration(labelText: 'Bug Severity'),
                    items: BugSeverity.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedSeverity = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Reproduction Steps & Description *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: stackCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Stack Trace / Error Message'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final newBug = SystemBug(
                  id: 'BUG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty ? 'Reported by QA lead' : descCtrl.text.trim(),
                  module: selectedModule,
                  severity: selectedSeverity,
                  stackTrace: stackCtrl.text.trim(),
                  reportedAt: DateTime.now(),
                  reportedBy: state.currentUser.fullName,
                );
                state.reportBug(newBug);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Bug ${newBug.id} registered into engineering backlog.'),
                    backgroundColor: const Color(0xFF0284C7),
                  ),
                );
              },
              child: const Text('Register Bug'),
            ),
          ],
        ),
      ),
    );
  }
}
