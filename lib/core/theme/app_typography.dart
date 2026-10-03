import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Clean modern sans-serif typography system for PIchiPlayer
class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'sans-serif';

  /// Brand wordmark: "PIchiPlayer"
  static const TextStyle brandWordmark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.2,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// Top app bar brand title
  static const TextStyle topBarBrand = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// Greeting subtitle: "Good evening", "Good morning"
  static const TextStyle greetingSubtitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  /// Subtitle: "Your Local Video Companion"
  static const TextStyle brandSubtitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.1,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Section heading: "Continue Watching", "Recently Added"
  static const TextStyle sectionHeading = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Section action: "View all", "See all"
  static const TextStyle sectionAction = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.electricBlueBright,
  );

  /// Large Featured Hero Title
  static const TextStyle heroTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// Hero metadata line: "2h 49m • 4K • HEVC"
  static const TextStyle heroMetadata = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  /// Video Card Title
  static const TextStyle videoCardTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Video Card Subtitle / Progress: "1:12:16 / 2:49:22"
  static const TextStyle videoCardProgress = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Video Duration Pill Badge text
  static const TextStyle durationBadge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Quality Badges: "4K", "HDR", "60 FPS"
  static const TextStyle qualityBadge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.electricBlueBright,
  );

  /// Bottom Navigation label
  static const TextStyle navLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  /// Scanning section header: "Scanning local videos..."
  static const TextStyle scanHeader = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Large dynamic scan percentage: e.g. "68%"
  static const TextStyle scanPercentage = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1.2,
  );

  /// Found videos count: "1,248 videos found"
  static const TextStyle scanVideoCount = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Current directory being scanned: "Scanning Movies/"
  static const TextStyle scanCurrentFolder = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textMuted,
    height: 1.3,
  );

  /// Offline badge title: "100% Offline"
  static const TextStyle privacyBadgeTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: AppColors.electricBlueBright,
    height: 1.2,
  );

  /// Offline statement: "Your videos stay on your device."
  static const TextStyle privacyStatement = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.textMuted,
    height: 1.3,
  );

  /// General button label
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: AppColors.textPrimary,
  );
}
