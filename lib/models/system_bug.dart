import 'package:flutter/material.dart';

enum BugSeverity {
  low('Low', Color(0xFF0284C7), Color(0xFFE0F2FE)),
  medium('Medium', Color(0xFFD97706), Color(0xFFFEF3C7)),
  high('High', Color(0xFFEA580C), Color(0xFFFFEDD5)),
  critical('Critical Crash', Color(0xFFDC2626), Color(0xFFFEE2E2));

  final String label;
  final Color color;
  final Color bgColor;
  const BugSeverity(this.label, this.color, this.bgColor);
}

enum BugStatus {
  open('Open Bug', Color(0xFFDC2626), Icons.bug_report_rounded),
  investigating('Investigating', Color(0xFFD97706), Icons.search_rounded),
  inProgress('Fix in Progress', Color(0xFF2563EB), Icons.code_rounded),
  resolved('Resolved & Patched', Color(0xFF16A34A), Icons.task_alt_rounded),
  closed('Closed / Deployed', Color(0xFF475569), Icons.check_circle_outline_rounded);

  final String label;
  final Color color;
  final IconData icon;
  const BugStatus(this.label, this.color, this.icon);
}

class SystemBug {
  final String id;
  final String title;
  final String description;
  final String module;
  final String stackTrace;
  final String deviceInfo;
  final BugSeverity severity;
  BugStatus status;
  final DateTime reportedAt;
  final String reportedBy;
  DateTime? resolvedAt;
  String? resolvedBy;
  String? resolutionNotes;
  String? fixCommitRef;

  SystemBug({
    required this.id,
    required this.title,
    required this.description,
    required this.module,
    this.stackTrace = 'No critical stack trace recorded. Diagnostic warning logged.',
    this.deviceInfo = 'System Service Worker / Cross-Platform',
    required this.severity,
    this.status = BugStatus.open,
    required this.reportedAt,
    required this.reportedBy,
    this.resolvedAt,
    this.resolvedBy,
    this.resolutionNotes,
    this.fixCommitRef,
  });

  bool get isResolved => status == BugStatus.resolved || status == BugStatus.closed;

  void markResolved({
    required String engineerName,
    required String notes,
    String? commitRef,
  }) {
    status = BugStatus.resolved;
    resolvedAt = DateTime.now();
    resolvedBy = engineerName;
    resolutionNotes = notes;
    fixCommitRef = commitRef ?? 'commit-${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
  }
}
