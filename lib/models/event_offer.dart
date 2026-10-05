import 'package:flutter/material.dart';

class EventOffer {
  final String id;
  String title;
  String titleAr;
  String eventType; // 'ramadan', 'eid', 'christmas', 'national_day', 'summer', 'school', 'big_deal', 'custom'
  String iconEmoji;
  String countryCode; // 'ALL' or 'QAT', 'UAE', 'KSA', etc.
  String countryFlag; // '🇶🇦', '🇦🇪', '🇸🇦', '🌐', etc.
  double discountPercent;
  String promoCode;
  String description;
  String descriptionAr;
  Color bannerColor;
  bool isActive;
  DateTime validFrom;
  DateTime validUntil;

  EventOffer({
    required this.id,
    required this.title,
    this.titleAr = '',
    required this.eventType,
    required this.iconEmoji,
    required this.countryCode,
    required this.countryFlag,
    required this.discountPercent,
    required this.promoCode,
    required this.description,
    this.descriptionAr = '',
    this.bannerColor = const Color(0xFF0F766E),
    this.isActive = true,
    required this.validFrom,
    required this.validUntil,
  }) {
    if (titleAr.isEmpty) titleAr = title;
    if (descriptionAr.isEmpty) descriptionAr = description;
  }

  EventOffer copyWith({
    String? id,
    String? title,
    String? titleAr,
    String? eventType,
    String? iconEmoji,
    String? countryCode,
    String? countryFlag,
    double? discountPercent,
    String? promoCode,
    String? description,
    String? descriptionAr,
    Color? bannerColor,
    bool? isActive,
    DateTime? validFrom,
    DateTime? validUntil,
  }) {
    return EventOffer(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      eventType: eventType ?? this.eventType,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      countryCode: countryCode ?? this.countryCode,
      countryFlag: countryFlag ?? this.countryFlag,
      discountPercent: discountPercent ?? this.discountPercent,
      promoCode: promoCode ?? this.promoCode,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      bannerColor: bannerColor ?? this.bannerColor,
      isActive: isActive ?? this.isActive,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
    );
  }
}
