import 'package:flutter/material.dart';
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
      isActive: true,
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
      isActive: true,
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
      isActive: true,
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
      isActive: true,
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
      isActive: true,
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
      isActive: true,
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
      isActive: true,
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
      isActive: true,
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
      isActive: true,
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
      isActive: true,
      isBroadcastPushed: true,
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
      isActive: true,
      isBroadcastPushed: true,
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
      isActive: true,
      isBroadcastPushed: true,
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
      isActive: true,
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
      isActive: true,
      isBroadcastPushed: true,
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
      isActive: true,
      isBroadcastPushed: true,
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
      isActive: true,
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
  final double _customerWalletBalance = 250.0;
  final int _customerLoyaltyPoints = 480;

  String get customerWashPreference => _customerWashPreference;
  String get customerScentPreference => _customerScentPreference;
  String get customerPackagingPreference => _customerPackagingPreference;
  String get customerStarchLevel => _customerStarchLevel;
  double get customerWalletBalance => _customerWalletBalance;
  int get customerLoyaltyPoints => _customerLoyaltyPoints;

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
      status: OrderStatus.placed,
      paymentMethod: 'cash',
      paymentStatus: 'pending',
      createdAt: now.subtract(const Duration(minutes: 25)),
      assignedDriverId: '',
      assignedDriverName: 'Unassigned',
      assignedDriverPhone: '',
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
  }) {
    final orderNumber = 10840 + _orders.length + 1;
    final newOrder = LaundryOrder(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: orderNumber,
      customerName: _currentUser.fullName,
      customerPhone: _currentUser.phone,
      address: _selectedAddress,
      items: List.from(_cart),
      status: OrderStatus.placed,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'cash' ? 'pending' : 'paid',
      specialInstructions: specialInstructions,
      createdAt: DateTime.now(),
      assignedDriverId: 'drv-01',
      assignedDriverName: 'Tariq Al-Mansoor',
      assignedDriverPhone: '+974 5512 8900',
      laundryName: 'UniWash Pearl & Marina Branch',
      laundryId: 'laundry-doha-01',
    );

    _orders.insert(0, newOrder);
    _cart.clear();
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

  // Laundry: Assign Driver (Shifts to Driver's Active Missions Console)
  void assignDriverToOrder(String orderId, DriverModel driver) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx].assignedDriverId = driver.id;
      _orders[idx].assignedDriverName = driver.fullName;
      _orders[idx].assignedDriverPhone = driver.phone;
      _orders[idx].isAcceptedByLaundry = true;
      if (_orders[idx].status == OrderStatus.placed) {
        _orders[idx].status = OrderStatus.driverAssigned;
      }
      _orders[idx].isDriverRideStarted = false;

      // Broadcast alert message to driver
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Dispatch Center',
        text: '📦 New Order Mission #${_orders[idx].orderNumber} assigned to you (${driver.fullName}) by Laundry. Check your active route!',
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
}

