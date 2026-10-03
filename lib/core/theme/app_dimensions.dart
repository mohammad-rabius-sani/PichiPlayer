import 'package:flutter/material.dart';

/// Spacing, radii, and sizing dimensions for PIchiPlayer
class AppDimensions {
  AppDimensions._();

  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // Corner Radii (Spec: 18-22dp)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 20.0; // 20dp smooth corners for cards and hero
  static const double cardRadius = 20.0;
  static const double radiusPill = 999.0;

  // Component Sizes
  static const double logoSize = 88.0;
  static const double progressBarHeight = 4.0;
  static const double maxContentWidth = 440.0; // Restrains width on wide screens / tablets

  // Home Screen Card Sizes
  static const double heroAspectRatio = 16 / 9;
  static const double videoCardWidth = 220.0;
  static const double videoCardThumbnailHeight = 124.0;
  static const double bottomNavHeight = 64.0;

  // Insets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 28.0);
  static const EdgeInsets homeHorizontalPadding = EdgeInsets.symmetric(horizontal: 18.0);
}
