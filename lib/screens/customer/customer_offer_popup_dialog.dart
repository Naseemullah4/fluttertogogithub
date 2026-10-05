import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/app_popup_offer.dart';
import '../../services/localization_service.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uniwash_logo.dart';

class CustomerOfferPopupDialog extends StatefulWidget {
  final AppPopupOffer offer;
  final VoidCallback? onClaim;

  const CustomerOfferPopupDialog({
    super.key,
    required this.offer,
    this.onClaim,
  });

  static Future<void> show(
    BuildContext context, {
    required AppPopupOffer offer,
    VoidCallback? onClaim,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CustomerOfferPopupDialog(
        offer: offer,
        onClaim: onClaim,
      ),
    );
  }

  @override
  State<CustomerOfferPopupDialog> createState() => _CustomerOfferPopupDialogState();
}

class _CustomerOfferPopupDialogState extends State<CustomerOfferPopupDialog> {
  bool _copied = false;

  void _copyPromoCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('🎉 Promo Code "$code" copied to clipboard!'),
          ],
        ),
        backgroundColor: widget.offer.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = state.currentLanguage == AppLanguage.ar;
    final offer = widget.offer;

    final title = isAr && offer.titleAr.isNotEmpty ? offer.titleAr : offer.title;
    final desc = isAr && offer.descriptionAr.isNotEmpty ? offer.descriptionAr : offer.description;
    final badge = isAr && offer.badgeTextAr.isNotEmpty ? offer.badgeTextAr : offer.badgeText;
    final ctaText = isAr && offer.ctaTextAr.isNotEmpty ? offer.ctaTextAr : offer.ctaText;
    final secondaryText = isAr && offer.secondaryTextAr.isNotEmpty ? offer.secondaryTextAr : offer.secondaryText;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo Header Banner with Gradient Overlay
                  Stack(
                    children: [
                      // Photo Image with Fallback
                      SizedBox(
                        height: 190,
                        width: double.infinity,
                        child: Image.network(
                          offer.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [offer.primaryColor, offer.primaryColor.withValues(alpha: 0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const UniWashLogo.badge(size: 48),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${offer.discountPercent.toStringAsFixed(0)}% OFF PROMOTION',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                        ),
                      ),

                      // Gradient Bottom Vignette on Photo
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 90,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Top Row: Logo Badge & Close (X)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const UniWashLogo.badge(size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${offer.countryFlag} UniWash',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                state.dismissPopupForSession(offer.id);
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Floating Offer Badge on Bottom of Photo
                      Positioned(
                        bottom: 12,
                        left: 14,
                        right: 14,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Color(0xFF78350F),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: offer.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '${offer.discountPercent.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Popup Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Promo Code Voucher Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.local_offer_outlined, color: Color(0xFF16A34A), size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PROMO CODE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF15803D),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    Text(
                                      offer.promoCode,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF166534),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _copied ? const Color(0xFF16A34A) : Colors.white,
                                  foregroundColor: _copied ? Colors.white : const Color(0xFF15803D),
                                  side: BorderSide(color: const Color(0xFF86EFAC)),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _copyPromoCode(offer.promoCode),
                                icon: Icon(_copied ? Icons.check : Icons.copy, size: 14),
                                label: Text(
                                  _copied ? 'Copied!' : 'Copy',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Main Action Button (Claim & Order)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: offer.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 3,
                              shadowColor: offer.primaryColor.withValues(alpha: 0.4),
                            ),
                            onPressed: () {
                              _copyPromoCode(offer.promoCode);
                              state.dismissPopupForSession(offer.id);
                              Navigator.pop(context);
                              if (widget.onClaim != null) {
                                widget.onClaim!();
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  ctaText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Secondary Dismiss Button
                        Center(
                          child: TextButton(
                            onPressed: () {
                              state.dismissPopupForSession(offer.id);
                              Navigator.pop(context);
                            },
                            child: Text(
                              secondaryText,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
