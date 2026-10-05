enum PricingUnit {
  piece,
  kg,
}

extension PricingUnitExtension on PricingUnit {
  String get displayName => this == PricingUnit.kg ? 'Per KG (Weight)' : 'Per Item (Piece)';
  String get shortLabel => this == PricingUnit.kg ? '/kg' : '/item';
  String get unitName => this == PricingUnit.kg ? 'KG' : 'Pcs';
}

class CatalogItem {
  final String id;
  String category;
  String categoryAr;
  String itemName;
  String itemNameAr;
  double basePriceQar;
  String icon;
  String description;
  String descriptionAr;
  PricingUnit pricingUnit;
  double saleDiscountPercent; // e.g. 20 for 20% off
  String? specialOfferTag; // e.g. "HOT DEAL", "RAMADAN 50% OFF", "WEEKEND SPECIAL"

  CatalogItem({
    required this.id,
    required this.category,
    this.categoryAr = '',
    required this.itemName,
    this.itemNameAr = '',
    required this.basePriceQar,
    required this.icon,
    this.description = '',
    this.descriptionAr = '',
    this.pricingUnit = PricingUnit.piece,
    this.saleDiscountPercent = 0.0,
    this.specialOfferTag,
  }) {
    if (categoryAr.isEmpty) categoryAr = category;
    if (itemNameAr.isEmpty) itemNameAr = itemName;
  }


  bool get isOnSale => saleDiscountPercent > 0;
  bool get hasSpecialOffer => specialOfferTag != null && specialOfferTag!.trim().isNotEmpty;

  /// Effective price after applying Super Admin sale discount
  double get effectivePriceQar {
    if (saleDiscountPercent <= 0) return basePriceQar;
    final discounted = basePriceQar * (1.0 - (saleDiscountPercent / 100.0));
    return (discounted * 10).roundToDouble() / 10; // 1 decimal place
  }

  CatalogItem copyWith({
    String? id,
    String? category,
    String? itemName,
    double? basePriceQar,
    String? icon,
    String? description,
    PricingUnit? pricingUnit,
    double? saleDiscountPercent,
    String? specialOfferTag,
  }) {
    return CatalogItem(
      id: id ?? this.id,
      category: category ?? this.category,
      itemName: itemName ?? this.itemName,
      basePriceQar: basePriceQar ?? this.basePriceQar,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      pricingUnit: pricingUnit ?? this.pricingUnit,
      saleDiscountPercent: saleDiscountPercent ?? this.saleDiscountPercent,
      specialOfferTag: specialOfferTag ?? this.specialOfferTag,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'itemName': itemName,
      'basePriceQar': basePriceQar,
      'icon': icon,
      'description': description,
      'pricingUnit': pricingUnit.name,
      'saleDiscountPercent': saleDiscountPercent,
      'specialOfferTag': specialOfferTag,
    };
  }

  factory CatalogItem.fromMap(Map<String, dynamic> map) {
    return CatalogItem(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      itemName: map['itemName'] ?? '',
      basePriceQar: (map['basePriceQar'] as num).toDouble(),
      icon: map['icon'] ?? '👕',
      description: map['description'] ?? '',
      pricingUnit: map['pricingUnit'] == 'kg' ? PricingUnit.kg : PricingUnit.piece,
      saleDiscountPercent: (map['saleDiscountPercent'] as num?)?.toDouble() ?? 0.0,
      specialOfferTag: map['specialOfferTag'],
    );
  }
}
