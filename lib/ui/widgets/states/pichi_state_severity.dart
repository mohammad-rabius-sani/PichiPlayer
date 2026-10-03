import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// The 3-tier error severity classification for PIchiPlayer.
///
/// Designed to keep the interface calm and trustworthy, avoiding unnecessary
/// critical red alerts for ordinary local media operations.
enum PichiSeverity {
  /// Neutral/electric blue treatment for informational events
  /// (e.g. updating library, switching audio track, indexing).
  info,

  /// Warm/amber restrained warning treatment
  /// (e.g. folder access required, decoder fallback, missing permissions).
  warning,

  /// Restrained red/destructive treatment for critical failures
  /// (e.g. unreadable/corrupt files, unsupported formats, missing files).
  critical,
}

extension PichiSeverityX on PichiSeverity {
  /// Primary solid accent color for this severity.
  Color get accentColor {
    switch (this) {
      case PichiSeverity.info:
        return AppColors.electricBlue;
      case PichiSeverity.warning:
        return AppColors.warning;
      case PichiSeverity.critical:
        return AppColors.error;
    }
  }

  /// Luminous/bright variant for icons and high-contrast badges.
  Color get brightColor {
    switch (this) {
      case PichiSeverity.info:
        return AppColors.electricBlueBright;
      case PichiSeverity.warning:
        return AppColors.warningBright;
      case PichiSeverity.critical:
        return AppColors.errorBright;
    }
  }

  /// Translucent subtle background tint.
  Color get subtleBackground {
    switch (this) {
      case PichiSeverity.info:
        return AppColors.infoSubtle;
      case PichiSeverity.warning:
        return AppColors.warningSubtle;
      case PichiSeverity.critical:
        return AppColors.errorSubtle;
    }
  }

  /// Subtle glass border color.
  Color get borderColor {
    switch (this) {
      case PichiSeverity.info:
        return AppColors.infoBorder;
      case PichiSeverity.warning:
        return AppColors.warningBorder;
      case PichiSeverity.critical:
        return AppColors.errorBorder;
    }
  }

  /// Soft atmospheric glow shadow color.
  Color get glowColor {
    switch (this) {
      case PichiSeverity.info:
        return AppColors.electricBlueGlow;
      case PichiSeverity.warning:
        return AppColors.warning.withOpacity(0.25);
      case PichiSeverity.critical:
        return AppColors.error.withOpacity(0.28);
    }
  }
}
