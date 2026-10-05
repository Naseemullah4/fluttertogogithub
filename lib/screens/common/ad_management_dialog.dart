import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../../models/advertisement.dart';
import '../../models/user.dart';
import '../../services/localization_service.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uniwash_logo.dart';
import 'admin_popup_manager_dialog.dart';

class AdManagementDialog extends StatefulWidget {
  final String? lockedCountryCode; // If set by Regional Admin, restrict to their territory

  const AdManagementDialog({super.key, this.lockedCountryCode});

  static void show(BuildContext context, {String? lockedCountryCode}) {
    showDialog(
      context: context,
      builder: (_) => AdManagementDialog(lockedCountryCode: lockedCountryCode),
    );
  }

  @override
  State<AdManagementDialog> createState() => _AdManagementDialogState();
}

class _AdManagementDialogState extends State<AdManagementDialog> {
  String _selectedFilter = 'ALL';
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = state.currentLanguage == AppLanguage.ar;
    final user = state.currentUser;
    final isRegionalAdmin = user.role == UserRole.regionalAdmin;
    final territoryFilter = widget.lockedCountryCode ?? (isRegionalAdmin ? state.selectedCountry.code : null);

    final allAds = state.advertisements;
    final filteredAds = allAds.where((ad) {
      if (territoryFilter != null && ad.countryCode != 'ALL' && ad.countryCode != territoryFilter) {
        return false;
      }
      if (_selectedFilter == 'ALL') return true;
      if (_selectedFilter == 'ACTIVE') return ad.isActive;
      if (_selectedFilter == 'BROADCAST') return ad.isBroadcastPushed;
      if (_selectedFilter == 'REGIONAL') return ad.countryCode != 'ALL';
      if (_selectedFilter == 'GLOBAL') return ad.countryCode == 'ALL';
      return true;
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 800),
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
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Text('📢', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isAr ? 'مدير الإعلانات ورسائل البث الترويجية' : 'Advertisement & Broadcast Messaging Console',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                            ),
                            const SizedBox(width: 8),
                            if (territoryFilter != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'Territory: $territoryFilter',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          isAr
                              ? 'إدارة لافتات ورسائل العروض الإقليمية وبثها فورياً لتطبيق العملاء'
                              : 'Upload ad graphics, configure regional banners & push live broadcasts to customer apps',
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
            const Divider(height: 24),

            // Action & Filter Bar
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildFilterChip('ALL', isAr ? 'الكل (${allAds.length})' : 'All Ads (${allAds.length})'),
                _buildFilterChip('ACTIVE', isAr ? 'النشطة' : 'Active Only'),
                _buildFilterChip('BROADCAST', isAr ? 'رسائل البث المباشر' : 'Pushed Broadcasts'),
                _buildFilterChip('REGIONAL', isAr ? 'الإقليمية' : 'Regional Territories'),
                _buildFilterChip('GLOBAL', isAr ? 'العالمية (ALL)' : 'Global Ads'),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showAddEditAdDialog(context, state, defaultCountryCode: territoryFilter),
                  icon: const Icon(Icons.add_photo_alternate, size: 16),
                  label: Text(
                    isAr ? 'إضافة إعلان وبث جديد' : 'New Ad / Broadcast Message',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => AdminPopupManagerDialog.show(context, lockedCountryCode: territoryFilter),
                  icon: const Icon(Icons.flash_on, size: 16),
                  label: Text(
                    isAr ? 'مدير نافذة العروض المنبثقة' : 'Customer Popup Manager',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ads List
            Expanded(
              child: filteredAds.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.campaign_outlined, size: 48, color: AppColors.textLight),
                          const SizedBox(height: 12),
                          Text(
                            isAr ? 'لا توجد إعلانات مطابقة للمحدد' : 'No advertisements found for this filter.',
                            style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredAds.length,
                      itemBuilder: (context, index) {
                        final ad = filteredAds[index];
                        return _buildAdCard(context, state, ad, isAr);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primaryDark : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildAdCard(BuildContext context, StateService state, Advertisement ad, bool isAr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ad.isBroadcastPushed ? Colors.amber.shade400 : AppColors.border,
          width: ad.isBroadcastPushed ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Graphic Banner Preview Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ad.primaryColor, ad.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(ad.graphicEmoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr && ad.titleAr.isNotEmpty ? ad.titleAr : ad.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          isAr && ad.messageAr.isNotEmpty ? ad.messageAr : ad.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(ad.countryFlag, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          ad.countryCode,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Body & Controls
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Active Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ad.isActive ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ad.isActive ? Colors.green.shade300 : Colors.red.shade300),
                          ),
                          child: Text(
                            ad.isActive ? '🟢 Active On App' : '⚪ Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ad.isActive ? Colors.green.shade800 : Colors.red.shade800,
                            ),
                          ),
                        ),
                        // Broadcast Status Badge
                        if (ad.isBroadcastPushed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: const Text(
                              '📢 Broadcast Live',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                            ),
                          ),
                        // CTA Link
                        Text(
                          'CTA: "${isAr ? ad.ctaTextAr : ad.ctaText}" → ${ad.ctaLink}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                        // Valid Until
                        Text(
                          'Valid: ${_dateFormat.format(ad.validUntil)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Push Live Broadcast Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ad.isBroadcastPushed ? Colors.amber.shade600 : const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          state.broadcastAdvertisementMessage(ad.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('📢 Broadcast pushed to customer app: "${ad.title}"'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.cell_tower, size: 14),
                        label: Text(
                          ad.isBroadcastPushed ? 'Re-Broadcast' : 'Push Broadcast',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Edit Button
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                        tooltip: 'Edit Ad',
                        onPressed: () => _showAddEditAdDialog(context, state, existingAd: ad),
                      ),

                      // Toggle Switch
                      Switch(
                        value: ad.isActive,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => state.toggleAdvertisementActive(ad.id),
                      ),

                      // Delete
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        tooltip: 'Delete Ad',
                        onPressed: () {
                          state.deleteAdvertisement(ad.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🗑️ Advertisement deleted successfully.')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditAdDialog(
    BuildContext context,
    StateService state, {
    Advertisement? existingAd,
    String? defaultCountryCode,
  }) {
    final titleController = TextEditingController(text: existingAd?.title ?? '');
    final titleArController = TextEditingController(text: existingAd?.titleAr ?? '');
    final messageController = TextEditingController(text: existingAd?.message ?? '');
    final messageArController = TextEditingController(text: existingAd?.messageAr ?? '');
    final ctaController = TextEditingController(text: existingAd?.ctaText ?? 'Claim Offer');
    final ctaArController = TextEditingController(text: existingAd?.ctaTextAr ?? 'احصل على العرض');

    String selectedCountry = existingAd?.countryCode ?? defaultCountryCode ?? 'ALL';
    String selectedPreset = existingAd?.graphicPreset ?? 'thobe_care';
    String selectedEmoji = existingAd?.graphicEmoji ?? '✨';
    Color selectedPrimary = existingAd?.primaryColor ?? const Color(0xFF0F766E);
    Color selectedSecondary = existingAd?.secondaryColor ?? const Color(0xFF14B8A6);
    AdBannerType selectedType = existingAd?.bannerType ?? AdBannerType.graphicBanner;
    bool broadcastNow = existingAd?.isBroadcastPushed ?? true;

    final presetGraphics = [
      {'key': 'thobe_care', 'emoji': '👔', 'label': 'Thobe & Bespoke'},
      {'key': 'dress_promo', 'emoji': '👗', 'label': 'Evening Gowns'},
      {'key': 'suit_luxury', 'emoji': '✨', 'label': 'Savile Row Suits'},
      {'key': 'carpet_curtain', 'emoji': '🛏️', 'label': 'Bedding & Drapes'},
      {'key': 'express_van', 'emoji': '🚚', 'label': 'Express Van'},
      {'key': 'shoes_clean', 'emoji': '👟', 'label': 'Footwear Spa'},
      {'key': 'eco_green', 'emoji': '🌿', 'label': 'Eco Solvent'},
      {'key': 'stars_gold', 'emoji': '⭐', 'label': 'VIP Gold'},
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            existingAd == null ? 'Create Advertisement & Broadcast' : 'Edit Advertisement',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SizedBox(
            width: 580,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Headline EN
                  const Text('Headline / Promo Title (English)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 50% OFF Luxury Thobe Pressing',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Headline AR
                  const Text('Headline (Arabic)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleArController,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      hintText: 'مثال: خصم 50% على غسيل وكوي الثياب الفاخرة',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message Body EN
                  const Text('Broadcast Message / Subtitle (English)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: messageController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Detailed offer message pushed to customer notifications and feed...',
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message Body AR
                  const Text('Broadcast Message (Arabic)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: messageArController,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'نص الرسالة الترويجية المنشورة بالتطبيق...',
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Territory & Type
                  Row(
                    children: [
                      // Country Territory
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Target Territory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: selectedCountry,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                              items: [
                                const DropdownMenuItem(value: 'ALL', child: Text('🌐 Global (All Countries)')),
                                ...LocalizationService.countries.values.map(
                                  (c) => DropdownMenuItem(value: c.code, child: Text('${c.flag} ${c.name} (${c.code})')),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) setDialogState(() => selectedCountry = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Banner Type
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ad Display Format', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<AdBannerType>(
                              initialValue: selectedType,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                              items: const [
                                DropdownMenuItem(value: AdBannerType.graphicBanner, child: Text('🖼️ Graphic Card Banner')),
                                DropdownMenuItem(value: AdBannerType.announcementTicker, child: Text('📢 Announcement Ticker')),
                                DropdownMenuItem(value: AdBannerType.carouselSlide, child: Text('🎠 Carousel Slide')),
                                DropdownMenuItem(value: AdBannerType.inAppPopup, child: Text('⚡ In-App Dialog Popup')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDialogState(() => selectedType = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Graphic Preset Selector
                  const Text('Select Graphic Banner Asset / Icon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presetGraphics.map((preset) {
                      final isSel = selectedPreset == preset['key'];
                      return InkWell(
                        onTap: () {
                          setDialogState(() {
                            selectedPreset = preset['key'] as String;
                            selectedEmoji = preset['emoji'] as String;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary.withValues(alpha: 0.15) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(preset['emoji'] as String, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(preset['label'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // CTA Button Text
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CTA Button (English)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: ctaController,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CTA Button (Arabic)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: ctaArController,
                              textDirection: TextDirection.rtl,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Push Broadcast Immediately checkbox
                  CheckboxListTile(
                    value: broadcastNow,
                    title: const Text('Push as live broadcast announcement to customer app immediately', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Customers will see an instant notification banner and promo alert upon opening app', style: TextStyle(fontSize: 10)),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setDialogState(() => broadcastNow = val ?? true),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                final flag = selectedCountry == 'ALL'
                    ? '🌐'
                    : (LocalizationService.countries[selectedCountry]?.flag ?? '🌐');

                if (existingAd == null) {
                  final newAd = Advertisement(
                    id: 'ad_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleController.text.trim().isEmpty ? 'Special Laundry Promotion' : titleController.text.trim(),
                    titleAr: titleArController.text.trim(),
                    message: messageController.text.trim().isEmpty ? 'Exclusive doorstep laundry savings available now.' : messageController.text.trim(),
                    messageAr: messageArController.text.trim(),
                    countryCode: selectedCountry,
                    countryFlag: flag,
                    graphicPreset: selectedPreset,
                    graphicEmoji: selectedEmoji,
                    ctaText: ctaController.text.trim(),
                    ctaTextAr: ctaArController.text.trim(),
                    bannerType: selectedType,
                    primaryColor: selectedPrimary,
                    secondaryColor: selectedSecondary,
                    isBroadcastPushed: broadcastNow,
                    createdAt: DateTime.now(),
                    validUntil: DateTime.now().add(const Duration(days: 30)),
                  );
                  state.addNewAdvertisement(newAd);
                } else {
                  final updated = existingAd.copyWith(
                    title: titleController.text.trim(),
                    titleAr: titleArController.text.trim(),
                    message: messageController.text.trim(),
                    messageAr: messageArController.text.trim(),
                    countryCode: selectedCountry,
                    countryFlag: flag,
                    graphicPreset: selectedPreset,
                    graphicEmoji: selectedEmoji,
                    ctaText: ctaController.text.trim(),
                    ctaTextAr: ctaArController.text.trim(),
                    bannerType: selectedType,
                    isBroadcastPushed: broadcastNow,
                  );
                  state.updateAdvertisement(updated);
                }

                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(existingAd == null ? '🎉 New advertisement created and activated!' : '✅ Advertisement updated.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text(existingAd == null ? 'Deploy Advertisement' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
