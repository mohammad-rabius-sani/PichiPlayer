import 'package:flutter/material.dart';

/// Design tokens for PIchiPlayer
/// Dark cinematic visual system with Electric Blue primary and subtle Violet accent.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF06080D); // Almost-black cinematic base
  static const Color backgroundNavy = Color(0xFF090D16);
  static const Color backgroundElevated = Color(0xFF0D121F);

  // Surfaces & Glassmorphism
  static const Color surface = Color(0xFF101626);
  static const Color surfaceSubtle = Color(0xFF141C30);
  static const Color surfaceGlass = Color(0x1A253352);
  static const Color glassBorder = Color(0x2E4A6296);
  static const Color glassBorderSubtle = Color(0x1A384D75);

  // Accents
  static const Color electricBlue = Color(0xFF0091FF); // Primary luminous accent
  static const Color electricBlueBright = Color(0xFF00D2FF);
  static const Color electricBlueDark = Color(0xFF0060DF);
  
  static const Color violetAccent = Color(0xFF8B5CF6); // Subtle secondary accent
  static const Color violetSubtle = Color(0xFF6D28D9);
  static const Color cyanAccent = Color(0xFF06B6D4);

  // Glows
  static const Color electricBlueGlow = Color(0x4D0091FF);
  static const Color violetGlow = Color(0x338B5CF6);
  static const Color ambientLightGlow = Color(0x1F0070F3);

  // Progress Bar Track
  static const Color progressTrack = Color(0xFF0F1524);
  static const Color progressTrackBorder = Color(0xFF182238);

  // High-Contrast Typography
  static const Color textPrimary = Color(0xFFF8FAFC); // Crisp off-white
  static const Color textSecondary = Color(0xFF94A3B8); // Cool silver/grey
  static const Color textMuted = Color(0xFF64748B); // Slate muted
  static const Color textDisabled = Color(0xFF334155);

  // Status & Badges
  static const Color success = Color(0xFF10B981);
  static const Color badgeBackground = Color(0x1400D2FF);
  static const Color badgeBorder = Color(0x2900D2FF);

  // Error Severity System Tokens
  static const Color info = Color(0xFF0091FF);
  static const Color infoBright = Color(0xFF00D2FF);
  static const Color infoSubtle = Color(0x1F0091FF);
  static const Color infoBorder = Color(0x3D0091FF);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBright = Color(0xFFFBBF24);
  static const Color warningSubtle = Color(0x1FF59E0B);
  static const Color warningBorder = Color(0x3DF59E0B);

  static const Color error = Color(0xFFEF4444);
  static const Color errorBright = Color(0xFFF87171);
  static const Color errorSubtle = Color(0x1FEF4444);
  static const Color errorBorder = Color(0x3DEF4444);
}
