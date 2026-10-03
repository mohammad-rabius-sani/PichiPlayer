package com.pichiplayer.ui.components

import android.net.Uri
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import coil.compose.AsyncImage
import coil.request.ImageRequest
import coil.decode.VideoFrameDecoder
import com.pichiplayer.data.database.VideoEntity
import com.pichiplayer.ui.theme.AppColors
import com.pichiplayer.ui.theme.AppDesignTokens
import com.pichiplayer.ui.theme.AppTypography
import java.io.File

/**
 * Reusable smoked glassmorphic container with customizable subtle border and tactile press feedback.
 */
@Composable
fun PichiGlassCard(
    modifier: Modifier = Modifier,
    shape: RoundedCornerShape = RoundedCornerShape(AppDesignTokens.RadiusCard),
    backgroundColor: Color = AppColors.surface.copy(alpha = 0.85f),
    borderColor: Color = AppColors.borderSubtle,
    borderWidth: Dp = 1.dp,
    onClick: (() -> Unit)? = null,
    content: @Composable BoxScope.() -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed && onClick != null) AppDesignTokens.PRESS_SCALE else 1.0f,
        animationSpec = tween(AppDesignTokens.DURATION_FAST),
        label = "cardScale"
    )

    val clickModifier = if (onClick != null) {
        Modifier.clickable(
            interactionSource = interactionSource,
            indication = ripple(color = AppColors.electricBlueGlow),
            onClick = onClick
        )
    } else Modifier

    Box(
        modifier = modifier
            .scale(scale)
            .clip(shape)
            .background(backgroundColor)
            .border(borderWidth, borderColor, shape)
            .then(clickModifier),
        content = content
    )
}

/**
 * Luminous Electric Blue primary button with smooth press scale.
 */
@Composable
fun PichiButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    enabled: Boolean = true,
    isSecondary: Boolean = false,
    contentPadding: PaddingValues = PaddingValues(horizontal = 20.dp, vertical = 12.dp)
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed && enabled) AppDesignTokens.PRESS_SCALE else 1.0f,
        animationSpec = tween(AppDesignTokens.DURATION_FAST),
        label = "buttonScale"
    )

    val backgroundBrush = if (!enabled) {
        Brush.linearGradient(listOf(AppColors.surfaceHigher.copy(alpha = 0.5f), AppColors.surfaceHigher.copy(alpha = 0.5f)))
    } else if (isSecondary) {
        Brush.horizontalGradient(listOf(AppColors.surfaceHigher, AppColors.surface))
    } else {
        Brush.horizontalGradient(listOf(AppColors.electricBlue, AppColors.electricBlueDark))
    }

    val borderColor = if (!enabled) {
        AppColors.glassBorderSubtle
    } else if (isSecondary) {
        AppColors.borderSubtle
    } else {
        AppColors.electricBlueBright.copy(alpha = 0.4f)
    }

    val shape = RoundedCornerShape(AppDesignTokens.RadiusButton)
    val clickModifier = if (enabled) {
        Modifier.clickable(
            interactionSource = interactionSource,
            indication = ripple(color = AppColors.electricBlueGlow),
            onClick = onClick
        )
    } else Modifier

    Box(
        modifier = modifier
            .scale(scale)
            .heightIn(min = AppDesignTokens.ButtonSmallHeight)
            .clip(shape)
            .background(backgroundBrush)
            .border(1.dp, borderColor, shape)
            .then(clickModifier)
            .padding(contentPadding),
        contentAlignment = Alignment.Center
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            if (icon != null) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = if (enabled) AppColors.textPrimary else AppColors.textDisabled,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
            }
            Text(
                text = text,
                style = AppTypography.cardTitle.copy(
                    fontWeight = FontWeight.SemiBold,
                    color = if (enabled) AppColors.textPrimary else AppColors.textDisabled
                )
            )
        }
    }
}

/**
 * Clean circular or rounded-square icon button with dark translucent backdrop.
 */
@Composable
fun PichiIconButton(
    icon: ImageVector,
    contentDescription: String?,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    size: Dp = 42.dp,
    iconSize: Dp = 20.dp,
    tint: Color = AppColors.textPrimary,
    backgroundColor: Color = AppColors.surfaceGlass,
    borderColor: Color = AppColors.glassBorderSubtle
) {
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(backgroundColor)
            .border(1.dp, borderColor, CircleShape)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = ripple(color = AppColors.electricBlueGlow),
                onClick = onClick
            ),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = contentDescription,
            tint = tint,
            modifier = Modifier.size(iconSize)
        )
    }
}

/**
 * Technical tag badge (4K, HDR, 1080p, 60fps, etc.)
 */
@Composable
fun PichiBadge(
    text: String,
    modifier: Modifier = Modifier,
    highlight: Boolean = false,
    color: Color = if (highlight) AppColors.electricBlueBright else AppColors.textSecondary
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(6.dp))
            .background(if (highlight) AppColors.badgeBackground else AppColors.surfaceSubtle)
            .border(1.dp, if (highlight) AppColors.badgeBorder else AppColors.glassBorderSubtle, RoundedCornerShape(6.dp))
            .padding(horizontal = 6.dp, vertical = 2.dp)
    ) {
        Text(
            text = text,
            style = AppTypography.caption.copy(
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                color = color
            )
        )
    }
}

/**
 * Video Thumbnail Card with badges, duration pill, and progress bar.
 */
@Composable
fun PichiVideoThumbnail(
    video: VideoEntity,
    modifier: Modifier = Modifier,
    thumbnailPath: String? = null,
    showDuration: Boolean = true,
    showProgress: Boolean = true
) {
    val context = LocalContext.current
    val custom = thumbnailPath ?: video.thumbnailPath
    val imageSource: Any? = remember(custom, video.filePath, video.contentUri) {
        when {
            !custom.isNullOrEmpty() && File(custom).exists() -> File(custom)
            !video.filePath.isNullOrEmpty() && File(video.filePath).exists() -> File(video.filePath)
            video.contentUri.isNotBlank() -> Uri.parse(video.contentUri)
            else -> null
        }
    }

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(AppDesignTokens.RadiusCard))
            .background(AppColors.surface)
            .border(1.dp, AppColors.borderSubtle, RoundedCornerShape(AppDesignTokens.RadiusCard))
    ) {
        if (imageSource != null) {
            AsyncImage(
                model = ImageRequest.Builder(context)
                    .data(imageSource)
                    .setParameter(VideoFrameDecoder.VIDEO_FRAME_MICROS_KEY, 2_000_000L)
                    .size(480, 270)
                    .crossfade(true)
                    .build(),
                contentDescription = video.displayName,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize()
            )
        } else {
            // Elegant gradient placeholder with cinematic icon
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(
                        Brush.linearGradient(
                            listOf(
                                AppColors.surface,
                                AppColors.backgroundSecondary,
                                AppColors.surfaceHigher
                            )
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.PlayCircleOutline,
                    contentDescription = null,
                    tint = AppColors.electricBlue.copy(alpha = 0.35f),
                    modifier = Modifier.size(36.dp)
                )
            }
        }

        // Top badges: 4K / HDR
        Row(
            modifier = Modifier
                .align(Alignment.TopStart)
                .padding(8.dp),
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            // Resolution Badge with distinct tailored palette
            when {
                video.is8K -> PichiBadge(text = "8K", highlight = true, color = Color(0xFFFF5252))
                video.is4K -> PichiBadge(text = "4K", highlight = true, color = AppColors.brandPrimary)
                video.is2K -> PichiBadge(text = "2K", highlight = true, color = AppColors.cyanAccent)
                video.is1080p -> PichiBadge(text = "1080p", highlight = true, color = AppColors.emerald)
                video.is720p -> PichiBadge(text = "720p", highlight = true, color = AppColors.blueAccent)
                video.is480p -> PichiBadge(text = "480p", color = Color(0xFF90A4AE))
                video.is360p -> PichiBadge(text = "360p", color = Color(0xFFFFB74D))
                video.is240p -> PichiBadge(text = "240p", color = Color(0xFFB0BEC5))
                video.is144p -> PichiBadge(text = "144p", color = Color(0xFF78909C))
                video.is3gp -> PichiBadge(text = "3GP", highlight = true, color = Color(0xFFFF9800))
                video.resolutionBadge.isNotEmpty() -> PichiBadge(text = video.resolutionBadge)
            }
            // Format Badge (3GP, MKV, WEBM, etc.)
            if (video.formatBadge != null && video.formatBadge != video.resolutionBadge) {
                PichiBadge(text = video.formatBadge!!, color = Color(0xFFCE93D8))
            }
            if (video.isHdr) {
                PichiBadge(text = "HDR", highlight = true, color = AppColors.violetAccent)
            }
        }

        // Bottom right duration pill
        if (showDuration && video.durationMs > 0) {
            Box(
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(8.dp)
                    .clip(RoundedCornerShape(6.dp))
                    .background(Color.Black.copy(alpha = 0.75f))
                    .border(1.dp, AppColors.borderSubtle, RoundedCornerShape(6.dp))
                    .padding(horizontal = 6.dp, vertical = 2.dp)
            ) {
                Text(
                    text = video.formattedDuration,
                    style = AppTypography.caption.copy(
                        fontSize = 11.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = AppColors.textPrimary
                    )
                )
            }
        }

        // Bottom progress bar for continue watching
        if (showProgress && video.watchedPercentage > 0.02f) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(3.dp)
                    .align(Alignment.BottomCenter)
                    .background(AppColors.progressTrack)
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth(video.watchedPercentage)
                        .fillMaxHeight()
                        .background(AppColors.brandGradient)
                )
            }
        }
    }
}

/**
 * Top App Bar with back navigation, title, and trailing actions.
 */
@Composable
fun PichiTopAppBar(
    title: String,
    modifier: Modifier = Modifier,
    onBackClick: (() -> Unit)? = null,
    actions: @Composable RowScope.() -> Unit = {}
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .statusBarsPadding()
            .height(56.dp)
            .padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (onBackClick != null) {
            PichiIconButton(
                icon = Icons.AutoMirrored.Filled.ArrowBack,
                contentDescription = "Back",
                onClick = onBackClick,
                size = 38.dp,
                iconSize = 18.dp
            )
            Spacer(modifier = Modifier.width(12.dp))
        }

        Text(
            text = title,
            style = AppTypography.heroTitle.copy(fontSize = 20.sp),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f)
        )

        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            content = actions
        )
    }
}

/**
 * Floating glass bottom navigation bar with active blue pill glow.
 */
enum class PichiNavDestination(val label: String, val icon: ImageVector, val selectedIcon: ImageVector) {
    HOME("Home", Icons.Outlined.Home, Icons.Filled.Home),
    LIBRARY("Library", Icons.Outlined.VideoLibrary, Icons.Filled.VideoLibrary),
    FOLDERS("Folders", Icons.Outlined.Folder, Icons.Filled.Folder),
    SETTINGS("Settings", Icons.Outlined.Settings, Icons.Filled.Settings)
}

@Composable
fun PichiBottomNavBar(
    currentDestination: PichiNavDestination,
    onNavigate: (PichiNavDestination) -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .padding(horizontal = 20.dp, vertical = 8.dp),
        contentAlignment = Alignment.BottomCenter
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(62.dp)
                .clip(RoundedCornerShape(31.dp))
                .background(Color(0xF2090D16))
                .border(1.dp, AppColors.glassBorder, RoundedCornerShape(31.dp))
                .padding(horizontal = 6.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceAround,
                verticalAlignment = Alignment.CenterVertically
            ) {
                PichiNavDestination.entries.forEach { destination ->
                    val isSelected = destination == currentDestination
                    val iconColor by animateColorAsState(
                        targetValue = if (isSelected) AppColors.electricBlueBright else AppColors.textMuted,
                        animationSpec = tween(200),
                        label = "iconColor"
                    )

                    Column(
                        modifier = Modifier
                            .clip(RoundedCornerShape(20.dp))
                            .clickable(
                                interactionSource = remember { MutableInteractionSource() },
                                indication = null,
                                onClick = { onNavigate(destination) }
                            )
                            .padding(horizontal = 12.dp, vertical = 4.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(12.dp))
                                .background(if (isSelected) AppColors.badgeBackground else Color.Transparent)
                                .border(
                                    1.dp,
                                    if (isSelected) AppColors.badgeBorder else Color.Transparent,
                                    RoundedCornerShape(12.dp)
                                )
                                .padding(horizontal = 12.dp, vertical = 3.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = if (isSelected) destination.selectedIcon else destination.icon,
                                contentDescription = destination.label,
                                tint = iconColor,
                                modifier = Modifier.size(22.dp)
                            )
                        }
                        Text(
                            text = destination.label,
                            style = AppTypography.caption.copy(
                                fontSize = 10.sp,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                                color = iconColor
                            )
                        )
                    }
                }
            }
        }
    }
}

/**
 * Custom Dark Cinematic Exit Confirmation Dialog with options to keep playing in background or stop completely.
 */
@Composable
fun ExitConfirmationDialog(
    isPlaying: Boolean,
    onPlayInBackground: () -> Unit,
    onStopAndExit: () -> Unit,
    onDismiss: () -> Unit
) {
    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = 0.75f))
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onDismiss
                ),
            contentAlignment = Alignment.Center
        ) {
            PichiGlassCard(
                modifier = Modifier
                    .fillMaxWidth(0.88f)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = {} // Consume inner click
                    ),
                shape = RoundedCornerShape(AppDesignTokens.RadiusDialog),
                backgroundColor = AppColors.surface,
                borderColor = AppColors.glassBorderSubtle,
                borderWidth = 1.dp
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    // Glowing Icon Badge
                    Box(
                        modifier = Modifier
                            .size(64.dp)
                            .clip(CircleShape)
                            .background(if (isPlaying) AppColors.electricBlueGlow else AppColors.surfaceSubtle)
                            .border(
                                1.dp,
                                if (isPlaying) AppColors.electricBlue else AppColors.borderSubtle,
                                CircleShape
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = if (isPlaying) Icons.Outlined.Headphones else Icons.Outlined.PowerSettingsNew,
                            contentDescription = null,
                            tint = if (isPlaying) AppColors.electricBlueBright else AppColors.textPrimary,
                            modifier = Modifier.size(30.dp)
                        )
                    }

                    // Title
                    Text(
                        text = if (isPlaying) "Active Playback" else "Exit PIchiPlayer",
                        style = AppTypography.sectionHeader.copy(
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center
                        )
                    )

                    // Description
                    Text(
                        text = if (isPlaying) {
                            "A video is currently playing. Keep listening with background playback, or stop playback and close the app?"
                        } else {
                            "Are you sure you want to close PIchiPlayer? All history and progress have been saved locally."
                        },
                        style = AppTypography.bodyMedium.copy(
                            color = AppColors.textSecondary,
                            textAlign = TextAlign.Center,
                            lineHeight = 21.sp
                        ),
                        modifier = Modifier.padding(horizontal = 8.dp)
                    )

                    Spacer(modifier = Modifier.height(4.dp))

                    // Buttons
                    Column(
                        modifier = Modifier.fillMaxWidth(),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        if (isPlaying) {
                            PichiButton(
                                text = "Play in Background",
                                icon = Icons.Outlined.Headphones,
                                onClick = onPlayInBackground,
                                modifier = Modifier.fillMaxWidth()
                            )
                            PichiButton(
                                text = "Stop & Exit",
                                icon = Icons.Outlined.PowerSettingsNew,
                                onClick = onStopAndExit,
                                modifier = Modifier.fillMaxWidth(),
                                isSecondary = true
                            )
                        } else {
                            PichiButton(
                                text = "Exit Application",
                                icon = Icons.Default.Check,
                                onClick = onStopAndExit,
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        TextButton(
                            onClick = onDismiss,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(
                                text = "Cancel",
                                style = AppTypography.cardTitle.copy(
                                    color = AppColors.textSecondary,
                                    fontSize = 14.sp
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}

/**
 * Glowing Cinematic Logo Emblem using the mathematical brand geometry.
 */
@Composable
fun CinematicLogoBadge(
    modifier: Modifier = Modifier,
    size: Dp = 72.dp
) {
    PichiEmblem(size = size, modifier = modifier)
}

