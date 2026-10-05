import 'package:flutter/material.dart';

import '../../models/laundry.dart';
import '../../theme/app_colors.dart';

class AdminEscalationDialog extends StatefulWidget {
  final String entityName;
  final String entityType; // 'Laundry' or 'Driver'
  final WarningLevel currentLevel;
  final Function(WarningLevel newLevel) onApply;

  const AdminEscalationDialog({
    super.key,
    required this.entityName,
    required this.entityType,
    required this.currentLevel,
    required this.onApply,
  });

  @override
  State<AdminEscalationDialog> createState() => _AdminEscalationDialogState();
}

class _AdminEscalationDialogState extends State<AdminEscalationDialog> {
  late WarningLevel _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentLevel;
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
                  Text(
                    'Escalation Warning Matrix',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'Managing: ${widget.entityType} "${widget.entityName}"',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const Divider(height: 20),
              const Text(
                'Select Regulatory Escalation Warning Level:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ...WarningLevel.values.map((lvl) {
                final isSelected = _selected == lvl;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: lvl.color.withValues(alpha: isSelected ? 0.2 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? lvl.color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: RadioListTile<WarningLevel>(
                    value: lvl,
                    // ignore: deprecated_member_use
                    groupValue: _selected,
                    activeColor: lvl.color,
                    title: Text(
                      lvl.displayName,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                    ),
                    subtitle: Text(
                      _getLevelDescription(lvl),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    // ignore: deprecated_member_use
                    onChanged: (val) {
                      if (val != null) setState(() => _selected = val);
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selected == WarningLevel.terminated
                        ? AppColors.error
                        : AppColors.primary,
                  ),
                  onPressed: () {
                    widget.onApply(_selected);
                    Navigator.pop(context);
                  },
                  child: Text(
                    _selected == WarningLevel.terminated
                        ? 'Terminate Account Access'
                        : 'Apply Warning Level',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLevelDescription(WarningLevel lvl) {
    switch (lvl) {
      case WarningLevel.none:
        return 'Standard operating status. High customer satisfaction and zero legal notices.';
      case WarningLevel.lightYellow:
        return 'Level 1: Minor delays or customer complaints. Soft email notification sent.';
      case WarningLevel.yellow:
        return 'Level 2: Repeated delay notices or count discrepancies. Formal warning issued.';
      case WarningLevel.lightRed:
        return 'Level 3: Contractual infraction risk. Daily monitoring and audit mandated.';
      case WarningLevel.fullRed:
        return 'Level 4: Final Notice before termination. Payouts withheld pending review.';
      case WarningLevel.terminated:
        return 'Account Terminated. Service access blocked and legal penalties applied.';
    }
  }
}
