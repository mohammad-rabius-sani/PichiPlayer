package com.pichiplayer.ui.settings

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.pichiplayer.PichiPlayerApp
import com.pichiplayer.media.playback.DecoderMode
import com.pichiplayer.data.update.UpdateManager
import com.pichiplayer.data.update.UpdateCheckResult
import com.pichiplayer.data.update.AppUpdateInfo
import com.pichiplayer.ui.components.*
import com.pichiplayer.ui.theme.AppColors
import com.pichiplayer.ui.theme.AppDesignTokens
import com.pichiplayer.ui.theme.AppTypography
import kotlinx.coroutines.launch

@Composable
fun SettingsScreen(
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val repository = PichiPlayerApp.instance.repository
    val preferences = PichiPlayerApp.instance.preferences
    val thumbnailCache = PichiPlayerApp.instance.thumbnailCache
    val playerManager = PichiPlayerApp.instance.playerManager
    val coroutineScope = rememberCoroutineScope()

    val resumePlayback by preferences.resumePlayback.collectAsState(initial = true)
    val currentDecoderCode by preferences.decoderMode.collectAsState(initial = "auto")
    val currentDecoderMode = remember(currentDecoderCode) { DecoderMode.fromCode(currentDecoderCode) }
    val bgPlayback by preferences.backgroundPlaybackEnabled.collectAsState(initial = false)
    val autoPip by preferences.autoPipEnabled.collectAsState(initial = true)
    val autoScan by preferences.autoScanOnStart.collectAsState(initial = true)
    val generateThumbs by preferences.generateThumbnails.collectAsState(initial = true)
    val defaultSpeed by preferences.defaultPlaybackSpeed.collectAsState(initial = 1.0f)
    val subtitleFontSize by preferences.subtitleFontSize.collectAsState(initial = 18)

    var cacheSizeBytes by remember { mutableLongStateOf(0L) }
    var showClearHistoryDialog by remember { mutableStateOf(false) }
    var showClearCacheDialog by remember { mutableStateOf(false) }
    var showDecoderDialog by remember { mutableStateOf(false) }
    var showUpdateDialog by remember { mutableStateOf(false) }
    var isCheckingUpdate by remember { mutableStateOf(false) }
    var updateResult by remember { mutableStateOf<UpdateCheckResult?>(null) }
    var snackbarMessage by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(Unit) {
        cacheSizeBytes = thumbnailCache.getCacheSizeBytes()
    }

    val formattedCacheSize = remember(cacheSizeBytes) {
        val mb = cacheSizeBytes.toDouble() / (1024 * 1024)
        "%.1f MB".format(mb)
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(AppColors.background)
            .statusBarsPadding()
            .displayCutoutPadding()
    ) {
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(bottom = 16.dp),
            contentPadding = PaddingValues(horizontal = 20.dp, vertical = 14.dp),
            verticalArrangement = Arrangement.spacedBy(18.dp)
        ) {
            // Header
            item {
                Column {
                    Text(
                        text = "Settings",
                        style = AppTypography.heroTitle
                    )
                    Text(
                        text = "Offline Player Configuration",
                        style = AppTypography.caption.copy(color = AppColors.electricBlueBright)
                    )
                }
            }

            // 1. Playback Section
            item {
                SettingsSection(title = "PLAYBACK") {
                    SettingsSwitchRow(
                        title = "Resume Playback",
                        subtitle = "Remember last watched position across videos",
                        icon = Icons.Outlined.Restore,
                        checked = resumePlayback,
                        onCheckedChange = { coroutineScope.launch { preferences.setResumePlayback(it) } }
                    )
                    HorizontalDivider(color = AppColors.glassBorderSubtle)
                    SettingsActionRow(
                        title = "Decoder Engine",
                        subtitle = "${currentDecoderMode.title} • ${currentDecoderMode.description}",
                        icon = Icons.Outlined.Memory,
                        actionText = currentDecoderMode.shortName,
                        onClick = { showDecoderDialog = true }
                    )
                }
            }

            // 2. Background & Picture-in-Picture Section
            item {
                SettingsSection(title = "BACKGROUND & PIP") {
                    SettingsSwitchRow(
                        title = "Background Audio Playback",
                        subtitle = "Continue audio when leaving the application",
                        icon = Icons.Outlined.Audiotrack,
                        checked = bgPlayback,
                        onCheckedChange = { coroutineScope.launch { preferences.setBackgroundPlaybackEnabled(it) } }
                    )
                    HorizontalDivider(color = AppColors.glassBorderSubtle)
                    SettingsSwitchRow(
                        title = "Auto Picture-in-Picture",
                        subtitle = "Shrink video to floating window on Home gesture",
                        icon = Icons.Outlined.PictureInPictureAlt,
                        checked = autoPip,
                        onCheckedChange = { coroutineScope.launch { preferences.setAutoPipEnabled(it) } }
                    )
                }
            }

            // 3. Subtitles Section
            item {
                SettingsSection(title = "SUBTITLES") {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column {
                            Text(text = "Subtitle Font Size", style = AppTypography.cardTitle)
                            Text(text = "${subtitleFontSize}sp", style = AppTypography.caption)
                        }

                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            PichiIconButton(
                                icon = Icons.Default.Remove,
                                contentDescription = "Decrease",
                                onClick = {
                                    if (subtitleFontSize > 12) {
                                        coroutineScope.launch { preferences.setSubtitleFontSize(subtitleFontSize - 2) }
                                    }
                                },
                                size = 34.dp
                            )
                            PichiIconButton(
                                icon = Icons.Default.Add,
                                contentDescription = "Increase",
                                onClick = {
                                    if (subtitleFontSize < 32) {
                                        coroutineScope.launch { preferences.setSubtitleFontSize(subtitleFontSize + 2) }
                                    }
                                },
                                size = 34.dp
                            )
                        }
                    }
                }
            }

            // 4. Library & Storage
            item {
                SettingsSection(title = "LIBRARY & CACHE") {
                    SettingsSwitchRow(
                        title = "Thumbnail Generation",
                        subtitle = "Extract video frame previews in background",
                        icon = Icons.Outlined.Image,
                        checked = generateThumbs,
                        onCheckedChange = { coroutineScope.launch { preferences.setGenerateThumbnails(it) } }
                    )
                    HorizontalDivider(color = AppColors.glassBorderSubtle)
                    SettingsActionRow(
                        title = "Clear Thumbnail Cache",
                        subtitle = "Cached previews ($formattedCacheSize)",
                        icon = Icons.Outlined.DeleteSweep,
                        actionText = "Clear",
                        onClick = { showClearCacheDialog = true }
                    )
                    HorizontalDivider(color = AppColors.glassBorderSubtle)
                    SettingsActionRow(
                        title = "Clear Playback History",
                        subtitle = "Reset progress on all watched videos",
                        icon = Icons.Outlined.History,
                        actionText = "Reset",
                        onClick = { showClearHistoryDialog = true }
                    )
                    HorizontalDivider(color = AppColors.glassBorderSubtle)
                    SettingsActionRow(
                        title = "Rescan Media Storage",
                        subtitle = "Refresh all local files and directories",
                        icon = Icons.Outlined.Refresh,
                        actionText = "Scan",
                        onClick = {
                            coroutineScope.launch {
                                repository.rescan()
                                snackbarMessage = "Scanning storage in background..."
                            }
                        }
                    )
                }
            }

            // 5. Updates & GitHub Releases
            item {
                SettingsSection(title = "UPDATES & RELEASES") {
                    SettingsActionRow(
                        title = "Check for Updates",
                        subtitle = if (isCheckingUpdate) "Contacting GitHub repository..." else "PichiPlayer v1.1.0 (Build 101) • PichiPlayer.apk",
                        icon = Icons.Outlined.SystemUpdate,
                        actionText = if (isCheckingUpdate) "Checking..." else "Check",
                        onClick = {
                            coroutineScope.launch {
                                isCheckingUpdate = true
                                val res = UpdateManager.checkForUpdates(context)
                                updateResult = res
                                isCheckingUpdate = false
                                showUpdateDialog = true
                            }
                        }
                    )
                }
            }

            // 6. Privacy & Offline Guarantee
            item {
                PichiGlassCard(
                    modifier = Modifier.fillMaxWidth(),
                    borderColor = AppColors.electricBlueGlow
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(18.dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.VerifiedUser,
                                contentDescription = null,
                                tint = AppColors.electricBlueBright,
                                modifier = Modifier.size(22.dp)
                            )
                            Text(
                                text = "100% Offline & Private",
                                style = AppTypography.cardTitle.copy(fontWeight = FontWeight.Bold)
                            )
                        }
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = "PIchiPlayer never connects to the internet. No accounts, no cloud sync, no tracking, and no advertisements. Your videos stay solely on this device.",
                            style = AppTypography.caption.copy(color = AppColors.textSecondary, lineHeight = 17.sp)
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "PIchiPlayer v1.0.0-release (Native Android)",
                            style = AppTypography.caption.copy(color = AppColors.textMuted, fontSize = 11.sp)
                        )
                    }
                }
            }

            // 7. Creator & Developer Credit
            item {
                SettingsSection(title = "CREATOR & DEVELOPER") {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(18.dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(14.dp)
                        ) {
                            // Avatar / Initials with gradient ring
                            Box(
                                modifier = Modifier
                                .size(52.dp)
                                .clip(CircleShape)
                                .background(AppColors.brandGradient),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "RS",
                                    style = AppTypography.cardTitle.copy(
                                        color = Color.White,
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 18.sp
                                    )
                                )
                            }

                            Column(modifier = Modifier.weight(1f)) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    Text(
                                        text = "Rabius Sani",
                                        style = AppTypography.cardTitle.copy(
                                            fontWeight = FontWeight.Bold,
                                            fontSize = 17.sp,
                                            color = AppColors.textPrimary
                                        )
                                    )
                                    PichiBadge(text = "Creator", highlight = true)
                                }

                                Spacer(modifier = Modifier.height(3.dp))

                                Text(
                                    text = "Owner & CEO at PichiPie & Freelancer",
                                    style = AppTypography.caption.copy(
                                        color = AppColors.electricBlueBright,
                                        fontWeight = FontWeight.Medium,
                                        fontSize = 12.sp
                                    )
                                )
                            }
                        }

                        Spacer(modifier = Modifier.height(14.dp))
                        HorizontalDivider(color = AppColors.glassBorderSubtle)
                        Spacer(modifier = Modifier.height(12.dp))

                        // Interactive Email Contact Row
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(12.dp))
                                .background(AppColors.surfaceSubtle)
                                .border(1.dp, AppColors.glassBorderSubtle, RoundedCornerShape(12.dp))
                                .clickable {
                                    val intent = Intent(Intent.ACTION_SENDTO).apply {
                                        data = Uri.parse("mailto:mohammad.rabius.sanii@gmail.com")
                                        putExtra(Intent.EXTRA_SUBJECT, "PIchiPlayer Feedback & Inquiry")
                                    }
                                    try {
                                        context.startActivity(intent)
                                    } catch (e: Exception) {
                                        // Ignore if no email client installed
                                    }
                                }
                                .padding(horizontal = 14.dp, vertical = 10.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(10.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Outlined.Email,
                                    contentDescription = "Email",
                                    tint = AppColors.electricBlueBright,
                                    modifier = Modifier.size(20.dp)
                                )
                                Column {
                                    Text(
                                        text = "mohammad.rabius.sanii@gmail.com",
                                        style = AppTypography.caption.copy(
                                            color = AppColors.textPrimary,
                                            fontWeight = FontWeight.SemiBold,
                                            fontSize = 12.5.sp
                                        )
                                    )
                                    Text(
                                        text = "Tap to email creator or hire for projects",
                                        style = AppTypography.caption.copy(
                                            color = AppColors.textMuted,
                                            fontSize = 11.sp
                                        )
                                    )
                                }
                            }

                            Icon(
                                imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                                contentDescription = null,
                                tint = AppColors.textMuted,
                                modifier = Modifier.size(18.dp)
                            )
                        }
                    }
                }
            }
        }

        // Dialogs
        if (showClearCacheDialog) {
            AlertDialog(
                onDismissRequest = { showClearCacheDialog = false },
                title = { Text(text = "Clear Thumbnail Cache", style = AppTypography.sectionHeader) },
                text = { Text(text = "Are you sure you want to delete all cached video preview thumbnails? They will be re-extracted as needed.", style = AppTypography.bodyMedium) },
                confirmButton = {
                    TextButton(onClick = {
                        thumbnailCache.clearCache()
                        cacheSizeBytes = 0L
                        showClearCacheDialog = false
                    }) {
                        Text(text = "Clear Cache", color = AppColors.errorBright)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showClearCacheDialog = false }) {
                        Text(text = "Cancel", color = AppColors.textPrimary)
                    }
                },
                containerColor = AppColors.surface,
                shape = RoundedCornerShape(18.dp)
            )
        }

        if (showClearHistoryDialog) {
            AlertDialog(
                onDismissRequest = { showClearHistoryDialog = false },
                title = { Text(text = "Reset Playback History", style = AppTypography.sectionHeader) },
                text = { Text(text = "Are you sure you want to clear playback positions for all watched videos?", style = AppTypography.bodyMedium) },
                confirmButton = {
                    TextButton(onClick = {
                        coroutineScope.launch { repository.clearPlaybackHistory() }
                        showClearHistoryDialog = false
                    }) {
                        Text(text = "Reset", color = AppColors.errorBright)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showClearHistoryDialog = false }) {
                        Text(text = "Cancel", color = AppColors.textPrimary)
                    }
                },
                containerColor = AppColors.surface,
                shape = RoundedCornerShape(18.dp)
            )
        }

        if (showDecoderDialog) {
            DecoderSelectionDialog(
                currentMode = currentDecoderMode,
                onSelectMode = { mode ->
                    coroutineScope.launch {
                        preferences.setDecoderMode(mode.code)
                        playerManager.setDecoderMode(mode)
                        snackbarMessage = "Decoder set to ${mode.title}"
                    }
                },
                onDismiss = { showDecoderDialog = false }
            )
        }

        if (showUpdateDialog) {
            val info = when (val res = updateResult) {
                is UpdateCheckResult.Available -> res.info
                is UpdateCheckResult.UpToDate -> res.info
                is UpdateCheckResult.Error -> res.fallbackInfo ?: UpdateManager.getLocalBundledInfo(context)
                null -> UpdateManager.getLocalBundledInfo(context)
            }
            val isAvail = updateResult is UpdateCheckResult.Available

            if (info != null) {
                UpdateDialog(
                    updateInfo = info,
                    isUpdateAvailable = isAvail,
                    onDismiss = { showUpdateDialog = false }
                )
            }
        }
    }
}

@Composable
private fun SettingsSection(
    title: String,
    content: @Composable ColumnScope.() -> Unit
) {
    Column {
        Text(
            text = title,
            style = AppTypography.caption.copy(
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.2.sp,
                color = AppColors.textMuted
            ),
            modifier = Modifier.padding(start = 4.dp, bottom = 8.dp)
        )
        PichiGlassCard(
            modifier = Modifier.fillMaxWidth(),
            content = {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    content = content
                )
            }
        )
    }
}

@Composable
private fun SettingsSwitchRow(
    title: String,
    subtitle: String,
    icon: ImageVector,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onCheckedChange(!checked) }
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp),
            modifier = Modifier.weight(1f)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = AppColors.electricBlueBright,
                modifier = Modifier.size(22.dp)
            )
            Column {
                Text(text = title, style = AppTypography.cardTitle)
                Spacer(modifier = Modifier.height(2.dp))
                Text(text = subtitle, style = AppTypography.caption.copy(color = AppColors.textSecondary))
            }
        }

        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(
                checkedThumbColor = Color.White,
                checkedTrackColor = AppColors.electricBlue,
                uncheckedThumbColor = AppColors.textMuted,
                uncheckedTrackColor = AppColors.surfaceSubtle
            )
        )
    }
}

@Composable
private fun SettingsActionRow(
    title: String,
    subtitle: String,
    icon: ImageVector,
    actionText: String,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp),
            modifier = Modifier.weight(1f)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = AppColors.electricBlueBright,
                modifier = Modifier.size(22.dp)
            )
            Column {
                Text(text = title, style = AppTypography.cardTitle)
                Spacer(modifier = Modifier.height(2.dp))
                Text(text = subtitle, style = AppTypography.caption.copy(color = AppColors.textSecondary))
            }
        }

        PichiButton(
            text = actionText,
            onClick = onClick,
            isSecondary = true,
            contentPadding = PaddingValues(horizontal = 14.dp, vertical = 6.dp)
        )
    }
}



