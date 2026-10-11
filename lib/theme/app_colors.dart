import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary (Executive Oceanic Sapphire & Royal Teal)
  static const Color primary = Color(0xFF0369A1); // Refined Executive Sapphire
  static const Color primaryLight = Color(0xFF0EA5E9); // Modern Sky Azure
  static const Color primaryDark = Color(0xFF0C4A6E); // Deep Navy Slate
  static const Color accent = Color(0xFF0284C7); // Vibrant Blue Accent

  // Secondary & Luxury Accents
  static const Color secondary = Color(0xFF4F46E5); // Royal Indigo
  static const Color secondaryLight = Color(0xFF6366F1);
  static const Color gold = Color(0xFFD97706);
  static const Color goldLight = Color(0xFFFBBF24);

  // Status & Escalation Colors (Crisp, High Contrast)
  static const Color statusPlaced = Color(0xFF64748B);
  static const Color statusDriver = Color(0xFF0284C7);
  static const Color statusLaundry = Color(0xFF7C3AED);
  static const Color statusProcessing = Color(0xFFD97706);
  static const Color statusReady = Color(0xFF059669);
  static const Color statusDelivery = Color(0xFF2563EB);
  static const Color statusDelivered = Color(0xFF16A34A);

  // Warning & Alert Levels
  static const Color warnLightYellow = Color(0xFFFEF9C3);
  static const Color warnYellow = Color(0xFFFACC15);
  static const Color warnLightRed = Color(0xFFFEE2E2);
  static const Color warnFullRed = Color(0xFFDC2626);
  static const Color warnTerminated = Color(0xFF0F172A);

  // Neutral Foundation (Clean, Crisp, Apple/Stripe-level Polished)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Text Hierarchy
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // System Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Luxury Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0C4A6E), Color(0xFF0284C7)],
  );

  static const LinearGradient luxuryTealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F766E), Color(0xFF0E7490)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  static const LinearGradient friendlyHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFF38BDF8)],
  );

  // Soft Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardElevation => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];
}
