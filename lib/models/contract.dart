enum ApprovalStatus {
  pending,
  approved,
  rejected,
  updateRequired,
}

extension ApprovalStatusExtension on ApprovalStatus {
  String get displayName {
    switch (this) {
      case ApprovalStatus.pending:
        return 'Pending Review';
      case ApprovalStatus.approved:
        return 'Approved & Active';
      case ApprovalStatus.rejected:
        return 'Rejected';
      case ApprovalStatus.updateRequired:
        return 'Document Update Required';
    }
  }
}

class LaundryContract {
  final String id;
  final String laundryId;
  final String laundryName;
  final bool isGovRegistered;
  final bool isLawCompliant;
  final bool isLicenseClear;
  final double commissionPercentage; // 15.0%
  final double cancellationDailyPenaltyUsd; // $55.00 USD
  final int advanceNoticeDays; // 2 days
  final DateTime signedAt;
  bool isApprovedBySuperAdmin;
  final String signedBy;

  LaundryContract({
    required this.id,
    required this.laundryId,
    required this.laundryName,
    required this.isGovRegistered,
    required this.isLawCompliant,
    required this.isLicenseClear,
    this.commissionPercentage = 15.0,
    this.cancellationDailyPenaltyUsd = 55.0,
    this.advanceNoticeDays = 2,
    required this.signedAt,
    this.isApprovedBySuperAdmin = true,
    required this.signedBy,
  });
}

class StaffOnboardingRequest {
  final String id;
  final String fullName;
  final String idCardNumber;
  final String role; // Driver, Cleaner, Office Boy, Engineer, Sales Team
  final String address;
  final String passportNumber;
  final String phone;
  final String email;
  final String nationality;
  final DateTime submittedAt;
  ApprovalStatus status;
  bool get isApprovedBySuperAdmin => status == ApprovalStatus.approved;
  set isApprovedBySuperAdmin(bool val) {
    status = val ? ApprovalStatus.approved : ApprovalStatus.pending;
  }
  final String regionalAdminName;
  String? adminNotes;
  String? requiredDocumentDetails;

  // Attached files
  final String passportFileName;
  final String qidFileName;
  final String drivingLicenseFileName;
  final String policeClearanceFileName;
  final String medicalCertificateFileName;

  StaffOnboardingRequest({
    required this.id,
    required this.fullName,
    required this.idCardNumber,
    required this.role,
    required this.address,
    required this.passportNumber,
    this.phone = '+974 5512 8820',
    this.email = 'applicant@uniwash.qa',
    this.nationality = 'Qatar Resident',
    required this.submittedAt,
    this.status = ApprovalStatus.pending,
    bool? isApprovedBySuperAdmin,
    required this.regionalAdminName,
    this.adminNotes,
    this.requiredDocumentDetails,
    this.passportFileName = 'passport_scan_verified.pdf',
    this.qidFileName = 'qatar_id_front_back.pdf',
    this.drivingLicenseFileName = 'driving_license_valid.pdf',
    this.policeClearanceFileName = 'good_conduct_certificate.pdf',
    this.medicalCertificateFileName = 'fit_to_work_medical.pdf',
  }) {
    if (isApprovedBySuperAdmin != null) {
      status = isApprovedBySuperAdmin ? ApprovalStatus.approved : ApprovalStatus.pending;
    }
  }
}

