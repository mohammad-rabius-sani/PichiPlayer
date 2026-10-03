package com.pichiplayer.ui.states

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.pichiplayer.ui.components.CinematicLogoBadge
import com.pichiplayer.ui.components.PichiBadge
import com.pichiplayer.ui.components.PichiButton
import com.pichiplayer.ui.components.PichiGlassCard
import com.pichiplayer.ui.theme.AppColors
import com.pichiplayer.ui.theme.AppTypography

/**
 * Generic Base State Layout for Empty, Error, Warning, and Permission screens.
 */
@Composable
fun PichiBaseStateView(
    icon: ImageVector,
    title: String,
    description: String,
    modifier: Modifier = Modifier,
    iconTint: Color = AppColors.electricBlue,
    iconContainerColor: Color = AppColors.surfaceGlass,
    iconContainerBorder: Color = AppColors.glassBorder,
    actionButtonText: String? = null,
    actionButtonIcon: ImageVector? = null,
    onActionClick: (() -> Unit)? = null,
    secondaryButtonText: String? = null,
    onSecondaryActionClick: (() -> Unit)? = null,
    content: (@Composable ColumnScope.() -> Unit)? = null
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Icon container
        Box(
            modifier = Modifier
                .size(76.dp)
                .clip(CircleShape)
                .background(iconContainerColor)
                .border(1.dp, iconContainerBorder, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = iconTint,
                modifier = Modifier.size(36.dp)
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Title
        Text(
            text = title,
            style = AppTypography.sectionHeader.copy(
                fontSize = 19.sp,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center
            )
        )

        Spacer(modifier = Modifier.height(10.dp))

        // Description
        Text(
            text = description,
            style = AppTypography.bodyMedium.copy(
                textAlign = TextAlign.Center,
                lineHeight = 20.sp,
                color = AppColors.textSecondary
            ),
            modifier = Modifier.padding(horizontal = 16.dp)
        )

        if (content != null) {
            Spacer(modifier = Modifier.height(20.dp))
            content()
        }

        // Action Buttons
        if (actionButtonText != null && onActionClick != null) {
            Spacer(modifier = Modifier.height(28.dp))
            PichiButton(
                text = actionButtonText,
                onClick = onActionClick,
                icon = actionButtonIcon
            )
        }

        if (secondaryButtonText != null && onSecondaryActionClick != null) {
            Spacer(modifier = Modifier.height(12.dp))
            PichiButton(
                text = secondaryButtonText,
                onClick = onSecondaryActionClick,
                isSecondary = true
            )
        }
    }
}

// -------------------------------------------------------------
// SPECIFIC PRESET REUSABLE STATE VIEWS
// -------------------------------------------------------------

/**
 * 1. Empty Library State (No videos found in storage)
 */
@Composable
fun EmptyLibraryState(
    onScanClick: () -> Unit,
    onSelectFolderClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    PichiBaseStateView(
        icon = Icons.Outlined.VideoLibrary,
        title = "No Local Videos Found",
        description = "No video files were detected in your standard device folders. Scan for media or choose a specific directory to index.",
        actionButtonText = "Scan Storage",
        actionButtonIcon = Icons.Default.Refresh,
        onActionClick = onScanClick,
        secondaryButtonText = "Choose Custom Folder",
        onSecondaryActionClick = onSelectFolderClick,
        modifier = modifier
    )
}

/**
 * 2. Empty Folder State
 */
@Composable
fun EmptyFolderState(
    folderName: String,
    onBackClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    PichiBaseStateView(
        icon = Icons.Outlined.FolderOpen,
        title = "Folder is Empty",
        description = "No playable video files were found in \"$folderName\".",
        actionButtonText = "Go Back",
        actionButtonIcon = Icons.AutoMirrored.Filled.ArrowBack,
        onActionClick = onBackClick,
        modifier = modifier
    )
}

/**
 * 3. Empty Search State
 */
@Composable
fun EmptySearchState(
    query: String,
    suggestedTerm: String? = null,
    onSuggestionClick: ((String) -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    PichiBaseStateView(
        icon = Icons.Outlined.SearchOff,
        title = "No Matches Found",
        description = "No local video files matched \"$query\". Check for spelling or try searching by folder or format.",
        modifier = modifier,
        content = {
            if (suggestedTerm != null && onSuggestionClick != null) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center,
                    modifier = Modifier.padding(top = 8.dp)
                ) {
                    Text(
                        text = "Did you mean: ",
                        style = AppTypography.bodyMedium
                    )
                    Text(
                        text = "\"$suggestedTerm\"?",
                        style = AppTypography.bodyMedium.copy(
                            color = AppColors.electricBlueBright,
                            fontWeight = FontWeight.Bold
                        )
                    )
                }
                Spacer(modifier = Modifier.height(14.dp))
                PichiButton(
                    text = "Search for \"$suggestedTerm\"",
                    onClick = { onSuggestionClick(suggestedTerm) },
                    isSecondary = true
                )
            }
        }
    )
}

/**
 * 4. Initial Media Scanner Loading State
 */
@Composable
fun MediaScannerLoadingState(
    progress: Float,
    videosFound: Int,
    currentFolder: String,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(AppColors.background)
            .padding(horizontal = 36.dp, vertical = 48.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        CinematicLogoBadge(size = 96.dp)

        Spacer(modifier = Modifier.height(28.dp))

        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = "Pichi",
                style = AppTypography.heroTitle.copy(
                    fontSize = 32.sp,
                    letterSpacing = (-0.5).sp,
                    color = AppColors.textPrimary
                )
            )
            Text(
                text = "Player",
                style = AppTypography.heroTitle.copy(
                    fontSize = 32.sp,
                    letterSpacing = (-0.5).sp,
                    brush = AppColors.brandGradient
                )
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "A premium local video player for Android.",
            style = AppTypography.bodyMedium.copy(
                fontSize = 13.5.sp,
                color = AppColors.textSecondary,
                textAlign = TextAlign.Center
            )
        )

        Spacer(modifier = Modifier.height(40.dp))

        // Sleek Luminous Progress Bar
        Box(
            modifier = Modifier
                .fillMaxWidth(0.82f)
                .height(5.dp)
                .clip(RoundedCornerShape(3.dp))
                .background(AppColors.surfaceHigher)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(progress.coerceIn(0.05f, 1.0f))
                    .fillMaxHeight()
                    .background(AppColors.brandGradient)
            )
        }

        Spacer(modifier = Modifier.height(20.dp))

        Text(
            text = if (currentFolder.isNotBlank()) "Scanning $currentFolder..." else "Indexing storage...",
            style = AppTypography.bodyMedium.copy(
                fontSize = 13.sp,
                color = AppColors.textTertiary
            ),
            textAlign = TextAlign.Center,
            maxLines = 1
        )

        Spacer(modifier = Modifier.height(10.dp))

        if (videosFound > 0) {
            PichiBadge(
                text = "$videosFound local videos indexed",
                highlight = true
            )
        }
    }
}

/**
 * 5. Permission Required State (Storage / Media access) - Screen 20
 */
@Composable
fun PermissionRequiredState(
    onGrantClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(AppColors.background)
            .statusBarsPadding()
            .displayCutoutPadding()
            .navigationBarsPadding()
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 28.dp, vertical = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            Spacer(modifier = Modifier.height(20.dp))

            // Center card & actions
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(18.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                // Amber Caution Badge
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .clip(RoundedCornerShape(22.dp))
                        .background(Color(0xFF1E1710))
                        .border(1.5.dp, Color(0xFFE5A100).copy(alpha = 0.55f), RoundedCornerShape(22.dp)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Outlined.WarningAmber,
                        contentDescription = null,
                        tint = Color(0xFFFFB800),
                        modifier = Modifier.size(40.dp)
                    )
                }

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = "Folder access required",
                    style = AppTypography.sectionHeader.copy(
                        fontSize = 21.sp,
                        fontWeight = FontWeight.Bold,
                        textAlign = TextAlign.Center
                    )
                )

                Text(
                    text = "PIchiPlayer operates 100% offline and requires access to your device storage to discover and play your local videos.",
                    style = AppTypography.bodyMedium.copy(
                        textAlign = TextAlign.Center,
                        lineHeight = 22.sp,
                        color = AppColors.textSecondary
                    ),
                    modifier = Modifier.padding(horizontal = 12.dp)
                )

                Spacer(modifier = Modifier.height(12.dp))

                PichiButton(
                    text = "Grant Access",
                    icon = Icons.Default.LockOpen,
                    onClick = onGrantClick,
                    modifier = Modifier.fillMaxWidth(0.85f),
                    contentPadding = PaddingValues(horizontal = 24.dp, vertical = 14.dp)
                )
            }

            // Bottom Privacy Assurance Message (Screen 20)
            PichiGlassCard(
                modifier = Modifier.fillMaxWidth(),
                backgroundColor = AppColors.surface.copy(alpha = 0.6f),
                borderColor = AppColors.glassBorderSubtle,
                shape = RoundedCornerShape(16.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 14.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(AppColors.surfaceSubtle)
                            .border(1.dp, AppColors.glassBorderSubtle, CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Outlined.Lock,
                            contentDescription = null,
                            tint = AppColors.electricBlueBright,
                            modifier = Modifier.size(18.dp)
                        )
                    }

                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Your videos stay on your device.",
                            style = AppTypography.cardTitle.copy(
                                fontSize = 13.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                        )
                        Text(
                            text = "Videos, playback history, preferences and thumbnail cache are stored locally.",
                            style = AppTypography.caption.copy(
                                fontSize = 11.5.sp,
                                color = AppColors.textTertiary,
                                lineHeight = 16.sp
                            )
                        )
                    }
                }
            }
        }
    }
}

/**
 * 6. Playback Error State
 */
@Composable
fun PlaybackErrorState(
    errorMessage: String?,
    onRetryClick: () -> Unit,
    onBackClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    PichiBaseStateView(
        icon = Icons.Outlined.ErrorOutline,
        title = "Playback Error",
        description = errorMessage ?: "The selected video could not be decoded. The file may be corrupt or encoded in an unsupported container.",
        iconTint = AppColors.errorBright,
        iconContainerColor = AppColors.errorSubtle,
        iconContainerBorder = AppColors.errorBorder,
        actionButtonText = "Retry Playback",
        actionButtonIcon = Icons.Default.Replay,
        onActionClick = onRetryClick,
        secondaryButtonText = "Return to Library",
        onSecondaryActionClick = onBackClick,
        modifier = modifier
    )
}
