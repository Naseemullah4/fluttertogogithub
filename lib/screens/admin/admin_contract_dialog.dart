import 'package:flutter/material.dart';
import '../../models/contract.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uniwash_logo.dart';

class AdminContractDialog extends StatelessWidget {
  final LaundryContract contract;

  const AdminContractDialog({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
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
                      Text(
                        'UniWash Master Laundry Agreement',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              Text(
                'Party: ${contract.laundryName} • Contract Ref: #${contract.id}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const Divider(height: 20),

              // Checklist Section
              const Text(
                'Mandatory Government & Legal Confirmations:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 8),
              _checkRow('Registered with Ministry of Commerce & Industry (Govt Registered)', contract.isGovRegistered),
              _checkRow('Fully compliant with Qatar Commercial & Labor Laws', contract.isLawCompliant),
              _checkRow('Valid Trade License without unresolved civil/penal violations', contract.isLicenseClear),

              const SizedBox(height: 16),
              const Text(
                'Binding Contract Clauses & Terms Enforced:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 8),
              _clauseCard(
                '1. Platform Royalty & Commission',
                'Platform charges 15.00% commission per completed laundry order, automatically deducted upon monthly settlement reconciliation.',
              ),
              _clauseCard(
                '2. Delivery Fees Allocation',
                'Customer delivery charges (15 QAR base) belong 100% to the platform to fund the dedicated driver fleet, insurance, and GPS navigation infrastructure.',
              ),
              _clauseCard(
                '3. Early Cancellation Penalty (\$55 USD/Day)',
                'This agreement is legally binding. Early breach or unauthorized termination requires paying \$55.00 USD per day for the remaining duration or equivalent contractual penalties, subject to civil prosecution in State of Qatar courts.',
              ),
              _clauseCard(
                '4. Advance Notice Policy (2 Working Days)',
                'Laundry facility closures, machinery breakdowns, or logistics delays require at least 2 working days\' written advance notice through the Operations portal.',
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.draw, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Digital Signature Verified', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          Text(contract.signedBy, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close Legal Agreement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkRow(String text, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(checked ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: checked ? AppColors.success : AppColors.error),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _clauseCard(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
