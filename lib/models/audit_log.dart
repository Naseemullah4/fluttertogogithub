import 'package:flutter/material.dart';

enum AuditActionType {
  orderStatusCorrected('Order Status Corrected', Icons.edit_note_rounded, Color(0xFF2563EB)),
  orderDriverReassigned('Driver Reassigned', Icons.swap_horiz_rounded, Color(0xFF7C3AED)),
  orderBranchReassigned('Branch Reassigned', Icons.store_rounded, Color(0xFF0284C7)),
  qrStateCorrected('QR State Overridden', Icons.qr_code_scanner_rounded, Color(0xFFD97706)),
  proofPhotoUpdated('Proof Photo Added/Replaced', Icons.add_a_photo_rounded, Color(0xFF059669)),
  orderReopened('Order Reopened', Icons.refresh_rounded, Color(0xFFEA580C)),
  problemResolved('Exception Resolved', Icons.check_circle_rounded, Color(0xFF16A34A)),
  adminCreated('Admin Account Created', Icons.person_add_rounded, Color(0xFF4F46E5)),
  adminEdited('Admin Permissions Updated', Icons.manage_accounts_rounded, Color(0xFF6366F1)),
  adminDeactivated('Admin Deactivated', Icons.person_off_rounded, Color(0xFFDC2626)),
  teamMemberCreated('Team Member Added', Icons.group_add_rounded, Color(0xFF0891B2)),
  teamMemberEdited('Team Member Updated', Icons.edit_rounded, Color(0xFF0284C7)),
  driverCreated('Driver Fleet Onboarded', Icons.sports_motorsports_rounded, Color(0xFF2563EB)),
  countryConfigUpdated('Country Settings Updated', Icons.public_rounded, Color(0xFF0F766E)),
  branchCreated('New Branch Activated', Icons.add_business_rounded, Color(0xFF0D9488));

  final String title;
  final IconData icon;
  final Color color;
  const AuditActionType(this.title, this.icon, this.color);
}

class AuditLogEntry {
  final String id;
  final String performedBy; // e.g. 'Super Admin (Faisal Al-Thani)'
  final String performedByRole; // 'superAdmin', 'regionalAdmin'
  final String performedById;
  final AuditActionType actionType;
  final String entity; // 'Order', 'Driver', 'Branch', 'Admin', 'Country'
  final String entityId; // e.g. 'ord-1002 (#10843)'
  final String previousValue;
  final String newValue;
  final String reason;
  final DateTime timestamp;
  final String ipAddress;
  final String countryCode;

  AuditLogEntry({
    required this.id,
    required this.performedBy,
    required this.performedByRole,
    required this.performedById,
    required this.actionType,
    required this.entity,
    required this.entityId,
    required this.previousValue,
    required this.newValue,
    required this.reason,
    required this.timestamp,
    this.ipAddress = '10.240.12.88 (Enterprise VPN)',
    this.countryCode = 'QAT',
  });
}
