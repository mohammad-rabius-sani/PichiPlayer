package com.pichiplayer.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val DarkColorScheme = darkColorScheme(
    primary = AppColors.electricBlue,
    onPrimary = AppColors.textPrimary,
    primaryContainer = AppColors.surfaceSubtle,
    onPrimaryContainer = AppColors.electricBlueBright,
    secondary = AppColors.violetAccent,
    onSecondary = AppColors.textPrimary,
    background = AppColors.background,
    onBackground = AppColors.textPrimary,
    surface = AppColors.surface,
    onSurface = AppColors.textPrimary,
    surfaceVariant = AppColors.surfaceSubtle,
    onSurfaceVariant = AppColors.textSecondary,
    error = AppColors.error,
    onError = AppColors.textPrimary
)

@Composable
fun PichiTheme(
    content: @Composable () -> Unit
) {
    val colorScheme = DarkColorScheme
    val view = LocalView.current

    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as? Activity)?.window
            if (window != null) {
                window.statusBarColor = AppColors.background.toArgb()
                window.navigationBarColor = AppColors.background.toArgb()
                WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
                WindowCompat.getInsetsController(window, view).isAppearanceLightNavigationBars = false
            }
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = AppTypography.typography,
        content = content
    )
}
