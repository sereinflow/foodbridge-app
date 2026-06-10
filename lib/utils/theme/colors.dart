import 'package:flutter/material.dart';

/// FoodBridge design system color palette.
class AppColors {
  // Brand
  static const Color primary = Color(0xFF059669); // Emerald 600
  static const Color secondary = Color(0xFFE2583E); // Terracotta/Warm Coral
  static const Color accent = Color(0xFFF59E0B); // Amber 500
  static const Color success = Color(0xFF10B981); // Emerald 500

  // Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color card = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate 100

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Semantic
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF97316); // Orange 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Legacy aliases (kept for gradual migration)
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color red = error;
  static const Color yellow = accent;
  static const Color grey = textSecondary;
  static Color backgroundColor = background;
  static Color greenAccent = const Color(0x1A059669);

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
