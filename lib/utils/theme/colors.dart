import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// FoodBridge design system color palette with Light/Dark dynamic adaptability.
class AppColors {
  static bool get isDark => Get.isDarkMode;

  // Brand (remain same for branding consistency)
  static const Color primary = Color(0xFF059669); // Emerald 600
  static const Color secondary = Color(0xFFE2583E); // Terracotta/Warm Coral
  static const Color accent = Color(0xFFF59E0B); // Amber 500
  static const Color success = Color(0xFF10B981); // Emerald 500

  // Surfaces (Dynamic)
  static Color get background => isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC); // Slate 900 vs Slate 50
  static Color get card => isDark ? const Color(0xFF1E293B) : Colors.white; // Slate 800 vs White
  static Color get surfaceMuted => isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9); // Slate 700 vs Slate 100

  // Text (Dynamic)
  static Color get textPrimary => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A); // Slate 50 vs Slate 900
  static Color get textSecondary => isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569); // Slate 300 vs Slate 600
  static Color get textMuted => isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8); // Slate 500 vs Slate 400

  // Semantic
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF97316); // Orange 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Legacy aliases (kept for gradual migration)
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color red = error;
  static const Color yellow = accent;
  static Color get grey => textSecondary;
  static Color get backgroundColor => background;
  static Color get greenAccent => isDark ? const Color(0x33059669) : const Color(0x1A059669);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF047857)], // Emerald 600 to Emerald 700
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), secondary], // Amber 400 to Terracotta
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
