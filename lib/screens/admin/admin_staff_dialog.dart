// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../models/admin_team.dart';
import '../../models/contract.dart';
import '../../models/driver.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uniwash_logo.dart';

class AdminStaffDialog extends StatefulWidget {
  final StateService stateService;

  const AdminStaffDialog({super.key, required this.stateService});

  @override
  State<AdminStaffDialog> createState() => _AdminStaffDialogState();
}

class _AdminStaffDialogState extends State<AdminStaffDialog> {
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _idCard = TextEditingController();
  final _passport = TextEditingController();
  final _address = TextEditingController();
  String _selectedRole = 'Driver';
  DriverAffiliation _driverAffiliation = DriverAffiliation.companyFleet;
  String? _assignedLaundryId;

  final List<String> _roles = [
    'Driver',
    'Customer Support / Service (CS)',
    'Engineer (System & QA Diagnostics)',
    'Office Staff',
    'Other Operational Staff',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.stateService.laundries.isNotEmpty) {
      _assignedLaundryId = widget.stateService.laundries.first.id;
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _idCard.dispose();
    _passport.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.stateService;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      UniWashLogo.badge(size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Admin Staff & Driver Onboarding',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Text(
                'Add Drivers (Company Fleet vs Laundry), Customer Support, Engineers, Office Staff or Others with role-based operational permissions.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 18),

              // Position / Role Selection
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Staff Position / Role *'),
                items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 14),

              // DRIVER AFFILIATION SELECTOR (MANDATORY REQUIREMENT)
              if (_selectedRole == 'Driver') ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.directions_car_filled_rounded, color: Color(0xFF166534), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Driver Affiliation (Crucial distinction):',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF14532D)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      RadioListTile<DriverAffiliation>(
                        dense: true,
                        title: const Text(
                          'Company Driver (UniWash Corporate Fleet)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: const Text(
                          'Direct company van driver. Works across all regional pickup orders (NOT for laundry dedicated intake).',
                          style: TextStyle(fontSize: 11, color: Color(0xFF166534)),
                        ),
                        value: DriverAffiliation.companyFleet,
                        groupValue: _driverAffiliation,
                        onChanged: (val) {
                          if (val != null) setState(() => _driverAffiliation = val);
                        },
                      ),
                      RadioListTile<DriverAffiliation>(
                        dense: true,
                        title: const Text(
                          'Laundry Driver (Assigned to Partner Laundry)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: const Text(
                          'Dedicated facility courier assigned directly to a contracted laundry partner.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF166534)),
                        ),
                        value: DriverAffiliation.laundryDedicated,
                        groupValue: _driverAffiliation,
                        onChanged: (val) {
                          if (val != null) setState(() => _driverAffiliation = val);
                        },
                      ),
                      if (_driverAffiliation == DriverAffiliation.laundryDedicated) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _assignedLaundryId,
                          decoration: const InputDecoration(labelText: 'Assigned Partner Laundry *'),
                          items: state.laundries.map((l) {
                            return DropdownMenuItem(value: l.id, child: Text(l.name, style: const TextStyle(fontSize: 12)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _assignedLaundryId = val);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Full Name & Phone
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fullName,
                      decoration: const InputDecoration(labelText: 'Full Legal Name *'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phone,
                      decoration: const InputDecoration(labelText: 'Mobile Phone (+974 ...) *'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Email
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Corporate Email Address'),
              ),
              const SizedBox(height: 12),

              // IDs
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _idCard,
                      decoration: const InputDecoration(labelText: 'QID / National ID *'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _passport,
                      decoration: const InputDecoration(labelText: 'Passport Number'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Residential Address
              TextField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Residential Address / Station'),
              ),
              const SizedBox(height: 16),

              // Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFFB45309), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Governance: Onboarding is logged in system audit trail. Member is added to operations roster immediately with Super Admin governance.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (_fullName.text.trim().isEmpty || _phone.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill full name and phone number.')),
                      );
                      return;
                    }

                    final name = _fullName.text.trim();
                    final phone = _phone.text.trim();
                    final email = _email.text.trim().isEmpty ? '${name.toLowerCase().replaceAll(' ', '.')}@uniwash.qa' : _email.text.trim();
                    final now = DateTime.now();

                    TeamCategory cat;
                    if (_selectedRole.startsWith('Driver')) {
                      cat = TeamCategory.driver;
                    } else if (_selectedRole.contains('Support')) {
                      cat = TeamCategory.customerService;
                    } else if (_selectedRole.contains('Engineer')) {
                      cat = TeamCategory.engineer;
                    } else if (_selectedRole.contains('Office')) {
                      cat = TeamCategory.officeStaff;
                    } else {
                      cat = TeamCategory.other;
                    }

                    final selectedLaundry = state.laundries.firstWhere(
                      (l) => l.id == _assignedLaundryId,
                      orElse: () => state.laundries.first,
                    );

                    // If Driver, register in Driver Fleet
                    if (cat == TeamCategory.driver) {
                      final newDriver = DriverModel(
                        id: 'drv-${now.millisecondsSinceEpoch}',
                        userId: 'DRV-QA-${now.millisecondsSinceEpoch.toString().substring(8)}',
                        fullName: name,
                        phone: phone,
                        licenseNumber: 'QA-DL-${_idCard.text.trim().isEmpty ? "88219" : _idCard.text.trim()}',
                        qidPassportNumber: _idCard.text.trim().isEmpty ? '29363401928' : _idCard.text.trim(),
                        assignedLaundryId: _driverAffiliation == DriverAffiliation.companyFleet ? 'corp-fleet-hub' : selectedLaundry.id,
                        assignedLaundryName: _driverAffiliation == DriverAffiliation.companyFleet ? 'UniWash Central Corporate Fleet (Not for Laundry)' : selectedLaundry.name,
                        affiliation: _driverAffiliation,
                        documents: DriverDocumentFolder(
                          passportDocumentName: 'Passport_$name.pdf',
                          visaDocumentName: 'Visa_QA.pdf',
                          drivingLicenseDocumentName: 'Driving_License_QA.pdf',
                          qidDocumentName: 'QID_${_idCard.text.trim()}.pdf',
                          signedContractDocumentName: 'Signed_Contract_2026.pdf',
                          vehicleRegPlate: 'QA-Plate-${now.millisecondsSinceEpoch.toString().substring(9)}',
                          joinedAt: now,
                        ),
                      );
                      state.addDriver(newDriver);
                    }

                    // Register in Team Member Roster
                    state.addTeamMember(TeamMemberModel(
                      id: 'tm-${now.millisecondsSinceEpoch}',
                      fullName: name,
                      email: email,
                      phone: phone,
                      category: cat,
                      driverAffiliation: cat == TeamCategory.driver ? _driverAffiliation : null,
                      countryCode: 'QAT',
                      branchId: selectedLaundry.id,
                      branchName: _driverAffiliation == DriverAffiliation.companyFleet && cat == TeamCategory.driver
                          ? 'UniWash Corporate Fleet'
                          : selectedLaundry.name,
                      jobTitle: cat == TeamCategory.driver
                          ? (_driverAffiliation == DriverAffiliation.companyFleet ? 'Company Courier (Corporate Fleet)' : 'Dedicated Laundry Courier')
                          : _selectedRole,
                      joinedAt: now,
                    ));

                    // Add to Staff Request
                    final req = StaffOnboardingRequest(
                      id: 'stf-${now.millisecondsSinceEpoch}',
                      fullName: name,
                      idCardNumber: _idCard.text.trim(),
                      role: _selectedRole,
                      address: _address.text.trim(),
                      passportNumber: _passport.text.trim(),
                      submittedAt: now,
                      isApprovedBySuperAdmin: true,
                      regionalAdminName: state.currentUser.fullName,
                    );
                    state.addStaffRequest(req);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Successfully onboarded "$name" as $_selectedRole!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: const Text('Complete Onboarding & Activate Staff', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
