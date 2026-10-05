import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LaundryDriverOnboardDialog extends StatefulWidget {
  final Function(Map<String, String> data) onSubmit;

  const LaundryDriverOnboardDialog({super.key, required this.onSubmit});

  @override
  State<LaundryDriverOnboardDialog> createState() => _LaundryDriverOnboardDialogState();
}

class _LaundryDriverOnboardDialogState extends State<LaundryDriverOnboardDialog> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _license = TextEditingController();
  final _qid = TextEditingController();

  bool _hasPassportPhoto = false;
  bool _hasVisaPhoto = false;
  bool _hasLicensePhoto = false;
  bool _hasDriverPhoto = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _license.dispose();
    _qid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Driver Onboarding Application', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Text('Submit driver registration to Regional Admin for review & credential generation', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: _firstName, decoration: const InputDecoration(labelText: 'First Name *'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: _lastName, decoration: const InputDecoration(labelText: 'Last Name *'))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Mobile Phone *'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email Address *'))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: _license, decoration: const InputDecoration(labelText: 'Driving License # *'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: _qid, decoration: const InputDecoration(labelText: 'QID / Passport # *'))),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Required Document Attachments', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _attachmentButton('Passport Photo', _hasPassportPhoto, () => setState(() => _hasPassportPhoto = true)),
                  _attachmentButton('Visa Photo', _hasVisaPhoto, () => setState(() => _hasVisaPhoto = true)),
                  _attachmentButton('License Copy', _hasLicensePhoto, () => setState(() => _hasLicensePhoto = true)),
                  _attachmentButton('Driver Face Photo', _hasDriverPhoto, () => setState(() => _hasDriverPhoto = true)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_firstName.text.isEmpty || _phone.text.isEmpty || _license.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill mandatory fields.')),
                      );
                      return;
                    }
                    widget.onSubmit({
                      'name': '${_firstName.text} ${_lastName.text}',
                      'phone': _phone.text,
                      'license': _license.text,
                      'qid': _qid.text,
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Submit Application to Admin'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachmentButton(String label, bool isDone, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFD1FAE5) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDone ? AppColors.success : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isDone ? Icons.check_circle : Icons.upload_file, size: 14, color: isDone ? AppColors.success : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDone ? AppColors.success : AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}
