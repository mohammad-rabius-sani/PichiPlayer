package com.pichiplayer.ui.theme

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.Easing
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Strict Design Tokens for PIchiPlayer
 * Spacing, Radii, Heights, and Animation durations.
 */
object AppDesignTokens {
    // 13. CORNER RADIUS SYSTEM
    val RadiusSmall = 11.dp       // Small controls: 10–12dp
    val RadiusButton = 13.dp      // Buttons: 12–14dp
    val RadiusCard = 17.dp        // Video cards: 16–18dp
    val RadiusHero = 21.dp        // Hero: 20–22dp
    val RadiusBottomSheet = 24.dp // Bottom sheets: 24dp
    val RadiusDialog = 24.dp      // Modal Dialogs: 24dp
    val RadiusLarge = 22.dp       // Large feature surfaces: 20–24dp

    val ShapeSmall = RoundedCornerShape(RadiusSmall)
    val ShapeButton = RoundedCornerShape(RadiusButton)
    val ShapeCard = RoundedCornerShape(RadiusCard)
    val ShapeHero = RoundedCornerShape(RadiusHero)
    val ShapeBottomSheet = RoundedCornerShape(topStart = RadiusBottomSheet, topEnd = RadiusBottomSheet)
    val ShapeDialog = RoundedCornerShape(RadiusDialog)
    val ShapeLarge = RoundedCornerShape(RadiusLarge)

    // SPACING SCALE
    val SpaceNone = 0.dp
    val SpaceMicro = 4.dp
    val SpaceSmall = 8.dp
    val SpaceMedium = 12.dp
    val SpaceDefault = 16.dp
    val SpaceLarge = 24.dp
    val SpaceXLarge = 32.dp

    // CONTROL HEIGHTS & TARGETS
    val TouchTargetMin = 48.dp
    val ButtonHeight = 48.dp
    val ButtonSmallHeight = 38.dp
    val ChipHeight = 36.dp
    val NavBarHeight = 62.dp
    val HeroHeight = 220.dp

    // 50. MOTION & ANIMATION DURATIONS (ms)
    const val DURATION_FAST = 140     // FAST: 120–160ms
    const val DURATION_STANDARD = 200 // STANDARD: 180–240ms
    const val DURATION_MEDIUM = 300   // MEDIUM: 250–350ms
    const val DURATION_LONG = 420     // LONG: 350–500ms

    // 43. EASING
    val StandardEasing: Easing = FastOutSlowInEasing
    val SmoothEasing: Easing = CubicBezierEasing(0.2f, 0.0f, 0.0f, 1.0f)

    // 15. PRESSED STATES
    const val PRESS_SCALE = 0.975f
}
