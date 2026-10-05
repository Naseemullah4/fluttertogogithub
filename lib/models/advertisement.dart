import 'package:flutter/material.dart';

enum AdBannerType {
  graphicBanner,
  inAppPopup,
  announcementTicker,
  carouselSlide,
}

class Advertisement {
  final String id;
  String title;
  String titleAr;
  String message;
  String messageAr;
  AdBannerType bannerType;
  String graphicPreset; // 'dress_promo', 'suit_luxury', 'thobe_care', 'shoes_clean', 'express_van', 'eco_green', 'carpet_curtain'
  String graphicEmoji;
  String countryCode; // 'ALL' or 'QAT', 'UAE', 'KSA', 'GBR', 'USA', 'PAK'
  String countryFlag;
  String ctaText;
  String ctaTextAr;
  String ctaLink; // 'catalog', 'referral', 'express', 'support'
  Color primaryColor;
  Color secondaryColor;
  bool isActive;
  bool isBroadcastPushed;
  DateTime createdAt;
  DateTime validUntil;

  Advertisement({
    required this.id,
    required this.title,
    this.titleAr = '',
    required this.message,
    this.messageAr = '',
    this.bannerType = AdBannerType.graphicBanner,
    this.graphicPreset = 'thobe_care',
    this.graphicEmoji = '✨',
    required this.countryCode,
    required this.countryFlag,
    this.ctaText = 'Order Now',
    this.ctaTextAr = 'اطلب الآن',
    this.ctaLink = 'catalog',
    this.primaryColor = const Color(0xFF0F766E),
    this.secondaryColor = const Color(0xFF14B8A6),
    this.isActive = true,
    this.isBroadcastPushed = false,
    required this.createdAt,
    required this.validUntil,
  }) {
    if (titleAr.isEmpty) titleAr = title;
    if (messageAr.isEmpty) messageAr = message;
    if (ctaTextAr.isEmpty) ctaTextAr = ctaText;
  }

  Advertisement copyWith({
    String? id,
    String? title,
    String? titleAr,
    String? message,
    String? messageAr,
    AdBannerType? bannerType,
    String? graphicPreset,
    String? graphicEmoji,
    String? countryCode,
    String? countryFlag,
    String? ctaText,
    String? ctaTextAr,
    String? ctaLink,
    Color? primaryColor,
    Color? secondaryColor,
    bool? isActive,
    bool? isBroadcastPushed,
    DateTime? createdAt,
    DateTime? validUntil,
  }) {
    return Advertisement(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      message: message ?? this.message,
      messageAr: messageAr ?? this.messageAr,
      bannerType: bannerType ?? this.bannerType,
      graphicPreset: graphicPreset ?? this.graphicPreset,
      graphicEmoji: graphicEmoji ?? this.graphicEmoji,
      countryCode: countryCode ?? this.countryCode,
      countryFlag: countryFlag ?? this.countryFlag,
      ctaText: ctaText ?? this.ctaText,
      ctaTextAr: ctaTextAr ?? this.ctaTextAr,
      ctaLink: ctaLink ?? this.ctaLink,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      isActive: isActive ?? this.isActive,
      isBroadcastPushed: isBroadcastPushed ?? this.isBroadcastPushed,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
    );
  }
}
