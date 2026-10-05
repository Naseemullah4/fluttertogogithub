import 'catalog_item.dart';

enum ServiceType {
  washIron,
  ironOnly,
  dryClean,
  onlyWash,
}

extension ServiceTypeExtension on ServiceType {
  String get displayName {
    switch (this) {
      case ServiceType.washIron:
        return 'Wash & Iron';
      case ServiceType.ironOnly:
        return 'Iron Only';
      case ServiceType.dryClean:
        return 'Dry Clean';
      case ServiceType.onlyWash:
        return 'Only Wash';
    }
  }

  String get code {
    switch (this) {
      case ServiceType.washIron:
        return 'iron_wash';
      case ServiceType.ironOnly:
        return 'iron_only';
      case ServiceType.dryClean:
        return 'dry_clean';
      case ServiceType.onlyWash:
        return 'only_wash';
    }
  }

  double get priceMultiplier {
    switch (this) {
      case ServiceType.washIron:
        return 1.0;
      case ServiceType.ironOnly:
        return 0.75;
      case ServiceType.dryClean:
        return 1.25;
      case ServiceType.onlyWash:
        return 0.70;
    }
  }
}

class OrderItem {
  final CatalogItem catalogItem;
  ServiceType serviceType;
  double quantityOrWeight; // Either count of items (1, 2, 3) or weight in KG (1.5, 3.0)
  double? verifiedQuantityOrWeight; // Set by laundry staff during manual count
  String notes;

  OrderItem({
    required this.catalogItem,
    this.serviceType = ServiceType.washIron,
    double? quantityOrWeight,
    int? quantity,
    double? verifiedQuantityOrWeight,
    int? verifiedQuantity,
    this.notes = '',
  })  : quantityOrWeight = quantityOrWeight ?? (quantity != null ? quantity.toDouble() : 1.0),
        verifiedQuantityOrWeight = verifiedQuantityOrWeight ?? verifiedQuantity?.toDouble();

  // Backward compatibility getter for int quantity
  int get quantity => quantityOrWeight.round();
  set quantity(int val) => quantityOrWeight = val.toDouble();

  int? get verifiedQuantity => verifiedQuantityOrWeight?.round();
  set verifiedQuantity(int? val) => verifiedQuantityOrWeight = val?.toDouble();

  // Unit price uses the effective sale price set by Super Admin!
  double get unitPrice => (catalogItem.effectivePriceQar * serviceType.priceMultiplier).roundToDouble();

  // Effective total uses verified or requested count/weight
  double get effectiveTotal => unitPrice * (verifiedQuantityOrWeight ?? quantityOrWeight);

  String get quantityFormatted {
    if (catalogItem.pricingUnit == PricingUnit.kg) {
      return '${(verifiedQuantityOrWeight ?? quantityOrWeight).toStringAsFixed(1)} KG';
    } else {
      return '${(verifiedQuantityOrWeight ?? quantityOrWeight).round()} Pcs';
    }
  }

  OrderItem copyWith({
    CatalogItem? catalogItem,
    ServiceType? serviceType,
    double? quantityOrWeight,
    double? verifiedQuantityOrWeight,
    String? notes,
  }) {
    return OrderItem(
      catalogItem: catalogItem ?? this.catalogItem,
      serviceType: serviceType ?? this.serviceType,
      quantityOrWeight: quantityOrWeight ?? this.quantityOrWeight,
      verifiedQuantityOrWeight: verifiedQuantityOrWeight ?? this.verifiedQuantityOrWeight,
      notes: notes ?? this.notes,
    );
  }
}
