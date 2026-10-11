import 'package:flutter/material.dart';
import 'laundry.dart';

enum DriverAffiliation {
  companyFleet(
    'Company Driver (UniWash Corporate Fleet - Not for Laundry)',
    'Company Fleet',
    Icons.business_center_rounded,
    Color(0xFF1E3A8A),
  ),
  laundryDedicated(
    'Laundry Driver (Assigned to Partner Laundry)',
    'Laundry Driver',
    Icons.local_laundry_service_rounded,
    Color(0xFF047857),
  );

  final String fullTitle;
  final String shortBadge;
  final IconData icon;
  final Color color;
  const DriverAffiliation(this.fullTitle, this.shortBadge, this.icon, this.color);
}

class DriverDocumentFolder {
  final String passportDocumentName;
  final String visaDocumentName;
  final String drivingLicenseDocumentName;
  final String qidDocumentName;
  final String signedContractDocumentName;
  final String vehicleRegPlate;
  final DateTime joinedAt;
  final String nationality;

  const DriverDocumentFolder({
    required this.passportDocumentName,
    required this.visaDocumentName,
    required this.drivingLicenseDocumentName,
    required this.qidDocumentName,
    required this.signedContractDocumentName,
    required this.vehicleRegPlate,
    required this.joinedAt,
    this.nationality = 'Qatar Resident',
  });
}

class DriverModel {
  final String id;
  final String userId; // Unique system ID e.g. DRV-QA-8821
  String systemPassword; // Admin can view/reset if driver forgets
  final String fullName;
  final String phone;
  final String licenseNumber;
  final String qidPassportNumber;
  final String assignedLaundryId;
  final String assignedLaundryName;
  DriverAffiliation affiliation; // Company Fleet (Not for Laundry) vs Laundry Dedicated
  WarningLevel warningStatus;
  bool isApproved;
  bool isOnline;
  double rating;
  int completedTrips;
  double todayEarningsQar;
  double currentLat;
  double currentLng;
  final DriverDocumentFolder documents;

  DriverModel({
    required this.id,
    required this.userId,
    this.systemPassword = 'Driver@Pass2026',
    required this.fullName,
    required this.phone,
    required this.licenseNumber,
    required this.qidPassportNumber,
    required this.assignedLaundryId,
    required this.assignedLaundryName,
    this.affiliation = DriverAffiliation.companyFleet,
    this.warningStatus = WarningLevel.none,
    this.isApproved = true,
    this.isOnline = true,
    this.rating = 4.9,
    this.completedTrips = 89,
    this.todayEarningsQar = 320.0,
    this.currentLat = 25.2867,
    this.currentLng = 51.5333,
    required this.documents,
  });

  int get starRating {
    if (completedTrips >= 200) return 4;
    if (completedTrips >= 150) return 3;
    if (completedTrips >= 100) return 2;
    if (completedTrips >= 50) return 1;
    return 0;
  }

  bool get hasBlueTag => completedTrips >= 200;
  bool get hasGoldenBadge => completedTrips >= 250;
  bool get hasPremiumDiamondBadge => completedTrips >= 300;

  double get bonusRatePerOrder {
    if (completedTrips >= 300) return 3.00;
    if (completedTrips >= 200) return 2.00;
    if (completedTrips >= 100) return 1.50;
    return 1.00;
  }

  double get totalBonusEarnings => completedTrips * bonusRatePerOrder;

  String get tierBadgeTitle {
    if (completedTrips >= 300) return 'Legendary Elite (Diamond Badge)';
    if (completedTrips >= 250) return 'Master Courier (Golden Badge)';
    if (completedTrips >= 200) return 'Elite Courier (Blue Tag)';
    if (completedTrips >= 150) return 'Senior Courier (3-Star)';
    if (completedTrips >= 100) return 'Pro Courier (2-Star)';
    if (completedTrips >= 50) return 'Active Courier (1-Star)';
    return 'Cadet Courier';
  }
}

class DriverDutySession {
  final String id;
  final String driverId;
  final String driverName;
  final DateTime startedAt;
  DateTime? endedAt;
  final String selfiePhoto;
  final String vanPhoto;
  final String platePhoto;
  final String hangerPhoto;
  final String laundrySetupPhoto;
  final bool has20Bags;
  final bool has100Tags;
  bool isActive;

  DriverDutySession({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.startedAt,
    this.endedAt,
    required this.selfiePhoto,
    required this.vanPhoto,
    required this.platePhoto,
    required this.hangerPhoto,
    required this.laundrySetupPhoto,
    required this.has20Bags,
    required this.has100Tags,
    this.isActive = true,
  });

  int get totalChecklistCompleted => 7; // 5 photos + 2 questions
}
