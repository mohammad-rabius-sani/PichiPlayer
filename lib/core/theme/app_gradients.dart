import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gradients for PIchiPlayer dark cinematic aesthetic
class AppGradients {
  AppGradients._();

  /// Primary play-symbol gradient: Electric Blue into vibrant Violet
  static const LinearGradient logoSymbol = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.electricBlueBright,
      AppColors.electricBlue,
      AppColors.violetAccent,
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Secondary inner facet gradient for geometric depth
  static const LinearGradient logoFacet = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF38BDF8),
      Color(0xFF2563EB),
      Color(0xFF7C3AED),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Smooth luminous progress bar gradient
  static const LinearGradient progressBar = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.electricBlueBright,
      AppColors.electricBlue,
      AppColors.violetAccent,
    ],
  );

  /// Progress bar shimmer wave
  static const LinearGradient progressShimmer = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Colors.transparent,
      Color(0x80FFFFFF),
      Colors.transparent,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Subtle atmospheric background gradient
  static const RadialGradient ambientCenter = RadialGradient(
    center: Alignment(0.0, -0.15),
    radius: 0.95,
    colors: [
      Color(0xFF0F182E), // Faint navy-blue bloom
      Color(0xFF0A0F1D),
      AppColors.background,
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Corner depth violet glow
  static const RadialGradient cornerVioletGlow = RadialGradient(
    center: Alignment(0.85, 0.85),
    radius: 0.8,
    colors: [
      Color(0x1A7C3AED), // 10% violet
      Colors.transparent,
    ],
    stops: [0.0, 1.0],
  );

  /// Top corner blue glow
  static const RadialGradient topCornerBlueGlow = RadialGradient(
    center: Alignment(-0.85, -0.85),
    radius: 0.75,
    colors: [
      Color(0x1A0091FF), // 10% blue
      Colors.transparent,
    ],
    stops: [0.0, 1.0],
  );

  /// Minimal glassmorphic card fill
  static const LinearGradient glassCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1A1E293B),
      Color(0x0D0F172A),
    ],
  );
}
