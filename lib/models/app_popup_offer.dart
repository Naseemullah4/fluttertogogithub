import 'package:flutter/material.dart';

class PopupImagePreset {
  final String key;
  final String label;
  final String emoji;
  final String imageUrl;
  final String defaultTitle;
  final String defaultTitleAr;
  final String defaultDesc;
  final String defaultDescAr;

  const PopupImagePreset({
    required this.key,
    required this.label,
    required this.emoji,
    required this.imageUrl,
    required this.defaultTitle,
    required this.defaultTitleAr,
    required this.defaultDesc,
    required this.defaultDescAr,
  });
}

class AppPopupOffer {
  final String id;
  bool isActive;
  String title;
  String titleAr;
  String description;
  String descriptionAr;
  String imageUrl;
  String imagePresetKey;
  String badgeText;
  String badgeTextAr;
  String promoCode;
  double discountPercent;
  String countryCode; // 'ALL' or 'QAT', 'UAE', 'KSA', 'GBR', 'USA', 'PAK'
  String countryFlag;
  String ctaText;
  String ctaTextAr;
  String ctaAction; // 'catalog', 'offers', 'express'
  String secondaryText;
  String secondaryTextAr;
  Color primaryColor;
  Color accentColor;
  DateTime createdAt;
  DateTime validUntil;

  AppPopupOffer({
    required this.id,
    this.isActive = true,
    required this.title,
    this.titleAr = '',
    required this.description,
    this.descriptionAr = '',
    required this.imageUrl,
    this.imagePresetKey = 'suit_luxury',
    this.badgeText = 'SPECIAL OFFER',
    this.badgeTextAr = 'عرض خاص وحصري',
    this.promoCode = 'UNIWASH30',
    this.discountPercent = 30.0,
    this.countryCode = 'ALL',
    this.countryFlag = '🌐',
    this.ctaText = 'Claim 30% OFF Now',
    this.ctaTextAr = 'احصل على الخصم واطلب الآن',
    this.ctaAction = 'catalog',
    this.secondaryText = 'Maybe Later',
    this.secondaryTextAr = 'ربما لاحقاً',
    this.primaryColor = const Color(0xFF0F766E),
    this.accentColor = const Color(0xFFF59E0B),
    required this.createdAt,
    required this.validUntil,
  }) {
    if (titleAr.isEmpty) titleAr = title;
    if (descriptionAr.isEmpty) descriptionAr = description;
    if (badgeTextAr.isEmpty) badgeTextAr = badgeText;
    if (ctaTextAr.isEmpty) ctaTextAr = ctaText;
    if (secondaryTextAr.isEmpty) secondaryTextAr = secondaryText;
  }

  static const List<PopupImagePreset> curatedPresets = [
    PopupImagePreset(
      key: 'suit_luxury',
      label: 'Luxury Suits & Dry Clean',
      emoji: '👔',
      imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=900&q=80',
      defaultTitle: 'VIP Master Dry Cleaning: 35% OFF',
      defaultTitleAr: 'تنظيف جاف ملكي للبدلات والأقمشة الفاخرة: خصم 35%',
      defaultDesc: 'Hand-finished pressing, delicate stain treatment, and protective garment packaging for all formalwear.',
      defaultDescAr: 'كوي يدوي متقن مع حماية الأنسجة وعلاقات فاخرة مخصصة لملابسكم الرسمية.',
    ),
    PopupImagePreset(
      key: 'fresh_linen',
      label: 'Bedding, Duvets & Linens',
      emoji: '🛏️',
      imageUrl: 'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?auto=format&fit=crop&w=900&q=80',
      defaultTitle: 'Fresh Hypoallergenic Linens & Bedding',
      defaultTitleAr: 'غسيل وتعقيم الألحفة والوسائد والمفارش',
      defaultDesc: 'Deep antibacterial wash and fragrant floral conditioning for duvets, blankets, and bedsheets.',
      defaultDescAr: 'غسيل بالبخار المضاد للبكتيريا وتعطير منعش يدوم طويلاً لجميع مفارش المنزل.',
    ),
    PopupImagePreset(
      key: 'thobe_abaya',
      label: 'Royal Thobe & Abaya Care',
      emoji: '✨',
      imageUrl: 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?auto=format&fit=crop&w=900&q=80',
      defaultTitle: 'Gulf Heritage: Crisp Thobe & Abaya Care',
      defaultTitleAr: 'العناية بالثوب الخليجي والعبايات الفاخرة',
      defaultDesc: 'Crisp collar stiffening, gentle dark fabric conditioning, and same-day express door delivery.',
      defaultDescAr: 'كوي نشا مخصص للياقات مع عناية بالأقمشة السوداء والحريرية وتوصيل سريع.',
    ),
    PopupImagePreset(
      key: 'steam_iron',
      label: 'Steam Pressing & Ironing',
      emoji: '💨',
      imageUrl: 'https://images.unsplash.com/photo-1584820927498-cfe5211fd8bf?auto=format&fit=crop&w=900&q=80',
      defaultTitle: 'Express Wrinkle-Free Steam Press',
      defaultTitleAr: 'كوي سريع بالبخار عالي الجودة لكافة الملابس',
      defaultDesc: 'Flawless precision pressing using commercial high-temperature steam. Zero shine or burn marks.',
      defaultDescAr: 'كوي متقن بالبخار يزيل أصعب التجاعيد دون التأثير على نعومة وجودة القماش.',
    ),
    PopupImagePreset(
      key: 'express_fleet',
      label: 'Doorstep 24h Express Van',
      emoji: '🚚',
      imageUrl: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=900&q=80',
      defaultTitle: 'Free Doorstep VIP Pickup & Delivery',
      defaultTitleAr: 'خدمة استلام وتوصيل مجاني من الباب للباب',
      defaultDesc: 'Live GPS tracked van collects your laundry basket within 45 minutes and returns next day.',
      defaultDescAr: 'أسطول سيارات مكيفة مجهزة بأنظمة تتبع مباشر لاستلام وتسليم الملابس بأمان تام.',
    ),
    PopupImagePreset(
      key: 'delicate_silk',
      label: 'Silk Gowns & Evening Dresses',
      emoji: '👗',
      imageUrl: 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=900&q=80',
      defaultTitle: 'Couture Dresses & Silk Dry Cleaning',
      defaultTitleAr: 'عناية خاصة بفساتين السهرة والحرير والدانتيل',
      defaultDesc: 'Ultra-gentle solvent technology for intricate beading, sequins, delicate lace, and bridal gowns.',
      defaultDescAr: 'تقنية تنظيف لطيفة للغاية تحافظ على التطريز والخرز والأقمشة الحساسة.',
    ),
  ];

  AppPopupOffer copyWith({
    String? id,
    bool? isActive,
    String? title,
    String? titleAr,
    String? description,
    String? descriptionAr,
    String? imageUrl,
    String? imagePresetKey,
    String? badgeText,
    String? badgeTextAr,
    String? promoCode,
    double? discountPercent,
    String? countryCode,
    String? countryFlag,
    String? ctaText,
    String? ctaTextAr,
    String? ctaAction,
    String? secondaryText,
    String? secondaryTextAr,
    Color? primaryColor,
    Color? accentColor,
    DateTime? createdAt,
    DateTime? validUntil,
  }) {
    return AppPopupOffer(
      id: id ?? this.id,
      isActive: isActive ?? this.isActive,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePresetKey: imagePresetKey ?? this.imagePresetKey,
      badgeText: badgeText ?? this.badgeText,
      badgeTextAr: badgeTextAr ?? this.badgeTextAr,
      promoCode: promoCode ?? this.promoCode,
      discountPercent: discountPercent ?? this.discountPercent,
      countryCode: countryCode ?? this.countryCode,
      countryFlag: countryFlag ?? this.countryFlag,
      ctaText: ctaText ?? this.ctaText,
      ctaTextAr: ctaTextAr ?? this.ctaTextAr,
      ctaAction: ctaAction ?? this.ctaAction,
      secondaryText: secondaryText ?? this.secondaryText,
      secondaryTextAr: secondaryTextAr ?? this.secondaryTextAr,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
    );
  }
}
