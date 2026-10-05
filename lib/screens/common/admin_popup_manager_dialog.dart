import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_popup_offer.dart';
import '../../models/user.dart';
import '../../services/localization_service.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uniwash_logo.dart';
import '../customer/customer_offer_popup_dialog.dart';

class AdminPopupManagerDialog extends StatefulWidget {
  final String? lockedCountryCode;

  const AdminPopupManagerDialog({super.key, this.lockedCountryCode});

  static void show(BuildContext context, {String? lockedCountryCode}) {
    showDialog(
      context: context,
      builder: (_) => AdminPopupManagerDialog(lockedCountryCode: lockedCountryCode),
    );
  }

  @override
  State<AdminPopupManagerDialog> createState() => _AdminPopupManagerDialogState();
}

class _AdminPopupManagerDialogState extends State<AdminPopupManagerDialog> {
  late bool _isActive;
  late String _selectedCountry;
  late TextEditingController _titleEnController;
  late TextEditingController _titleArController;
  late TextEditingController _descEnController;
  late TextEditingController _descArController;
  late TextEditingController _imageUrlController;
  late TextEditingController _promoCodeController;
  late TextEditingController _badgeEnController;
  late TextEditingController _badgeArController;
  late TextEditingController _ctaEnController;
  late TextEditingController _ctaArController;
  late double _discountPercent;
  late Color _primaryColor;
  late String _selectedPresetKey;

  final List<Color> _colorOptions = const [
    Color(0xFF0F766E), // Teal
    Color(0xFF0284C7), // Sky Blue
    Color(0xFF7C3AED), // Purple
    Color(0xFFB91C1C), // Deep Red
    Color(0xFF15803D), // Emerald Green
    Color(0xFF800020), // Burgundy
  ];

  @override
  void initState() {
    super.initState();
    final state = Provider.of<StateService>(context, listen: false);
    final existing = state.activePopupOffer ??
        (state.popupOffers.isNotEmpty
            ? state.popupOffers.first
            : AppPopupOffer(
                id: 'popup_${DateTime.now().millisecondsSinceEpoch}',
                title: 'Special Laundry Promotion: 35% OFF',
                titleAr: 'عرض ترويجي خاص: خصم 35%',
                description: 'Enjoy professional garment care, stain protection, and free pickup.',
                descriptionAr: 'عناية فائقة بملابسكم مع استلام وتوصيل مجاني لباب منزلك.',
                imageUrl: AppPopupOffer.curatedPresets.first.imageUrl,
                imagePresetKey: AppPopupOffer.curatedPresets.first.key,
                promoCode: 'OFFER35',
                discountPercent: 35,
                createdAt: DateTime.now(),
                validUntil: DateTime.now().add(const Duration(days: 30)),
              ));

    _isActive = existing.isActive;
    _selectedCountry = widget.lockedCountryCode ?? existing.countryCode;
    _titleEnController = TextEditingController(text: existing.title);
    _titleArController = TextEditingController(text: existing.titleAr);
    _descEnController = TextEditingController(text: existing.description);
    _descArController = TextEditingController(text: existing.descriptionAr);
    _imageUrlController = TextEditingController(text: existing.imageUrl);
    _promoCodeController = TextEditingController(text: existing.promoCode);
    _badgeEnController = TextEditingController(text: existing.badgeText);
    _badgeArController = TextEditingController(text: existing.badgeTextAr);
    _ctaEnController = TextEditingController(text: existing.ctaText);
    _ctaArController = TextEditingController(text: existing.ctaTextAr);
    _discountPercent = existing.discountPercent;
    _primaryColor = existing.primaryColor;
    _selectedPresetKey = existing.imagePresetKey;
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleArController.dispose();
    _descEnController.dispose();
    _descArController.dispose();
    _imageUrlController.dispose();
    _promoCodeController.dispose();
    _badgeEnController.dispose();
    _badgeArController.dispose();
    _ctaEnController.dispose();
    _ctaArController.dispose();
    super.dispose();
  }

  void _applyPreset(PopupImagePreset preset) {
    setState(() {
      _selectedPresetKey = preset.key;
      _imageUrlController.text = preset.imageUrl;
      if (_titleEnController.text.isEmpty || _titleEnController.text.contains('OFF')) {
        _titleEnController.text = preset.defaultTitle;
      }
      if (_titleArController.text.isEmpty || _titleArController.text.contains('%')) {
        _titleArController.text = preset.defaultTitleAr;
      }
      if (_descEnController.text.isEmpty) {
        _descEnController.text = preset.defaultDesc;
      }
      if (_descArController.text.isEmpty) {
        _descArController.text = preset.defaultDescAr;
      }
    });
  }

  AppPopupOffer _buildCurrentOffer() {
    final countryConfig = LocalizationService.getCountry(_selectedCountry);
    return AppPopupOffer(
      id: 'popup_main_offer',
      isActive: _isActive,
      title: _titleEnController.text.trim().isEmpty ? 'Special Laundry Offer' : _titleEnController.text.trim(),
      titleAr: _titleArController.text.trim().isEmpty ? _titleEnController.text.trim() : _titleArController.text.trim(),
      description: _descEnController.text.trim().isEmpty ? 'Claim your exclusive offer today!' : _descEnController.text.trim(),
      descriptionAr: _descArController.text.trim().isEmpty ? _descEnController.text.trim() : _descArController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? AppPopupOffer.curatedPresets.first.imageUrl
          : _imageUrlController.text.trim(),
      imagePresetKey: _selectedPresetKey,
      badgeText: _badgeEnController.text.trim().isEmpty ? 'SPECIAL OFFER' : _badgeEnController.text.trim(),
      badgeTextAr: _badgeArController.text.trim().isEmpty ? 'عرض خاص' : _badgeArController.text.trim(),
      promoCode: _promoCodeController.text.trim().isEmpty ? 'SAVE30' : _promoCodeController.text.trim().toUpperCase(),
      discountPercent: _discountPercent,
      countryCode: _selectedCountry,
      countryFlag: countryConfig.flag,
      ctaText: _ctaEnController.text.trim().isEmpty ? 'Claim Discount & Order' : _ctaEnController.text.trim(),
      ctaTextAr: _ctaArController.text.trim().isEmpty ? 'احصل على الخصم واطلب الآن' : _ctaArController.text.trim(),
      ctaAction: 'catalog',
      secondaryText: 'Maybe Later',
      secondaryTextAr: 'ربما لاحقاً',
      primaryColor: _primaryColor,
      createdAt: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 30)),
    );
  }

  void _saveAndPublish(StateService state) {
    final offer = _buildCurrentOffer();
    state.savePopupOffer(offer);
    state.resetPopupSessionDismissal(offer.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              _isActive
                  ? '🎉 Popup Offer published live! Customers will see it on app launch.'
                  : 'ℹ️ Popup Offer saved as DISABLED (Customers won\'t see it until enabled).',
            ),
          ],
        ),
        backgroundColor: _isActive ? const Color(0xFF15803D) : const Color(0xFF475569),
        duration: const Duration(seconds: 4),
      ),
    );
    Navigator.pop(context);
  }

  void _testOnCustomerApp(StateService state) {
    final offer = _buildCurrentOffer();
    state.resetPopupSessionDismissal(offer.id);
    CustomerOfferPopupDialog.show(context, offer: offer);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = state.currentLanguage == AppLanguage.ar;
    final user = state.currentUser;
    final isRegionalAdmin = user.role == UserRole.regionalAdmin;
    final previewOffer = _buildCurrentOffer();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1020, maxHeight: 850),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const UniWashLogo.badge(size: 32),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('⚡', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'مدير النافذة المنبثقة لتطبيق العملاء' : 'Customer App Offer Popup Console',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        Text(
                          isAr
                              ? 'تحكم بصور العروض، نصوص الخصم، كود الخصم، وتفعيل النافذة مباشرة'
                              : 'Control offer photo, discount code, custom message & live launch popup',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),

                // Live Active Switch & Close
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isActive ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isActive ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isActive ? Icons.visibility : Icons.visibility_off,
                            size: 16,
                            color: _isActive ? const Color(0xFF16A34A) : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isActive ? 'POPUP ACTIVE' : 'DISABLED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: _isActive ? const Color(0xFF15803D) : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: _isActive,
                            activeThumbColor: const Color(0xFF16A34A),
                            onChanged: (val) => setState(() => _isActive = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),

            // Main Two-Column Body
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Configuration Form
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Territory Target & Color Palette Row
                          Row(
                            children: [
                              // Territory
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Target Territory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedCountry,
                                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                      items: [
                                        const DropdownMenuItem(value: 'ALL', child: Text('🌐 Global (All Countries)')),
                                        ...LocalizationService.countries.values.map(
                                          (c) => DropdownMenuItem(value: c.code, child: Text('${c.flag} ${c.name} (${c.code})')),
                                        ),
                                      ],
                                      onChanged: isRegionalAdmin
                                          ? null
                                          : (val) {
                                              if (val != null) setState(() => _selectedCountry = val);
                                            },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Color Palette
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Brand Theme Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      children: _colorOptions.map((c) {
                                        final isSel = _primaryColor == c;
                                        return InkWell(
                                          onTap: () => setState(() => _primaryColor = c),
                                          child: Container(
                                            width: 26,
                                            height: 26,
                                            decoration: BoxDecoration(
                                              color: c,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSel ? Colors.black : Colors.transparent,
                                                width: 2.5,
                                              ),
                                              boxShadow: [
                                                if (isSel)
                                                  BoxShadow(
                                                    color: c.withValues(alpha: 0.5),
                                                    blurRadius: 6,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Photo / Image Selection Section
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.photo_library_outlined, size: 18, color: AppColors.primary),
                                        SizedBox(width: 6),
                                        Text('Popup Banner Photo & Presets', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                      ],
                                    ),
                                    Text(
                                      'Click any preset to auto-apply image & copy',
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Preset Chips
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: AppPopupOffer.curatedPresets.map((preset) {
                                    final isSel = _selectedPresetKey == preset.key;
                                    return InkWell(
                                      onTap: () => _applyPreset(preset),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isSel ? _primaryColor.withValues(alpha: 0.15) : Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSel ? _primaryColor : AppColors.border,
                                            width: isSel ? 1.5 : 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(preset.emoji, style: const TextStyle(fontSize: 14)),
                                            const SizedBox(width: 6),
                                            Text(
                                              preset.label,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                                color: isSel ? _primaryColor : AppColors.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 12),

                                // Direct Image URL Input
                                const Text('Or Enter Custom Image URL (Direct Link):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _imageUrlController,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: 'https://images.unsplash.com/...',
                                    prefixIcon: const Icon(Icons.link, size: 16),
                                    suffixIcon: _imageUrlController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 16),
                                            onPressed: () => setState(() => _imageUrlController.clear()),
                                          )
                                        : null,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Promo Code & Discount Row
                          Row(
                            children: [
                              // Promo Code
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Promo Coupon Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _promoCodeController,
                                      onChanged: (_) => setState(() {}),
                                      textCapitalization: TextCapitalization.characters,
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. UNIWASH35, EIDSPECIAL',
                                        prefixIcon: Icon(Icons.local_offer, size: 16),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Discount % Slider
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Discount Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _primaryColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${_discountPercent.toStringAsFixed(0)}% OFF',
                                            style: TextStyle(fontWeight: FontWeight.w900, color: _primaryColor, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Slider(
                                      value: _discountPercent,
                                      min: 0,
                                      max: 90,
                                      divisions: 18,
                                      activeColor: _primaryColor,
                                      onChanged: (val) => setState(() => _discountPercent = val),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Offer Headline / Badge
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Offer Badge (English)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _badgeEnController,
                                      onChanged: (_) => setState(() {}),
                                      decoration: const InputDecoration(hintText: 'e.g. EXCLUSIVE PROMO', contentPadding: EdgeInsets.all(10)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Offer Badge (Arabic)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _badgeArController,
                                      textDirection: TextDirection.rtl,
                                      onChanged: (_) => setState(() {}),
                                      decoration: const InputDecoration(hintText: 'عرض خاص وحصري', contentPadding: EdgeInsets.all(10)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Title EN & AR
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Popup Title (English)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _titleEnController,
                                      onChanged: (_) => setState(() {}),
                                      decoration: const InputDecoration(hintText: 'e.g. VIP Master Dry Clean: 35% OFF', contentPadding: EdgeInsets.all(10)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Popup Title (Arabic)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _titleArController,
                                      textDirection: TextDirection.rtl,
                                      onChanged: (_) => setState(() {}),
                                      decoration: const InputDecoration(hintText: 'عنوان العرض بالعربية...', contentPadding: EdgeInsets.all(10)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Description EN & AR
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Description (English)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _descEnController,
                                      maxLines: 2,
                                      onChanged: (_) => setState(() {}),
                                      decoration: const InputDecoration(
                                        hintText: 'Hand-finished pressing, delicate stain treatment, and cedar hangers.',
                                        contentPadding: EdgeInsets.all(10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Description (Arabic)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _descArController,
                                      textDirection: TextDirection.rtl,
                                      maxLines: 2,
                                      onChanged: (_) => setState(() {}),
                                      decoration: const InputDecoration(
                                        hintText: 'كوي يدوي متقن مع حماية الأنسجة وتوصيل سريع...',
                                        contentPadding: EdgeInsets.all(10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // CTA Button Label EN & AR
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Action Button Text (English)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _ctaEnController,
                                      onChanged: (_) => setState(() {}),
                                      decoration: const InputDecoration(hintText: 'e.g. Claim 35% OFF Now', contentPadding: EdgeInsets.all(10)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Action Button Text (Arabic)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _ctaArController,
                                      textDirection: TextDirection.rtl,
                                      onChanged: (_) => setState(() {}),
                                      decoration: const InputDecoration(hintText: 'احصل على الخصم واطلب الآن', contentPadding: EdgeInsets.all(10)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Vertical Divider
                  const VerticalDivider(width: 24),

                  // Right Column: Live Customer App Mobile Preview
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.smartphone, size: 18, color: AppColors.primary),
                                SizedBox(width: 6),
                                Text('Live Customer Screen Preview', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => _testOnCustomerApp(state),
                              icon: const Icon(Icons.open_in_new, size: 14),
                              label: const Text('Test Pop-Up', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Preview Phone Container
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.black, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  // Simulated Customer App Background
                                  Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: Center(
                                      child: Opacity(
                                        opacity: 0.35,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const UniWashLogo(height: 40),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Customer Home Screen Underneath',
                                              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Dark backdrop overlay for modal
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.5),
                                  ),

                                  // Live Preview Dialog Card
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 16,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              // Preview Photo
                                              Stack(
                                                children: [
                                                  SizedBox(
                                                    height: 120,
                                                    width: double.infinity,
                                                    child: Image.network(
                                                      previewOffer.imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => Container(
                                                        color: previewOffer.primaryColor,
                                                        child: Center(
                                                          child: Text(
                                                            '${previewOffer.discountPercent.toStringAsFixed(0)}% OFF',
                                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 8,
                                                    left: 10,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF59E0B),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        previewOffer.badgeText,
                                                        style: const TextStyle(
                                                          color: Color(0xFF78350F),
                                                          fontWeight: FontWeight.w900,
                                                          fontSize: 8,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // Preview Text
                                              Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      previewOffer.title,
                                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                                      maxLines: 2,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      previewOffer.description,
                                                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                                      maxLines: 2,
                                                    ),
                                                    const SizedBox(height: 8),

                                                    // Promo Tag
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF0FDF4),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: const Color(0xFF86EFAC)),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'CODE: ${previewOffer.promoCode}',
                                                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF15803D), fontSize: 10),
                                                          ),
                                                          const Text('✂️ Copy', style: TextStyle(color: Color(0xFF16A34A), fontSize: 9, fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),

                                                    // Button
                                                    Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: previewOffer.primaryColor,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          previewOffer.ctaText,
                                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            // Bottom Actions Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isActive
                      ? '🟢 Popup is currently LIVE for customer app users.'
                      : '⚪ Popup is currently INACTIVE. Toggle switch on to show to customers.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isActive ? const Color(0xFF15803D) : AppColors.textMuted,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _saveAndPublish(state),
                      icon: const Icon(Icons.rocket_launch, size: 16),
                      label: const Text('Save & Publish to Customer App', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
