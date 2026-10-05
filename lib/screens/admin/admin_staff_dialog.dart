import 'package:flutter/material.dart';
import '../../models/contract.dart';
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
  final _idCard = TextEditingController();
  final _passport = TextEditingController();
  final _address = TextEditingController();
  String _selectedRole = 'Cleaner';

  final List<String> _roles = [
    'Driver',
    'Cleaner',
    'Office Boy',
    'Engineer',
    'Sales Team',
  ];

  @override
  void dispose() {
    _fullName.dispose();
    _idCard.dispose();
    _passport.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      UniWashLogo.badge(size: 26),
                      SizedBox(width: 8),
                      Text('Internal Staff Onboarding', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Text(
                'Register Drivers, Cleaners, Engineers & Sales with compliance metadata.\nRequires Super Admin sign-off.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Staff Position / Role'),
                items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: 'Full Name (As on Passport) *'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _idCard,
                      decoration: const InputDecoration(labelText: 'QID / National ID *'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _passport,
                      decoration: const InputDecoration(labelText: 'Passport Number *'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Residential Address in Qatar *'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock_clock, color: Color(0xFFB45309), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Compliance Note: Staff member cannot access active shifts until Super Admin signs approval.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_fullName.text.isEmpty || _idCard.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all mandatory fields')),
                      );
                      return;
                    }

                    final req = StaffOnboardingRequest(
                      id: 'stf-${DateTime.now().millisecondsSinceEpoch}',
                      fullName: _fullName.text.trim(),
                      idCardNumber: _idCard.text.trim(),
                      role: _selectedRole,
                      address: _address.text.trim(),
                      passportNumber: _passport.text.trim(),
                      submittedAt: DateTime.now(),
                      isApprovedBySuperAdmin: false,
                      regionalAdminName: widget.stateService.currentUser.fullName,
                    );

                    widget.stateService.addStaffRequest(req);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Staff registration for "${_fullName.text}" dispatched to Super Admin queue.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: const Text('Forward to Super Admin Approval Queue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
