import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — Kente-inspired warm gold
  static const Color primary = Color(0xFFD4A843);
  static const Color primaryLight = Color(0xFFE8C96A);
  static const Color primaryDark = Color(0xFFB8892E);

  // Secondary — Deep green
  static const Color secondary = Color(0xFF1B5E20);
  static const Color secondaryLight = Color(0xFF2E7D32);
  static const Color secondaryDark = Color(0xFF0D3B12);

  // Accent — Warm brown
  static const Color accent = Color(0xFF5D4037);
  static const Color accentLight = Color(0xFF795548);

  // Background
  static const Color background = Color(0xFFFFF8E1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F0E0);
  static const Color scaffoldBackground = Color(0xFFFFFBF0);

  // Text
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textTertiary = Color(0xFF79747E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFB3261E);
  static const Color warning = Color(0xFFE65100);
  static const Color info = Color(0xFF0277BD);

  // Categories
  static const Color categoryFood = Color(0xFF4CAF50);
  static const Color categoryClothing = Color(0xFF2196F3);
  static const Color categoryElectronics = Color(0xFF9C27B0);
  static const Color categoryServices = Color(0xFFFF9800);
  static const Color categoryOther = Color(0xFF607D8B);

  // Mic button gradient
  static const List<Color> micGradient = [
    Color(0xFFD4A843),
    Color(0xFFE8C96A),
  ];

  static const List<Color> micActiveGradient = [
    Color(0xFF1B5E20),
    Color(0xFF2E7D32),
  ];
}
