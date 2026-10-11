import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/catalog_item.dart';
import '../models/order_item.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../models/laundry.dart';
import '../models/driver.dart';
import '../models/contract.dart';
import '../models/ticket.dart';
import '../models/event_offer.dart';
import '../models/advertisement.dart';
import '../models/app_popup_offer.dart';
import '../models/occasion_theme.dart';
import '../models/country_branch.dart';
import '../models/admin_team.dart';
import '../models/order_problem.dart';
import '../models/audit_log.dart';
import '../models/system_bug.dart';
import '../models/wallet_transaction.dart';
import 'catalog_data.dart';
import 'localization_service.dart';

class StateService extends ChangeNotifier {
  // Localization & Multi-Country Dashboard
  AppLanguage _currentLanguage = AppLanguage.en;
  AppLanguage get currentLanguage => _currentLanguage;

  CountryConfig? _selectedCountry = LocalizationService.defaultCountry;
  CountryConfig get selectedCountry => _selectedCountry ?? LocalizationService.defaultCountry;

  void setLanguage(AppLanguage lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == AppLanguage.en ? AppLanguage.ar : AppLanguage.en;
    notifyListeners();
  }

  void setSelectedCountry(String code) {
    _selectedCountry = LocalizationService.getCountry(code);
    notifyListeners();
  }

  String formatCurrency(double qarAmount) {
    final current = selectedCountry;
    final converted = qarAmount * current.exchangeRateToQar;
    final sym = _currentLanguage == AppLanguage.ar 
        ? current.currencySymbolAr 
        : current.currencySymbol;
    return '${converted.toStringAsFixed(converted.truncateToDouble() == converted ? 0 : 2)} $sym';
  }

  /// Price visibility rule:
  /// Prices are ONLY visible to Customer, Regional Admin, and Super Admin.
  /// Laundry staff, drivers, support, and all other roles cannot see prices.
  bool canViewPrice([UserRole? role]) {
    final targetRole = role ?? _currentUser.role;
    return targetRole == UserRole.customer ||
           targetRole == UserRole.regionalAdmin ||
           targetRole == UserRole.superAdmin;
  }

  String formatRestrictedPrice(double qarAmount, {UserRole? role, String hiddenPlaceholder = '—'}) {
    if (canViewPrice(role)) {
      return formatCurrency(qarAmount);
    }
    return hiddenPlaceholder;
  }

  // Current Active User
  AppUser _currentUser = const AppUser(
    id: 'user_cust_01',
    fullName: 'Jassim Al-Kuwari',
    email: 'jassim@example.qa',
    phone: '+974 5589 1234',
    role: UserRole.customer,
    countryCode: 'QAT',
  );
  AppUser get currentUser => _currentUser;

  void switchRole(UserRole newRole) {
    switch (newRole) {
      case UserRole.customer:
        _currentUser = const AppUser(
          id: 'user_cust_01',
          fullName: 'Jassim Al-Kuwari',
          email: 'jassim@example.qa',
          phone: '+974 5589 1234',
          role: UserRole.customer,
          countryCode: 'QAT',
        );
        break;
      case UserRole.driver:
        _currentUser = const AppUser(
          id: 'user_drv_01',
          fullName: 'Tariq Al-Mansoor',
          email: 'tariq.driver@uniwash.qa',
          phone: '+974 5512 8900',
          role: UserRole.driver,
          countryCode: 'QAT',
        );
        break;
      case UserRole.laundryWorker:
        _currentUser = const AppUser(
          id: 'user_lnd_01',
          fullName: 'Hamad Dry Cleaners Staff',
          email: 'pearl.branch@uniwash.qa',
          phone: '+974 4499 8811',
          role: UserRole.laundryWorker,
          countryCode: 'QAT',
        );
        break;
      case UserRole.regionalAdmin:
        _currentUser = const AppUser(
          id: 'user_adm_01',
          fullName: 'Rashid Al-Sulaiti (Qatar Operations)',
          email: 'rashid.ops@uniwash.qa',
          phone: '+974 3300 4455',
          role: UserRole.regionalAdmin,
          countryCode: 'QAT',
        );
        break;
      case UserRole.superAdmin:
        _currentUser = const AppUser(
          id: 'user_sup_01',
          fullName: 'Global Platform Executive',
          email: 'superadmin@uniwash.global',
          phone: '+974 4000 0000',
          role: UserRole.superAdmin,
          countryCode: 'GLOBAL',
        );
        break;
      case UserRole.customerService:
        _currentUser = const AppUser(
          id: 'user_cs_01',
          fullName: 'Sara Mansoor (CS Operations Lead)',
          email: 'support.lead@uniwash.qa',
          phone: '+974 4499 1003',
          role: UserRole.customerService,
          countryCode: 'QAT',
        );
        break;
      case UserRole.engineer:
        _currentUser = const AppUser(
          id: 'user_eng_01',
          fullName: 'Eng. Zaid Mansoori (Tech & QA Engineer)',
          email: 'zaid.eng@uniwash.qa',
          phone: '+974 5544 3322',
          role: UserRole.engineer,
          countryCode: 'GLOBAL',
        );
        break;
    }
    notifyListeners();
  }

  // Dynamic Catalog Items Repository (Super Admin can edit in real time)
  final List<CatalogItem> _catalogItems = CatalogData.getDefaultItems();
  List<CatalogItem> get catalogItems => List.unmodifiable(_catalogItems);

  void adjustItemPrice(String itemId, double delta) {
    final idx = _catalogItems.indexWhere((i) => i.id == itemId);
    if (idx >= 0) {
      final updatedPrice = (_catalogItems[idx].basePriceQar + delta).clamp(1.0, 9999.0);
      _catalogItems[idx].basePriceQar = updatedPrice;
      notifyListeners();
    }
  }

  void updateItemPrice(String itemId, double newPrice) {
    final idx = _catalogItems.indexWhere((i) => i.id == itemId);
    if (idx >= 0) {
      _catalogItems[idx].basePriceQar = newPrice.clamp(1.0, 9999.0);
      notifyListeners();
    }
  }

  void updateItemPricingUnit(String itemId, PricingUnit newUnit) {
    final idx = _catalogItems.indexWhere((i) => i.id == itemId);
    if (idx >= 0) {
      _catalogItems[idx].pricingUnit = newUnit;
      notifyListeners();
    }
  }

  void updateItemSaleOffer(String itemId, {required double discountPercent, String? specialOfferTag}) {
    final idx = _catalogItems.indexWhere((i) => i.id == itemId);
    if (idx >= 0) {
      _catalogItems[idx].saleDiscountPercent = discountPercent.clamp(0.0, 95.0);
      _catalogItems[idx].specialOfferTag = specialOfferTag?.trim().isEmpty == true ? null : specialOfferTag?.trim();
      notifyListeners();
    }
  }

  void updateItemIcon(String itemId, String newIcon) {
    final idx = _catalogItems.indexWhere((i) => i.id == itemId);
    if (idx >= 0) {
      _catalogItems[idx].icon = newIcon;
      notifyListeners();
    }
  }

  void updateCatalogItem(CatalogItem updated) {
    final idx = _catalogItems.indexWhere((i) => i.id == updated.id);
    if (idx >= 0) {
      _catalogItems[idx] = updated;
      notifyListeners();
    }
  }

  void addNewCatalogItem(CatalogItem newItem) {
    _catalogItems.insert(0, newItem);
    notifyListeners();
  }

  // Event & Seasonal Offers Engine (Ramadan, Eid, National Days, Summer, Back to School, Big Offers)
  // Initially inactive by default — only display on customer app when explicitly enabled or created by Admin
  final List<EventOffer> _eventOffers = [
    EventOffer(
      id: 'offer_ramadan',
      title: 'Ramazan Kareem Mubarak Offer',
      titleAr: 'عروض شهر رمضان المبارك',
      eventType: 'ramadan',
      iconEmoji: '🌙',
      countryCode: 'ALL',
      countryFlag: '🌙',
      discountPercent: 25.0,
      promoCode: 'RAMADAN25',
      description: '25% OFF on all Traditional Thobes, Abayas & Prayer Rugs wash & iron.',
      descriptionAr: 'خصم 25% على غسيل وكوي الثياب التقليدية والعبايات وسجاد الصلاة.',
      bannerColor: const Color(0xFF0F766E),
      isActive: false,
      validFrom: DateTime.now().subtract(const Duration(days: 5)),
      validUntil: DateTime.now().add(const Duration(days: 25)),
    ),
    EventOffer(
      id: 'offer_eid',
      title: 'Eid Al-Fitr & Eid Al-Adha Mega Offer',
      titleAr: 'عروض وتخفيضات العيد السعيد',
      eventType: 'eid',
      iconEmoji: '🕌',
      countryCode: 'ALL',
      countryFlag: '🕌',
      discountPercent: 30.0,
      promoCode: 'EIDMUBARAK',
      description: '30% OFF on Formal Suits, Silk Dresses, Bisht & Festive Attire.',
      descriptionAr: 'خصم 30% على البدل الرسمية، فساتين الحرير، البشوت والملابس الاحتفالية.',
      bannerColor: const Color(0xFF7C3AED),
      isActive: false,
      validFrom: DateTime.now().subtract(const Duration(days: 2)),
      validUntil: DateTime.now().add(const Duration(days: 10)),
    ),
    EventOffer(
      id: 'offer_christmas',
      title: 'Carmiss & Holiday Winter Offer',
      titleAr: 'عروض الكريسماس والعطلات الشتوية',
      eventType: 'christmas',
      iconEmoji: '🎄',
      countryCode: 'ALL',
      countryFlag: '🎄',
      discountPercent: 25.0,
      promoCode: 'XMAS25',
      description: '25% OFF Winter Jackets, Woolen Blankets, Quilts & Linens.',
      descriptionAr: 'خصم 25% على المعاطف الشتوية، البطانيات الصوفية والمفارش.',
      bannerColor: const Color(0xFFDC2626),
      isActive: false,
      validFrom: DateTime.now().subtract(const Duration(days: 1)),
      validUntil: DateTime.now().add(const Duration(days: 30)),
    ),
    EventOffer(
      id: 'offer_nd_qat',
      title: 'Qatar National Day Mega Offer',
      titleAr: 'عروض اليوم الوطني لدولة قطر',
      eventType: 'national_day',
      iconEmoji: '🇶🇦',
      countryCode: 'QAT',
      countryFlag: '🇶🇦',
      discountPercent: 50.0,
      promoCode: 'QATAR50',
      description: 'Celebrate 18 Dec with 50% Golden Discount across all laundry services!',
      descriptionAr: 'احتفل باليوم الوطني 18 ديسمبر مع خصم ذهبي 50% على جميع خدمات الغسيل!',
      bannerColor: const Color(0xFF8A1538),
      isActive: false,
      validFrom: DateTime.now().subtract(const Duration(days: 10)),
      validUntil: DateTime.now().add(const Duration(days: 20)),
    ),
    EventOffer(
      id: 'offer_nd_uae',
      title: 'UAE National Day Union Offer',
      titleAr: 'عروض عيد الاتحاد لدولة الإمارات',
      eventType: 'national_day',
      iconEmoji: '🇦🇪',
      countryCode: 'UAE',
      countryFlag: '🇦🇪',
      discountPercent: 40.0,
      promoCode: 'UAE40',
      description: 'Celebrate 2 Dec Union Day with 40% OFF all premium wash packages!',
      descriptionAr: 'احتفل باليوم الوطني 2 ديسمبر مع خصم 40% على جميع باقات الغسيل الفاخرة!',
      bannerColor: const Color(0xFF00732F),
      isActive: false,
      validFrom: DateTime.now().subtract(const Duration(days: 5)),
      validUntil: DateTime.now().add(const Duration(days: 15)),
    ),
    EventOffer(
      id: 'offer_nd_ksa',
      title: 'Saudi National Day Pride Offer',
      titleAr: 'عروض اليوم الوطني السعودي',
      eventType: 'national_day',
      iconEmoji: '🇸🇦',
      countryCode: 'KSA',
      countryFlag: '🇸🇦',
      discountPercent: 35.0,
      promoCode: 'KSA35',
      description: 'Celebrate 23 Sep Kingdom Pride with 35% OFF all garment & textile care!',
      descriptionAr: 'احتفل باليوم الوطني 23 سبتمبر مع خصم 35% على العناية بجميع الملابس والأقمشة!',
      bannerColor: const Color(0xFF165B33),
      isActive: false,
      validFrom: DateTime.now().subtract(const Duration(days: 5)),
      validUntil: DateTime.now().add(const Duration(days: 15)),
    ),
    EventOffer(
      id: 'offer_summer',
      title: 'Hot Summer Splash Laundry Offer',
      titleAr: 'عروض حرارة الصيف والانتعاش',
      eventType: 'summer',
      iconEmoji: '☀️',
      countryCode: 'ALL',
      countryFlag: '☀️',
      discountPercent: 20.0,
      promoCode: 'SUMMER20',
      description: '20% OFF Wash & Fold by KG and Light Linens throughout summer months.',
      descriptionAr: 'خصم 20% على الغسيل والطي بالكيلو والمفارش الخفيفة طوال أشهر الصيف.',
      bannerColor: const Color(0xFFD97706),
      isActive: false,
      validFrom: DateTime.now().subtract(const Duration(days: 20)),
      validUntil: DateTime.now().add(const Duration(days: 40)),
    ),
    EventOffer(
      id: 'offer_school',
      title: 'Back to School Uniforms & Bags Offer',
      titleAr: 'عروض العودة إلى المدارس والجامعات',
      eventType: 'school',
      iconEmoji: '🎒',
      countryCode: 'ALL',
      countryFlag: '🎒',
      discountPercent: 20.0,
      promoCode: 'BACK2SCHOOL',
      description: '20% OFF School Uniforms, Sports Kits & Backpacks sanitization & wash.',
      descriptionAr: 'خصم 20% على الزي المدرسي، الأطقم الرياضية وتعقيم وغسيل الحقائب المدرسية.',
      bannerColor: const Color(0xFF2563EB),
      isActive: false,
      validFrom: DateTime.now().subtract(const Duration(days: 10)),
      validUntil: DateTime.now().add(const Duration(days: 30)),
    ),
    EventOffer(
      id: 'offer_big',
      title: 'Big Mega Weekend Flash Sale',
      titleAr: 'العرض الأكبر - تخفيضات نهاية الأسبوع',
      eventType: 'big_deal',
      iconEmoji: '💥',
      countryCode: 'ALL',
      countryFlag: '💥',
      discountPercent: 40.0,
      promoCode: 'BIGWEEKEND',
      description: 'Super 40% OFF Flash Discount for Express 24-hr Doorstep Laundry.',
      descriptionAr: 'خصم فلاش ضخم 40% على خدمات الغسيل السريعة خلال 24 ساعة حتى باب المنزل.',
      bannerColor: const Color(0xFFBE185D),
      isActive: false,
      validFrom: DateTime.now().subtract(const Duration(days: 1)),
      validUntil: DateTime.now().add(const Duration(days: 3)),
    ),
  ];

  List<EventOffer> get eventOffers => List.unmodifiable(_eventOffers);

  /// Active offers filtered strictly for the selected territory/country + global 'ALL'
  List<EventOffer> get activeEventOffers {
    final country = selectedCountry.code;
    return _eventOffers.where((o) => o.isActive && (o.countryCode == 'ALL' || o.countryCode == country)).toList();
  }

  void toggleEventOfferActive(String id) {
    final idx = _eventOffers.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      _eventOffers[idx].isActive = !_eventOffers[idx].isActive;
      notifyListeners();
    }
  }

  void addNewEventOffer(EventOffer offer) {
    _eventOffers.insert(0, offer);
    notifyListeners();
  }

  void updateEventOffer(EventOffer updated) {
    final idx = _eventOffers.indexWhere((o) => o.id == updated.id);
    if (idx >= 0) {
      _eventOffers[idx] = updated;
      notifyListeners();
    }
  }

  void deleteEventOffer(String id) {
    _eventOffers.removeWhere((o) => o.id == id);
    notifyListeners();
  }

  // ==========================================
  // Dynamic Occasion-Based Theming Engine
  // ==========================================
  final Map<String, OccasionTheme> _countryOccasionThemes = {
    'QAT': OccasionTheme.qatarNationalDay,
    'UAE': OccasionTheme.uaeNationalDay,
    'GBR': OccasionTheme.ukNational,
    'USA': OccasionTheme.usNational,
    'PAK': OccasionTheme.pakistanNational,
    'ALL': OccasionTheme.defaultEmerald,
  };
  OccasionTheme _activeGlobalOccasionTheme = OccasionTheme.defaultEmerald;

  OccasionTheme get currentOccasionTheme {
    final cCode = selectedCountry.code;
    return _countryOccasionThemes[cCode] ?? _activeGlobalOccasionTheme;
  }

  OccasionTheme getOccasionThemeForCountry(String countryCode) {
    return _countryOccasionThemes[countryCode] ?? _activeGlobalOccasionTheme;
  }

  /// Sets theme with strict role-based access check (Super Admin & Admin only)
  bool setOccasionTheme(OccasionTheme theme, {String? targetCountryCode}) {
    if (_currentUser.role != UserRole.superAdmin && _currentUser.role != UserRole.regionalAdmin) {
      return false; // Unauthorized for non-admin roles
    }

    if (_currentUser.role == UserRole.regionalAdmin) {
      // Regional Admin can only modify the theme for their specific territory
      final territory = selectedCountry.code;
      _countryOccasionThemes[territory] = theme;
    } else {
      // Super Admin can set globally ('ALL') or for any country
      final code = targetCountryCode ?? theme.countryCode;
      if (code == 'ALL') {
        _activeGlobalOccasionTheme = theme;
        _countryOccasionThemes['ALL'] = theme;
      } else {
        _countryOccasionThemes[code] = theme;
      }
    }
    notifyListeners();
    return true;
  }

  // ==========================================
  // Advertisements & Messaging Module
  // ==========================================
  final List<Advertisement> _advertisements = [
    Advertisement(
      id: 'ad_qat_thobe_concierge',
      title: 'VIP Qatar Thobe Concierge & Starch Pressing',
      titleAr: 'خدمة كبار الشخصيات: عناية ملكية بالثوب القطري والبشت',
      message: 'Hand-pressed with delicate collar stiffening. Delivered on custom cedar hangers within 12 hours.',
      messageAr: 'كوي يدوي فاخر للياقات والأكمام مع أكياس حافظة وعلاقات خشبية فاخرة.',
      bannerType: AdBannerType.graphicBanner,
      graphicPreset: 'thobe_care',
      graphicEmoji: '👔',
      countryCode: 'QAT',
      countryFlag: '🇶🇦',
      ctaText: 'Book VIP Pickup',
      ctaTextAr: 'حجز استلام VIP',
      ctaLink: 'express',
      primaryColor: const Color(0xFF800020),
      secondaryColor: const Color(0xFFB91C1C),
      isActive: false,
      isBroadcastPushed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      validUntil: DateTime.now().add(const Duration(days: 20)),
    ),
    Advertisement(
      id: 'ad_uae_express_pickup',
      title: 'Dubai & Abu Dhabi: 24h Express Laundry Pickup',
      titleAr: 'دبي وأبوظبي: خدمة الاستلام والتوصيل السريع خلال 24 ساعة',
      message: 'Live GPS tracked driver fleet will collect from your doorstep and deliver pristine garments tomorrow.',
      messageAr: 'سائقونا مجهزون بنظام تتبع مباشر لاستلام وتسليم ملابسكم المغسولة والمكوية بكل احترافية.',
      bannerType: AdBannerType.graphicBanner,
      graphicPreset: 'express_van',
      graphicEmoji: '🚚',
      countryCode: 'UAE',
      countryFlag: '🇦🇪',
      ctaText: 'Schedule Express',
      ctaTextAr: 'جدولة الغسيل السريع',
      ctaLink: 'catalog',
      primaryColor: const Color(0xFF047857),
      secondaryColor: const Color(0xFF0D9488),
      isActive: false,
      isBroadcastPushed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      validUntil: DateTime.now().add(const Duration(days: 15)),
    ),
    Advertisement(
      id: 'ad_gbr_mayfair_luxury',
      title: 'Mayfair & Knightsbridge Delicate Dry Cleaning',
      titleAr: 'لندن: التنظيف الجاف الفاخر للأقمشة الصوفية والحريرية',
      message: 'Master solvent dry cleaning for bespoke Savile Row suits, cashmere knitwear, and evening gowns.',
      messageAr: 'تنظيف جاف متخصص للبدلات الرسمية والأصواف الفاخرة وفساتين السهرة.',
      bannerType: AdBannerType.graphicBanner,
      graphicPreset: 'suit_luxury',
      graphicEmoji: '✨',
      countryCode: 'GBR',
      countryFlag: '🇬🇧',
      ctaText: 'Explore Services',
      ctaTextAr: 'استعراض الخدمات',
      ctaLink: 'catalog',
      primaryColor: const Color(0xFF1E3A8A),
      secondaryColor: const Color(0xFF2563EB),
      isActive: false,
      isBroadcastPushed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      validUntil: DateTime.now().add(const Duration(days: 25)),
    ),
    Advertisement(
      id: 'ad_usa_curtain_bedding',
      title: 'New York & Tri-State: Bedding & Curtains 35% OFF',
      titleAr: 'خصم 35% على غسيل المفارش والألحفة والستائر',
      message: 'Deep hypoallergenic steam wash for luxury duvet covers, heavy draperies, and down comforters.',
      messageAr: 'غسيل بالبخار المضاد للحساسية للألحفة والستائر الكبيرة مع تعقيم شامل.',
      bannerType: AdBannerType.carouselSlide,
      graphicPreset: 'carpet_curtain',
      graphicEmoji: '🛏️',
      countryCode: 'USA',
      countryFlag: '🇺🇸',
      ctaText: 'Claim 35% Discount',
      ctaTextAr: 'احصل على الخصم',
      ctaLink: 'catalog',
      primaryColor: const Color(0xFF1D4ED8),
      secondaryColor: const Color(0xFF0284C7),
      isActive: false,
      isBroadcastPushed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      validUntil: DateTime.now().add(const Duration(days: 18)),
    ),
    Advertisement(
      id: 'ad_pak_azadi_kameez',
      title: 'Pakistan: Premium Kurta & Shalwar Starch Finishing',
      titleAr: 'باكستان: كوي وغسيل متميز للأزياء التقليدية والشالوار',
      message: 'Flawless press, stain removal, and fragrant floral conditioning for all traditional wear.',
      messageAr: 'إزالة كاملة للبقع مع كوي مثالي وتعطير منعش يدوم طويلاً.',
      bannerType: AdBannerType.graphicBanner,
      graphicPreset: 'thobe_care',
      graphicEmoji: '🇵🇰',
      countryCode: 'PAK',
      countryFlag: '🇵🇰',
      ctaText: 'Order Wash & Press',
      ctaTextAr: 'طلب الغسيل والكوي',
      ctaLink: 'catalog',
      primaryColor: const Color(0xFF0F5132),
      secondaryColor: const Color(0xFF15803D),
      isActive: false,
      isBroadcastPushed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      validUntil: DateTime.now().add(const Duration(days: 30)),
    ),
    Advertisement(
      id: 'ad_global_first_order',
      title: 'Global Welcome: 50% OFF First Laundry Basket',
      titleAr: 'عرض الترحيب العالمي: خصم 50% على أول سلة غسيل',
      message: 'Use promo code UNIWASH50 at checkout. Includes free door-to-door pickup & delivery.',
      messageAr: 'استخدم كود الخصم UNIWASH50 عند إتمام الطلب مع استلام وتوصيل مجاني.',
      bannerType: AdBannerType.announcementTicker,
      graphicPreset: 'dress_promo',
      graphicEmoji: '🎉',
      countryCode: 'ALL',
      countryFlag: '🌐',
      ctaText: 'Apply UNIWASH50',
      ctaTextAr: 'تطبيق الكوبون',
      ctaLink: 'catalog',
      primaryColor: const Color(0xFF7C3AED),
      secondaryColor: const Color(0xFF9333EA),
      isActive: false,
      isBroadcastPushed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      validUntil: DateTime.now().add(const Duration(days: 45)),
    ),
  ];

  List<Advertisement> get advertisements => List.unmodifiable(_advertisements);

  /// Active advertisements targeted to current country + global 'ALL'
  List<Advertisement> get activeAdvertisements {
    final country = selectedCountry.code;
    return _advertisements.where((a) => a.isActive && (a.countryCode == 'ALL' || a.countryCode == country)).toList();
  }

  /// Latest active broadcast notification pushed to app
  Advertisement? get latestBroadcastAnnouncement {
    final active = activeAdvertisements.where((a) => a.isBroadcastPushed).toList();
    if (active.isEmpty) return null;
    return active.first;
  }

  void addNewAdvertisement(Advertisement ad) {
    _advertisements.insert(0, ad);
    notifyListeners();
  }

  void updateAdvertisement(Advertisement updated) {
    final idx = _advertisements.indexWhere((a) => a.id == updated.id);
    if (idx >= 0) {
      _advertisements[idx] = updated;
      notifyListeners();
    }
  }

  void deleteAdvertisement(String id) {
    _advertisements.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void toggleAdvertisementActive(String id) {
    final idx = _advertisements.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      _advertisements[idx].isActive = !_advertisements[idx].isActive;
      notifyListeners();
    }
  }

  void broadcastAdvertisementMessage(String id) {
    final idx = _advertisements.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      _advertisements[idx].isBroadcastPushed = true;
      notifyListeners();
    }
  }

  // ==========================================
  // In-App Customer Offer & Announcement Popups
  // ==========================================
  final List<AppPopupOffer> _popupOffers = [
    AppPopupOffer(
      id: 'popup_grand_welcome',
      isActive: false,
      title: 'Grand VIP Laundry & Dry Clean: 35% OFF',
      titleAr: 'عرض الترحيب الملكي: خصم 35% على كافة خدمات الغسيل والكوي',
      description: 'Experience ultra-gentle steam pressing, hypoallergenic wash, and custom cedar hangers delivered directly to your door.',
      descriptionAr: 'استمتع بعناية استثنائية لملابسك مع كوي بالبخار، وتعطير برائحة العود الفاخر، وتوصيل مجاني لباب منزلك.',
      imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=900&q=80',
      imagePresetKey: 'suit_luxury',
      badgeText: 'EXCLUSIVE PROMO',
      badgeTextAr: 'عرض ترويجي حصري',
      promoCode: 'UNIWASH35',
      discountPercent: 35.0,
      countryCode: 'ALL',
      countryFlag: '🌐',
      ctaText: 'Claim 35% OFF & Order',
      ctaTextAr: 'احصل على الخصم واطلب الآن',
      ctaAction: 'catalog',
      secondaryText: 'Maybe Later',
      secondaryTextAr: 'تخطي الآن',
      primaryColor: const Color(0xFF0F766E),
      accentColor: const Color(0xFFF59E0B),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      validUntil: DateTime.now().add(const Duration(days: 30)),
    ),
  ];

  final Set<String> _dismissedPopupIds = {};

  List<AppPopupOffer> get popupOffers => List.unmodifiable(_popupOffers);

  AppPopupOffer? get activePopupOffer {
    final country = selectedCountry.code;
    final match = _popupOffers.where((p) => p.isActive && (p.countryCode == 'ALL' || p.countryCode == country));
    return match.isNotEmpty ? match.first : null;
  }

  bool hasDismissedPopupInSession(String popupId) {
    return _dismissedPopupIds.contains(popupId);
  }

  void dismissPopupForSession(String popupId) {
    _dismissedPopupIds.add(popupId);
    notifyListeners();
  }

  void resetPopupSessionDismissal([String? popupId]) {
    if (popupId != null) {
      _dismissedPopupIds.remove(popupId);
    } else {
      _dismissedPopupIds.clear();
    }
    notifyListeners();
  }

  void savePopupOffer(AppPopupOffer offer) {
    final idx = _popupOffers.indexWhere((p) => p.id == offer.id);
    if (idx >= 0) {
      _popupOffers[idx] = offer;
    } else {
      _popupOffers.insert(0, offer);
    }
    // When saved, clear dismissal so customer sees updated popup
    _dismissedPopupIds.remove(offer.id);
    notifyListeners();
  }

  void togglePopupActive(String id) {
    final idx = _popupOffers.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      _popupOffers[idx].isActive = !_popupOffers[idx].isActive;
      if (_popupOffers[idx].isActive) {
        _dismissedPopupIds.remove(id);
      }
      notifyListeners();
    }
  }

  void deletePopupOffer(String id) {
    _popupOffers.removeWhere((p) => p.id == id);
    _dismissedPopupIds.remove(id);
    notifyListeners();
  }


  // ==========================================
  // Customer Profile & Preferences
  // ==========================================
  String _customerWashPreference = 'Delicate Cycle • 30°C';
  String _customerScentPreference = 'Royal Jasmine & Oud';
  String _customerPackagingPreference = 'Premium Hangers with Dust Protection Bags';
  String _customerStarchLevel = 'Light Form Starch (Crisp & Comfortable)';
  double _customerWalletBalance = 250.0;
  int _customerLoyaltyPoints = 480;

  String get customerWashPreference => _customerWashPreference;
  String get customerScentPreference => _customerScentPreference;
  String get customerPackagingPreference => _customerPackagingPreference;
  String get customerStarchLevel => _customerStarchLevel;
  double get customerWalletBalance => _customerWalletBalance;
  int get customerLoyaltyPoints => _customerLoyaltyPoints;

  final List<WalletTransaction> _walletTransactions = [
    WalletTransaction(
      id: 'tx_01',
      title: 'Digital Wallet Welcome Credit',
      amount: 150.0,
      isCredit: true,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      reference: 'PROMO-WELCOME',
      type: 'bonus',
    ),
    WalletTransaction(
      id: 'tx_02',
      title: 'Order Payment #UNW-1002',
      amount: 45.0,
      isCredit: false,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      reference: 'ORDER-1002',
      type: 'order_payment',
    ),
    WalletTransaction(
      id: 'tx_03',
      title: 'Instant Card Top-Up (+5% VIP Bonus)',
      amount: 145.0,
      isCredit: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      reference: 'VISA-9921',
      type: 'top_up',
    ),
  ];
  List<WalletTransaction> get walletTransactions => List.unmodifiable(_walletTransactions);

  // VIP Premium Membership System
  bool _isCustomerPremium = false;
  String _customerPremiumTier = 'Standard Member';
  DateTime? _premiumExpiryDate;

  // Auto-Reload Wallet Settings
  bool _isAutoReloadEnabled = false;
  double _autoReloadThreshold = 30.0;
  double _autoReloadAmount = 100.0;

  bool get isCustomerPremium => _isCustomerPremium;
  String get customerPremiumTier => _customerPremiumTier;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;
  bool get isAutoReloadEnabled => _isAutoReloadEnabled;
  double get autoReloadThreshold => _autoReloadThreshold;
  double get autoReloadAmount => _autoReloadAmount;

  void toggleAutoReload(bool enabled, {double? threshold, double? amount}) {
    _isAutoReloadEnabled = enabled;
    if (threshold != null) _autoReloadThreshold = threshold;
    if (amount != null) _autoReloadAmount = amount;
    notifyListeners();
  }

  void upgradeToPremiumMembership({
    required String tier,
    required double price,
    String paymentMethod = 'wallet',
  }) {
    if (paymentMethod == 'wallet') {
      if (_customerWalletBalance < price) {
        throw Exception('Insufficient wallet balance');
      }
      _customerWalletBalance -= price;
      _walletTransactions.insert(
        0,
        WalletTransaction(
          id: 'tx_vip_${DateTime.now().millisecondsSinceEpoch}',
          title: '$tier Membership (30 Days)',
          amount: price,
          isCredit: false,
          timestamp: DateTime.now(),
          reference: 'VIP-SUB-${DateTime.now().millisecondsSinceEpoch % 10000}',
          type: 'membership_payment',
        ),
      );
    }
    _isCustomerPremium = true;
    _customerPremiumTier = tier;
    _premiumExpiryDate = DateTime.now().add(const Duration(days: 30));

    logAudit(
      actionType: AuditActionType.orderStatusCorrected,
      entity: 'VIP Membership Subscription',
      entityId: _currentUser.id,
      previousValue: 'Standard Member',
      newValue: tier,
      reason: 'Customer upgraded to $tier via Customer Portal',
      countryCode: 'QAT',
    );

    _messages.add(ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      sender: 'UniWash VIP Concierge',
      text: '👑 Welcome to $tier! You now enjoy Free Delivery on all orders, 50% discount on Urgent Rush Fees, and priority laundry processing.',
      timestamp: DateTime.now(),
      isMe: false,
    ));

    notifyListeners();
  }

  void cancelPremiumMembership() {
    _isCustomerPremium = false;
    _customerPremiumTier = 'Standard Member';
    _premiumExpiryDate = null;
    notifyListeners();
  }

  void topUpCustomerWallet(
    double amount, {
    String reference = 'Card Top-Up',
    double bonus = 0.0,
    String paymentGateway = 'QCB Debit/Credit Gateway',
  }) {
    if (amount > 0) {
      final totalCredit = amount + bonus;
      _customerWalletBalance += totalCredit;
      _walletTransactions.insert(
        0,
        WalletTransaction(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          title: bonus > 0
              ? 'Top-Up (${formatCurrency(amount)} + ${formatCurrency(bonus)} Bonus) via $paymentGateway'
              : 'Wallet Reload via $paymentGateway',
          amount: totalCredit,
          isCredit: true,
          timestamp: DateTime.now(),
          reference: reference,
          type: bonus > 0 ? 'bonus' : 'top_up',
        ),
      );
      notifyListeners();
    }
  }

  bool payWithCustomerWallet(double amount, {String orderNumber = ''}) {
    if (_customerWalletBalance >= amount) {
      _customerWalletBalance -= amount;
      _walletTransactions.insert(
        0,
        WalletTransaction(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          title: orderNumber.isNotEmpty ? 'Order Payment #$orderNumber' : 'Laundry Service Payment',
          amount: amount,
          isCredit: false,
          timestamp: DateTime.now(),
          reference: orderNumber.isNotEmpty ? 'ORDER-$orderNumber' : 'PURCHASE',
          type: 'order_payment',
        ),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  bool redeemCustomerLoyaltyPoints(int points, double creditReward) {
    if (_customerLoyaltyPoints >= points) {
      _customerLoyaltyPoints -= points;
      _customerWalletBalance += creditReward;
      notifyListeners();
      return true;
    }
    return false;
  }

  void addCustomerLoyaltyPoints(int points) {
    if (points > 0) {
      _customerLoyaltyPoints += points;
      notifyListeners();
    }
  }

  void updateCustomerProfile({
    required String fullName,
    required String email,
    required String phone,
    String? washPreference,
    String? scentPreference,
    String? packagingPreference,
    String? starchLevel,
  }) {
    _currentUser = AppUser(
      id: _currentUser.id,
      fullName: fullName,
      email: email,
      phone: phone,
      role: _currentUser.role,
      countryCode: _currentUser.countryCode,
    );
    if (washPreference != null) _customerWashPreference = washPreference;
    if (scentPreference != null) _customerScentPreference = scentPreference;
    if (packagingPreference != null) _customerPackagingPreference = packagingPreference;
    if (starchLevel != null) _customerStarchLevel = starchLevel;
    notifyListeners();
  }

  // Customer Cart
  final List<OrderItem> _cart = [];
  List<OrderItem> get cart => List.unmodifiable(_cart);

  void addToCart(CatalogItem item, ServiceType serviceType, {double quantityOrWeight = 1.0, String notes = ''}) {
    final existingIndex = _cart.indexWhere(
      (element) => element.catalogItem.id == item.id && element.serviceType == serviceType,
    );

    if (existingIndex >= 0) {
      _cart[existingIndex].quantityOrWeight += quantityOrWeight;
      if (notes.isNotEmpty) {
        _cart[existingIndex].notes = notes;
      }
    } else {
      _cart.add(OrderItem(
        catalogItem: item,
        serviceType: serviceType,
        quantityOrWeight: quantityOrWeight,
        notes: notes,
      ));
    }
    notifyListeners();
  }

  void updateCartQuantity(int index, int newQty) {
    if (index >= 0 && index < _cart.length) {
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantityOrWeight = newQty.toDouble();
      }
      notifyListeners();
    }
  }

  void updateCartQuantityOrWeight(int index, double newQtyOrWeight) {
    if (index >= 0 && index < _cart.length) {
      if (newQtyOrWeight <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantityOrWeight = (newQtyOrWeight * 10).round() / 10;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  double get cartSubtotal => _cart.fold(0.0, (sum, item) => sum + item.effectiveTotal);
  double get cartTotal => cartSubtotal + 15.0; // 15 QAR delivery

  // Saved Addresses
  CustomerAddress _selectedAddress = const CustomerAddress(
    buildingNo: '48',
    streetNo: '950 Lusail Marina',
    zoneNo: '69',
    apartmentRoom: '1204',
    city: 'Lusail, Doha',
  );
  CustomerAddress get selectedAddress => _selectedAddress;

  void updateAddress(CustomerAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  // Orders Repository (Lifetime records retained forever, searchable across 5 roles)
  final List<LaundryOrder> _orders = [];
  List<LaundryOrder> get orders => List.unmodifiable(_orders);

  // Super Search Google-like Omnibar query engine
  List<LaundryOrder> searchOrders(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) return List.unmodifiable(_orders);

    return _orders.where((order) {
      final orderNumStr = order.orderNumber.toString();
      final custName = order.customerName.toLowerCase();
      final phone = order.customerPhone.replaceAll(RegExp(r'\s+'), '').toLowerCase();
      final cleanQuery = query.replaceAll(RegExp(r'\s+'), '');
      final driver = order.assignedDriverName.toLowerCase();
      final laundry = order.laundryName.toLowerCase();
      final statusName = order.status.displayName.toLowerCase();
      final address = order.address.formatted.toLowerCase();

      final matchesItem = order.items.any((item) =>
          item.catalogItem.itemName.toLowerCase().contains(query) ||
          item.catalogItem.itemNameAr.contains(query));

      return orderNumStr.contains(query) ||
          custName.contains(query) ||
          phone.contains(cleanQuery) ||
          driver.contains(query) ||
          laundry.contains(query) ||
          statusName.contains(query) ||
          address.contains(query) ||
          matchesItem;
    }).toList();
  }

  // Active Order Tracker for Customer
  LaundryOrder? get currentCustomerActiveOrder {
    for (final o in _orders) {
      if (o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled) {
        return o;
      }
    }
    return _orders.isNotEmpty ? _orders.first : null;
  }

  // Laundries List with credentials, full folder, and periodic operational analytics
  final List<LaundryBranch> _laundries = [
    LaundryBranch(
      id: 'laundry-doha-01',
      userId: 'LND-DOH-01',
      systemPassword: 'Pearl@Branch2026',
      name: 'UniWash Pearl & Marina Branch',
      legalRegNumber: 'QA-CR-892104',
      managerName: 'Nasser Al-Hajri',
      phone: '+974 4499 8811',
      completedOrders: 1420,
      grossEarningsQar: 94500.0,
      rating: 4.9,
      warningStatus: WarningLevel.none,
      documents: LaundryDocumentFolder(
        crCommercialRegDoc: 'CR_892104_Ministry_Commerce.pdf',
        municipalityLicenseDoc: 'Municipality_Health_Cert_2026.pdf',
        civilDefenseCertificateDoc: 'Civil_Defense_Fire_Clearance.pdf',
        ownerQidDoc: 'Owner_QID_28463401928.pdf',
        signedContractDoc: 'UniWash_Master_Franchise_Agmt.pdf',
        bankIbanCertificate: 'QNB_Corporate_IBAN_Letter.pdf',
        registrationDate: DateTime(2023, 5, 14),
      ),
      stats: const LaundryPeriodicStats(
        todayReceived: 24,
        todayInProcessing: 16,
        todayReady: 18,
        todayDelivered: 17,
        todayGrossRevenue: 2450.0,
        weeklyOrders: 148,
        weeklyRevenue: 16800.0,
        monthlyOrders: 610,
        monthlyRevenue: 69400.0,
        yearlyOrders: 7200,
        yearlyRevenue: 820000.0,
        lifetimeOrders: 18450,
        lifetimeRevenue: 2150000.0,
      ),
    ),
    LaundryBranch(
      id: 'laundry-doha-02',
      userId: 'LND-SADD-02',
      systemPassword: 'AlSadd@Clean2026',
      name: 'Royal Al-Sadd Cleaners',
      legalRegNumber: 'QA-CR-772910',
      managerName: 'Fahad Al-Tamimi',
      phone: '+974 4433 2211',
      completedOrders: 890,
      grossEarningsQar: 62100.0,
      rating: 4.4,
      warningStatus: WarningLevel.yellow,
      documents: LaundryDocumentFolder(
        crCommercialRegDoc: 'CR_772910_Royal_Cleaners.pdf',
        municipalityLicenseDoc: 'Doha_Municipality_Permit.pdf',
        civilDefenseCertificateDoc: 'Civil_Defense_Inspection.pdf',
        ownerQidDoc: 'Owner_QID_27963402198.pdf',
        signedContractDoc: 'Royal_Partner_Agreement.pdf',
        bankIbanCertificate: 'Commercial_Bank_IBAN.pdf',
        registrationDate: DateTime(2024, 1, 10),
      ),
      stats: const LaundryPeriodicStats(
        todayReceived: 14,
        todayInProcessing: 9,
        todayReady: 12,
        todayDelivered: 11,
        todayGrossRevenue: 1390.0,
        weeklyOrders: 85,
        weeklyRevenue: 9800.0,
        monthlyOrders: 360,
        monthlyRevenue: 41200.0,
        yearlyOrders: 4300,
        yearlyRevenue: 495000.0,
        lifetimeOrders: 9800,
        lifetimeRevenue: 1120000.0,
      ),
    ),
    LaundryBranch(
      id: 'laundry-doha-03',
      userId: 'LND-WEST-03',
      systemPassword: 'WestBay@Sec2026',
      name: 'Express West Bay Dry Cleaners',
      legalRegNumber: 'QA-CR-661209',
      managerName: 'Ibrahim Khouri',
      phone: '+974 4411 9900',
      completedOrders: 310,
      grossEarningsQar: 21500.0,
      rating: 3.9,
      warningStatus: WarningLevel.lightRed,
      documents: LaundryDocumentFolder(
        crCommercialRegDoc: 'CR_661209_Express_WestBay.pdf',
        municipalityLicenseDoc: 'Municipality_Renewal_Pending.pdf',
        civilDefenseCertificateDoc: 'Civil_Defense_Valid.pdf',
        ownerQidDoc: 'Owner_QID_28263401124.pdf',
        signedContractDoc: 'Standard_Franchise_Agmt.pdf',
        bankIbanCertificate: 'DohaBank_Corporate_IBAN.pdf',
        registrationDate: DateTime(2024, 6, 20),
      ),
      stats: const LaundryPeriodicStats(
        todayReceived: 8,
        todayInProcessing: 5,
        todayReady: 7,
        todayDelivered: 6,
        todayGrossRevenue: 820.0,
        weeklyOrders: 46,
        weeklyRevenue: 5100.0,
        monthlyOrders: 195,
        monthlyRevenue: 21900.0,
        yearlyOrders: 2100,
        yearlyRevenue: 240000.0,
        lifetimeOrders: 4200,
        lifetimeRevenue: 480000.0,
      ),
    ),
  ];
  List<LaundryBranch> get laundries => List.unmodifiable(_laundries);

  void updateLaundryPassword(String laundryId, String newPassword) {
    final idx = _laundries.indexWhere((l) => l.id == laundryId);
    if (idx >= 0) {
      _laundries[idx].systemPassword = newPassword;
      notifyListeners();
    }
  }

  // Drivers List with User ID, Admin-accessible System Password, and Document Folder
  final List<DriverModel> _drivers = [
    DriverModel(
      id: 'drv-01',
      userId: 'DRV-QA-8821',
      systemPassword: 'Tariq@Driver2026',
      fullName: 'Tariq Al-Mansoor',
      phone: '+974 5512 8900',
      licenseNumber: 'QA-DL-4482910',
      qidPassportNumber: '29363401928',
      assignedLaundryId: 'laundry-doha-01',
      assignedLaundryName: 'UniWash Pearl & Marina Branch',
      affiliation: DriverAffiliation.companyFleet, // Corporate Fleet (Not for laundry)
      warningStatus: WarningLevel.none,
      completedTrips: 320, // Tier: 300+ orders (Diamond Badge, Blue Tag, 3 QAR/order)
      todayEarningsQar: 480.0,
      rating: 4.98,
      documents: DriverDocumentFolder(
        passportDocumentName: 'Passport_Scan_Tariq_2028.pdf',
        visaDocumentName: 'Work_Residence_Permit_Qatar.pdf',
        drivingLicenseDocumentName: 'Heavy_Light_License_QA.pdf',
        qidDocumentName: 'QID_Front_Back_29363401928.pdf',
        signedContractDocumentName: 'UniWash_Driver_Contract_2025.pdf',
        vehicleRegPlate: 'QA-Plate-68201 (Toyota Hiace)',
        joinedAt: DateTime(2023, 2, 1),
        nationality: 'Qatar Resident',
      ),
    ),
    DriverModel(
      id: 'drv-02',
      userId: 'DRV-QA-5529',
      systemPassword: 'Bilal@Driver2026',
      fullName: 'Bilal Ahmed',
      phone: '+974 6623 4455',
      licenseNumber: 'QA-DL-5591023',
      qidPassportNumber: '29163402847',
      assignedLaundryId: 'laundry-doha-01',
      assignedLaundryName: 'UniWash Pearl & Marina Branch',
      affiliation: DriverAffiliation.companyFleet, // Corporate Fleet (Not for laundry)
      warningStatus: WarningLevel.none,
      completedTrips: 265, // Tier: 250+ orders (Golden Badge, Blue Tag, 2 QAR/order)
      todayEarningsQar: 390.0,
      rating: 4.88,
      documents: DriverDocumentFolder(
        passportDocumentName: 'Passport_Bilal_A.pdf',
        visaDocumentName: 'QID_Residency_Visa.pdf',
        drivingLicenseDocumentName: 'Motorcycle_Car_License.pdf',
        qidDocumentName: 'QID_29163402847.pdf',
        signedContractDocumentName: 'Courier_Agreement_Signed.pdf',
        vehicleRegPlate: 'QA-Plate-71904 (Nissan Urvan)',
        joinedAt: DateTime(2023, 8, 15),
      ),
    ),
    DriverModel(
      id: 'drv-03',
      userId: 'DRV-QA-4418',
      systemPassword: 'Rashid@Driver2026',
      fullName: 'Rashid Al-Kuwari',
      phone: '+974 3388 9911',
      licenseNumber: 'QA-DL-8812903',
      qidPassportNumber: '29463409918',
      assignedLaundryId: 'laundry-doha-02',
      assignedLaundryName: 'Royal Al-Sadd Cleaners',
      affiliation: DriverAffiliation.laundryDedicated, // Dedicated to Royal Al-Sadd Cleaners
      warningStatus: WarningLevel.none,
      completedTrips: 210, // Tier: 200+ orders (Blue Verified Tag, 4 Stars, 2 QAR/order)
      todayEarningsQar: 310.0,
      rating: 4.79,
      documents: DriverDocumentFolder(
        passportDocumentName: 'Passport_Rashid.pdf',
        visaDocumentName: 'Work_Permit_2026.pdf',
        drivingLicenseDocumentName: 'Professional_License_QA.pdf',
        qidDocumentName: 'QID_29463409918.pdf',
        signedContractDocumentName: 'Elite_Courier_Contract.pdf',
        vehicleRegPlate: 'QA-Plate-88192 (Ford Transit)',
        joinedAt: DateTime(2024, 1, 10),
      ),
    ),
    DriverModel(
      id: 'drv-04',
      userId: 'DRV-QA-3310',
      systemPassword: 'Karim@Driver2026',
      fullName: 'Karim Mostafa',
      phone: '+974 7711 0022',
      licenseNumber: 'QA-DL-3391822',
      qidPassportNumber: '28963401123',
      assignedLaundryId: 'laundry-doha-02',
      assignedLaundryName: 'Royal Al-Sadd Cleaners',
      affiliation: DriverAffiliation.laundryDedicated, // Dedicated to Royal Al-Sadd Cleaners
      warningStatus: WarningLevel.none,
      completedTrips: 165, // Tier: 150+ orders (3 Stars, 1.50 QAR/order)
      todayEarningsQar: 245.0,
      rating: 4.65,
      documents: DriverDocumentFolder(
        passportDocumentName: 'Passport_Karim_M.pdf',
        visaDocumentName: 'Work_Permit_2026.pdf',
        drivingLicenseDocumentName: 'Commercial_Driver_License.pdf',
        qidDocumentName: 'QID_28963401123.pdf',
        signedContractDocumentName: 'Employment_Contract_Signed.pdf',
        vehicleRegPlate: 'QA-Plate-39102 (Hyundai Staria)',
        joinedAt: DateTime(2024, 4, 1),
      ),
    ),
    DriverModel(
      id: 'drv-05',
      userId: 'DRV-QA-2290',
      systemPassword: 'Hamza@Driver2026',
      fullName: 'Hamza Noor',
      phone: '+974 5599 3322',
      licenseNumber: 'QA-DL-2291044',
      qidPassportNumber: '29563408821',
      assignedLaundryId: 'laundry-doha-01',
      assignedLaundryName: 'UniWash Pearl & Marina Branch',
      affiliation: DriverAffiliation.companyFleet, // Corporate Fleet (Not for laundry)
      warningStatus: WarningLevel.none,
      completedTrips: 110, // Tier: 100+ orders (2 Stars, 1.50 QAR/order)
      todayEarningsQar: 180.0,
      rating: 4.55,
      documents: DriverDocumentFolder(
        passportDocumentName: 'Passport_Hamza.pdf',
        visaDocumentName: 'Residence_Visa.pdf',
        drivingLicenseDocumentName: 'Light_Vehicle_License.pdf',
        qidDocumentName: 'QID_29563408821.pdf',
        signedContractDocumentName: 'Courier_Agreement.pdf',
        vehicleRegPlate: 'QA-Plate-44120 (Renault Trafic)',
        joinedAt: DateTime(2024, 6, 12),
      ),
    ),
    DriverModel(
      id: 'drv-06',
      userId: 'DRV-QA-1102',
      systemPassword: 'Omar@Driver2026',
      fullName: 'Omar Farooq',
      phone: '+974 3311 7766',
      licenseNumber: 'QA-DL-1102934',
      qidPassportNumber: '29863401290',
      assignedLaundryId: 'laundry-doha-02',
      assignedLaundryName: 'Royal Al-Sadd Cleaners',
      affiliation: DriverAffiliation.laundryDedicated, // Dedicated to partner laundry
      warningStatus: WarningLevel.lightYellow,
      completedTrips: 60, // Tier: 50+ orders (1 Star, 1.00 QAR/order)
      todayEarningsQar: 95.0,
      rating: 4.40,
      documents: DriverDocumentFolder(
        passportDocumentName: 'Passport_Omar.pdf',
        visaDocumentName: 'Driver_Visa_QA.pdf',
        drivingLicenseDocumentName: 'Driver_License_QA.pdf',
        qidDocumentName: 'QID_29863401290.pdf',
        signedContractDocumentName: 'Probation_Agreement.pdf',
        vehicleRegPlate: 'QA-Plate-11209 (Toyota TownAce)',
        joinedAt: DateTime(2024, 8, 20),
      ),
    ),
  ];
  List<DriverModel> get drivers => List.unmodifiable(_drivers);

  void addDriver(DriverModel driver) {
    _drivers.add(driver);
    logAudit(
      actionType: AuditActionType.driverCreated,
      entity: 'Driver Fleet',
      entityId: '${driver.userId} (${driver.fullName})',
      previousValue: 'None',
      newValue: '${driver.affiliation.shortBadge} assigned to ${driver.assignedLaundryName}',
      reason: 'Driver onboarded by operations administration',
      countryCode: 'QAT',
    );
    notifyListeners();
  }

  void updateDriverPassword(String driverId, String newPassword) {
    final idx = _drivers.indexWhere((d) => d.id == driverId);
    if (idx >= 0) {
      _drivers[idx].systemPassword = newPassword;
      notifyListeners();
    }
  }

  // Staff Onboarding & TM Contracts
  final List<LaundryContract> _contracts = [
    LaundryContract(
      id: 'cnt-01',
      laundryId: 'laundry-doha-01',
      laundryName: 'UniWash Pearl & Marina Branch',
      isGovRegistered: true,
      isLawCompliant: true,
      isLicenseClear: true,
      signedAt: DateTime.now().subtract(const Duration(days: 90)),
      signedBy: 'Nasser Al-Hajri (Managing Partner)',
    ),
    LaundryContract(
      id: 'cnt-02',
      laundryId: 'laundry-doha-02',
      laundryName: 'Royal Al-Sadd Cleaners',
      isGovRegistered: true,
      isLawCompliant: true,
      isLicenseClear: true,
      signedAt: DateTime.now().subtract(const Duration(days: 45)),
      signedBy: 'Fahad Al-Tamimi (Owner)',
    ),
  ];
  List<LaundryContract> get contracts => List.unmodifiable(_contracts);

  final List<StaffOnboardingRequest> _staffRequests = [
    StaffOnboardingRequest(
      id: 'stf-01',
      fullName: 'Zubair Khan',
      idCardNumber: 'QA-QID-29458291039',
      role: 'Driver / Delivery Rider',
      address: 'Zone 43, St 810, Bldg 12, Doha',
      passportNumber: 'P8921048',
      phone: '+974 5512 8820',
      email: 'zubair.rider@uniwash.qa',
      nationality: 'Pakistani Resident',
      submittedAt: DateTime.now().subtract(const Duration(hours: 4)),
      status: ApprovalStatus.pending,
      regionalAdminName: 'Rashid Al-Sulaiti',
    ),
    StaffOnboardingRequest(
      id: 'stf-02',
      fullName: 'Mohammad Al-Amin',
      idCardNumber: 'QA-QID-29158291442',
      role: 'Pressing & Ironing Specialist',
      address: 'Zone 55, St 320, Bldg 4, Al Rayyan',
      passportNumber: 'K7728192',
      phone: '+974 6611 9922',
      email: 'amin.dryclean@uniwash.qa',
      nationality: 'Egyptian Resident',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: ApprovalStatus.approved,
      regionalAdminName: 'Rashid Al-Sulaiti',
    ),
    StaffOnboardingRequest(
      id: 'stf-03',
      fullName: 'Sunil Kumar',
      idCardNumber: 'QA-QID-28858291881',
      role: 'Heavy Dry Cleaning Operator',
      address: 'Industrial Area St 24, Doha',
      passportNumber: 'N4481920',
      phone: '+974 3322 1100',
      email: 'sunil.clean@uniwash.qa',
      nationality: 'Indian Resident',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      status: ApprovalStatus.updateRequired,
      regionalAdminName: 'Rashid Al-Sulaiti',
      requiredDocumentDetails: 'Please re-upload clear color scan of driving license and valid QID back side.',
    ),
  ];
  List<StaffOnboardingRequest> get staffRequests => List.unmodifiable(_staffRequests);

  // Support Tickets & Complaints
  final List<SupportTicket> _tickets = [
    SupportTicket(
      id: 'tkt-101',
      authorName: 'Jassim Al-Kuwari',
      authorRole: 'customer',
      type: TicketType.suggestion,
      title: 'Include express 4-hour service option',
      description: 'Would love an option for VIP express delivery within the Pearl zone.',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      status: 'open',
    ),
    SupportTicket(
      id: 'tkt-102',
      authorName: 'Tariq Al-Mansoor',
      authorRole: 'driver',
      type: TicketType.vehicleBreakdown,
      title: 'Flat tire delay notification - 30 min',
      description: 'En route to Lusail customer; tire replacement in progress.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'resolved',
      attachmentName: 'tire_inspection_photo.jpg',
    ),
  ];
  List<SupportTicket> get tickets => List.unmodifiable(_tickets);

  // Live Chat
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'msg-1',
      sender: 'Driver (Tariq)',
      text: 'Salam Alaykum! I have arrived outside your tower at Lusail Marina.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      isMe: false,
    ),
    ChatMessage(
      id: 'msg-2',
      sender: 'Customer',
      text: 'Wa Alaykum Assalam! Security is giving you elevator clearance now.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      isMe: true,
    ),
    ChatMessage(
      id: 'msg-3',
      sender: 'Driver (Tariq)',
      text: 'Perfect, coming up to floor 12 now.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      isMe: false,
    ),
  ];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void sendChatMessage(String text) {
    if (text.trim().isEmpty) return;
    _messages.add(ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      sender: _currentUser.fullName,
      text: text.trim(),
      timestamp: DateTime.now(),
      isMe: true,
    ));
    notifyListeners();
  }

  // Referral System
  final String referralCode = 'UNIWASH-QAT-7882';
  int friendsInvited = 2;
  double referralCreditQar = 100.0;

  // Initialize with full lifetime order history
  StateService() {
    _initSampleOrders();
  }

  CatalogItem _safeFindItem(String targetName) {
    final query = targetName.toLowerCase();
    for (final item in _catalogItems) {
      final name = item.itemName.toLowerCase();
      if (name == query || name.contains(query) || query.contains(name)) {
        return item;
      }
    }
    if (_catalogItems.isNotEmpty) return _catalogItems.first;
    return CatalogData.getDefaultItems().first;
  }

  void _initSampleOrders() {
    final now = DateTime.now();

    // Order 1: Active In Washing
    final order1 = LaundryOrder(
      id: 'ord-1001',
      orderNumber: 10842,
      customerName: 'Jassim Al-Kuwari',
      customerPhone: '+974 5589 1234',
      address: _selectedAddress,
      status: OrderStatus.inLaundry,
      paymentMethod: 'pos_card',
      paymentStatus: 'paid',
      specialInstructions: 'Light starch on Thobe, delicate hanger for Abaya',
      createdAt: now.subtract(const Duration(hours: 3)),
      assignedDriverId: 'drv-01',
      assignedDriverName: 'Tariq Al-Mansoor',
      assignedDriverPhone: '+974 5512 8900',
      laundryName: 'UniWash Pearl & Marina Branch',
      laundryId: 'laundry-doha-01',
      isCountVerifiedByLaundry: true,
      isAcceptedByLaundry: true,
      isDriverRideStarted: true,
      driverRideStartedAt: now.subtract(const Duration(minutes: 45)),
      driverPingCount: 1,
      lastDriverPingAt: now.subtract(const Duration(minutes: 20)),
      attachments: [
        OrderAttachment(
          id: 'att-101',
          fileName: 'customer_thobe_stain.jpg',
          fileType: 'image',
          uploadedBy: 'customer',
          description: 'Coffee spill spot on right sleeve cuff requiring oxygen soak.',
          uploadedAt: now.subtract(const Duration(hours: 3)),
        ),
        OrderAttachment(
          id: 'att-102',
          fileName: 'abaya_delicate_care_guide.pdf',
          fileType: 'pdf',
          uploadedBy: 'customer',
          description: 'Designer crystal embellishment steam & ironing temperature specs.',
          uploadedAt: now.subtract(const Duration(hours: 3)),
        ),
      ],
      items: [
        OrderItem(
          catalogItem: _safeFindItem('Kandura / Thobe'),
          serviceType: ServiceType.washIron,
          quantity: 3,
          verifiedQuantity: 3,
        ),
        OrderItem(
          catalogItem: _safeFindItem('Abaya'),
          serviceType: ServiceType.dryClean,
          quantity: 2,
          verifiedQuantity: 2,
        ),
        OrderItem(
          catalogItem: _safeFindItem('Ghutra'),
          serviceType: ServiceType.washIron,
          quantity: 2,
          verifiedQuantity: 2,
        ),
      ],
    );

    // Order 2: Placed awaiting driver pickup
    final order2 = LaundryOrder(
      id: 'ord-1002',
      orderNumber: 10843,
      customerName: 'Sheikha Maryam',
      customerPhone: '+974 6677 8899',
      address: const CustomerAddress(
        buildingNo: '12',
        streetNo: 'Al Waab St',
        zoneNo: '55',
        apartmentRoom: 'Villa 3',
        city: 'Doha',
      ),
      status: OrderStatus.driverAssigned,
      paymentMethod: 'cash',
      paymentStatus: 'pending',
      createdAt: now.subtract(const Duration(minutes: 25)),
      assignedDriverId: 'drv-01',
      assignedDriverName: 'Tariq Al-Mansoor',
      assignedDriverPhone: '+974 5512 8900',
      laundryName: 'UniWash Pearl & Marina Branch',
      isAcceptedByLaundry: false,
      isDriverRideStarted: false,
      driverPingCount: 0,
      attachments: [
        OrderAttachment(
          id: 'att-201',
          fileName: 'suit_wool_label.jpg',
          fileType: 'image',
          uploadedBy: 'customer',
          description: 'Italian super 150s wool fabric care label.',
          uploadedAt: now.subtract(const Duration(minutes: 25)),
        ),
      ],
      items: [
        OrderItem(
          catalogItem: _safeFindItem('2-Piece Suit'),
          serviceType: ServiceType.dryClean,
          quantity: 1,
        ),
        OrderItem(
          catalogItem: _safeFindItem('Shirt on Hanger'),
          serviceType: ServiceType.washIron,
          quantity: 4,
        ),
      ],
    );

    // Order 3: Ready for delivery (Today)
    final order3 = LaundryOrder(
      id: 'ord-1003',
      orderNumber: 10840,
      customerName: 'Dr. Khalid Al-Dosari',
      customerPhone: '+974 3344 5566',
      address: const CustomerAddress(
        buildingNo: '22',
        streetNo: 'West Bay Lagoon',
        zoneNo: '66',
        apartmentRoom: 'Villa 8',
        city: 'Doha',
      ),
      status: OrderStatus.readyForDelivery,
      paymentMethod: 'online',
      paymentStatus: 'paid',
      createdAt: now.subtract(const Duration(hours: 6)),
      assignedDriverId: 'drv-02',
      assignedDriverName: 'Bilal Ahmed',
      assignedDriverPhone: '+974 6623 4455',
      laundryName: 'UniWash Pearl & Marina Branch',
      isCountVerifiedByLaundry: true,
      isAcceptedByLaundry: true,
      isDriverRideStarted: false,
      driverPingCount: 2,
      lastDriverPingAt: now.subtract(const Duration(minutes: 15)),
      attachments: [
        OrderAttachment(
          id: 'att-301',
          fileName: 'prewash_inspection_report.pdf',
          fileType: 'pdf',
          uploadedBy: 'laundry',
          description: 'Quality manager inspection clearance and count sign-off.',
          uploadedAt: now.subtract(const Duration(hours: 4)),
        ),
      ],
      items: [
        OrderItem(
          catalogItem: _safeFindItem('Bed Sheet'),
          serviceType: ServiceType.washIron,
          quantity: 4,
          verifiedQuantity: 4,
        ),
        OrderItem(
          catalogItem: _safeFindItem('Duvet Cover'),
          serviceType: ServiceType.dryClean,
          quantity: 2,
          verifiedQuantity: 2,
        ),
      ],
    );

    // Order 4: Delivered (Yesterday)
    final order4 = LaundryOrder(
      id: 'ord-1004',
      orderNumber: 10839,
      customerName: 'Fatima Al-Ansari',
      customerPhone: '+974 5522 3344',
      address: const CustomerAddress(
        buildingNo: '8',
        streetNo: 'Al Sadd Sports Club St',
        zoneNo: '38',
        apartmentRoom: 'Apt 402',
        city: 'Doha',
      ),
      status: OrderStatus.delivered,
      paymentMethod: 'pos_card',
      paymentStatus: 'paid',
      createdAt: now.subtract(const Duration(days: 1, hours: 4)),
      assignedDriverId: 'drv-01',
      assignedDriverName: 'Tariq Al-Mansoor',
      laundryName: 'Royal Al-Sadd Cleaners',
      isCountVerifiedByLaundry: true,
      laundryRating: 5.0,
      driverRating: 5.0,
      laundryReview: 'Excellent pressing on delicate silks!',
      items: [
        OrderItem(
          catalogItem: _safeFindItem('Evening'),
          serviceType: ServiceType.dryClean,
          quantity: 1,
          verifiedQuantity: 1,
        ),
        OrderItem(
          catalogItem: _safeFindItem('Top / Blouse'),
          serviceType: ServiceType.washIron,
          quantity: 3,
          verifiedQuantity: 3,
        ),
      ],
    );

    // Order 5: Delivered (Past Week Lifetime Record)
    final order5 = LaundryOrder(
      id: 'ord-1005',
      orderNumber: 10815,
      customerName: 'Mohammed Al-Kuwari',
      customerPhone: '+974 7788 9900',
      address: const CustomerAddress(
        buildingNo: '101',
        streetNo: 'The Pearl Porto Arabia',
        zoneNo: '66',
        apartmentRoom: 'Penthouse 18',
        city: 'Doha',
      ),
      status: OrderStatus.delivered,
      paymentMethod: 'online',
      paymentStatus: 'paid',
      createdAt: now.subtract(const Duration(days: 6)),
      assignedDriverId: 'drv-02',
      assignedDriverName: 'Bilal Ahmed',
      laundryName: 'UniWash Pearl & Marina Branch',
      isCountVerifiedByLaundry: true,
      laundryRating: 4.9,
      driverRating: 5.0,
      items: [
        OrderItem(
          catalogItem: _safeFindItem('Kandura / Thobe'),
          serviceType: ServiceType.washIron,
          quantity: 8,
          verifiedQuantity: 8,
        ),
        OrderItem(
          catalogItem: _safeFindItem('Bisht'),
          serviceType: ServiceType.dryClean,
          quantity: 1,
          verifiedQuantity: 1,
        ),
      ],
    );

    _orders.addAll([order1, order2, order3, order4, order5]);
  }

  // Customer Checkout
  LaundryOrder placeOrder({
    required String paymentMethod,
    String specialInstructions = '',
    bool isUrgent = false,
    double urgentFee = 25.0,
    DateTime? scheduledPickupDate,
    String? scheduledPickupSlot,
    DateTime? scheduledDeliveryDate,
    String? scheduledDeliverySlot,
    bool freeDelivery = false,
  }) {
    final orderNumber = 10840 + _orders.length + 1;
    // Premium VIP benefits: Free delivery & 50% discount on urgent express rush fee
    final effectiveDeliveryFee = (_isCustomerPremium || freeDelivery) ? 0.0 : 15.0;
    final effectiveUrgentFee = _isCustomerPremium ? (urgentFee * 0.5) : urgentFee;

    final tags = <String>[];
    if (isUrgent) {
      tags.add('🚨 URGENT RUSH');
      tags.add('⚡ 4-Hour Express');
    }
    if (_isCustomerPremium) {
      tags.add('👑 VIP Member');
    }

    final newOrder = LaundryOrder(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: orderNumber,
      customerName: _currentUser.fullName,
      customerPhone: _currentUser.phone,
      address: _selectedAddress,
      items: List.from(_cart),
      status: OrderStatus.placed,
      deliveryFee: effectiveDeliveryFee,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'cash' ? 'pending' : 'paid',
      specialInstructions: specialInstructions,
      createdAt: DateTime.now(),
      assignedDriverId: '',
      assignedDriverName: 'Unassigned',
      assignedDriverPhone: '',
      laundryName: 'UniWash Pearl & Marina Branch',
      laundryId: 'laundry-doha-01',
      isAcceptedByLaundry: false,
      isUrgent: isUrgent,
      urgentFee: effectiveUrgentFee,
      scheduledPickupDate: scheduledPickupDate,
      scheduledPickupSlot: scheduledPickupSlot,
      scheduledDeliveryDate: scheduledDeliveryDate,
      scheduledDeliverySlot: scheduledDeliverySlot,
      tags: tags,
    );

    if (paymentMethod == 'wallet') {
      _customerWalletBalance = (_customerWalletBalance - newOrder.totalAmount).clamp(0.0, double.infinity);
      _walletTransactions.insert(
        0,
        WalletTransaction(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Order Payment #$orderNumber',
          amount: newOrder.totalAmount,
          isCredit: false,
          timestamp: DateTime.now(),
          reference: 'ORDER-$orderNumber',
          type: 'order_payment',
        ),
      );
    }
    // Award 1 loyalty point per 2 QAR spent
    final earnedPoints = (newOrder.totalAmount / 2).round();
    if (earnedPoints > 0) {
      _customerLoyaltyPoints += earnedPoints;
    }

    _orders.insert(0, newOrder);
    _cart.clear();

    // High-priority Alert for Admin Dispatch, Driver Fleet & Customer Service
    final urgentPrefix = isUrgent ? '🚨⚡ [URGENT 4-HOUR RUSH] ' : '';
    final scheduleDetails = 'Pickup: ${scheduledPickupSlot ?? 'Immediate'}, Drop-off: ${scheduledDeliverySlot ?? 'Standard Next-Day'}';
    _messages.add(ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      sender: isUrgent ? '⚡ Express Emergency Dispatch' : 'Admin Operations Control',
      text: '$urgentPrefix New Order #$orderNumber placed by ${_currentUser.fullName}! ($scheduleDetails). Sent directly to Admin & Fleet with ${isUrgent ? 'TOP PRIORITY' : 'standard routing'}.',
      timestamp: DateTime.now(),
      isMe: false,
    ));

    notifyListeners();
    return newOrder;
  }

  // Order Stepper Status Advance
  void updateOrderStatus(String orderId, OrderStatus nextStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index].status = nextStatus;
      if (nextStatus == OrderStatus.pickedUp || nextStatus == OrderStatus.outForDelivery) {
        _orders[index].isDriverRideStarted = true;
        _orders[index].driverRideStartedAt ??= DateTime.now();
      }
      notifyListeners();
    }
  }

  // Laundry: Accept Incoming Order
  void acceptOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].isAcceptedByLaundry = true;
      notifyListeners();
    }
  }

  // Admin: Assign Driver (Directly dispatches mission to Driver's Active Missions Console)
  void assignDriverToOrder(String orderId, DriverModel driver) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].assignedDriverId = driver.id;
      _orders[idx].assignedDriverName = driver.fullName;
      _orders[idx].assignedDriverPhone = driver.phone;
      if (_orders[idx].status == OrderStatus.placed) {
        _orders[idx].status = OrderStatus.driverAssigned;
      }
      _orders[idx].isDriverRideStarted = false;

      // Broadcast alert message to driver
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Regional Admin Dispatch',
        text: '📦 New Order Mission #${_orders[idx].orderNumber} assigned to you (${driver.fullName}) by Regional Admin. Check your active route!',
        timestamp: DateTime.now(),
        isMe: false,
      ));
      notifyListeners();
    }
  }

  // Driver / Laundry: Driver Ride Started Tracker
  void startDriverRide(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].isDriverRideStarted = true;
      _orders[idx].driverRideStartedAt = DateTime.now();
      if (_orders[idx].status == OrderStatus.placed) {
        _orders[idx].status = OrderStatus.driverAssigned;
      }
      notifyListeners();
    }
  }

  // Laundry: Ping Driver Repeatedly (Send Urgent Nudge with count)
  void pingDriver(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].driverPingCount++;
      _orders[idx].lastDriverPingAt = DateTime.now();

      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Laundry Dispatch (Urgent Ping #${_orders[idx].driverPingCount})',
        text: '🔔 URGENT PING for Order #${_orders[idx].orderNumber}: Driver ${_orders[idx].assignedDriverName}, laundry facility is waiting for pickup/dispatch!',
        timestamp: DateTime.now(),
        isMe: false,
      ));
      notifyListeners();
    }
  }

  // Laundry / Customer: Add Requirement Attachment (Photo or PDF)
  void addOrderAttachment(String orderId, OrderAttachment attachment) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].attachments.insert(0, attachment);
      notifyListeners();
    }
  }

  // Per-driver order performance & history
  List<LaundryOrder> getOrdersForDriver(String driverId) {
    return _orders.where((o) => o.assignedDriverId == driverId).toList();
  }

  // Laundry: Item Count Verification Counter
  void verifyOrderItemQuantity(String orderId, int itemIndex, int verifiedQty) {
    final orderIdx = _orders.indexWhere((o) => o.id == orderId);
    if (orderIdx >= 0 && itemIndex < _orders[orderIdx].items.length) {
      _orders[orderIdx].items[itemIndex].verifiedQuantity = verifiedQty;
      notifyListeners();
    }
  }

  void finalizeItemVerification(String orderId) {
    final orderIdx = _orders.indexWhere((o) => o.id == orderId);
    if (orderIdx >= 0) {
      _orders[orderIdx].isCountVerifiedByLaundry = true;
      notifyListeners();
    }
  }

  // Driver Ratings & Reviews
  void rateOrder(String orderId, {required double laundryRating, required double driverRating, String? laundryReview, String? driverReview}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].laundryRating = laundryRating;
      _orders[idx].driverRating = driverRating;
      _orders[idx].laundryReview = laundryReview;
      _orders[idx].driverReview = driverReview;
      notifyListeners();
    }
  }

  // Customer Service / Admin: Compensate Customer Wallet for any complaint/issue
  void compensateCustomerWallet(double amount, {required int orderNumber, required String reason}) {
    if (amount > 0) {
      _customerWalletBalance += amount;
      _walletTransactions.insert(
        0,
        WalletTransaction(
          id: 'tx_comp_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Support Courtesy Credit (Order #$orderNumber)',
          amount: amount,
          isCredit: true,
          timestamp: DateTime.now(),
          reference: 'CS-COMP-$orderNumber',
          type: 'compensation',
        ),
      );
      logAudit(
        actionType: AuditActionType.problemResolved,
        entity: 'Customer Digital Wallet',
        entityId: 'Order #$orderNumber',
        previousValue: 'Uncompensated',
        newValue: '+$amount QAR Courtesy Credit ($reason)',
        reason: 'Customer Support courtesy resolution for Order #$orderNumber',
        countryCode: 'QAT',
      );
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Customer Support Operations',
        text: '🎁 Courtesy refund credit of ${formatCurrency(amount)} was credited to your digital wallet for Order #$orderNumber ($reason).',
        timestamp: DateTime.now(),
        isMe: false,
      ));
      notifyListeners();
    }
  }

  // Customer Service: Upgrade Order to VIP Express Rush
  void upgradeOrderToExpress(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      if (!_orders[idx].tags.contains('⚡ VIP Express')) {
        _orders[idx].tags.add('⚡ VIP Express');
      }
      _orders[idx].specialInstructions = [
        '⚡ VIP EXPRESS RUSH TURNAROUND',
        if (_orders[idx].specialInstructions.isNotEmpty) _orders[idx].specialInstructions,
      ].join(' | ');
      logAudit(
        actionType: AuditActionType.orderStatusCorrected,
        entity: 'Order Priority Level',
        entityId: 'Order #${_orders[idx].orderNumber}',
        previousValue: 'Standard Processing',
        newValue: '⚡ VIP Express Rush',
        reason: 'Customer requested rush expedited turnaround via Support',
        countryCode: 'QAT',
      );
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Customer Support Dispatch',
        text: '⚡ Order #${_orders[idx].orderNumber} upgraded to VIP Express Priority! Laundry & courier alerted for priority line.',
        timestamp: DateTime.now(),
        isMe: false,
      ));
      notifyListeners();
    }
  }

  // Customer Service: Waive Delivery Fee
  void waiveDeliveryFee(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      if (!_orders[idx].tags.contains('Free Delivery Waived')) {
        _orders[idx].tags.add('Free Delivery Waived');
      }
      compensateCustomerWallet(15.0, orderNumber: _orders[idx].orderNumber, reason: 'Doorstep Delivery Fee Waived');
    }
  }

  // Customer Service: Update Order Delivery Address
  void updateOrderAddress(String orderId, CustomerAddress newAddress) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final oldAddr = _orders[idx].address.formatted;
      _orders[idx].address = newAddress;
      logAudit(
        actionType: AuditActionType.orderStatusCorrected,
        entity: 'Order Destination Address',
        entityId: 'Order #${_orders[idx].orderNumber}',
        previousValue: oldAddr,
        newValue: newAddress.formatted,
        reason: 'Customer updated delivery coordinates via Customer Support portal',
        countryCode: 'QAT',
      );
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Customer Support Dispatch',
        text: '📍 REROUTE ALERT: Destination address for Order #${_orders[idx].orderNumber} was updated to: ${newAddress.formatted}',
        timestamp: DateTime.now(),
        isMe: false,
      ));
      notifyListeners();
    }
  }

  // Customer Service: Trigger Doorbell Grace Timer (Customer unreachable)
  void triggerDoorbellGraceTimer(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].specialInstructions = [
        '🔔 Doorbell Grace Alert Triggered at ${DateFormat('HH:mm').format(DateTime.now())} (15m waiting window)',
        if (_orders[idx].specialInstructions.isNotEmpty) _orders[idx].specialInstructions,
      ].join(' | ');
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Customer Support Operations',
        text: '🔔 Doorbell/Intercom Alert: Driver arrived at Order #${_orders[idx].orderNumber}. Waiting 15m grace window. Please confirm entry or authorize doorstep drop-off.',
        timestamp: DateTime.now(),
        isMe: false,
      ));
      notifyListeners();
    }
  }

  // Customer Service / Admin: Ping Driver with High Priority Audible Audio Alert
  void dispatchRadioPingToDriver(String driverId, {required String message, int? orderNumber}) {
    final driver = _drivers.firstWhere((d) => d.id == driverId, orElse: () => _drivers.first);
    logAudit(
      actionType: AuditActionType.problemResolved,
      entity: 'Driver Dispatch Radios',
      entityId: driver.fullName,
      previousValue: 'Standby Telemetry',
      newValue: 'Audible Priority Ping: $message',
      reason: 'Support Agent dispatched urgent audio ping to courier in-transit',
      countryCode: 'QAT',
    );
    _messages.add(ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      sender: 'Dispatcher Radio • Ping',
      text: '📡 Urgent Radio Alert sent to Driver ${driver.fullName}: "$message"${orderNumber != null ? ' (Order #$orderNumber)' : ''}',
      timestamp: DateTime.now(),
      isMe: true,
    ));
    notifyListeners();
  }

  // Customer Service: Authorize Safe Contactless Doorstep Drop-off
  void authorizeDoorstepDropoff(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      if (!_orders[idx].tags.contains('Safe Doorstep Authorized')) {
        _orders[idx].tags.add('Safe Doorstep Authorized');
      }
      _orders[idx].specialInstructions = [
        '🚪 SAFE CONTACTLESS DOORSTEP DROP-OFF AUTHORIZED BY CS SUPERVISOR (Photo proof required)',
        if (_orders[idx].specialInstructions.isNotEmpty) _orders[idx].specialInstructions,
      ].join(' | ');
      logAudit(
        actionType: AuditActionType.orderStatusCorrected,
        entity: 'Doorstep Drop-off Authorization',
        entityId: 'Order #${_orders[idx].orderNumber}',
        previousValue: 'Signature Required',
        newValue: 'Contactless Doorstep Authorized',
        reason: 'Customer requested contactless delivery via Customer Support',
        countryCode: 'QAT',
      );
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Customer Support Dispatch',
        text: '🚪 Doorstep drop-off authorized for Order #${_orders[idx].orderNumber}. Driver instructed to take proof photo at door.',
        timestamp: DateTime.now(),
        isMe: false,
      ));
      notifyListeners();
    }
  }

  // Customer Service: Emergency Replace QR Tag Payload
  void replaceOrderQrPayload(String orderId, String newPayload, {required String reason}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final oldPayload = _orders[idx].qrCodePayload;
      _orders[idx].qrCodePayload = newPayload;
      if (!_orders[idx].tags.contains('Emergency QR Replaced')) {
        _orders[idx].tags.add('Emergency QR Replaced');
      }
      logAudit(
        actionType: AuditActionType.orderStatusCorrected,
        entity: 'Garment QR Tag',
        entityId: 'Order #${_orders[idx].orderNumber}',
        previousValue: oldPayload,
        newValue: newPayload,
        reason: reason,
        countryCode: 'QAT',
      );
      notifyListeners();
    }
  }

  // Customer Service: Remove / Delete Custom QR Tag and restore default
  void removeOrderQrPayload(String orderId, {required String reason}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].customQrTag = null;
      _orders[idx].tags.removeWhere((t) => t.contains('QR'));
      logAudit(
        actionType: AuditActionType.orderStatusCorrected,
        entity: 'Garment QR Tag',
        entityId: 'Order #${_orders[idx].orderNumber}',
        previousValue: 'Custom Tag Removed',
        newValue: 'Reset to System Default QR Payload',
        reason: reason,
        countryCode: 'QAT',
      );
      notifyListeners();
    }
  }

  // Customer Service: Request Proof from Courier (Photo, Video, Loading, Delivery)
  void requestProofFromDriver(String orderId, {required String proofType, required String notes}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final ord = _orders[idx];
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'CS Dispatch Proof Request',
        text: '📸 PROOF MANDATORY REQUEST for Order #${ord.orderNumber}: Driver ${ord.assignedDriverName}, upload $proofType. Notes: $notes',
        timestamp: DateTime.now(),
        isMe: true,
      ));
      logAudit(
        actionType: AuditActionType.orderStatusCorrected,
        entity: 'Courier Proof Request',
        entityId: 'Order #${ord.orderNumber}',
        previousValue: 'Unrequested',
        newValue: 'Requested $proofType from ${ord.assignedDriverName}',
        reason: notes,
        countryCode: 'QAT',
      );
      notifyListeners();
    }
  }

  // Customer Service: Record Order Delay Root Cause & Courier Explanation
  void recordDelayRootCause(String orderId, {required String reason, required String driverExplanation}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final ord = _orders[idx];
      if (!ord.tags.contains('⚠️ Delayed Investigated')) {
        ord.tags.add('⚠️ Delayed Investigated');
      }
      ord.specialInstructions = [
        '⚠️ DELAY LOG: $reason | Courier Note: $driverExplanation (${DateFormat('HH:mm').format(DateTime.now())})',
        if (ord.specialInstructions.isNotEmpty) ord.specialInstructions,
      ].join(' | ');
      logAudit(
        actionType: AuditActionType.orderStatusCorrected,
        entity: 'Order SLA Turnaround Delay',
        entityId: 'Order #${ord.orderNumber}',
        previousValue: 'Unexplained Delay',
        newValue: 'Documented Root Cause: $reason',
        reason: driverExplanation,
        countryCode: 'QAT',
      );
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Operations SLA Investigation',
        text: '⚠️ Delay verified for Order #${ord.orderNumber}. Cause: $reason. Driver explanation: "$driverExplanation"',
        timestamp: DateTime.now(),
        isMe: false,
      ));
      notifyListeners();
    }
  }

  // Regional Admin: Escalation Warning System
  void setLaundryWarning(String laundryId, WarningLevel level) {
    final idx = _laundries.indexWhere((l) => l.id == laundryId);
    if (idx >= 0) {
      _laundries[idx].warningStatus = level;
      if (level == WarningLevel.terminated) {
        _laundries[idx].isActive = false;
      }
      notifyListeners();
    }
  }

  void setDriverWarning(String driverId, WarningLevel level) {
    final idx = _drivers.indexWhere((d) => d.id == driverId);
    if (idx >= 0) {
      _drivers[idx].warningStatus = level;
      if (level == WarningLevel.terminated) {
        _drivers[idx].isApproved = false;
      }
      notifyListeners();
    }
  }

  // Super Admin: Approvals, Rejections, and Request Document Updates
  void addStaffRequest(StaffOnboardingRequest request) {
    _staffRequests.insert(0, request);
    notifyListeners();
  }

  void approveStaffRequest(String requestId) {
    final idx = _staffRequests.indexWhere((s) => s.id == requestId);
    if (idx >= 0) {
      _staffRequests[idx].status = ApprovalStatus.approved;
      notifyListeners();
    }
  }

  void rejectStaffRequest(String requestId, {String? reason}) {
    final idx = _staffRequests.indexWhere((s) => s.id == requestId);
    if (idx >= 0) {
      _staffRequests[idx].status = ApprovalStatus.rejected;
      _staffRequests[idx].adminNotes = reason;
      notifyListeners();
    }
  }

  void requestStaffDocumentUpdate(String requestId, String requiredDocs) {
    final idx = _staffRequests.indexWhere((s) => s.id == requestId);
    if (idx >= 0) {
      _staffRequests[idx].status = ApprovalStatus.updateRequired;
      _staffRequests[idx].requiredDocumentDetails = requiredDocs;
      notifyListeners();
    }
  }

  // Support Ticket Submission
  void submitTicket({
    required TicketType type,
    required String title,
    required String description,
    String? attachmentName,
  }) {
    _tickets.insert(
      0,
      SupportTicket(
        id: 'tkt-${DateTime.now().millisecondsSinceEpoch}',
        authorName: _currentUser.fullName,
        authorRole: _currentUser.role.name,
        type: type,
        title: title,
        description: description,
        createdAt: DateTime.now(),
        attachmentName: attachmentName,
      ),
    );
    notifyListeners();
  }

  // ==========================================
  // Driver Duty & Workflow Management
  // ==========================================
  DriverModel get currentDriver {
    return _drivers.firstWhere(
      (d) => d.id == 'drv-01',
      orElse: () => _drivers.first,
    );
  }

  DriverDutySession? _currentDutySession;
  DriverDutySession? get currentDutySession => _currentDutySession;
  bool get isDriverOnDuty => _currentDutySession != null && _currentDutySession!.isActive;

  void startDriverDuty(DriverDutySession session) {
    _currentDutySession = session;
    notifyListeners();
  }

  void endDriverDuty() {
    if (_currentDutySession != null) {
      _currentDutySession!.isActive = false;
      _currentDutySession!.endedAt = DateTime.now();
    }
    notifyListeners();
  }

  // 1. Order Collection Phase
  void startOrderCollection(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].collectionStartedAt ??= DateTime.now();
      _orders[idx].workflowStep = DriverWorkflowStep.collectionStarted;
      _orders[idx].isDriverRideStarted = true;
      _orders[idx].driverRideStartedAt ??= DateTime.now();
      notifyListeners();
    }
  }

  void verifyOrderCollectionQr(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].collectionQrScanned = true;
      _orders[idx].collectionQrScannedAt = DateTime.now();
      _orders[idx].workflowStep = DriverWorkflowStep.collectionQrScanned;
      notifyListeners();
    }
  }

  void uploadOrderCollectionProof(String orderId, String photoName) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].collectionProofPhoto = photoName;
      _orders[idx].collectionProofUploadedAt = DateTime.now();
      _orders[idx].workflowStep = DriverWorkflowStep.collectionProofUploaded;
      notifyListeners();
    }
  }

  void completeOrderCollection(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].collectionCompletedAt = DateTime.now();
      _orders[idx].workflowStep = DriverWorkflowStep.collectionCompleted;
      _orders[idx].status = OrderStatus.pickedUp;
      notifyListeners();
    }
  }

  // 2. Order Arrival at Laundry Phase
  void markOrderLaundryQrScanned(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].arrivedAtLaundryAt ??= DateTime.now();
      _orders[idx].laundryQrScanned = true;
      _orders[idx].laundryQrScannedAt = DateTime.now();
      _orders[idx].workflowStep = DriverWorkflowStep.laundryQrScanCompleted;
      notifyListeners();
    }
  }

  void dispatchOrdersToLaundry({
    required List<String> orderIds,
    required String batchPhotoName,
  }) {
    final now = DateTime.now();
    for (final id in orderIds) {
      final idx = _orders.indexWhere((o) => o.id == id);
      if (idx >= 0) {
        _orders[idx].arrivedAtLaundryAt ??= now;
        _orders[idx].laundryQrScanned = true;
        _orders[idx].laundryQrScannedAt ??= now;
        _orders[idx].laundryProofPhoto = batchPhotoName;
        _orders[idx].dispatchedToLaundryAt = now;
        _orders[idx].workflowStep = DriverWorkflowStep.dispatchedToLaundry;
        _orders[idx].status = OrderStatus.inLaundry;
      }
    }
    notifyListeners();
  }

  // 3. Start Order Delivery (Loading into Van)
  void startDeliveryLoading(List<String> orderIds) {
    final now = DateTime.now();
    for (final id in orderIds) {
      final idx = _orders.indexWhere((o) => o.id == id);
      if (idx >= 0) {
        _orders[idx].deliveryLoadingStartedAt ??= now;
        _orders[idx].workflowStep = DriverWorkflowStep.deliveryStarted;
      }
    }
    notifyListeners();
  }

  void markOrderLoadedForDelivery(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].deliveryLoadingQrScanned = true;
      _orders[idx].deliveryLoadedInVan = true;
      _orders[idx].workflowStep = DriverWorkflowStep.loadedInVan;
      notifyListeners();
    }
  }

  void completeVanLoadingAndDispatch({
    required List<String> orderIds,
    required String bagHangerPhoto,
    required String platePhoto,
    required String laundryPhoto,
  }) {
    for (final id in orderIds) {
      final idx = _orders.indexWhere((o) => o.id == id);
      if (idx >= 0) {
        _orders[idx].deliveryLoadingBagHangerPhoto = bagHangerPhoto;
        _orders[idx].deliveryLoadingPlatePhoto = platePhoto;
        _orders[idx].deliveryLoadingLaundryPhoto = laundryPhoto;
        _orders[idx].status = OrderStatus.outForDelivery;
        _orders[idx].workflowStep = DriverWorkflowStep.deliveryStarted;
        _orders[idx].isDriverRideStarted = true;
        _orders[idx].driverRideStartedAt ??= DateTime.now();
      }
    }
    notifyListeners();
  }

  // 4. Individual Order Delivery
  void startIndividualOrderDelivery(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].deliveryStartedAt = DateTime.now();
      _orders[idx].status = OrderStatus.outForDelivery;
      _orders[idx].workflowStep = DriverWorkflowStep.deliveryStartedForOrder;
      _orders[idx].isDriverRideStarted = true;
      notifyListeners();
    }
  }

  void verifyIndividualOrderDeliveryQr(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].deliveryQrScanned = true;
      _orders[idx].deliveryQrScannedAt = DateTime.now();
      notifyListeners();
    }
  }

  void completeIndividualOrderDelivery({
    required String orderId,
    required String deliveryProofPhoto,
    required String deliveryLocation,
    String? deliveryLocationNote,
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final order = _orders[idx];
      order.deliveryProofPhoto = deliveryProofPhoto;
      order.deliveryProofUploadedAt = DateTime.now();
      order.deliveryLocation = deliveryLocation;
      order.deliveryLocationNote = deliveryLocationNote;
      order.deliveredAt = DateTime.now();
      order.status = OrderStatus.delivered;
      order.workflowStep = DriverWorkflowStep.delivered;

      // Credit bonus to driver
      final driver = currentDriver;
      final bonus = driver.bonusRatePerOrder;
      order.earnedBonus = bonus;
      driver.completedTrips += 1;
      driver.todayEarningsQar += bonus;

      notifyListeners();
    }
  }

  // 5. Cancel Order with Proof
  void cancelOrderWithProof({
    required String orderId,
    required String reasonCategory,
    required String reason,
    String? customDescription,
    required String locationPhoto,
    required String callLogPhoto,
    List<String> additionalPhotos = const [],
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final driver = currentDriver;
      final record = OrderCancellationRecord(
        orderId: orderId,
        driverId: driver.userId,
        driverName: driver.fullName,
        reasonCategory: reasonCategory,
        reason: reason,
        customDescription: customDescription,
        locationPhoto: locationPhoto,
        callLogPhoto: callLogPhoto,
        additionalPhotos: additionalPhotos,
        cancelledAt: DateTime.now(),
      );

      _orders[idx].status = OrderStatus.cancelled;
      _orders[idx].workflowStep = DriverWorkflowStep.cancelled;
      _orders[idx].cancellationRecord = record;

      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Driver Cancellation Alert',
        text: '❌ Order #${_orders[idx].orderNumber} CANCELLED by ${driver.fullName}. Reason: $reason. Proof photos attached.',
        timestamp: DateTime.now(),
        isMe: false,
      ));

      notifyListeners();
    }
  }

  // ==========================================
  // COUNTRY & BRANCH ENTERPRISE MANAGEMENT
  // ==========================================
  final List<CountryModel> _countries = [
    CountryModel(
      code: 'QAT',
      name: 'Qatar',
      nameAr: 'دولة قطر',
      flag: '🇶🇦',
      currencyCode: 'QAR',
      currencySymbol: 'QAR',
      currencySymbolAr: 'ر.ق',
      exchangeRateToQar: 1.0,
      hqAddress: 'Level 24, Al Fardan Commercial Towers, West Bay, Doha, Qatar',
      primaryContactPhone: '+974 4499 1000',
      primaryContactEmail: 'operations.doha@uniwash.qa',
      isActive: true,
      createdAt: DateTime(2022, 1, 1),
      branches: [
        BranchModel(
          id: 'branch-qat-01',
          code: 'DOH-01',
          name: 'Doha Central & Pearl Marina Hub',
          nameAr: 'فرع الدوحة واللؤلؤة الرئيسي',
          countryCode: 'QAT',
          city: 'Doha',
          address: 'Porto Arabia Tower 12, The Pearl-Qatar, Doha',
          phone: '+974 4499 8811',
          email: 'pearl.branch@uniwash.qa',
          managerName: 'Nasser Al-Hajri',
          isActive: true,
          createdAt: DateTime(2022, 2, 1),
          activeDriversCount: 16,
          activeLaundriesCount: 4,
          activeStaffCount: 8,
        ),
        BranchModel(
          id: 'branch-qat-02',
          code: 'DOH-02',
          name: 'Al Sadd & Bin Mahmoud Station',
          nameAr: 'فرع السد وبن محمود',
          countryCode: 'QAT',
          city: 'Doha',
          address: 'Al Sadd St, Near Sports Club, Doha',
          phone: '+974 4433 2211',
          email: 'alsadd.branch@uniwash.qa',
          managerName: 'Fahad Al-Tamimi',
          isActive: true,
          createdAt: DateTime(2022, 5, 10),
          activeDriversCount: 12,
          activeLaundriesCount: 3,
          activeStaffCount: 6,
        ),
        BranchModel(
          id: 'branch-qat-03',
          code: 'DOH-03',
          name: 'West Bay Diplomatic Hub',
          nameAr: 'فرع الخليج الغربي الدبلوماسي',
          countryCode: 'QAT',
          city: 'Doha',
          address: 'Majlis Al Taawon St, Diplomatic Area, Doha',
          phone: '+974 4411 9900',
          email: 'westbay.hub@uniwash.qa',
          managerName: 'Ibrahim Khouri',
          isActive: true,
          createdAt: DateTime(2022, 9, 15),
          activeDriversCount: 8,
          activeLaundriesCount: 2,
          activeStaffCount: 4,
        ),
        BranchModel(
          id: 'branch-qat-04',
          code: 'LUS-01',
          name: 'Lusail Marina Smart Hub',
          nameAr: 'فرع لوسيل مارينا الذكي',
          countryCode: 'QAT',
          city: 'Lusail',
          address: 'Marina Promenade Building B3, Lusail City',
          phone: '+974 4455 7788',
          email: 'lusail.ops@uniwash.qa',
          managerName: 'Tariq Al-Kawari',
          isActive: true,
          createdAt: DateTime(2023, 1, 12),
          activeDriversCount: 6,
          activeLaundriesCount: 2,
          activeStaffCount: 5,
        ),
      ],
    ),
    CountryModel(
      code: 'UAE',
      name: 'United Arab Emirates',
      nameAr: 'الإمارات العربية المتحدة',
      flag: '🇦🇪',
      currencyCode: 'AED',
      currencySymbol: 'AED',
      currencySymbolAr: 'د.إ',
      exchangeRateToQar: 1.01,
      hqAddress: 'Level 18, Burj Daman Building, DIFC, Dubai, UAE',
      primaryContactPhone: '+971 4 330 9900',
      primaryContactEmail: 'dubai.hub@uniwash.ae',
      isActive: true,
      createdAt: DateTime(2022, 6, 1),
      branches: [
        BranchModel(
          id: 'branch-uae-01',
          code: 'DXB-01',
          name: 'Dubai Marina & JBR Logistics Hub',
          nameAr: 'فرع دبي مارينا وجميرا بيتش',
          countryCode: 'UAE',
          city: 'Dubai',
          address: 'Marina Gate Tower 1, Dubai Marina',
          phone: '+971 4 330 9911',
          email: 'marina.dxb@uniwash.ae',
          managerName: 'Farah El-Sayed',
          isActive: true,
          createdAt: DateTime(2022, 7, 1),
          activeDriversCount: 45,
          activeLaundriesCount: 15,
          activeStaffCount: 18,
        ),
        BranchModel(
          id: 'branch-uae-02',
          code: 'DXB-02',
          name: 'Downtown & Business Bay Center',
          nameAr: 'فرع وسط المدينة والخليج التجاري',
          countryCode: 'UAE',
          city: 'Dubai',
          address: 'Marasi Drive, Business Bay, Dubai',
          phone: '+971 4 330 9922',
          email: 'downtown.dxb@uniwash.ae',
          managerName: 'Rashid Al-Falasi',
          isActive: true,
          createdAt: DateTime(2022, 10, 1),
          activeDriversCount: 28,
          activeLaundriesCount: 12,
          activeStaffCount: 14,
        ),
        BranchModel(
          id: 'branch-uae-03',
          code: 'AUH-01',
          name: 'Abu Dhabi Corniche & Al Reem',
          nameAr: 'فرع كورنيش أبوظبي وجزيرة الريم',
          countryCode: 'UAE',
          city: 'Abu Dhabi',
          address: 'Sky Tower, Al Reem Island, Abu Dhabi',
          phone: '+971 2 440 8800',
          email: 'abudhabi.hub@uniwash.ae',
          managerName: 'Mariam Al-Zaabi',
          isActive: true,
          createdAt: DateTime(2023, 3, 1),
          activeDriversCount: 22,
          activeLaundriesCount: 8,
          activeStaffCount: 10,
        ),
      ],
    ),
    CountryModel(
      code: 'KSA',
      name: 'Saudi Arabia',
      nameAr: 'المملكة العربية السعودية',
      flag: '🇸🇦',
      currencyCode: 'SAR',
      currencySymbol: 'SAR',
      currencySymbolAr: 'ر.س',
      exchangeRateToQar: 1.03,
      hqAddress: 'King Fahd Road, Al-Olaya Business District, Riyadh, KSA',
      primaryContactPhone: '+966 11 400 8800',
      primaryContactEmail: 'riyadh.ops@uniwash.sa',
      isActive: true,
      createdAt: DateTime(2022, 8, 1),
      branches: [
        BranchModel(
          id: 'branch-ksa-01',
          code: 'RUH-01',
          name: 'Riyadh Al-Olaya Central Station',
          nameAr: 'فرع العليا الرياض المركزي',
          countryCode: 'KSA',
          city: 'Riyadh',
          address: 'Olaya Towers, Olaya St, Riyadh',
          phone: '+966 11 400 8811',
          email: 'olaya.ruh@uniwash.sa',
          managerName: 'Sultan Al-Ghamdi',
          isActive: true,
          createdAt: DateTime(2022, 9, 1),
          activeDriversCount: 65,
          activeLaundriesCount: 30,
          activeStaffCount: 25,
        ),
        BranchModel(
          id: 'branch-ksa-02',
          code: 'JED-01',
          name: 'Jeddah Al-Hamra Coastal Hub',
          nameAr: 'فرع جدة الحمراء الساحلي',
          countryCode: 'KSA',
          city: 'Jeddah',
          address: 'Palestine St, Al-Hamra District, Jeddah',
          phone: '+966 12 600 4400',
          email: 'jeddah.hub@uniwash.sa',
          managerName: 'Abdulaziz Al-Shehri',
          isActive: true,
          createdAt: DateTime(2023, 2, 1),
          activeDriversCount: 42,
          activeLaundriesCount: 18,
          activeStaffCount: 16,
        ),
      ],
    ),
    CountryModel(
      code: 'KWT',
      name: 'Kuwait',
      nameAr: 'دولة الكويت',
      flag: '🇰🇼',
      currencyCode: 'KWD',
      currencySymbol: 'KWD',
      currencySymbolAr: 'د.ك',
      exchangeRateToQar: 0.084,
      hqAddress: 'Arraya Commercial Center, Al-Shuhada St, Kuwait City',
      primaryContactPhone: '+965 2220 1100',
      primaryContactEmail: 'kwt.hub@uniwash.com',
      isActive: true,
      createdAt: DateTime(2023, 3, 1),
      branches: [
        BranchModel(
          id: 'branch-kwt-01',
          code: 'KWT-01',
          name: 'Kuwait City Arraya Hub',
          nameAr: 'فرع مدينة الكويت الراية',
          countryCode: 'KWT',
          city: 'Kuwait City',
          address: 'Al-Shuhada St, Arraya Tower, Kuwait City',
          phone: '+965 2220 1111',
          email: 'city.kwt@uniwash.com',
          managerName: 'Yousef Al-Kandari',
          isActive: true,
          createdAt: DateTime(2023, 3, 10),
          activeDriversCount: 28,
          activeLaundriesCount: 12,
          activeStaffCount: 9,
        ),
      ],
    ),
    CountryModel(
      code: 'OMN',
      name: 'Oman',
      nameAr: 'سلطنة عمان',
      flag: '🇴🇲',
      currencyCode: 'OMR',
      currencySymbol: 'OMR',
      currencySymbolAr: 'ر.ع',
      exchangeRateToQar: 0.106,
      hqAddress: 'Muscat Grand Mall Complex, Dohat Al Adab St, Muscat, Oman',
      primaryContactPhone: '+968 2440 2200',
      primaryContactEmail: 'muscat.hub@uniwash.com',
      isActive: true,
      createdAt: DateTime(2023, 5, 1),
      branches: [
        BranchModel(
          id: 'branch-omn-01',
          code: 'MCT-01',
          name: 'Muscat Grand Mall Center',
          nameAr: 'فرع مسقط جراند مول',
          countryCode: 'OMN',
          city: 'Muscat',
          address: 'Dohat Al Adab St, Al Khuwair, Muscat',
          phone: '+968 2440 2211',
          email: 'muscat.city@uniwash.com',
          managerName: 'Haitham Al-Balushi',
          isActive: true,
          createdAt: DateTime(2023, 5, 15),
          activeDriversCount: 20,
          activeLaundriesCount: 9,
          activeStaffCount: 7,
        ),
      ],
    ),
    CountryModel(
      code: 'BHR',
      name: 'Bahrain',
      nameAr: 'مملكة البحرين',
      flag: '🇧🇭',
      currencyCode: 'BHD',
      currencySymbol: 'BHD',
      currencySymbolAr: 'د.ب',
      exchangeRateToQar: 0.103,
      hqAddress: 'Bahrain Financial Harbour, West Tower, Manama, Bahrain',
      primaryContactPhone: '+973 1750 3300',
      primaryContactEmail: 'bahrain.ops@uniwash.com',
      isActive: true,
      createdAt: DateTime(2023, 7, 1),
      branches: [
        BranchModel(
          id: 'branch-bhr-01',
          code: 'BAH-01',
          name: 'Manama Financial Harbour Branch',
          nameAr: 'فرع مرفأ البحرين المالي بالمنامة',
          countryCode: 'BHR',
          city: 'Manama',
          address: 'West Tower, Financial Harbour, Manama',
          phone: '+973 1750 3311',
          email: 'manama.hub@uniwash.com',
          managerName: 'Salman Al-Khalifa',
          isActive: true,
          createdAt: DateTime(2023, 7, 10),
          activeDriversCount: 18,
          activeLaundriesCount: 8,
          activeStaffCount: 6,
        ),
      ],
    ),
    CountryModel(
      code: 'GBR',
      name: 'United Kingdom',
      nameAr: 'المملكة المتحدة',
      flag: '🇬🇧',
      currencyCode: 'GBP',
      currencySymbol: '£',
      currencySymbolAr: 'ج.إ',
      exchangeRateToQar: 0.21,
      hqAddress: '45 Berkeley Square, Mayfair, London W1J 5AS, UK',
      primaryContactPhone: '+44 20 7946 0192',
      primaryContactEmail: 'london.hq@uniwash.com',
      isActive: true,
      createdAt: DateTime(2023, 9, 1),
      branches: [
        BranchModel(
          id: 'branch-gbr-01',
          code: 'LON-01',
          name: 'London Mayfair & West End Hub',
          nameAr: 'فرع لندن مايفير وويست إند',
          countryCode: 'GBR',
          city: 'London',
          address: '45 Berkeley Square, Mayfair, London',
          phone: '+44 20 7946 0199',
          email: 'mayfair.lon@uniwash.com',
          managerName: 'Edward Sterling',
          isActive: true,
          createdAt: DateTime(2023, 9, 15),
          activeDriversCount: 50,
          activeLaundriesCount: 24,
          activeStaffCount: 20,
        ),
      ],
    ),
    CountryModel(
      code: 'USA',
      name: 'United States',
      nameAr: 'الولايات المتحدة',
      flag: '🇺🇸',
      currencyCode: 'USD',
      currencySymbol: '\$',
      currencySymbolAr: '\$',
      exchangeRateToQar: 0.27,
      hqAddress: '1251 Avenue of the Americas, Manhattan, New York, NY 10020',
      primaryContactPhone: '+1 212 555 0188',
      primaryContactEmail: 'ny.ops@uniwash.com',
      isActive: true,
      createdAt: DateTime(2023, 11, 1),
      branches: [
        BranchModel(
          id: 'branch-usa-01',
          code: 'NYC-01',
          name: 'Manhattan Midtown & Wall St Logistics Hub',
          nameAr: 'فرع مانهاتن نيويورك المركزي',
          countryCode: 'USA',
          city: 'New York',
          address: '1251 Avenue of the Americas, Manhattan, NY',
          phone: '+1 212 555 0199',
          email: 'manhattan.nyc@uniwash.com',
          managerName: 'Marcus Vance',
          isActive: true,
          createdAt: DateTime(2023, 11, 15),
          activeDriversCount: 110,
          activeLaundriesCount: 55,
          activeStaffCount: 42,
        ),
      ],
    ),
  ];

  List<CountryModel> get countries => List.unmodifiable(_countries);

  CountryModel? getCountryByCode(String code) {
    try {
      return _countries.firstWhere((c) => c.code.toUpperCase() == code.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  void addCountry(CountryModel newCountry) {
    _countries.add(newCountry);
    logAudit(
      actionType: AuditActionType.countryConfigUpdated,
      entity: 'Country',
      entityId: newCountry.code,
      previousValue: 'None',
      newValue: 'Added ${newCountry.name} (${newCountry.code})',
      reason: 'New geographic operational market initialized by Super Admin',
      countryCode: newCountry.code,
    );
    notifyListeners();
  }

  void updateCountry(String code, {required String name, required String hqAddress, required String phone, required String email}) {
    final idx = _countries.indexWhere((c) => c.code == code);
    if (idx >= 0) {
      final old = _countries[idx];
      _countries[idx] = CountryModel(
        code: old.code,
        name: name,
        nameAr: old.nameAr,
        flag: old.flag,
        currencyCode: old.currencyCode,
        currencySymbol: old.currencySymbol,
        currencySymbolAr: old.currencySymbolAr,
        exchangeRateToQar: old.exchangeRateToQar,
        hqAddress: hqAddress,
        primaryContactPhone: phone,
        primaryContactEmail: email,
        isActive: old.isActive,
        createdAt: old.createdAt,
        branches: old.branches,
      );
      logAudit(
        actionType: AuditActionType.countryConfigUpdated,
        entity: 'Country',
        entityId: code,
        previousValue: '${old.name} | ${old.primaryContactPhone}',
        newValue: '$name | $phone',
        reason: 'Country contact & regional HQ records updated',
        countryCode: code,
      );
      notifyListeners();
    }
  }

  void toggleCountryStatus(String code) {
    final idx = _countries.indexWhere((c) => c.code == code);
    if (idx >= 0) {
      final oldStatus = _countries[idx].isActive;
      _countries[idx].isActive = !oldStatus;
      logAudit(
        actionType: AuditActionType.countryConfigUpdated,
        entity: 'Country',
        entityId: code,
        previousValue: oldStatus ? 'Active' : 'Inactive',
        newValue: !oldStatus ? 'Active' : 'Inactive',
        reason: 'Super Admin toggled country operational status',
        countryCode: code,
      );
      notifyListeners();
    }
  }

  // Branch CRUD
  List<BranchModel> get allBranches {
    final List<BranchModel> all = [];
    for (final c in _countries) {
      all.addAll(c.branches);
    }
    return all;
  }

  List<BranchModel> getBranchesForCountry(String code) {
    final country = getCountryByCode(code);
    return country?.branches ?? [];
  }

  void addBranch(String countryCode, BranchModel branch) {
    final country = getCountryByCode(countryCode);
    if (country != null) {
      country.branches.add(branch);
      logAudit(
        actionType: AuditActionType.branchCreated,
        entity: 'Branch',
        entityId: '${branch.code} (${branch.name})',
        previousValue: 'None',
        newValue: 'Created in ${country.name}',
        reason: 'New branch facility established',
        countryCode: countryCode,
      );
      notifyListeners();
    }
  }

  void updateBranch(String branchId, {required String name, required String city, required String address, required String phone, required String email, required String managerName}) {
    for (final country in _countries) {
      final idx = country.branches.indexWhere((b) => b.id == branchId);
      if (idx >= 0) {
        final old = country.branches[idx];
        country.branches[idx] = old.copyWith(
          name: name,
          city: city,
          address: address,
          phone: phone,
          email: email,
          managerName: managerName,
        );
        logAudit(
          actionType: AuditActionType.branchCreated,
          entity: 'Branch',
          entityId: branchId,
          previousValue: '${old.name} | ${old.managerName}',
          newValue: '$name | $managerName',
          reason: 'Branch details modified',
          countryCode: country.code,
        );
        notifyListeners();
        return;
      }
    }
  }

  void toggleBranchStatus(String branchId) {
    for (final country in _countries) {
      final idx = country.branches.indexWhere((b) => b.id == branchId);
      if (idx >= 0) {
        final old = country.branches[idx];
        country.branches[idx].isActive = !old.isActive;
        logAudit(
          actionType: AuditActionType.branchCreated,
          entity: 'Branch',
          entityId: branchId,
          previousValue: old.isActive ? 'Active' : 'Deactivated',
          newValue: !old.isActive ? 'Active' : 'Deactivated',
          reason: 'Branch operational status updated',
          countryCode: country.code,
        );
        notifyListeners();
        return;
      }
    }
  }

  // ==========================================
  // ADMIN & ROLE-BASED ACCESS CONTROL
  // ==========================================
  final List<AdminUserModel> _admins = [
    AdminUserModel(
      id: 'adm-01',
      fullName: 'Eng. Sheikh Faisal Al-Thani',
      email: 'faisal.director@uniwash.qa',
      phone: '+974 4499 1000',
      countryCode: 'GLOBAL',
      assignedBranchIds: [],
      permissions: AppPermission.superAdminPermissions,
      isSuperAdmin: true,
      isActive: true,
      createdAt: DateTime(2022, 1, 1),
      lastLoginAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    AdminUserModel(
      id: 'adm-02',
      fullName: 'Rashid Al-Sulaiti',
      email: 'rashid.ops@uniwash.qa',
      phone: '+974 3300 4455',
      countryCode: 'QAT',
      assignedBranchIds: ['branch-qat-01', 'branch-qat-02', 'branch-qat-03', 'branch-qat-04'],
      permissions: AppPermission.regionalAdminDefaults,
      isSuperAdmin: false,
      isActive: true,
      createdAt: DateTime(2022, 3, 1),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AdminUserModel(
      id: 'adm-03',
      fullName: 'Farah El-Sayed',
      email: 'farah.ops@uniwash.ae',
      phone: '+971 4 330 9901',
      countryCode: 'UAE',
      assignedBranchIds: ['branch-uae-01', 'branch-uae-02'],
      permissions: AppPermission.regionalAdminDefaults,
      isSuperAdmin: false,
      isActive: true,
      createdAt: DateTime(2022, 7, 1),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AdminUserModel(
      id: 'adm-04',
      fullName: 'Sultan Al-Ghamdi',
      email: 'sultan.md@uniwash.sa',
      phone: '+966 11 400 8800',
      countryCode: 'KSA',
      assignedBranchIds: ['branch-ksa-01', 'branch-ksa-02'],
      permissions: AppPermission.regionalAdminDefaults,
      isSuperAdmin: false,
      isActive: true,
      createdAt: DateTime(2022, 9, 1),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AdminUserModel(
      id: 'adm-05',
      fullName: 'Mona Al-Kuwari',
      email: 'mona.ops@uniwash.qa',
      phone: '+974 4499 1001',
      countryCode: 'QAT',
      assignedBranchIds: ['branch-qat-01', 'branch-qat-03'],
      permissions: AppPermission.customerServiceDefaults,
      isSuperAdmin: false,
      isActive: true,
      createdAt: DateTime(2023, 1, 15),
      lastLoginAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  List<AdminUserModel> get admins => List.unmodifiable(_admins);

  void addAdmin(AdminUserModel admin) {
    _admins.add(admin);
    logAudit(
      actionType: AuditActionType.adminCreated,
      entity: 'Admin',
      entityId: '${admin.id} (${admin.fullName})',
      previousValue: 'None',
      newValue: 'Assigned to ${admin.countryCode}',
      reason: 'New Regional Admin onboarded with custom permission set',
      countryCode: admin.countryCode,
    );
    notifyListeners();
  }

  void updateAdmin(String id, {required String fullName, required String email, required String phone, required String countryCode, required List<String> branches, required Set<AppPermission> permissions}) {
    final idx = _admins.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      final old = _admins[idx];
      _admins[idx] = AdminUserModel(
        id: old.id,
        fullName: fullName,
        email: email,
        phone: phone,
        countryCode: countryCode,
        assignedBranchIds: branches,
        permissions: permissions,
        isSuperAdmin: old.isSuperAdmin,
        isActive: old.isActive,
        createdAt: old.createdAt,
        lastLoginAt: old.lastLoginAt,
      );
      logAudit(
        actionType: AuditActionType.adminEdited,
        entity: 'Admin',
        entityId: id,
        previousValue: '${old.fullName} | ${old.countryCode} (${old.permissions.length} perms)',
        newValue: '$fullName | $countryCode (${permissions.length} perms)',
        reason: 'Super Admin updated admin assignments and permission scope',
        countryCode: countryCode,
      );
      notifyListeners();
    }
  }

  void toggleAdminStatus(String id) {
    final idx = _admins.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      final old = _admins[idx];
      _admins[idx].isActive = !old.isActive;
      logAudit(
        actionType: AuditActionType.adminDeactivated,
        entity: 'Admin',
        entityId: id,
        previousValue: old.isActive ? 'Active' : 'Deactivated',
        newValue: !old.isActive ? 'Active' : 'Deactivated',
        reason: 'Admin access toggled',
        countryCode: old.countryCode,
      );
      notifyListeners();
    }
  }

  // ==========================================
  // TEAM MANAGEMENT (CUSTOMER SERVICE, DRIVERS, OFFICE STAFF)
  // ==========================================
  final List<TeamMemberModel> _teamMembers = [
    TeamMemberModel(
      id: 'tm-cs-01',
      fullName: 'Sara Mansoor',
      email: 'sara.disputes@uniwash.qa',
      phone: '+974 4499 1003',
      category: TeamCategory.customerService,
      countryCode: 'QAT',
      branchId: 'branch-qat-01',
      branchName: 'Doha Central & Pearl Marina Hub',
      jobTitle: 'Senior Customer Dispute & VIP Service Specialist',
      joinedAt: DateTime(2022, 4, 1),
      assignedOrdersCount: 142,
      completedOrdersCount: 139,
      rating: 4.95,
    ),
    TeamMemberModel(
      id: 'tm-cs-02',
      fullName: 'Noora Al-Attiyah',
      email: 'noora.cs@uniwash.qa',
      phone: '+974 4499 1004',
      category: TeamCategory.customerService,
      countryCode: 'QAT',
      branchId: 'branch-qat-03',
      branchName: 'West Bay Diplomatic Hub',
      jobTitle: 'Customer Care & Order Resolution Agent',
      joinedAt: DateTime(2023, 2, 10),
      assignedOrdersCount: 98,
      completedOrdersCount: 95,
      rating: 4.88,
    ),
    TeamMemberModel(
      id: 'tm-of-01',
      fullName: 'Ahmed Tariq',
      email: 'dispatch.doha@uniwash.qa',
      phone: '+974 4499 1002',
      category: TeamCategory.officeStaff,
      countryCode: 'QAT',
      branchId: 'branch-qat-01',
      branchName: 'Doha Central & Pearl Marina Hub',
      jobTitle: 'Logistics, Shift & Van Fleet Supervisor',
      joinedAt: DateTime(2022, 3, 1),
      assignedOrdersCount: 420,
      completedOrdersCount: 412,
      rating: 4.92,
    ),
    TeamMemberModel(
      id: 'tm-of-02',
      fullName: 'Kavita Patel',
      email: 'kavita.qa@uniwash.qa',
      phone: '+974 4499 1005',
      category: TeamCategory.officeStaff,
      countryCode: 'QAT',
      branchId: 'branch-qat-02',
      branchName: 'Al Sadd & Bin Mahmoud Station',
      jobTitle: 'Garment Quality & Cleanliness Inspector',
      joinedAt: DateTime(2022, 6, 1),
      assignedOrdersCount: 310,
      completedOrdersCount: 308,
      rating: 4.96,
    ),
    TeamMemberModel(
      id: 'tm-dr-01',
      fullName: 'Tariq Al-Mansoor',
      email: 'tariq.driver@uniwash.qa',
      phone: '+974 5512 8900',
      category: TeamCategory.driver,
      driverAffiliation: DriverAffiliation.companyFleet,
      countryCode: 'QAT',
      branchId: 'branch-qat-01',
      branchName: 'Doha Central & Pearl Marina Hub',
      jobTitle: 'Lead Courier & Platinum Driver (Company Fleet)',
      joinedAt: DateTime(2023, 2, 1),
      assignedOrdersCount: 320,
      completedOrdersCount: 318,
      rating: 4.98,
    ),
    TeamMemberModel(
      id: 'tm-dr-02',
      fullName: 'Bilal Ahmed',
      email: 'bilal.driver@uniwash.qa',
      phone: '+974 6623 4455',
      category: TeamCategory.driver,
      driverAffiliation: DriverAffiliation.companyFleet,
      countryCode: 'QAT',
      branchId: 'branch-qat-01',
      branchName: 'Doha Central & Pearl Marina Hub',
      jobTitle: 'Express Van Courier (Company Fleet)',
      joinedAt: DateTime(2023, 8, 15),
      assignedOrdersCount: 265,
      completedOrdersCount: 262,
      rating: 4.88,
    ),
    TeamMemberModel(
      id: 'tm-dr-03',
      fullName: 'Rashid Al-Kuwari',
      email: 'rashid.driver@uniwash.qa',
      phone: '+974 3388 9911',
      category: TeamCategory.driver,
      driverAffiliation: DriverAffiliation.laundryDedicated,
      countryCode: 'QAT',
      branchId: 'branch-qat-02',
      branchName: 'Al Sadd & Bin Mahmoud Station',
      jobTitle: 'Dedicated Laundry Facility Driver',
      joinedAt: DateTime(2024, 1, 10),
      assignedOrdersCount: 210,
      completedOrdersCount: 207,
      rating: 4.79,
    ),
    TeamMemberModel(
      id: 'tm-eng-01',
      fullName: 'Eng. Zaid Mansoori',
      email: 'zaid.eng@uniwash.qa',
      phone: '+974 5544 3322',
      category: TeamCategory.engineer,
      countryCode: 'QAT',
      branchId: 'branch-qat-01',
      branchName: 'Doha Central & Pearl Marina Hub',
      jobTitle: 'Lead Mobile & Backend Systems Engineer',
      joinedAt: DateTime(2023, 5, 20),
      assignedOrdersCount: 0,
      completedOrdersCount: 0,
      rating: 5.0,
      notes: 'Responsible for app bugs, sync exceptions, scanner issues, and API health',
    ),
    TeamMemberModel(
      id: 'tm-oth-01',
      fullName: 'Farhan Qasim',
      email: 'farhan.contractor@uniwash.qa',
      phone: '+974 7788 1234',
      category: TeamCategory.other,
      countryCode: 'QAT',
      branchId: 'branch-qat-01',
      branchName: 'Doha Central & Pearl Marina Hub',
      jobTitle: 'Facility Equipment & Van Fleet Contractor',
      joinedAt: DateTime(2024, 2, 1),
      assignedOrdersCount: 0,
      completedOrdersCount: 0,
      rating: 4.85,
    ),
  ];

  List<TeamMemberModel> get teamMembers => List.unmodifiable(_teamMembers);

  List<TeamMemberModel> getTeamMembersForCountry(String code) {
    if (code == 'ALL' || code == 'GLOBAL') return _teamMembers;
    return _teamMembers.where((m) => m.countryCode == code).toList();
  }

  void addTeamMember(TeamMemberModel member) {
    _teamMembers.add(member);
    logAudit(
      actionType: AuditActionType.teamMemberCreated,
      entity: 'Team Member',
      entityId: '${member.id} (${member.fullName})',
      previousValue: 'None',
      newValue: '${member.category.title} at ${member.branchName}',
      reason: 'New team member added to operations roster',
      countryCode: member.countryCode,
    );
    notifyListeners();
  }

  void updateTeamMember(String id, {required String fullName, required String email, required String phone, required TeamCategory category, required String jobTitle, required String branchId, required String branchName}) {
    final idx = _teamMembers.indexWhere((m) => m.id == id);
    if (idx >= 0) {
      final old = _teamMembers[idx];
      _teamMembers[idx] = TeamMemberModel(
        id: old.id,
        fullName: fullName,
        email: email,
        phone: phone,
        category: category,
        countryCode: old.countryCode,
        branchId: branchId,
        branchName: branchName,
        jobTitle: jobTitle,
        isActive: old.isActive,
        joinedAt: old.joinedAt,
        assignedOrdersCount: old.assignedOrdersCount,
        completedOrdersCount: old.completedOrdersCount,
        rating: old.rating,
      );
      logAudit(
        actionType: AuditActionType.teamMemberEdited,
        entity: 'Team Member',
        entityId: id,
        previousValue: '${old.fullName} | ${old.jobTitle}',
        newValue: '$fullName | $jobTitle',
        reason: 'Team member profile and role assignments updated',
        countryCode: old.countryCode,
      );
      notifyListeners();
    }
  }

  void toggleTeamMemberStatus(String id) {
    final idx = _teamMembers.indexWhere((m) => m.id == id);
    if (idx >= 0) {
      final old = _teamMembers[idx];
      _teamMembers[idx].isActive = !old.isActive;
      logAudit(
        actionType: AuditActionType.teamMemberEdited,
        entity: 'Team Member',
        entityId: id,
        previousValue: old.isActive ? 'Active' : 'Inactive',
        newValue: !old.isActive ? 'Active' : 'Inactive',
        reason: 'Team member active status toggled',
        countryCode: old.countryCode,
      );
      notifyListeners();
    }
  }

  // ==========================================
  // ORDER PROBLEMS & EXCEPTIONS MANAGEMENT
  // ==========================================
  final List<OrderProblem> _orderProblems = [
    OrderProblem(
      id: 'prb-101',
      orderId: 'ord-1002',
      orderNumber: 10843,
      customerName: 'Sheikha Maryam',
      countryCode: 'QAT',
      branchName: 'Doha Central & Pearl Marina Hub',
      type: ProblemType.qrScanMissed,
      severity: ProblemSeverity.high,
      description: 'Order collected but pickup verification QR scan timestamp was missed by courier Tariq.',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 40)),
      reportedBy: 'Automated Exception Monitor',
    ),
    OrderProblem(
      id: 'prb-102',
      orderId: 'ord-1003',
      orderNumber: 10840,
      customerName: 'Dr. Khalid Al-Dosari',
      countryCode: 'QAT',
      branchName: 'Doha Central & Pearl Marina Hub',
      type: ProblemType.missingProofPhoto,
      severity: ProblemSeverity.medium,
      description: 'Order moved to Ready for Delivery but facility intake batch photo is missing from record.',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
      reportedBy: 'Regional QA Inspector',
    ),
    OrderProblem(
      id: 'prb-103',
      orderId: 'ord-1001',
      orderNumber: 10842,
      customerName: 'Jassim Al-Kuwari',
      countryCode: 'QAT',
      branchName: 'Doha Central & Pearl Marina Hub',
      type: ProblemType.orderStuck,
      severity: ProblemSeverity.low,
      description: 'Order has been in laundry processing for 4+ hours during standard shift.',
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
      reportedBy: 'Shift Supervisor',
      isResolved: true,
      resolvedAt: DateTime.now().subtract(const Duration(hours: 1)),
      resolvedBy: 'Super Admin (Sheikh Faisal Al-Thani)',
      resolutionNotes: 'Verified delicate silk embroidery hand washing protocol in progress.',
      correctedAction: 'Extended SLA timestamp and notified customer.',
    ),
  ];

  List<OrderProblem> get orderProblems => List.unmodifiable(_orderProblems);

  int get unresolvedProblemsCount => _orderProblems.where((p) => !p.isResolved).length;

  void reportOrderProblem(OrderProblem problem) {
    _orderProblems.insert(0, problem);
    notifyListeners();
  }

  void resolveOrderProblem(String problemId, {required String notes, required String action}) {
    final idx = _orderProblems.indexWhere((p) => p.id == problemId);
    if (idx >= 0) {
      final p = _orderProblems[idx];
      p.markResolved(
        resolvedBy: '${_currentUser.fullName} (${_currentUser.role.title})',
        action: action,
        notes: notes,
      );
      logAudit(
        actionType: AuditActionType.problemResolved,
        entity: 'Order Exception',
        entityId: 'Problem #${p.id} for Order #${p.orderNumber}',
        previousValue: 'Open (${p.severity.label})',
        newValue: 'Resolved: $action',
        reason: notes,
        countryCode: p.countryCode,
      );
      notifyListeners();
    }
  }

  // Customer Service / Admin: Escalate Unresolved Problem to Admin
  void escalateProblemToAdmin(String problemId, {required String adminName, required String reason}) {
    final idx = _orderProblems.indexWhere((p) => p.id == problemId);
    if (idx >= 0) {
      final p = _orderProblems[idx];
      p.escalateToAdmin(
        adminName: adminName,
        reason: reason,
        escalatedBy: '${_currentUser.fullName} (${_currentUser.role.title})',
      );
      logAudit(
        actionType: AuditActionType.problemResolved,
        entity: 'Escalated Order Exception',
        entityId: 'Problem #${p.id} for Order #${p.orderNumber}',
        previousValue: 'Customer Support Queue',
        newValue: 'Escalated to $adminName',
        reason: reason,
        countryCode: p.countryCode,
      );
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Executive Operations Alert',
        text: '🚨 EXCEPTION ESCALATED TO ADMIN ($adminName): Order #${p.orderNumber} - $reason',
        timestamp: DateTime.now(),
        isMe: false,
      ));
      notifyListeners();
    }
  }

  // ==========================================
  // AUDIT LOGGING SYSTEM
  // ==========================================
  final List<AuditLogEntry> _auditLogs = [
    AuditLogEntry(
      id: 'aud-001',
      performedBy: 'Sheikh Faisal Al-Thani',
      performedByRole: 'Super Admin',
      performedById: 'adm-01',
      actionType: AuditActionType.adminCreated,
      entity: 'Admin Account',
      entityId: 'adm-02 (Rashid Al-Sulaiti)',
      previousValue: 'Unregistered',
      newValue: 'Assigned Qatar Operations Admin',
      reason: 'Regional Operations mandate for Qatar World Class Laundry Standards',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      countryCode: 'QAT',
    ),
    AuditLogEntry(
      id: 'aud-002',
      performedBy: 'Rashid Al-Sulaiti',
      performedByRole: 'Regional Admin',
      performedById: 'adm-02',
      actionType: AuditActionType.orderDriverReassigned,
      entity: 'Order',
      entityId: 'ord-1002 (#10843)',
      previousValue: 'Unassigned',
      newValue: 'Assigned Tariq Al-Mansoor (DRV-QA-8821)',
      reason: 'Fast express dispatch scheduled for Pearl VIP pickup',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      countryCode: 'QAT',
    ),
  ];

  List<AuditLogEntry> get auditLogs => List.unmodifiable(_auditLogs);

  void logAudit({
    required AuditActionType actionType,
    required String entity,
    required String entityId,
    required String previousValue,
    required String newValue,
    required String reason,
    String? countryCode,
  }) {
    final entry = AuditLogEntry(
      id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
      performedBy: _currentUser.fullName,
      performedByRole: _currentUser.role.title,
      performedById: _currentUser.id,
      actionType: actionType,
      entity: entity,
      entityId: entityId,
      previousValue: previousValue,
      newValue: newValue,
      reason: reason,
      timestamp: DateTime.now(),
      countryCode: countryCode ?? _currentUser.countryCode,
    );
    _auditLogs.insert(0, entry);
    notifyListeners();
  }

  // ==========================================
  // OPERATIONAL CORRECTION TOOLS (CONTROLLED WITH AUDIT)
  // ==========================================
  bool correctOrderStatus(String orderId, OrderStatus newStatus, {required String reason}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final old = _orders[idx];
      final prevName = old.status.name;
      old.status = newStatus;

      // Sync workflow step if applicable
      if (newStatus == OrderStatus.inLaundry) {
        old.workflowStep = DriverWorkflowStep.dispatchedToLaundry;
      } else if (newStatus == OrderStatus.delivered) {
        old.workflowStep = DriverWorkflowStep.delivered;
      } else if (newStatus == OrderStatus.pickedUp) {
        old.workflowStep = DriverWorkflowStep.collectionCompleted;
      }

      logAudit(
        actionType: AuditActionType.orderStatusCorrected,
        entity: 'Order',
        entityId: 'Order #${old.orderNumber} ($orderId)',
        previousValue: prevName,
        newValue: newStatus.name,
        reason: reason,
        countryCode: 'QAT',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  bool reassignOrderDriver(String orderId, String newDriverId, {required String reason}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final old = _orders[idx];
      final driver = _drivers.firstWhere((d) => d.id == newDriverId, orElse: () => _drivers.first);
      final prevDriver = old.assignedDriverName;

      old.assignedDriverId = driver.id;
      old.assignedDriverName = driver.fullName;
      old.assignedDriverPhone = driver.phone;
      if (old.status == OrderStatus.placed) {
        old.status = OrderStatus.driverAssigned;
        old.workflowStep = DriverWorkflowStep.assigned;
      }

      logAudit(
        actionType: AuditActionType.orderDriverReassigned,
        entity: 'Order',
        entityId: 'Order #${old.orderNumber} ($orderId)',
        previousValue: prevDriver,
        newValue: '${driver.fullName} (${driver.userId})',
        reason: reason,
        countryCode: 'QAT',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  bool reassignOrderBranch(String orderId, String newLaundryId, {required String reason}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final old = _orders[idx];
      final laundry = _laundries.firstWhere((l) => l.id == newLaundryId, orElse: () => _laundries.first);
      final prevLaundry = old.laundryName;

      old.laundryId = laundry.id;
      old.laundryName = laundry.name;

      logAudit(
        actionType: AuditActionType.orderBranchReassigned,
        entity: 'Order',
        entityId: 'Order #${old.orderNumber} ($orderId)',
        previousValue: prevLaundry,
        newValue: '${laundry.name} (${laundry.userId})',
        reason: reason,
        countryCode: 'QAT',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  bool overrideOrderQrState(String orderId, {required bool isScanned, required String reason}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final old = _orders[idx];
      final prev = 'Pickup QR: ${old.collectionQrScanned}, Laundry QR: ${old.laundryQrScanned}, Delivery QR: ${old.deliveryQrScanned}';
      
      old.collectionQrScanned = isScanned;
      if (isScanned && old.collectionQrScannedAt == null) {
        old.collectionQrScannedAt = DateTime.now();
      }

      logAudit(
        actionType: AuditActionType.qrStateCorrected,
        entity: 'Order QR State',
        entityId: 'Order #${old.orderNumber} ($orderId)',
        previousValue: prev,
        newValue: 'Overridden to scanned=$isScanned with supervisor override clearance',
        reason: reason,
        countryCode: 'QAT',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  bool reopenOrder(String orderId, {required String reason}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final old = _orders[idx];
      final prev = old.status.name;
      old.status = OrderStatus.inLaundry;
      old.workflowStep = DriverWorkflowStep.dispatchedToLaundry;

      logAudit(
        actionType: AuditActionType.orderReopened,
        entity: 'Order',
        entityId: 'Order #${old.orderNumber} ($orderId)',
        previousValue: prev,
        newValue: 'Reopened to ${OrderStatus.inLaundry.name}',
        reason: reason,
        countryCode: 'QAT',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void addOrderInternalNote(String orderId, String noteText) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].attachments.add(OrderAttachment(
        id: 'note-${DateTime.now().millisecondsSinceEpoch}',
        fileName: 'Supervisor_Internal_Note.txt',
        fileType: 'text',
        uploadedBy: 'admin',
        description: '[$nowFormatted - ${_currentUser.fullName}]: $noteText',
        uploadedAt: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  String get nowFormatted {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // ==========================================
  // SYSTEM BUGS & BACKEND DIAGNOSTICS (ENGINEER WORKSPACE)
  // ==========================================
  final List<SystemBug> _systemBugs = [
    SystemBug(
      id: 'BUG-1092',
      title: 'Camera autofocus delay during QR barcode capture on low-light Samsung devices',
      description: 'Drivers with Galaxy A54 report 3-4 second shutter delay when scanning bag QR in indoor parking garages.',
      module: 'Driver App QR Scanner',
      stackTrace: 'Camera2Device.java:142\nCameraCaptureSession.setRepeatingRequest() [Timeout 4000ms]\nQRScannerOverlay.dart:184',
      deviceInfo: 'Samsung SM-A546B / Android 14 / Driver Build v2.4.1',
      severity: BugSeverity.medium,
      status: BugStatus.inProgress,
      reportedAt: DateTime.now().subtract(const Duration(hours: 4)),
      reportedBy: 'Driver Telemetry (Tariq Al-Mansoor)',
    ),
    SystemBug(
      id: 'BUG-1093',
      title: 'WebSocket live courier GPS ping disconnect after device screen sleeps > 10m',
      description: 'Background geolocation service enters deep doze state on aggressive OEM battery savers, delaying live ETA on Customer Screen.',
      module: 'Live GPS Tracking & Sync',
      stackTrace: 'BackgroundGeolocationService.kt:88\nWSSocketManager.onDisconnect(1006 - Abnormal Closure)\nStateService.updateDriverLocation:310',
      deviceInfo: 'Xiaomi Redmi Note 12 / MIUI 14 / Driver Build v2.4.1',
      severity: BugSeverity.high,
      status: BugStatus.open,
      reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
      reportedBy: 'QA Automated Heartbeat Monitor',
    ),
    SystemBug(
      id: 'BUG-1094',
      title: 'Bluetooth thermal invoice printer ESC/POS line feed offset by 10mm on 58mm rolls',
      description: 'Thermal receipt footer prints slightly off-center on 58mm compact portable mobile printers.',
      module: 'Thermal Invoice Printing',
      stackTrace: 'EscPosPrinter.dart:94\nThermalReceiptDialog.dart:312',
      deviceInfo: 'Sunmi V2 Pro / Android 11 / Laundry Portal v2.4.0',
      severity: BugSeverity.low,
      status: BugStatus.resolved,
      reportedAt: DateTime.now().subtract(const Duration(days: 1)),
      reportedBy: 'Pearl Branch Laundry Supervisor',
      resolvedAt: DateTime.now().subtract(const Duration(hours: 2)),
      resolvedBy: 'Eng. Zaid Mansoori',
      resolutionNotes: 'Calibrated ESC/POS 58mm canvas margin to 384 dots width. Patch tested on Sunmi V2.',
      fixCommitRef: 'commit-escpos-margin-fix-v242',
    ),
  ];

  List<SystemBug> get systemBugs => List.unmodifiable(_systemBugs);
  int get openBugsCount => _systemBugs.where((b) => !b.isResolved).length;

  void reportBug(SystemBug bug) {
    _systemBugs.insert(0, bug);
    notifyListeners();
  }

  void updateBugStatus(String bugId, BugStatus status) {
    final idx = _systemBugs.indexWhere((b) => b.id == bugId);
    if (idx >= 0) {
      _systemBugs[idx].status = status;
      notifyListeners();
    }
  }

  void resolveBug(String bugId, {required String notes, String? commitRef}) {
    final idx = _systemBugs.indexWhere((b) => b.id == bugId);
    if (idx >= 0) {
      _systemBugs[idx].markResolved(
        engineerName: _currentUser.fullName,
        notes: notes,
        commitRef: commitRef,
      );
      logAudit(
        actionType: AuditActionType.adminEdited,
        entity: 'System Bug Patch',
        entityId: 'Bug #$bugId (${_systemBugs[idx].title})',
        previousValue: 'Open',
        newValue: 'Resolved & Patched by ${_currentUser.fullName}',
        reason: notes,
        countryCode: 'GLOBAL',
      );
      notifyListeners();
    }
  }

  // ==========================================
  // CUSTOMER SERVICE & ADMIN ORDER ACTIONS
  // ==========================================

  // Reschedule Order (Pickup / Delivery)
  bool rescheduleOrder(
    String orderId, {
    DateTime? pickupDate,
    String? pickupSlot,
    DateTime? deliveryDate,
    String? deliverySlot,
    required String reason,
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final order = _orders[idx];
      final prev = 'Pickup: ${order.scheduledPickupDate != null ? "${order.scheduledPickupDate!.day}/${order.scheduledPickupDate!.month}" : "Standard"} (${order.scheduledPickupSlot ?? "ASAP"}), Delivery: ${order.scheduledDeliveryDate != null ? "${order.scheduledDeliveryDate!.day}/${order.scheduledDeliveryDate!.month}" : "Standard"} (${order.scheduledDeliverySlot ?? "Standard"})';
      
      if (pickupDate != null) order.scheduledPickupDate = pickupDate;
      if (pickupSlot != null) order.scheduledPickupSlot = pickupSlot;
      if (deliveryDate != null) order.scheduledDeliveryDate = deliveryDate;
      if (deliverySlot != null) order.scheduledDeliverySlot = deliverySlot;

      final updated = 'Pickup: ${order.scheduledPickupDate != null ? "${order.scheduledPickupDate!.day}/${order.scheduledPickupDate!.month}" : "Standard"} (${order.scheduledPickupSlot ?? "ASAP"}), Delivery: ${order.scheduledDeliveryDate != null ? "${order.scheduledDeliveryDate!.day}/${order.scheduledDeliveryDate!.month}" : "Standard"} (${order.scheduledDeliverySlot ?? "Standard"})';

      addOrderInternalNote(orderId, 'Rescheduled by ${_currentUser.fullName}: $reason ($updated)');

      logAudit(
        actionType: AuditActionType.orderStatusCorrected,
        entity: 'Order Reschedule',
        entityId: 'Order #${order.orderNumber} ($orderId)',
        previousValue: prev,
        newValue: updated,
        reason: reason,
        countryCode: 'QAT',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  // Create Manual Order (via Call/WhatsApp Customer Service Intake)
  LaundryOrder createManualOrder({
    required String customerName,
    required String customerPhone,
    required CustomerAddress address,
    required List<OrderItem> items,
    required String laundryId,
    required String laundryName,
    DateTime? pickupDate,
    String? pickupSlot,
    DateTime? deliveryDate,
    String? deliverySlot,
    String specialInstructions = '',
    String paymentMethod = 'cash',
    double deliveryFee = 15.0,
    List<String>? tags,
    String? customQrTag,
  }) {
    final nextNumber = (_orders.map((o) => o.orderNumber).fold(10845, (max, n) => n > max ? n : max)) + 1;
    final newOrder = LaundryOrder(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: nextNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      address: address,
      items: items,
      laundryId: laundryId,
      laundryName: laundryName,
      createdAt: DateTime.now(),
      status: OrderStatus.placed,
      deliveryFee: deliveryFee,
      paymentMethod: paymentMethod,
      specialInstructions: specialInstructions,
      scheduledPickupDate: pickupDate,
      scheduledPickupSlot: pickupSlot,
      scheduledDeliveryDate: deliveryDate,
      scheduledDeliverySlot: deliverySlot,
      tags: tags ?? ['TAG-$nextNumber-NEW'],
      customQrTag: customQrTag,
      customerContactNotes: ['Order manually booked via Customer Service by ${_currentUser.fullName} at $nowFormatted.'],
      isCustomerVerified: true,
    );

    _orders.insert(0, newOrder);

    logAudit(
      actionType: AuditActionType.orderStatusCorrected,
      entity: 'Manual Order Created',
      entityId: 'Order #${newOrder.orderNumber} ($customerName)',
      previousValue: 'None',
      newValue: 'Manual order created by CS/Admin with ${items.length} items',
      reason: 'Customer requested order intake via direct phone/WhatsApp channel',
      countryCode: 'QAT',
    );
    notifyListeners();
    return newOrder;
  }

  // Delete / Cancel Order
  bool deleteOrder(String orderId, {required String reason}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final order = _orders[idx];
      order.status = OrderStatus.cancelled;
      order.cancellationRecord = OrderCancellationRecord(
        orderId: order.id,
        cancelledAt: DateTime.now(),
        reason: reason,
        customDescription: 'Cancelled at stage: ${order.workflowStep.displayName}',
        cancelledBy: '${_currentUser.fullName} (${_currentUser.role.title})',
      );

      logAudit(
        actionType: AuditActionType.orderStatusCorrected,
        entity: 'Order Cancelled/Deleted',
        entityId: 'Order #${order.orderNumber} ($orderId)',
        previousValue: 'Active (${order.workflowStep.displayName})',
        newValue: 'Cancelled / Archived by ${_currentUser.fullName}',
        reason: reason,
        countryCode: 'QAT',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  // Add / Edit / Remove Order Garment Tags
  void updateOrderTags(String orderId, List<String> newTags) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final order = _orders[idx];
      final prev = order.tags.join(', ');
      order.tags = List.from(newTags);
      logAudit(
        actionType: AuditActionType.orderStatusCorrected,
        entity: 'Order Tags',
        entityId: 'Order #${order.orderNumber} ($orderId)',
        previousValue: prev.isEmpty ? 'No Tags' : prev,
        newValue: order.tags.join(', '),
        reason: 'Garment and bag tags updated by ${_currentUser.fullName}',
        countryCode: 'QAT',
      );
      notifyListeners();
    }
  }

  // Custom QR Code Tag Override / Regeneration
  void overrideCustomQrTag(String orderId, String? customQr) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final order = _orders[idx];
      final prev = order.qrCodePayload;
      order.customQrTag = customQr;
      logAudit(
        actionType: AuditActionType.qrStateCorrected,
        entity: 'Order QR Tag Code',
        entityId: 'Order #${order.orderNumber} ($orderId)',
        previousValue: prev,
        newValue: order.qrCodePayload,
        reason: 'QR Tag override/regeneration performed by ${_currentUser.fullName}',
        countryCode: 'QAT',
      );
      notifyListeners();
    }
  }

  // Contact Customer & Log Call/WhatsApp Check
  void logCustomerContact(
    String orderId, {
    required String channel,
    required String outcome,
    required String notes,
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final order = _orders[idx];
      final log = '[$nowFormatted via $channel]: $outcome — $notes (Agent: ${_currentUser.fullName})';
      order.customerContactNotes.insert(0, log);
      order.isCustomerVerified = true;
      addOrderInternalNote(orderId, 'Customer verification logged: $log');
      notifyListeners();
    }
  }

  // Order Check & Item Count Verification
  void verifyOrderCheck(String orderId, {required String checkNotes}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final order = _orders[idx];
      order.isCountVerifiedByLaundry = true;
      for (final item in order.items) {
        item.verifiedQuantity = item.quantity;
      }
      addOrderInternalNote(orderId, 'Order verified by ${_currentUser.fullName}: $checkNotes');
      notifyListeners();
    }
  }

  // Customer Service: Send direct message to customer (Live Chat, WhatsApp, Email)
  void sendCustomerDirectMessage(String orderId, {required String channel, required String text, String? recipientEmail}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final ord = _orders[idx];
      final timestampStr = DateFormat('HH:mm').format(DateTime.now());
      ord.customerContactNotes.insert(0, '[$timestampStr via $channel]: $text (Agent: ${_currentUser.fullName})');
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Support Agent (${_currentUser.fullName}) to ${ord.customerName}',
        text: '[$channel • Order #${ord.orderNumber}]: $text',
        timestamp: DateTime.now(),
        isMe: true,
      ));
      logAudit(
        actionType: AuditActionType.orderStatusCorrected,
        entity: 'Customer Communication',
        entityId: 'Order #${ord.orderNumber} (${ord.customerName})',
        previousValue: 'Standby',
        newValue: 'Dispatched via $channel',
        reason: text,
        countryCode: 'QAT',
      );
      notifyListeners();
    }
  }
}


