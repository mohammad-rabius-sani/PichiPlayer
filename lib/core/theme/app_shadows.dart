import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Soft luminous glows and depth shadows for PIchiPlayer
class AppShadows {
  AppShadows._();

  /// Soft ambient glow behind the logo
  static const List<BoxShadow> logoAura = [
    BoxShadow(
      color: Color(0x330091FF), // 20% electric blue
      blurRadius: 48,
      spreadRadius: 8,
      offset: Offset(0, 0),
    ),
    BoxShadow(
      color: Color(0x268B5CF6), // 15% violet
      blurRadius: 64,
      spreadRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  /// Core sharp glow for the play icon
  static const List<BoxShadow> logoCore = [
    BoxShadow(
      color: Color(0x660091FF),
      blurRadius: 20,
      spreadRadius: 1,
      offset: Offset(0, 4),
    ),
  ];

  /// Soft luminous glow for the progress indicator
  static const List<BoxShadow> progressGlow = [
    BoxShadow(
      color: Color(0x550091FF),
      blurRadius: 12,
      spreadRadius: 1,
      offset: Offset(0, 0),
    ),
  ];

  /// Progress bar leading thumb glow
  static const List<BoxShadow> progressThumbGlow = [
    BoxShadow(
      color: AppColors.electricBlueBright,
      blurRadius: 8,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: AppColors.electricBlue,
      blurRadius: 16,
      spreadRadius: 4,
    ),
  ];

  /// Minimal glass card shadow
  static const List<BoxShadow> glassCard = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
}
