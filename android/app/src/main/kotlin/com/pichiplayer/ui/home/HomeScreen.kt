package com.pichiplayer.ui.home

import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.annotation.OptIn
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.media3.common.util.UnstableApi
import androidx.media3.ui.AspectRatioFrameLayout
import androidx.media3.ui.PlayerView
import com.pichiplayer.PichiPlayerApp
import com.pichiplayer.data.database.VideoEntity
import com.pichiplayer.ui.components.*
import com.pichiplayer.ui.states.EmptyLibraryState
import com.pichiplayer.ui.states.MediaScannerLoadingState
import com.pichiplayer.ui.theme.AppColors
import com.pichiplayer.ui.theme.AppDesignTokens
import androidx.compose.ui.platform.LocalContext
import com.pichiplayer.data.update.UpdateManager
import com.pichiplayer.ui.theme.AppTypography
import kotlinx.coroutines.launch

@OptIn(UnstableApi::class)
@Composable
fun HomeScreen(
    onPlayVideo: (VideoEntity, List<VideoEntity>) -> Unit,
    onExpandFullscreen: () -> Unit,
    onVideoDetails: (Long) -> Unit,
    onNavigateSearch: () -> Unit,
    onNavigateLibrary: () -> Unit,
    onSelectCustomFolder: () -> Unit,
    modifier: Modifier = Modifier
) {
    val repository = PichiPlayerApp.instance.repository
    val preferences = PichiPlayerApp.instance.preferences
    val scanner = PichiPlayerApp.instance.scanner
    val playerManager = PichiPlayerApp.instance.playerManager
    val coroutineScope = rememberCoroutineScope()
    val context = LocalContext.current

    val continueWatching by repository.continueWatchingVideos.collectAsState(initial = emptyList())
    val recentlyAdded by repository.recentlyAddedVideos.collectAsState(initial = emptyList())
    val fourKVideos by repository.fourKVideos.collectAsState(initial = emptyList())
    val allVideos by repository.allVideos.collectAsState(initial = emptyList())
    val scanProgress by scanner.scanProgress.collectAsState()
    val playerUiState by playerManager.uiState.collectAsState()
    val lastSeenVersion by preferences.lastSeenVersionCode.collectAsState()

    val currentVersionCode = remember { UpdateManager.getCurrentVersionCode(context) }
    var showWhatsNewDialog by remember { mutableStateOf(false) }

    LaunchedEffect(lastSeenVersion) {
        if (lastSeenVersion < currentVersionCode) {
            showWhatsNewDialog = true
        }
    }

    var isScanning by remember { mutableStateOf(false) }

    LaunchedEffect(scanProgress.isComplete) {
        if (scanProgress.isComplete) {
            isScanning = false
        }
    }

    // Keep reference to inline PlayerView so we cleanly detach on disposal
    var inlinePlayerView by remember { mutableStateOf<PlayerView?>(null) }
    var dismissedInlineVideoId by remember { mutableStateOf<Long?>(null) }
    DisposableEffect(Unit) {
        onDispose {
            inlinePlayerView?.player = null
        }
    }

    val handleExpandFullscreen: () -> Unit = {
        inlinePlayerView?.player = null
        onExpandFullscreen()
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(AppColors.background)
    ) {
        val isFirstRunScanning = allVideos.isEmpty() && (!scanProgress.isComplete || scanProgress.progress < 1.0f)

        if (isFirstRunScanning) {
            MediaScannerLoadingState(
                progress = scanProgress.progress,
                videosFound = scanProgress.videosFound,
                currentFolder = scanProgress.currentFolder
            )
        } else if (allVideos.isEmpty()) {
            EmptyLibraryState(
                onScanClick = {
                    coroutineScope.launch {
                        repository.rescan()
                    }
                },
                onSelectFolderClick = onSelectCustomFolder
            )
        } else {
            Column(modifier = Modifier.fillMaxSize()) {
                // FIXED TOP APP BAR: perfectly respects punchhole display and status bar
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .statusBarsPadding()
                        .displayCutoutPadding()
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(start = 20.dp, end = 20.dp, top = 8.dp, bottom = 6.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        PichiLogo(
                            emblemSize = 28.dp,
                            fontSize = 21.sp
                        )

                        Row(
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            PichiIconButton(
                                icon = Icons.Outlined.Search,
                                contentDescription = "Search",
                                onClick = onNavigateSearch,
                                size = 38.dp
                            )
                            PichiIconButton(
                                icon = Icons.Outlined.Refresh,
                                contentDescription = "Rescan Media",
                                onClick = {
                                    isScanning = true
                                    coroutineScope.launch { repository.rescan() }
                                },
                                size = 38.dp
                            )
                        }
                    }

                    // Background scan banner if active
                    if (!scanProgress.isComplete && scanProgress.progress < 1.0f) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 20.dp, vertical = 4.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            PichiBadge(
                                text = "Indexing storage • ${scanProgress.videosFound} videos found",
                                highlight = true
                            )
                        }
                    }
                }

                // Scrollable Content starts immediately below top bar with zero extra space
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(top = 4.dp, bottom = 24.dp)
                ) {
                    // Smart Hero Card (Screen 02 style)
                    // If video was playing or loaded, play live video inline here
                    val activeVideo = playerUiState.currentVideo
                    val heroVideo = activeVideo ?: continueWatching.firstOrNull() ?: allVideos.firstOrNull()

                    if (heroVideo != null) {
                        val isPlayingInline = activeVideo != null && activeVideo.id == heroVideo.id && dismissedInlineVideoId != heroVideo.id

                        item {
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(horizontal = 20.dp, vertical = 6.dp)
                            ) {
                                PichiGlassCard(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .height(if (isPlayingInline) 276.dp else 252.dp),
                                    shape = RoundedCornerShape(AppDesignTokens.RadiusHero),
                                    onClick = {
                                        if (isPlayingInline) {
                                            handleExpandFullscreen()
                                        } else {
                                            dismissedInlineVideoId = null
                                            onPlayVideo(heroVideo, allVideos)
                                        }
                                    }
                                ) {
                                    if (isPlayingInline) {
                                        // Smart live inline playback
                                        AndroidView(
                                            factory = { ctx ->
                                                PlayerView(ctx).apply {
                                                    player = playerManager.player
                                                    useController = false
                                                    resizeMode = AspectRatioFrameLayout.RESIZE_MODE_ZOOM
                                                    setShutterBackgroundColor(android.graphics.Color.TRANSPARENT)
                                                    setShowBuffering(PlayerView.SHOW_BUFFERING_NEVER)
                                                    layoutParams = FrameLayout.LayoutParams(
                                                        ViewGroup.LayoutParams.MATCH_PARENT,
                                                        ViewGroup.LayoutParams.MATCH_PARENT
                                                    )
                                                    inlinePlayerView = this
                                                }
                                            },
                                            update = { view ->
                                                if (view.player != playerManager.player) {
                                                    view.player = playerManager.player
                                                }
                                            },
                                            modifier = Modifier.fillMaxSize()
                                        )
                                    } else {
                                        PichiVideoThumbnail(
                                            video = heroVideo,
                                            showDuration = false,
                                            showProgress = false,
                                            modifier = Modifier.fillMaxSize()
                                        )
                                    }

                                    // Dark cinematic gradient scrim for legibility
                                    Box(
                                        modifier = Modifier
                                            .fillMaxSize()
                                            .background(
                                                Brush.verticalGradient(
                                                    listOf(
                                                        Color.Black.copy(alpha = 0.35f),
                                                        Color.Transparent,
                                                        AppColors.background.copy(alpha = 0.65f),
                                                        AppColors.background.copy(alpha = 0.98f)
                                                    )
                                                )
                                            )
                                    )

                                    // Top Quick Indicators: Live badge & Close/Fullscreen buttons
                                    Row(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .padding(14.dp)
                                            .align(Alignment.TopStart),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        if (isPlayingInline) {
                                            PichiBadge(
                                                text = if (playerUiState.isPlaying) "NOW PLAYING" else "PAUSED",
                                                highlight = playerUiState.isPlaying
                                            )
                                        } else {
                                            PichiBadge(
                                                text = "FEATURED",
                                                highlight = true
                                            )
                                        }

                                        Row(
                                            verticalAlignment = Alignment.CenterVertically,
                                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                                        ) {
                                            if (isPlayingInline) {
                                                PichiIconButton(
                                                    icon = Icons.Default.Close,
                                                    contentDescription = "Close player",
                                                    onClick = {
                                                        playerManager.player.pause()
                                                        inlinePlayerView?.player = null
                                                        dismissedInlineVideoId = heroVideo.id
                                                    },
                                                    size = 36.dp
                                                )
                                            }

                                            PichiIconButton(
                                                icon = Icons.Default.Fullscreen,
                                                contentDescription = "Expand Fullscreen",
                                                onClick = {
                                                    if (isPlayingInline) {
                                                        handleExpandFullscreen()
                                                    } else {
                                                        dismissedInlineVideoId = null
                                                        onPlayVideo(heroVideo, allVideos)
                                                    }
                                                },
                                                size = 36.dp
                                            )
                                        }
                                    }

                                    // Bottom Hero metadata and controls
                                    Column(
                                        modifier = Modifier
                                            .align(Alignment.BottomStart)
                                            .padding(horizontal = 16.dp, vertical = 14.dp)
                                    ) {
                                        Text(
                                            text = heroVideo.displayName,
                                            style = AppTypography.heroTitle.copy(
                                                fontSize = 17.5.sp,
                                                fontWeight = FontWeight.Bold,
                                                lineHeight = 22.sp
                                            ),
                                            maxLines = 2,
                                            overflow = TextOverflow.Ellipsis
                                        )

                                        Spacer(modifier = Modifier.height(4.dp))

                                        // Tags: 4K / 2K / FHD • HDR • Duration • Folder
                                        Row(
                                            verticalAlignment = Alignment.CenterVertically,
                                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                                        ) {
                                            PichiBadge(
                                                text = heroVideo.resolutionLabel,
                                                highlight = true,
                                                color = when {
                                                    heroVideo.is8K -> Color(0xFFFF5252)
                                                    heroVideo.is4K -> AppColors.brandPrimary
                                                    heroVideo.is2K -> AppColors.cyanAccent
                                                    heroVideo.is1080p -> AppColors.emerald
                                                    heroVideo.is720p -> AppColors.blueAccent
                                                    heroVideo.is3gp -> Color(0xFFFF9800)
                                                    else -> AppColors.textSecondary
                                                }
                                            )
                                            if (heroVideo.formatBadge != null && heroVideo.formatBadge != heroVideo.resolutionBadge) {
                                                PichiBadge(text = heroVideo.formatBadge!!, color = Color(0xFFCE93D8))
                                            }
                                            if (heroVideo.isHdr) {
                                                PichiBadge(text = "HDR", highlight = true, color = AppColors.violetAccent)
                                            }
                                            if (heroVideo.durationMs > 0) {
                                                Text(
                                                    text = heroVideo.formattedDuration,
                                                    style = AppTypography.caption.copy(color = AppColors.textSecondary)
                                                )
                                            }
                                            Text(
                                                text = "•",
                                                style = AppTypography.caption.copy(color = AppColors.textTertiary)
                                            )
                                            Text(
                                                text = heroVideo.folderName,
                                                style = AppTypography.caption.copy(color = AppColors.textSecondary),
                                                maxLines = 1,
                                                overflow = TextOverflow.Ellipsis
                                            )
                                        }

                                        Spacer(modifier = Modifier.height(10.dp))

                                        if (isPlayingInline) {
                                            // Progress bar for active playback
                                            val progress = if (playerUiState.durationMs > 0) {
                                                (playerUiState.currentPositionMs.toFloat() / playerUiState.durationMs).coerceIn(0f, 1f)
                                            } else 0f

                                            Box(
                                                modifier = Modifier
                                                    .fillMaxWidth()
                                                    .height(3.dp)
                                                    .clip(RoundedCornerShape(2.dp))
                                                    .background(AppColors.progressTrack)
                                            ) {
                                                Box(
                                                    modifier = Modifier
                                                        .fillMaxWidth(progress)
                                                        .fillMaxHeight()
                                                        .background(AppColors.electricBlueBright)
                                                )
                                            }

                                            Spacer(modifier = Modifier.height(10.dp))

                                            // Smart Inline Controls: Seek -10s, Play/Pause, Seek +10s, and Fullscreen
                                            Row(
                                                horizontalArrangement = Arrangement.spacedBy(8.dp),
                                                verticalAlignment = Alignment.CenterVertically
                                            ) {
                                                // Rewind 10s
                                                PichiIconButton(
                                                    icon = Icons.Default.Replay10,
                                                    contentDescription = "Rewind 10s",
                                                    onClick = { playerManager.seekBy(-10) },
                                                    size = 38.dp,
                                                    iconSize = 22.dp
                                                )

                                                // Play / Pause
                                                PichiButton(
                                                    text = if (playerUiState.isPlaying) "Pause" else "Play",
                                                    icon = if (playerUiState.isPlaying) Icons.Filled.Pause else Icons.Filled.PlayArrow,
                                                    onClick = { playerManager.togglePlayPause() },
                                                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp)
                                                )

                                                // Forward 10s
                                                PichiIconButton(
                                                    icon = Icons.Default.Forward10,
                                                    contentDescription = "Forward 10s",
                                                    onClick = { playerManager.seekBy(10) },
                                                    size = 38.dp,
                                                    iconSize = 22.dp
                                                )

                                                // Fullscreen
                                                PichiButton(
                                                    text = "Fullscreen",
                                                    icon = Icons.Default.OpenInFull,
                                                    onClick = { handleExpandFullscreen() },
                                                    isSecondary = true,
                                                    contentPadding = PaddingValues(horizontal = 14.dp, vertical = 8.dp)
                                                )
                                            }
                                        } else {
                                            // Action buttons: "Play/Resume" & "Details"
                                            Row(
                                                horizontalArrangement = Arrangement.spacedBy(10.dp),
                                                verticalAlignment = Alignment.CenterVertically
                                            ) {
                                                PichiButton(
                                                    text = if (heroVideo.isPartiallyWatched) "Resume" else "Play",
                                                    icon = Icons.Filled.PlayArrow,
                                                    onClick = {
                                                        dismissedInlineVideoId = null
                                                        onPlayVideo(heroVideo, allVideos)
                                                    },
                                                    contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp)
                                                )

                                                PichiButton(
                                                    text = "Details",
                                                    icon = Icons.Outlined.Info,
                                                    onClick = { onVideoDetails(heroVideo.id) },
                                                    isSecondary = true,
                                                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp)
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Section: Continue Watching Row (if more than 1)
                    if (continueWatching.size > 1) {
                        item {
                            SectionHeader(title = "Resume Playback", onSeeAll = onNavigateLibrary)
                            LazyRow(
                                contentPadding = PaddingValues(horizontal = 20.dp),
                                horizontalArrangement = Arrangement.spacedBy(14.dp)
                            ) {
                                items(continueWatching.drop(1), key = { it.id }) { video ->
                                    VideoCompactCard(
                                        video = video,
                                        onClick = { onPlayVideo(video, continueWatching) },
                                        onMoreClick = { onVideoDetails(video.id) }
                                    )
                                }
                            }
                            Spacer(modifier = Modifier.height(16.dp))
                        }
                    }

                    // Section: Recently Added
                    if (recentlyAdded.isNotEmpty()) {
                        item {
                            SectionHeader(title = "Recently Added", onSeeAll = onNavigateLibrary)
                            LazyRow(
                                contentPadding = PaddingValues(horizontal = 20.dp),
                                horizontalArrangement = Arrangement.spacedBy(14.dp)
                            ) {
                                items(recentlyAdded, key = { it.id }) { video ->
                                    VideoCompactCard(
                                        video = video,
                                        onClick = { onPlayVideo(video, recentlyAdded) },
                                        onMoreClick = { onVideoDetails(video.id) }
                                    )
                                }
                            }
                            Spacer(modifier = Modifier.height(16.dp))
                        }
                    }

                    // Section: 4K Ultra HD Collection
                    if (fourKVideos.isNotEmpty()) {
                        item {
                            SectionHeader(
                                title = "4K Ultra HD",
                                badgeText = "${fourKVideos.size} UHD",
                                onSeeAll = onNavigateLibrary
                            )
                            LazyRow(
                                contentPadding = PaddingValues(horizontal = 20.dp),
                                horizontalArrangement = Arrangement.spacedBy(14.dp)
                            ) {
                                items(fourKVideos, key = { it.id }) { video ->
                                    VideoCompactCard(
                                        video = video,
                                        onClick = { onPlayVideo(video, fourKVideos) },
                                        onMoreClick = { onVideoDetails(video.id) }
                                    )
                                }
                            }
                            Spacer(modifier = Modifier.height(16.dp))
                        }
                    }

                    // Section: Storage Overview Summary Card
                    item {
                        StorageSummaryCard(
                            totalVideos = allVideos.size,
                            totalSizeBytes = allVideos.sumOf { it.fileSize }
                        )
                    }
                }
            }
        }

        if (showWhatsNewDialog) {
            val updateInfo = UpdateManager.getLocalBundledInfo(context)
            if (updateInfo != null) {
                WhatsNewDialog(
                    updateInfo = updateInfo,
                    onGotIt = {
                        coroutineScope.launch {
                            preferences.setLastSeenVersionCode(currentVersionCode)
                        }
                        showWhatsNewDialog = false
                    }
                )
            }
        }
    }
}

@Composable
private fun SectionHeader(
    title: String,
    badgeText: String? = null,
    onSeeAll: (() -> Unit)? = null
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = title,
                style = AppTypography.sectionHeader
            )
            if (badgeText != null) {
                PichiBadge(text = badgeText, highlight = true)
            }
        }

        if (onSeeAll != null) {
            Text(
                text = "See All",
                style = AppTypography.caption.copy(
                    color = AppColors.electricBlueBright,
                    fontWeight = FontWeight.SemiBold
                ),
                modifier = Modifier
                    .clip(RoundedCornerShape(8.dp))
                    .clickable(onClick = onSeeAll)
                    .padding(horizontal = 6.dp, vertical = 4.dp)
            )
        }
    }
}

@Composable
private fun VideoCompactCard(
    video: VideoEntity,
    onClick: () -> Unit,
    onMoreClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .width(160.dp)
            .clickable(onClick = onClick)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(100.dp)
        ) {
            PichiVideoThumbnail(
                video = video,
                thumbnailPath = video.thumbnailPath,
                modifier = Modifier.fillMaxSize()
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.Top,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = video.displayName,
                    style = AppTypography.cardTitle.copy(fontSize = 13.5.sp),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = "${video.formattedFileSize} • ${video.folderName}",
                    style = AppTypography.caption.copy(fontSize = 11.sp),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            IconButton(
                onClick = onMoreClick,
                modifier = Modifier.size(24.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.MoreVert,
                    contentDescription = "Details",
                    tint = AppColors.textMuted,
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
}

@Composable
private fun StorageSummaryCard(
    totalVideos: Int,
    totalSizeBytes: Long
) {
    val formattedSize = remember(totalSizeBytes) {
        val gb = totalSizeBytes.toDouble() / (1024 * 1024 * 1024)
        if (gb >= 1.0) "%.1f GB".format(gb) else "%.0f MB".format(totalSizeBytes.toDouble() / (1024 * 1024))
    }

    PichiGlassCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 12.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(AppColors.surfaceGlass)
                        .border(1.dp, AppColors.glassBorder, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Storage,
                        contentDescription = null,
                        tint = AppColors.electricBlueBright,
                        modifier = Modifier.size(24.dp)
                    )
                }
                Column {
                    Text(
                        text = "Local Video Library",
                        style = AppTypography.cardTitle.copy(fontWeight = FontWeight.Bold)
                    )
                    Text(
                        text = "$totalVideos videos indexed • $formattedSize",
                        style = AppTypography.bodyMedium.copy(color = AppColors.textSecondary)
                    )
                }
            }

            PichiBadge(text = "100% Offline", highlight = true)
        }
    }
}
