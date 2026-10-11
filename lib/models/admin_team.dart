import 'package:flutter/material.dart';
import 'driver.dart';

enum AppPermission {
  ordersView('orders.view', 'View Orders'),
  ordersCreate('orders.create', 'Create Orders'),
  ordersEdit('orders.edit', 'Edit Orders'),
  ordersDelete('orders.delete', 'Cancel / Delete Orders'),
  ordersPrint('orders.print', 'Print Orders'),
  ordersExport('orders.export', 'Export Orders'),
  ordersCorrectStatus('orders.correct_status', 'Correct Order Status & Workflows'),
  
  driversView('drivers.view', 'View Drivers'),
  driversCreate('drivers.create', 'Add Drivers'),
  driversEdit('drivers.edit', 'Edit Drivers'),
  driversDelete('drivers.delete', 'Deactivate Drivers'),
  
  customersView('customers.view', 'View Customers'),
  customersCreate('customers.create', 'Add Customers'),
  customersEdit('customers.edit', 'Edit Customers'),
  customersDelete('customers.delete', 'Deactivate Customers'),
  
  laundryView('laundry.view', 'View Laundries'),
  laundryCreate('laundry.create', 'Add Laundries'),
  laundryEdit('laundry.edit', 'Edit Laundries'),
  laundryDelete('laundry.delete', 'Deactivate Laundries'),
  
  adminsView('admins.view', 'View Admins'),
  adminsCreate('admins.create', 'Add Admins'),
  adminsEdit('admins.edit', 'Edit Admins & Permissions'),
  adminsDelete('admins.delete', 'Deactivate Admins'),
  
  reportsView('reports.view', 'View Reports & BI Analytics'),
  reportsExport('reports.export', 'Export Reports'),
  
  auditLogsView('audit_logs.view', 'View System Audit Logs');

  final String key;
  final String label;
  const AppPermission(this.key, this.label);

  static Set<AppPermission> get superAdminPermissions => AppPermission.values.toSet();
  static Set<AppPermission> get regionalAdminDefaults => {
    ordersView, ordersCreate, ordersEdit, ordersPrint, ordersExport, ordersCorrectStatus,
    driversView, driversCreate, driversEdit,
    customersView, customersCreate, customersEdit,
    laundryView, laundryCreate, laundryEdit,
    reportsView, reportsExport,
    auditLogsView,
  };
  static Set<AppPermission> get customerServiceDefaults => {
    ordersView, ordersCreate, ordersEdit, ordersPrint,
    customersView, customersCreate,
    driversView,
    laundryView,
  };
}

enum TeamCategory {
  customerService('Customer Support & Service', Icons.support_agent_rounded, Color(0xFF0284C7)),
  driver('Driver Fleet', Icons.sports_motorsports_rounded, Color(0xFF2563EB)),
  engineer('System & QA Engineer', Icons.engineering_rounded, Color(0xFF0D9488)),
  officeStaff('Office Staff', Icons.business_center_rounded, Color(0xFF7C3AED)),
  laundrySupervisor('Laundry Supervisor', Icons.local_laundry_service_rounded, Color(0xFF059669)),
  regionalAdmin('Regional Admin', Icons.admin_panel_settings_rounded, Color(0xFFD97706)),
  other('Other Operational Staff', Icons.badge_outlined, Color(0xFF64748B));

  final String title;
  final IconData icon;
  final Color color;
  const TeamCategory(this.title, this.icon, this.color);
}

class AdminUserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String countryCode;
  final List<String> assignedBranchIds;
  final Set<AppPermission> permissions;
  bool isSuperAdmin;
  bool isActive;
  final DateTime createdAt;
  DateTime lastLoginAt;

  AdminUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.countryCode,
    required this.assignedBranchIds,
    required this.permissions,
    this.isSuperAdmin = false,
    this.isActive = true,
    required this.createdAt,
    required this.lastLoginAt,
  });

  bool hasPermission(AppPermission perm) {
    if (isSuperAdmin) return true;
    if (!isActive) return false;
    return permissions.contains(perm);
  }

  bool canAccessCountry(String cCode) {
    if (isSuperAdmin) return true;
    return countryCode == cCode || countryCode == 'ALL';
  }

  bool canAccessBranch(String branchId) {
    if (isSuperAdmin) return true;
    if (assignedBranchIds.isEmpty) return true; // all branches in country
    return assignedBranchIds.contains(branchId);
  }
}

class TeamMemberModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final TeamCategory category;
  final DriverAffiliation? driverAffiliation; // If driver: companyFleet (Corporate, Not for laundry) or laundryDedicated
  final String countryCode;
  final String branchId;
  final String branchName;
  final String jobTitle;
  final String? notes;
  bool isActive;
  final DateTime joinedAt;
  final int assignedOrdersCount;
  final int completedOrdersCount;
  final double rating;

  TeamMemberModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.category,
    this.driverAffiliation,
    required this.countryCode,
    required this.branchId,
    required this.branchName,
    required this.jobTitle,
    this.notes,
    this.isActive = true,
    required this.joinedAt,
    this.assignedOrdersCount = 0,
    this.completedOrdersCount = 0,
    this.rating = 5.0,
  });
}
