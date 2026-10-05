import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable UniWash Official Brand Logo Widget
class UniWashLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;
  final BoxFit fit;
  final bool isCircle;
  final bool showBorder;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const UniWashLogo({
    super.key,
    this.width,
    this.height,
    this.size,
    this.fit = BoxFit.contain,
    this.isCircle = false,
    this.showBorder = true,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = 10,
    this.padding,
    this.onTap,
  });

  /// Circular emblem badge (e.g. for AppBars, dialogs, user headers)
  const UniWashLogo.badge({
    super.key,
    this.size = 36,
    this.showBorder = true,
    this.borderColor,
    this.backgroundColor = Colors.black,
    this.onTap,
  })  : width = size,
        height = size,
        fit = BoxFit.cover,
        isCircle = true,
        borderRadius = 999,
        padding = EdgeInsets.zero;

  /// Full rectangular banner with both medallion & typography
  const UniWashLogo.banner({
    super.key,
    this.width,
    this.height = 48,
    this.size,
    this.borderRadius = 8,
    this.showBorder = true,
    this.borderColor,
    this.backgroundColor = Colors.black,
    this.onTap,
  })  : isCircle = false,
        fit = BoxFit.contain,
        padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2);

  @override
  Widget build(BuildContext context) {
    final effectiveW = width ?? size;
    final effectiveH = height ?? size;
    final effectiveBorderColor = borderColor ?? const Color(0xFFD4AF37).withValues(alpha: 0.6); // Gold metallic

    Widget logoImage = Image.asset(
      'assets/images/uniwash_logo.jpg',
      fit: fit,
      width: effectiveW,
      height: effectiveH,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: effectiveW,
          height: effectiveH,
          color: Colors.black,
          child: const Center(
            child: Icon(Icons.local_laundry_service, color: Color(0xFFD4AF37), size: 20),
          ),
        );
      },
    );

    Widget content = Container(
      width: effectiveW,
      height: effectiveH,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: effectiveBorderColor,
                width: 1.2,
              )
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                  blurRadius: 6,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: isCircle
            ? BorderRadius.circular(effectiveH != null ? effectiveH / 2 : 100)
            : BorderRadius.circular(borderRadius - 1),
        child: logoImage,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isCircle ? 999 : borderRadius),
        child: content,
      );
    }

    return content;
  }
}

/// Official UniWash Brand Title Header with Logo Badge and Subtext
class UniWashBrandHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isDark;
  final double logoSize;

  const UniWashBrandHeader({
    super.key,
    this.title = 'UniWash Laundry',
    this.subtitle = '24/7 Professional Laundry & Dry Cleaning',
    this.isDark = false,
    this.logoSize = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        UniWashLogo.badge(size: logoSize),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.3,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : AppColors.textMuted,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
