import 'laundry.dart';

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
