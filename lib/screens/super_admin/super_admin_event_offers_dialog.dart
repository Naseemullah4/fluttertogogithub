import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniwash_laundry/services/localization_service.dart';

import '../../models/event_offer.dart';
import '../../models/user.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uniwash_logo.dart';

class SuperAdminEventOffersDialog extends StatefulWidget {
  final String? lockedCountryCode;

  const SuperAdminEventOffersDialog({super.key, this.lockedCountryCode});

  static void show(BuildContext context, {String? lockedCountryCode}) {
    showDialog(
      context: context,
      builder: (_) => SuperAdminEventOffersDialog(lockedCountryCode: lockedCountryCode),
    );
  }

  @override
  State<SuperAdminEventOffersDialog> createState() =>
      _SuperAdminEventOffersDialogState();
}

class _SuperAdminEventOffersDialogState
    extends State<SuperAdminEventOffersDialog> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = state.currentLanguage == AppLanguage.ar;
    final user = state.currentUser;
    final isRegionalAdmin = user.role == UserRole.regionalAdmin;
    final territory = widget.lockedCountryCode ?? (isRegionalAdmin ? state.selectedCountry.code : null);

    final offers = state.eventOffers;

    final filteredOffers = offers.where((offer) {
      if (territory != null && offer.countryCode != 'ALL' && offer.countryCode != territory) {
        return false;
      }
      if (_selectedFilter == 'ALL') return true;
      if (_selectedFilter == 'ACTIVE') return offer.isActive;
      if (_selectedFilter == 'NATIONAL_DAYS') {
        return offer.eventType == 'national_day';
      }
      if (_selectedFilter == 'RELIGIOUS') {
        return offer.eventType == 'ramadan' ||
            offer.eventType == 'eid' ||
            offer.eventType == 'christmas';
      }
      if (_selectedFilter == 'SEASONAL') {
        return offer.eventType == 'summer' || offer.eventType == 'school';
      }
      return true;
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 880, maxHeight: 780),
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
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('🎉', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr
                              ? 'مدير العروض والمناسبات والأعياد الوطنية'
                              : 'Seasonal & Event Offers Engine',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          isAr
                              ? 'عروض رمضان، العيد، اليوم الوطني مع الأعلام، الكريسماس، الصيف والعودة للمدارس'
                              : 'Ramadan, Eid, National Days with Country Flags, Christmas, Summer & School',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
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

            // Filter Bar & "Add New Offer" Action
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'ALL',
                          'All Events (${offers.length})',
                        ),
                        _buildFilterChip(
                          'ACTIVE',
                          'Active (${offers.where((o) => o.isActive).length})',
                        ),
                        _buildFilterChip(
                          'NATIONAL_DAYS',
                          'National Days (🇶🇦 🇦🇪 🇸🇦)',
                        ),
                        _buildFilterChip(
                          'RELIGIOUS',
                          'Ramadan & Eid & Xmas (🌙 🕌 🎄)',
                        ),
                        _buildFilterChip('SEASONAL', 'Summer & School (☀️ 🎒)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => _showAddOfferDialog(context, state),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text(
                    isAr ? 'إضافة عرض جديد' : 'Add New Event Offer',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Offers List
            Expanded(
              child: filteredOffers.isEmpty
                  ? const Center(
                      child: Text(
                        'No event offers match this filter.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredOffers.length,
                      itemBuilder: (ctx, idx) {
                        final offer = filteredOffers[idx];
                        return _buildOfferCard(context, offer, state, isAr);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSel = _selectedFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSel,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
        onSelected: (val) {
          if (val) setState(() => _selectedFilter = key);
        },
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context,
    EventOffer offer,
    StateService state,
    bool isAr,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: offer.isActive
              ? offer.bannerColor.withValues(alpha: 0.5)
              : const Color(0xFFE2E8F0),
          width: offer.isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: offer.isActive
                ? offer.bannerColor.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji / Flag Avatar
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: offer.bannerColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: offer.bannerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(offer.iconEmoji, style: const TextStyle(fontSize: 28)),
                if (offer.countryFlag.isNotEmpty &&
                    offer.countryFlag != offer.iconEmoji)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        offer.countryFlag,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Main Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isAr ? offer.titleAr : offer.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: offer.bannerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${offer.discountPercent.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        'FLAG: ${offer.countryFlag}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isAr ? offer.descriptionAr : offer.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.confirmation_number_outlined,
                            size: 13,
                            color: Color(0xFF92400E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PROMO: ${offer.promoCode}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Target Territory: ${offer.countryCode == "ALL" ? "Global (All 15 Countries)" : offer.countryCode}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Actions: Toggle Active Switch, Delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    offer.isActive ? 'LIVE ON APP' : 'PAUSED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: offer.isActive
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Switch(
                    value: offer.isActive,
                    activeThumbColor: offer.bannerColor,
                    onChanged: (val) {
                      state.toggleEventOfferActive(offer.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            val
                                ? '✨ "${offer.title}" is now LIVE in Customer App!'
                                : '⏸️ "${offer.title}" has been paused.',
                          ),
                          backgroundColor: val
                              ? AppColors.success
                              : AppColors.textDark,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.error,
                ),
                tooltip: 'Delete Offer',
                onPressed: () {
                  state.deleteEventOffer(offer.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Removed offer "${offer.title}"')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddOfferDialog(BuildContext context, StateService state) {
    final titleController = TextEditingController();
    final titleArController = TextEditingController();
    final promoCodeController = TextEditingController(text: 'SPECIAL');
    final descController = TextEditingController();
    final descArController = TextEditingController();
    double discount = 25.0;
    String eventType = 'national_day';
    String countryFlag = '🇶🇦';
    String countryCode = 'QAT';
    String iconEmoji = '🇶🇦';
    Color bannerColor = const Color(0xFF0F766E);

    final List<Map<String, String>> countryOptions = [
      {'code': 'ALL', 'flag': '🌐', 'name': 'Global (All Countries)'},
      {
        'code': 'QAT',
        'flag': '🇶🇦',
        'name': 'Qatar 🇶🇦 (18 Dec National Day)',
      },
      {'code': 'UAE', 'flag': '🇦🇪', 'name': 'UAE 🇦🇪 (2 Dec Union Day)'},
      {
        'code': 'KSA',
        'flag': '🇸🇦',
        'name': 'Saudi Arabia 🇸🇦 (23 Sep National Day)',
      },
      {
        'code': 'KWT',
        'flag': '🇰🇼',
        'name': 'Kuwait 🇰🇼 (25 Feb National Day)',
      },
      {
        'code': 'OMN',
        'flag': '🇴🇲',
        'name': 'Oman 🇴🇲 (18 Nov National Day)',
      },
      {
        'code': 'BHR',
        'flag': '🇧🇭',
        'name': 'Bahrain 🇧🇭 (16 Dec National Day)',
      },
      {'code': 'GBR', 'flag': '🇬🇧', 'name': 'United Kingdom 🇬🇧'},
      {'code': 'USA', 'flag': '🇺🇸', 'name': 'United States 🇺🇸 (4th July)'},
      {'code': 'PAK', 'flag': '🇵🇰', 'name': 'Pakistan 🇵🇰 (14 Aug Independence Day)'},
    ];

    final List<Map<String, String>> eventTypePresets = [
      {
        'type': 'ramadan',
        'label': '🌙 Ramadan Offer',
        'icon': '🌙',
        'code': 'RAMADAN',
        'color': '0xFF0F766E',
      },
      {
        'type': 'eid',
        'label': '🕌 Eid Mubarak Offer',
        'icon': '🕌',
        'code': 'EIDMUBARAK',
        'color': '0xFF7C3AED',
      },
      {
        'type': 'national_day',
        'label': '🇶🇦 National Day Offer',
        'icon': '🇶🇦',
        'code': 'NATIONALDAY',
        'color': '0xFF8A1538',
      },
      {
        'type': 'christmas',
        'label': '🎄 Carmiss & Holidays',
        'icon': '🎄',
        'code': 'XMAS25',
        'color': '0xFFDC2626',
      },
      {
        'type': 'summer',
        'label': '☀️ Summer Offer',
        'icon': '☀️',
        'code': 'SUMMER20',
        'color': '0xFFD97706',
      },
      {
        'type': 'school',
        'label': '🎒 Back to School',
        'icon': '🎒',
        'code': 'BACK2SCHOOL',
        'color': '0xFF2563EB',
      },
      {
        'type': 'big_deal',
        'label': '💥 Big Weekend Deal',
        'icon': '💥',
        'code': 'BIGDEAL',
        'color': '0xFFBE185D',
      },
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580),
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
                            Icon(
                              Icons.campaign_outlined,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Create New Event & Seasonal Offer',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Event Presets Quick Selector
                    const Text(
                      'Select Event Type Preset:',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: eventTypePresets.map((preset) {
                        final isSel = eventType == preset['type'];
                        return ChoiceChip(
                          avatar: Text(preset['icon']!),
                          label: Text(
                            preset['label']!,
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) {
                              setDlgState(() {
                                eventType = preset['type']!;
                                iconEmoji = preset['icon']!;
                                promoCodeController.text = preset['code']!;
                                bannerColor = Color(
                                  int.parse(preset['color']!),
                                );
                                if (eventType == 'ramadan') {
                                  titleController.text =
                                      'Ramadan Special Laundry Offer';
                                  titleArController.text =
                                      'عروض شهر رمضان المبارك';
                                  descController.text =
                                      '25% OFF Traditional Thobes & Abayas';
                                } else if (eventType == 'eid') {
                                  titleController.text =
                                      'Eid Mubarak Mega Offer';
                                  titleArController.text =
                                      'عروض عيد الفطر السعيد';
                                  descController.text =
                                      '30% OFF Formal Wear & Dry Clean';
                                } else if (eventType == 'christmas') {
                                  titleController.text =
                                      'Carmiss & Holiday Winter Offer';
                                  titleArController.text =
                                      'عروض أعياد الميلاد الشتوية';
                                  descController.text =
                                      '25% OFF Blankets, Quilts & Coats';
                                } else if (eventType == 'summer') {
                                  titleController.text =
                                      'Summer Splash Laundry Offer';
                                  titleArController.text = 'عروض حرارة الصيف';
                                  descController.text =
                                      '20% OFF Wash & Fold by KG';
                                } else if (eventType == 'school') {
                                  titleController.text =
                                      'Back to School Uniform Offer';
                                  titleArController.text =
                                      'عروض العودة إلى المدارس';
                                  descController.text =
                                      '20% OFF Uniforms & Backpacks';
                                } else if (eventType == 'national_day') {
                                  titleController.text =
                                      'National Day Golden Offer';
                                  titleArController.text =
                                      'عروض اليوم الوطني التراثية';
                                  descController.text =
                                      '50% OFF Golden Jubilation Discount';
                                }
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Country Flag Selector
                    const Text(
                      'Select Target Country Flag:',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButton<String>(
                        value: countryCode,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: countryOptions.map((c) {
                          return DropdownMenuItem<String>(
                            value: c['code'],
                            child: Row(
                              children: [
                                Text(
                                  c['flag']!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  c['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (code) {
                          if (code != null) {
                            final chosen = countryOptions.firstWhere(
                              (c) => c['code'] == code,
                            );
                            setDlgState(() {
                              countryCode = code;
                              countryFlag = chosen['flag']!;
                              if (eventType == 'national_day') {
                                iconEmoji = chosen['flag']!;
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Titles
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Offer Title (English) *',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleArController,
                      decoration: const InputDecoration(
                        labelText: 'Offer Title (Arabic) *',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Discount & Promo Code
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Discount: ${discount.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              Slider(
                                value: discount,
                                min: 5,
                                max: 70,
                                divisions: 13,
                                activeColor: bannerColor,
                                label: '${discount.toStringAsFixed(0)}%',
                                onChanged: (val) =>
                                    setDlgState(() => discount = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: promoCodeController,
                            decoration: const InputDecoration(
                              labelText: 'Promo Coupon Code *',
                              prefixIcon: Icon(Icons.local_offer_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Descriptions
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Offer Subtitle / Description (English)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descArController,
                      decoration: const InputDecoration(
                        labelText: 'وصف العرض والشروط (بالعربية)',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bannerColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;
                          final newOffer = EventOffer(
                            id: 'offer_${DateTime.now().millisecondsSinceEpoch}',
                            title: titleController.text.trim(),
                            titleAr: titleArController.text.trim().isEmpty
                                ? titleController.text.trim()
                                : titleArController.text.trim(),
                            eventType: eventType,
                            iconEmoji: iconEmoji,
                            countryCode: countryCode,
                            countryFlag: countryFlag,
                            discountPercent: discount,
                            promoCode: promoCodeController.text
                                .trim()
                                .toUpperCase(),
                            description: descController.text.trim().isEmpty
                                ? '${discount.toStringAsFixed(0)}% OFF Event Discount'
                                : descController.text.trim(),
                            descriptionAr: descArController.text.trim(),
                            bannerColor: bannerColor,
                            isActive: true,
                            validFrom: DateTime.now(),
                            validUntil: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          );
                          state.addNewEventOffer(newOffer);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🎉 Event Offer "${newOffer.title}" with Flag ${newOffer.countryFlag} is LIVE!',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'Publish Offer to Live Customer App',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
