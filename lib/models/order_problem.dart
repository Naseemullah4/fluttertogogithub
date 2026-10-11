import 'package:flutter/material.dart';

enum ProblemSeverity {
  low('Low', Color(0xFF0284C7), Color(0xFFE0F2FE)),
  medium('Medium', Color(0xFFD97706), Color(0xFFFEF3C7)),
  high('High', Color(0xFFEA580C), Color(0xFFFFEDD5)),
  critical('Critical', Color(0xFFDC2626), Color(0xFFFEE2E2));

  final String label;
  final Color color;
  final Color bgColor;
  const ProblemSeverity(this.label, this.color, this.bgColor);
}

enum ProblemType {
  qrScanMissed('Missing QR Scan', 'QR code was not scanned during required transition'),
  qrScanDuplicate('Duplicate QR Scan', 'QR code was scanned multiple times unexpectedly'),
  qrScanIncorrect('Incorrect / Mismatched QR', 'Scanned QR code payload does not match order record'),
  missingProofPhoto('Missing Proof Photo', 'Proof photo not uploaded during collection or delivery'),
  driverMismatched('Driver Assignment Error', 'Driver assigned is in wrong territory or offline'),
  driverMistake('Driver Operational Mistake', 'Driver made an operational error during pickup, loading, or transit'),
  orderStuck('Order Stuck / SLA Breached', 'Order has remained in stage longer than SLA limit'),
  wrongBranch('Branch Mismatch', 'Order was assigned to incorrect branch facility'),
  customerUnreachable('Customer Unreachable', 'Repeated failed contact attempts during delivery'),
  damagedGarment('Garment Damage / Defect Found', 'Pre-existing or transit damage flagged during intake check'),
  wrongAddress('Incorrect Address / Destination', 'Driver navigated or attempted delivery at wrong address'),
  rescheduleRequested('Reschedule Required', 'Customer or driver requested pickup/delivery date or slot change'),
  systemError('Technical / Sync Exception', 'API or network synchronization anomaly');

  final String title;
  final String description;
  const ProblemType(this.title, this.description);
}

class OrderProblem {
  final String id;
  final String orderId;
  final int orderNumber;
  final String customerName;
  final String countryCode;
  final String branchName;
  final ProblemType type;
  final ProblemSeverity severity;
  final String description;
  final DateTime reportedAt;
  final String reportedBy; // 'System Audit', 'Driver Tariq', 'Laundry Pearl', 'Regional Admin'
  bool isResolved;
  DateTime? resolvedAt;
  String? resolvedBy;
  String? resolutionNotes;
  String? correctedAction;
  bool isEscalatedToAdmin;
  String? assignedAdminName;
  DateTime? escalatedAt;
  String? escalationReason;

  OrderProblem({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.countryCode,
    required this.branchName,
    required this.type,
    required this.severity,
    required this.description,
    required this.reportedAt,
    this.reportedBy = 'Automated System Monitor',
    this.isResolved = false,
    this.resolvedAt,
    this.resolvedBy,
    this.resolutionNotes,
    this.correctedAction,
    this.isEscalatedToAdmin = false,
    this.assignedAdminName,
    this.escalatedAt,
    this.escalationReason,
  });

  void markResolved({
    required String resolvedBy,
    required String action,
    required String notes,
  }) {
    isResolved = true;
    this.resolvedBy = resolvedBy;
    resolvedAt = DateTime.now();
    correctedAction = action;
    resolutionNotes = notes;
  }

  void escalateToAdmin({
    required String adminName,
    required String reason,
    required String escalatedBy,
  }) {
    isEscalatedToAdmin = true;
    assignedAdminName = adminName;
    escalatedAt = DateTime.now();
    escalationReason = reason;
  }
}
