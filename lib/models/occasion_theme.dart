import 'package:flutter/material.dart';

class OccasionTheme {
  final String id;
  final String name;
  final String nameAr;
  final String iconEmoji;
  final String countryCode; // 'ALL' or specific country 'QAT', 'UAE', 'GBR', 'USA', 'PAK'
  final Color primaryColor;
  final Color primaryLightColor;
  final Color primaryDarkColor;
  final Color accentColor;
  final Color surfaceColor;
  final Color backgroundColor;
  final String greetingBanner;
  final String greetingBannerAr;
  final bool isDark;

  const OccasionTheme({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.iconEmoji,
    this.countryCode = 'ALL',
    required this.primaryColor,
    required this.primaryLightColor,
    required this.primaryDarkColor,
    required this.accentColor,
    this.surfaceColor = Colors.white,
    this.backgroundColor = const Color(0xFFF8FAFC),
    required this.greetingBanner,
    required this.greetingBannerAr,
    this.isDark = false,
  });

  static const OccasionTheme defaultEmerald = OccasionTheme(
    id: 'theme_default',
    name: 'UniWash Royal Teal (Default)',
    nameAr: 'العلامة الملكية الفيروزية (الافتراضي)',
    iconEmoji: '💎',
    countryCode: 'ALL',
    primaryColor: Color(0xFF0F766E),
    primaryLightColor: Color(0xFF14B8A6),
    primaryDarkColor: Color(0xFF115E59),
    accentColor: Color(0xFF0284C7),
    greetingBanner: 'Premium Doorstep Laundry & Form Pressing',
    greetingBannerAr: 'خدمات الغسيل والكوي بالبخار الفاخرة حتى باب منزلك',
  );

  static const OccasionTheme ramadan = OccasionTheme(
    id: 'theme_ramadan',
    name: 'Ramadan Kareem 🌙',
    nameAr: 'رمضان كريم 🌙',
    iconEmoji: '🌙',
    countryCode: 'ALL',
    primaryColor: Color(0xFF064E3B), // Deep Emerald Crescent
    primaryLightColor: Color(0xFF047857),
    primaryDarkColor: Color(0xFF022C22),
    accentColor: Color(0xFFF59E0B), // Golden Lantern
    greetingBanner: 'Ramadan Mubarak! Blessings, peace & pristine traditional garments.',
    greetingBannerAr: 'رمضان مبارك! تقبل الله طاعاتكم وملابس ناصعة البياض لكافة الصلوات.',
  );

  static const OccasionTheme eid = OccasionTheme(
    id: 'theme_eid',
    name: 'Eid Mubarak Celebration ✨',
    nameAr: 'عيد مبارك وسعيد ✨',
    iconEmoji: '✨',
    countryCode: 'ALL',
    primaryColor: Color(0xFF581C87), // Royal Festive Violet
    primaryLightColor: Color(0xFF7E22CE),
    primaryDarkColor: Color(0xFF3B0764),
    accentColor: Color(0xFFEAB308), // Sparkling Gold
    greetingBanner: 'Eid Mubarak! Step out in sparkling elegance and fresh crisp thobes.',
    greetingBannerAr: 'عيدكم مبارك وكل عام وأنتم بخير! تألقوا بأفخم الثياب المكوية بأعلى عناية.',
  );

  static const OccasionTheme christmas = OccasionTheme(
    id: 'theme_christmas',
    name: 'Christmas & Winter Holiday 🎄',
    nameAr: 'موسم الأعياد ورأس السنة 🎄',
    iconEmoji: '🎄',
    countryCode: 'ALL',
    primaryColor: Color(0xFF991B1B), // Festive Crimson Red
    primaryLightColor: Color(0xFFDC2626),
    primaryDarkColor: Color(0xFF7F1D1D),
    accentColor: Color(0xFF15803D), // Pine Forest Green
    greetingBanner: 'Season’s Greetings! Fresh coats, festive suits & spotless holiday linens.',
    greetingBannerAr: 'أجمل التهاني بموسم الأعياد! تنظيف جاف فاخر للمعاطف والملابس الشتوية.',
  );

  static const OccasionTheme qatarNationalDay = OccasionTheme(
    id: 'theme_qatar_national_day',
    name: 'Qatar National Day 🇶🇦',
    nameAr: 'اليوم الوطني لدولة قطر 🇶🇦',
    iconEmoji: '🇶🇦',
    countryCode: 'QAT',
    primaryColor: Color(0xFF800020), // Royal Maroon (Al Adaam)
    primaryLightColor: Color(0xFF9A1B36),
    primaryDarkColor: Color(0xFF580016),
    accentColor: Color(0xFFD4AF37), // Metallic Gold
    greetingBanner: 'Happy Qatar National Day! Celebrating unity, pride and royal white thobes.',
    greetingBannerAr: 'اليوم الوطني لدولة قطر! نحتفل بالمجد والعزة وأرقى خدمات الكوي للثوب القطري.',
  );

  static const OccasionTheme uaeNationalDay = OccasionTheme(
    id: 'theme_uae_national_day',
    name: 'UAE National Day 🇦🇪',
    nameAr: 'اليوم الوطني الإماراتي 🇦🇪',
    iconEmoji: '🇦🇪',
    countryCode: 'UAE',
    primaryColor: Color(0xFF047857), // Pan-Arab Green
    primaryLightColor: Color(0xFF059669),
    primaryDarkColor: Color(0xFF064E3B),
    accentColor: Color(0xFFDC2626), // Pan-Arab Red
    greetingBanner: 'Happy UAE National Day! Spirit of the Union and spotless Kanduras.',
    greetingBannerAr: 'عاش اتحاد إماراتنا! عناية فائقة بالكندورة والعبايات الفاخرة.',
  );

  static const OccasionTheme ukNational = OccasionTheme(
    id: 'theme_uk_national',
    name: 'United Kingdom Royal Blue 🇬🇧',
    nameAr: 'المملكة المتحدة واليوبيل الملكي 🇬🇧',
    iconEmoji: '🇬🇧',
    countryCode: 'GBR',
    primaryColor: Color(0xFF1E3A8A), // Royal British Navy
    primaryLightColor: Color(0xFF2563EB),
    primaryDarkColor: Color(0xFF172554),
    accentColor: Color(0xFFDC2626), // St George Crimson Red
    greetingBanner: 'Great British Laundry Craftsmanship & Mayfair Garment Care.',
    greetingBannerAr: 'خدمات الغسيل الملكية البريطانية الفاخرة والعناية بأرقى الأقمشة.',
  );

  static const OccasionTheme usNational = OccasionTheme(
    id: 'theme_us_national',
    name: 'United States 4th of July / Patriotic 🇺🇸',
    nameAr: 'الولايات المتحدة ويوم الاستقلال 🇺🇸',
    iconEmoji: '🇺🇸',
    countryCode: 'USA',
    primaryColor: Color(0xFF1D4ED8), // American Blue
    primaryLightColor: Color(0xFF3B82F6),
    primaryDarkColor: Color(0xFF1E40AF),
    accentColor: Color(0xFFB91C1C), // Liberty Red
    greetingBanner: '4th of July & Everyday Premium American Doorstep Dry Cleaning.',
    greetingBannerAr: 'خدمات التنظيف الجاف الأمريكية الفائقة والتوصيل حتى الباب.',
  );

  static const OccasionTheme pakistanNational = OccasionTheme(
    id: 'theme_pakistan_national',
    name: 'Pakistan Independence / National Green 🇵🇰',
    nameAr: 'يوم الاستقلال الباكستاني 🇵🇰',
    iconEmoji: '🇵🇰',
    countryCode: 'PAK',
    primaryColor: Color(0xFF0F5132), // Crescent Green
    primaryLightColor: Color(0xFF198754),
    primaryDarkColor: Color(0xFF0A3622),
    accentColor: Color(0xFFFACC15), // Star Gold
    greetingBanner: 'Azadi Mubarak! Immaculate Shalwar Kameez and festive fabric care.',
    greetingBannerAr: 'يوم استقلال مبارك! غسيل وكوي مميز للزي التقليدي بأعلى جودة.',
  );

  static const OccasionTheme blackDay = OccasionTheme(
    id: 'theme_black_day',
    name: 'Black Day / Solemn Mourning 🖤',
    nameAr: 'يوم الحداد الوطني والوقار 🖤',
    iconEmoji: '🖤',
    countryCode: 'ALL',
    primaryColor: Color(0xFF18181B), // Solemn Black / Zinc
    primaryLightColor: Color(0xFF27272A),
    primaryDarkColor: Color(0xFF09090B),
    accentColor: Color(0xFF71717A), // Muted Silver
    greetingBanner: 'In Solemn Remembrance & Respect. Operations continue with dignity.',
    greetingBannerAr: 'في ذكرى الوقار والحداد. تستمر خدماتنا بمسؤولية واحترام تام.',
    isDark: true,
  );

  static List<OccasionTheme> get presetThemes => [
    defaultEmerald,
    ramadan,
    eid,
    christmas,
    qatarNationalDay,
    uaeNationalDay,
    ukNational,
    usNational,
    pakistanNational,
    blackDay,
  ];
}
