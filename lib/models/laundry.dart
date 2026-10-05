import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum WarningLevel {
  none,
  lightYellow,
  yellow,
  lightRed,
  fullRed,
  terminated,
}

extension WarningLevelExtension on WarningLevel {
  String get displayName {
    switch (this) {
      case WarningLevel.none:
        return 'Good Standing';
      case WarningLevel.lightYellow:
        return 'Light Yellow (Level 1 Notice)';
      case WarningLevel.yellow:
        return 'Yellow (Level 2 Warning)';
      case WarningLevel.lightRed:
        return 'Light Red (Level 3 Suspension Risk)';
      case WarningLevel.fullRed:
        return 'Full Red (Final Notice)';
      case WarningLevel.terminated:
        return 'Terminated';
    }
  }

  Color get color {
    switch (this) {
      case WarningLevel.none:
        return AppColors.success;
      case WarningLevel.lightYellow:
        return AppColors.warnLightYellow;
      case WarningLevel.yellow:
        return AppColors.warnYellow;
      case WarningLevel.lightRed:
        return AppColors.warnLightRed;
      case WarningLevel.fullRed:
        return AppColors.warnFullRed;
      case WarningLevel.terminated:
        return AppColors.warnTerminated;
    }
  }

  Color get textColor {
    switch (this) {
      case WarningLevel.none:
        return Colors.white;
      case WarningLevel.lightYellow:
      case WarningLevel.yellow:
        return const Color(0xFF78350F);
      case WarningLevel.lightRed:
        return const Color(0xFF7F1D1D);
      case WarningLevel.fullRed:
      case WarningLevel.terminated:
        return Colors.white;
    }
  }
}

class LaundryDocumentFolder {
  final String crCommercialRegDoc;
  final String municipalityLicenseDoc;
  final String civilDefenseCertificateDoc;
  final String ownerQidDoc;
  final String signedContractDoc;
  final String bankIbanCertificate;
  final DateTime registrationDate;
  final String taxCardNumber;

  const LaundryDocumentFolder({
    required this.crCommercialRegDoc,
    required this.municipalityLicenseDoc,
    required this.civilDefenseCertificateDoc,
    required this.ownerQidDoc,
    required this.signedContractDoc,
    required this.bankIbanCertificate,
    required this.registrationDate,
    this.taxCardNumber = 'CR-QA-908122-TX',
  });
}

class LaundryPeriodicStats {
  final int todayReceived;
  final int todayInProcessing;
  final int todayReady;
  final int todayDelivered;
  final double todayGrossRevenue;

  final int weeklyOrders;
  final double weeklyRevenue;

  final int monthlyOrders;
  final double monthlyRevenue;

  final int yearlyOrders;
  final double yearlyRevenue;

  final int lifetimeOrders;
  final double lifetimeRevenue;

  const LaundryPeriodicStats({
    this.todayReceived = 18,
    this.todayInProcessing = 12,
    this.todayReady = 15,
    this.todayDelivered = 14,
    this.todayGrossRevenue = 1890.0,
    this.weeklyOrders = 112,
    this.weeklyRevenue = 12450.0,
    this.monthlyOrders = 482,
    this.monthlyRevenue = 54890.0,
    this.yearlyOrders = 5940,
    this.yearlyRevenue = 642800.0,
    this.lifetimeOrders = 14820,
    this.lifetimeRevenue = 1592000.0,
  });
}

class LaundryBranch {
  final String id;
  final String userId; // System credentials ID e.g. LND-DOH-01
  String systemPassword; // Admin can view/reset if manager forgets
  String name;
  String legalRegNumber;
  double commissionRate; // 15.0%
  WarningLevel warningStatus;
  bool isActive;
  String country;
  String managerName;
  String phone;
  int completedOrders;
  double grossEarningsQar;
  double rating;
  final LaundryDocumentFolder documents;
  LaundryPeriodicStats stats;

  LaundryBranch({
    required this.id,
    required this.userId,
    this.systemPassword = 'Branch@Secret2026',
    required this.name,
    required this.legalRegNumber,
    this.commissionRate = 15.0,
    this.warningStatus = WarningLevel.none,
    this.isActive = true,
    this.country = 'Qatar',
    required this.managerName,
    required this.phone,
    this.completedOrders = 124,
    this.grossEarningsQar = 28450.0,
    this.rating = 4.8,
    required this.documents,
    this.stats = const LaundryPeriodicStats(),
  });
}

