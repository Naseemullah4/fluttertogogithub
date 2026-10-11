class BranchModel {
  final String id;
  final String code;
  final String name;
  final String nameAr;
  final String countryCode;
  final String city;
  final String address;
  final String phone;
  final String email;
  final String managerName;
  bool isActive;
  final DateTime createdAt;
  final int activeDriversCount;
  final int activeLaundriesCount;
  final int activeStaffCount;

  BranchModel({
    required this.id,
    required this.code,
    required this.name,
    required this.nameAr,
    required this.countryCode,
    required this.city,
    required this.address,
    required this.phone,
    required this.email,
    required this.managerName,
    this.isActive = true,
    required this.createdAt,
    this.activeDriversCount = 0,
    this.activeLaundriesCount = 0,
    this.activeStaffCount = 0,
  });

  BranchModel copyWith({
    String? name,
    String? nameAr,
    String? city,
    String? address,
    String? phone,
    String? email,
    String? managerName,
    bool? isActive,
    int? activeDriversCount,
    int? activeLaundriesCount,
    int? activeStaffCount,
  }) {
    return BranchModel(
      id: id,
      code: code,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      countryCode: countryCode,
      city: city ?? this.city,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      managerName: managerName ?? this.managerName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      activeDriversCount: activeDriversCount ?? this.activeDriversCount,
      activeLaundriesCount: activeLaundriesCount ?? this.activeLaundriesCount,
      activeStaffCount: activeStaffCount ?? this.activeStaffCount,
    );
  }
}

class CountryModel {
  final String code;
  final String name;
  final String nameAr;
  final String flag;
  final String currencyCode;
  final String currencySymbol;
  final String currencySymbolAr;
  final double exchangeRateToQar;
  final String hqAddress;
  final String primaryContactPhone;
  final String primaryContactEmail;
  bool isActive;
  final DateTime createdAt;
  List<BranchModel> branches;

  CountryModel({
    required this.code,
    required this.name,
    required this.nameAr,
    required this.flag,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencySymbolAr,
    this.exchangeRateToQar = 1.0,
    required this.hqAddress,
    required this.primaryContactPhone,
    required this.primaryContactEmail,
    this.isActive = true,
    required this.createdAt,
    List<BranchModel>? branches,
  }) : branches = branches ?? [];

  int get totalBranches => branches.length;
  int get activeBranches => branches.where((b) => b.isActive).length;
}
