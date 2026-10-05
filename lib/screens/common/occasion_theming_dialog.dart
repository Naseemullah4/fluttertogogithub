import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/occasion_theme.dart';
import '../../models/user.dart';
import '../../services/localization_service.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uniwash_logo.dart';

class OccasionThemingDialog extends StatefulWidget {
  final String? lockedCountryCode;

  const OccasionThemingDialog({super.key, this.lockedCountryCode});

  static void show(BuildContext context, {String? lockedCountryCode}) {
    showDialog(
      context: context,
      builder: (_) => OccasionThemingDialog(lockedCountryCode: lockedCountryCode),
    );
  }

  @override
  State<OccasionThemingDialog> createState() => _OccasionThemingDialogState();
}

class _OccasionThemingDialogState extends State<OccasionThemingDialog> {
  late String _selectedTargetCountry;

  @override
  void initState() {
    super.initState();
    _selectedTargetCountry = widget.lockedCountryCode ?? 'ALL';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = state.currentLanguage == AppLanguage.ar;
    final user = state.currentUser;
    final isSuperAdmin = user.role == UserRole.superAdmin;
    final isRegionalAdmin = user.role == UserRole.regionalAdmin;

    // Strict Role-Based Access Restriction
    if (!isSuperAdmin && !isRegionalAdmin) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_person, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text(
                'Access Restricted',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Occasion-based theming and app styling controls are strictly restricted to Super Admin and Regional Admin roles.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
      );
    }

    final targetCountry = widget.lockedCountryCode ?? (isRegionalAdmin ? state.selectedCountry.code : _selectedTargetCountry);
    final activeTheme = state.getOccasionThemeForCountry(targetCountry);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const UniWashLogo.badge(size: 34),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD8B4FE)),
                      ),
                      child: const Text('🎨', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'مخصص سمات المناسبات والأعياد الديناميكي' : 'Dynamic Occasion-Based Theming Engine',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        Text(
                          isAr
                              ? 'تخصيص ألوان وتصميم التطبيق حسب المناسبات (رمضان، الأعياد، الأيام الوطنية، الحداد) لكل دولة'
                              : 'Customize app colors, festive icons & greeting banners per-country or globally',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),

            // Territory / Dashboard Selector Bar
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.public, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'النطاق الإقليمي المستهدف للتخصيص:' : 'Target Territory / Dashboard:',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      Text(
                        isSuperAdmin
                            ? 'Super Admin can assign themes per-country or global (ALL)'
                            : 'Regional Admin: Theme locked to your assigned territory ($targetCountry)',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (isSuperAdmin && widget.lockedCountryCode == null)
                    DropdownButton<String>(
                      value: _selectedTargetCountry,
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem(value: 'ALL', child: Text('🌐 Global (All Countries)')),
                        ...LocalizationService.countries.values.map(
                          (c) => DropdownMenuItem(value: c.code, child: Text('${c.flag} ${c.name} (${c.code})')),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTargetCountry = val);
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${LocalizationService.countries[targetCountry]?.flag ?? '🌐'} $targetCountry',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Active Theme Preview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [activeTheme.primaryColor, activeTheme.primaryDarkColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: activeTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(activeTheme.iconEmoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isAr ? activeTheme.nameAr : activeTheme.name,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('CURRENT LIVE THEME', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr ? activeTheme.greetingBannerAr : activeTheme.greetingBanner,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildColorDot('Primary', activeTheme.primaryColor),
                      const SizedBox(width: 6),
                      _buildColorDot('Light', activeTheme.primaryLightColor),
                      const SizedBox(width: 6),
                      _buildColorDot('Accent', activeTheme.accentColor),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Select from Occasion Themes
            Text(
              isAr ? 'اختر سمة المناسبة لتفعيلها:' : 'Available Occasion Themes Gallery:',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 10),

            // Themes Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.3,
                ),
                itemCount: OccasionTheme.presetThemes.length,
                itemBuilder: (context, index) {
                  final preset = OccasionTheme.presetThemes[index];
                  final isCurrentActive = preset.id == activeTheme.id;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrentActive ? preset.primaryColor : AppColors.border,
                        width: isCurrentActive ? 2.2 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: preset.primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(preset.iconEmoji, style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? preset.nameAr : preset.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(color: preset.primaryColor, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(color: preset.accentColor, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        preset.countryCode == 'ALL' ? 'Global' : preset.countryCode,
                                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                isAr ? preset.greetingBannerAr : preset.greetingBanner,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isCurrentActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: const Text(
                                  'Active ✓',
                                  style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              )
                            else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: preset.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: const Size(60, 28),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  state.setOccasionTheme(preset, targetCountryCode: targetCountry);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('🎨 Theme activated for $targetCountry: "${preset.name}"'),
                                      backgroundColor: preset.primaryColor,
                                    ),
                                  );
                                },
                                child: const Text('Apply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 8)),
      ],
    );
  }
}
