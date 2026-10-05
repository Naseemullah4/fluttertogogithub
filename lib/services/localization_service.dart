
enum AppLanguage {
  en,
  ar,
}

class CountryConfig {
  final String code;
  final String name;
  final String nameAr;
  final String flag;
  final String currencyCode;
  final String currencySymbol;
  final String currencySymbolAr;
  final double exchangeRateToQar; // For multi-currency dynamic calculations

  const CountryConfig({
    required this.code,
    required this.name,
    required this.nameAr,
    required this.flag,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencySymbolAr,
    this.exchangeRateToQar = 1.0,
  });
}

class LocalizationService {
  static const CountryConfig defaultCountry = CountryConfig(
    code: 'QAT',
    name: 'Qatar',
    nameAr: 'قطر',
    flag: '🇶🇦',
    currencyCode: 'QAR',
    currencySymbol: 'QAR',
    currencySymbolAr: 'ر.ق',
    exchangeRateToQar: 1.0,
  );

  static CountryConfig getCountry(String? code) {
    if (code == null) return defaultCountry;
    return countries[code] ?? defaultCountry;
  }

  static const Map<String, CountryConfig> countries = {
    'QAT': defaultCountry,
    'UAE': CountryConfig(
      code: 'UAE',
      name: 'United Arab Emirates',
      nameAr: 'الإمارات العربية المتحدة',
      flag: '🇦🇪',
      currencyCode: 'AED',
      currencySymbol: 'AED',
      currencySymbolAr: 'د.إ',
      exchangeRateToQar: 1.01,
    ),
    'KSA': CountryConfig(
      code: 'KSA',
      name: 'Saudi Arabia',
      nameAr: 'المملكة العربية السعودية',
      flag: '🇸🇦',
      currencyCode: 'SAR',
      currencySymbol: 'SAR',
      currencySymbolAr: 'ر.س',
      exchangeRateToQar: 1.03,
    ),
    'KWT': CountryConfig(
      code: 'KWT',
      name: 'Kuwait',
      nameAr: 'الكويت',
      flag: '🇰🇼',
      currencyCode: 'KWD',
      currencySymbol: 'KWD',
      currencySymbolAr: 'د.ك',
      exchangeRateToQar: 0.084,
    ),
    'OMN': CountryConfig(
      code: 'OMN',
      name: 'Oman',
      nameAr: 'سلطنة عمان',
      flag: '🇴🇲',
      currencyCode: 'OMR',
      currencySymbol: 'OMR',
      currencySymbolAr: 'ر.ع',
      exchangeRateToQar: 0.106,
    ),
    'BHR': CountryConfig(
      code: 'BHR',
      name: 'Bahrain',
      nameAr: 'البحرين',
      flag: '🇧🇭',
      currencyCode: 'BHD',
      currencySymbol: 'BHD',
      currencySymbolAr: 'د.ب',
      exchangeRateToQar: 0.104,
    ),
    'GBR': CountryConfig(
      code: 'GBR',
      name: 'United Kingdom',
      nameAr: 'المملكة المتحدة',
      flag: '🇬🇧',
      currencyCode: 'GBP',
      currencySymbol: '£',
      currencySymbolAr: 'جنيه',
      exchangeRateToQar: 0.21,
    ),
    'USA': CountryConfig(
      code: 'USA',
      name: 'United States',
      nameAr: 'الولايات المتحدة',
      flag: '🇺🇸',
      currencyCode: 'USD',
      currencySymbol: '\$',
      currencySymbolAr: 'دولار',
      exchangeRateToQar: 0.27,
    ),
    'CAN': CountryConfig(
      code: 'CAN',
      name: 'Canada',
      nameAr: 'كندا',
      flag: '🇨🇦',
      currencyCode: 'CAD',
      currencySymbol: 'C\$',
      currencySymbolAr: 'د.كندي',
      exchangeRateToQar: 0.38,
    ),
    'EUR': CountryConfig(
      code: 'EUR',
      name: 'Europe (EU)',
      nameAr: 'الاتحاد الأوروبي',
      flag: '🇪🇺',
      currencyCode: 'EUR',
      currencySymbol: '€',
      currencySymbolAr: 'يورو',
      exchangeRateToQar: 0.25,
    ),
    'SGP': CountryConfig(
      code: 'SGP',
      name: 'Singapore',
      nameAr: 'سنغافورة',
      flag: '🇸🇬',
      currencyCode: 'SGD',
      currencySymbol: 'S\$',
      currencySymbolAr: 'د.سنغافوري',
      exchangeRateToQar: 0.36,
    ),
    'MYS': CountryConfig(
      code: 'MYS',
      name: 'Malaysia',
      nameAr: 'ماليزيا',
      flag: '🇲🇾',
      currencyCode: 'MYR',
      currencySymbol: 'RM',
      currencySymbolAr: 'رنجت',
      exchangeRateToQar: 1.22,
    ),
    'PAK': CountryConfig(
      code: 'PAK',
      name: 'Pakistan',
      nameAr: 'باكستان',
      flag: '🇵🇰',
      currencyCode: 'PKR',
      currencySymbol: 'PKR',
      currencySymbolAr: 'روبية',
      exchangeRateToQar: 76.5,
    ),
    'IND': CountryConfig(
      code: 'IND',
      name: 'India',
      nameAr: 'الهند',
      flag: '🇮🇳',
      currencyCode: 'INR',
      currencySymbol: '₹',
      currencySymbolAr: 'روبية هندي',
      exchangeRateToQar: 23.4,
    ),
    'ZAF': CountryConfig(
      code: 'ZAF',
      name: 'South Africa',
      nameAr: 'جنوب إفريقيا',
      flag: '🇿🇦',
      currencyCode: 'ZAR',
      currencySymbol: 'R',
      currencySymbolAr: 'راند',
      exchangeRateToQar: 4.85,
    ),
  };

  // Dual-language translations map for Arabic & English
  static const Map<String, Map<String, String>> translations = {
    'app_title': {
      'en': 'UniWash Laundry & Dry Cleaning',
      'ar': 'يوني واش لغسيل الملابس والتنظيف الجاف',
    },
    'deliver_to': {
      'en': 'Deliver to',
      'ar': 'التوصيل إلى',
    },
    'search_hint': {
      'en': 'Search by order #, phone, customer name, garments...',
      'ar': 'ابحث برقم الطلب، الهاتف، اسم العميل، الملابس...',
    },
    'per_item': {
      'en': 'Per Item',
      'ar': 'بالقطعة',
    },
    'per_kg': {
      'en': 'Per KG',
      'ar': 'بالكيلوغرام',
    },
    'sale': {
      'en': 'SALE',
      'ar': 'تخفيض',
    },
    'basket': {
      'en': 'Basket',
      'ar': 'السلة',
    },
    'total': {
      'en': 'Total Amount',
      'ar': 'المبلغ الإجمالي',
    },
    'order_status': {
      'en': 'Order Status',
      'ar': 'حالة الطلب',
    },
    'placed': {
      'en': 'Order Placed',
      'ar': 'تم تقديم الطلب',
    },
    'driver_assigned': {
      'en': 'Driver En-Route for Pickup',
      'ar': 'السائق في الطريق للاستلام',
    },
    'picked_up': {
      'en': 'Picked Up & In Laundry',
      'ar': 'تم الاستلام وفي المصبغة',
    },
    'washing': {
      'en': 'In Washing & Pressing',
      'ar': 'جاري الغسيل والكي',
    },
    'ready': {
      'en': 'Order Ready for Delivery',
      'ar': 'الطلب جاهز للتسليم',
    },
    'out_for_delivery': {
      'en': 'Out for Delivery',
      'ar': 'الطلب في طريق التوصيل',
    },
    'delivered': {
      'en': 'Delivered',
      'ar': 'تم التسليم بنجاح',
    },
  };

  static String tr(String key, AppLanguage lang) {
    return translations[key]?[lang.name] ?? key;
  }
}
