package com.pichiplayer.ui.theme

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

/**
 * Strict Design Tokens for PIchiPlayer
 * Dark cinematic visual system with Electric Blue primary and subtle Violet accent.
 */
object AppColors {
    // 2. PRIMARY COLOR PALETTE
    val background = Color(0xFF07090D)             // Primary background: #07090D
    val backgroundSecondary = Color(0xFF0B0F16)    // Secondary background: #0B0F16
    val surface = Color(0xFF111722)                // Elevated surface: #111722
    val surfaceHigher = Color(0xFF171E2B)          // Higher elevated surface: #171E2B
    val playerBackground = Color(0xFF030507)       // Fullscreen player: #030507

    // Backward-compatible surface aliases
    val backgroundNavy = backgroundSecondary
    val backgroundElevated = surface
    val surfaceSubtle = surfaceHigher
    val surfaceElevated = surfaceHigher
    val surfaceGlass = Color(0xCC111722)           // Smoked dark glass

    // 11. BORDERS
    val borderSubtle = Color(0x14FFFFFF)           // ~8% white subtle border
    val glassBorder = Color(0x1AFFFFFF)            // 10% white for elevated glass
    val glassBorderSubtle = Color(0x0FFFFFFF)      // 6% white
    val borderSelected = Color(0x594F8CFF)         // 35% electric blue for selected state

    // 4. PRIMARY ACCENT
    val electricBlue = Color(0xFF4F8CFF)           // Main PIchiPlayer blue: #4F8CFF
    val electricBlueBright = Color(0xFF67A1FF)     // Bright interactive blue: #67A1FF
    val electricBlueDark = Color(0xFF2E6BDA)       // Deep blue: #2E6BDA
    val brandPrimary = electricBlue                // Brand primary alias

    // 5. SECONDARY ACCENT
    val violetAccent = Color(0xFF8B6CFF)           // Subtle violet: #8B6CFF
    val violetSubtle = Color(0xFF7450EB)
    val cyanAccent = Color(0xFF38BDF8)
    val blueAccent = Color(0xFF38BDF8)
    val emerald = Color(0xFF10B981)
    val amberAccent = Color(0xFFF59E0B)

    // 6. BRAND GRADIENT (#4F8CFF -> #8B6CFF diagonal)
    val brandGradient = Brush.linearGradient(
        colors = listOf(electricBlue, violetAccent),
        start = Offset.Zero,
        end = Offset(1000f, 1000f)
    )

    // 7. AMBIENT BACKGROUND LIGHTING (subtle, low opacity)
    val electricBlueGlow = Color(0x264F8CFF)       // 15% electric blue glow
    val violetGlow = Color(0x1F8B6CFF)             // 12% violet glow
    val ambientLightGlow = Color(0x144F8CFF)

    // Progress Bar Track
    val progressTrack = Color(0xFF0F1524)
    val progressTrackBorder = Color(0xFF182238)

    // 3. TEXT COLORS
    val textPrimary = Color(0xFFF5F7FA)            // Primary text: #F5F7FA
    val textSecondary = Color(0xFFAAB3C2)          // Secondary text: #AAB3C2
    val textTertiary = Color(0xFF707A8C)           // Tertiary text: #707A8C
    val textDisabled = Color(0xFF4B5362)           // Disabled text: #4B5362
    val textMuted = textTertiary

    // Status & Badges
    val success = Color(0xFF10B981)
    val badgeBackground = Color(0x1A4F8CFF)
    val badgeBorder = Color(0x334F8CFF)

    // Severity / Alert Tokens
    val info = electricBlue
    val infoBright = electricBlueBright
    val infoSubtle = Color(0x1F4F8CFF)
    val infoBorder = Color(0x3D4F8CFF)

    val warning = Color(0xFFF59E0B)
    val warningBright = Color(0xFFFBBF24)
    val warningSubtle = Color(0x1FF59E0B)
    val warningBorder = Color(0x3DF59E0B)

    val error = Color(0xFFEF4444)
    val errorBright = Color(0xFFF87171)
    val errorSubtle = Color(0x1FEF4444)
    val errorBorder = Color(0x3DEF4444)
}
