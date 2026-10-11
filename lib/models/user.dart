enum UserRole {
  customer,
  driver,
  laundryWorker,
  regionalAdmin,
  superAdmin,
  customerService,
  engineer,
}

extension UserRoleExtension on UserRole {
  String get title {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.driver:
        return 'Driver';
      case UserRole.laundryWorker:
        return 'Laundry Staff / Worker';
      case UserRole.regionalAdmin:
        return 'Regional Admin (Qatar)';
      case UserRole.superAdmin:
        return 'Super Admin (Global)';
      case UserRole.customerService:
        return 'Customer Support & Service Specialist';
      case UserRole.engineer:
        return 'Software & System QA Engineer';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.driver:
        return 'Driver';
      case UserRole.laundryWorker:
        return 'Laundry';
      case UserRole.regionalAdmin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.customerService:
        return 'Support / CS';
      case UserRole.engineer:
        return 'Engineer';
    }
  }
}

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final String countryCode;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.countryCode = 'QAT',
  });
}
