import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/advertisement.dart';
import '../../models/event_offer.dart';
import '../../services/localization_service.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import 'referral_screen.dart';
import 'customer_offer_popup_dialog.dart';
import '../../widgets/uniwash_logo.dart';

class CustomerOffersTab extends StatelessWidget {
  final VoidCallback onOrderNow;

  const CustomerOffersTab({super.key, required this.onOrderNow});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = state.currentLanguage == AppLanguage.ar;
    final offers = state.activeEventOffers;
    final ads = state.activeAdvertisements;
    final theme = state.currentOccasionTheme;
    final country = state.selectedCountry;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Occasion Festive Ribbon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.primaryDarkColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const UniWashLogo.badge(size: 32),
                  const SizedBox(width: 10),
                  Text(theme.iconEmoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? theme.nameAr : theme.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                        Text(
                          isAr ? theme.greetingBannerAr : theme.greetingBanner,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${country.flag} ${country.code}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Active Customer Popup Offer Card
            if (state.activePopupOffer != null && state.activePopupOffer!.isActive) ...[
              Builder(
                builder: (context) {
                  final popup = state.activePopupOffer!;
                  return InkWell(
                    onTap: () => CustomerOfferPopupDialog.show(context, offer: popup),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: popup.primaryColor.withValues(alpha: 0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: popup.primaryColor.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  height: 110,
                                  width: double.infinity,
                                  child: Image.network(
                                    popup.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: popup.primaryColor,
                                      child: Center(
                                        child: Text(
                                          '${popup.discountPercent.toStringAsFixed(0)}% OFF PROMO',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isAr && popup.badgeTextAr.isNotEmpty ? popup.badgeTextAr : popup.badgeText,
                                      style: const TextStyle(
                                        color: Color(0xFF78350F),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: popup.primaryColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${popup.discountPercent.toStringAsFixed(0)}% OFF',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isAr && popup.titleAr.isNotEmpty ? popup.titleAr : popup.title,
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isAr && popup.descriptionAr.isNotEmpty ? popup.descriptionAr : popup.description,
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: popup.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => CustomerOfferPopupDialog.show(context, offer: popup),
                                    child: Text(
                                      isAr ? 'عرض العرض' : 'View Popup',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
            ],

            // Section: Official Promotional Advertisements & Broadcasts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('📢', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'الإعلانات وبث العروض الرسمية' : 'Promotional Advertisements & Broadcasts',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ads.length} Live Ads',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (ads.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    isAr ? 'لا توجد إعلانات نشطة لهذا الإقليم حالياً' : 'No active regional ads for this territory right now.',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              )
            else
              ...ads.map((ad) => _buildAdCard(context, state, ad, isAr)),

            const SizedBox(height: 24),

            // Section: Regional Event & Seasonal Offers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'عروض المناسبات والأعياد' : 'Regional Event & Holiday Offers',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Text(
                  '${offers.length} Offers in ${country.name}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (offers.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    isAr ? 'لا توجد عروض موسمية نشطة لهذا الإقليم' : 'No seasonal event offers active for this territory right now.',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              )
            else
              ...offers.map((offer) => _buildOfferCard(context, state, offer, isAr)),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAdCard(BuildContext context, StateService state, Advertisement ad, bool isAr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ad.isBroadcastPushed ? Colors.amber.shade400 : AppColors.border,
          width: ad.isBroadcastPushed ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Top Gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ad.primaryColor, ad.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(ad.graphicEmoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ad.isBroadcastPushed)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade400,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '📢 OFFICIAL BROADCAST',
                              style: TextStyle(color: Colors.black87, fontSize: 9, fontWeight: FontWeight.w900),
                            ),
                          ),
                        Text(
                          isAr && ad.titleAr.isNotEmpty ? ad.titleAr : ad.title,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(ad.countryFlag, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          ad.countryCode,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Message Body & CTA
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr && ad.messageAr.isNotEmpty ? ad.messageAr : ad.message,
                    style: const TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ends: ${DateFormat('dd MMM yyyy').format(ad.validUntil)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ad.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (ad.ctaLink == 'referral') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen()));
                          } else {
                            onOrderNow();
                          }
                        },
                        child: Text(
                          isAr ? ad.ctaTextAr : ad.ctaText,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, StateService state, EventOffer offer, bool isAr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Top
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: offer.bannerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Text(offer.iconEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? offer.titleAr : offer.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      Text(
                        '${offer.discountPercent.toStringAsFixed(0)}% DISCOUNT • Code: ${offer.promoCode}',
                        style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${offer.countryFlag} ${offer.countryCode}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Body & Copy Code
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? offer.descriptionAr : offer.description,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Valid until ${DateFormat('dd MMM').format(offer.validUntil)}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: offer.bannerColor,
                    side: BorderSide(color: offer.bannerColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: offer.promoCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Promo Code "${offer.promoCode}" copied to clipboard!'),
                        backgroundColor: offer.bannerColor,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 14),
                  label: Text(offer.promoCode, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
