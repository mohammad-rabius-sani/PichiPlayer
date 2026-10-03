package com.pichiplayer.ui.player

import android.app.Activity
import android.content.Context
import android.media.AudioManager
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.annotation.OptIn
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.automirrored.filled.VolumeDown
import androidx.compose.material.icons.automirrored.filled.VolumeMute
import androidx.compose.material.icons.automirrored.filled.VolumeUp
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import android.content.pm.ActivityInfo
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.rememberScrollState
import androidx.compose.ui.viewinterop.AndroidView
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.ui.PlayerView
import com.pichiplayer.PichiPlayerApp
import com.pichiplayer.media.playback.DecoderMode
import com.pichiplayer.media.playback.TrackInfo
import com.pichiplayer.media.playback.VideoScalingMode
import com.pichiplayer.ui.components.*
import com.pichiplayer.ui.states.PlaybackErrorState
import com.pichiplayer.ui.theme.AppColors
import com.pichiplayer.ui.theme.AppDesignTokens
import com.pichiplayer.ui.theme.AppTypography
import kotlinx.coroutines.delay
import kotlin.math.roundToInt

@OptIn(UnstableApi::class)
@Composable
fun PlayerScreen(
    onBackClick: () -> Unit,
    onEnterPiP: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val activity = context as? Activity
    val playerManager = PichiPlayerApp.instance.playerManager
    val playerUiState by playerManager.uiState.collectAsState()
    val isInPipMode by playerManager.isInPipMode.collectAsState()

    // 1 = Landscape, 2 = Portrait
    var orientationMode by remember { mutableIntStateOf(2) }

    // Start in PORTRAIT by default; Rotate button switches to Landscape
    DisposableEffect(Unit) {
        val window = activity?.window
        if (window != null) {
            val insetsController = WindowInsetsControllerCompat(window, window.decorView)
            insetsController.systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            insetsController.hide(WindowInsetsCompat.Type.systemBars())
        }

        // Always open in portrait mode first
        activity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        orientationMode = 2

        onDispose {
            activity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
            if (window != null) {
                val insetsController = WindowInsetsControllerCompat(window, window.decorView)
                insetsController.show(WindowInsetsCompat.Type.systemBars())
            }
        }
    }

    // Reference to PlayerView for clean detachment on disposal
    var playerViewRef by remember { mutableStateOf<PlayerView?>(null) }
    DisposableEffect(Unit) {
        onDispose {
            playerViewRef?.player = null
        }
    }

    // Controls visibility & auto-hide timer
    var areControlsVisible by remember { mutableStateOf(true) }
    var lastInteractionTime by remember { mutableLongStateOf(System.currentTimeMillis()) }

    // Gesture feedback HUD states
    var hudBrightness by remember { mutableStateOf<Float?>(null) }
    var hudVolume by remember { mutableStateOf<Int?>(null) }
    var doubleTapFeedback by remember { mutableStateOf<String?>(null) }

    // Screen sheets (Screens 08, 10, 11, 12, 13, 14, 15, 16)
    var showAdvancedSheet by remember { mutableStateOf(false) }
    var showAudioSheet by remember { mutableStateOf(false) }
    var showSubtitleSheet by remember { mutableStateOf(false) }
    var showSubtitleStyleSheet by remember { mutableStateOf(false) }
    var showSpeedSheet by remember { mutableStateOf(false) }
    var showScalingSheet by remember { mutableStateOf(false) }
    var showSleepTimerSheet by remember { mutableStateOf(false) }
    var showAbRepeatSheet by remember { mutableStateOf(false) }
    var showStatsOverlay by remember { mutableStateOf(false) }
    var isSoftwareDecoder by remember { mutableStateOf(false) }

    // Auto-hide controls after 4.5 seconds of inactivity if playing and not locked
    LaunchedEffect(areControlsVisible, playerUiState.isPlaying, lastInteractionTime, playerUiState.isScreenLocked, isInPipMode) {
        if (isInPipMode) {
            areControlsVisible = false
        } else if (areControlsVisible && playerUiState.isPlaying && !playerUiState.isScreenLocked) {
            delay(4500L)
            areControlsVisible = false
        }
    }

    // Instantly hide all overlays when entering PiP mode to eliminate any overlay flash
    LaunchedEffect(isInPipMode) {
        if (isInPipMode) {
            areControlsVisible = false
            showAdvancedSheet = false
            showAudioSheet = false
            showSubtitleSheet = false
            showSubtitleStyleSheet = false
            showSpeedSheet = false
            showScalingSheet = false
            showSleepTimerSheet = false
            showAbRepeatSheet = false
            showStatsOverlay = false
            hudBrightness = null
            hudVolume = null
            doubleTapFeedback = null
        }
    }

    val handleEnterPiP: () -> Unit = {
        areControlsVisible = false
        showAdvancedSheet = false
        playerManager.setInPipMode(true)
        onEnterPiP()
    }

    // Dismiss HUD overlay after delay
    LaunchedEffect(hudBrightness, hudVolume, doubleTapFeedback) {
        if (hudBrightness != null || hudVolume != null || doubleTapFeedback != null) {
            delay(1500L)
            hudBrightness = null
            hudVolume = null
            doubleTapFeedback = null
        }
    }

    val audioManager = remember { context.getSystemService(Context.AUDIO_SERVICE) as AudioManager }
    val maxVolume = remember { audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC) }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(Color.Black)
    ) {
        // Playback Error State
        if (playerUiState.isDecoderError) {
            PlaybackErrorState(
                errorMessage = playerUiState.decoderErrorMessage,
                onRetryClick = {
                    playerUiState.currentVideo?.let { playerManager.playVideo(it) }
                },
                onBackClick = onBackClick
            )
            return@Box
        }

        // 1. Fullscreen Video Surface via Media3 PlayerView
        AndroidView(
            factory = { ctx ->
                PlayerView(ctx).apply {
                    player = playerManager.player
                    useController = false
                    resizeMode = playerUiState.scalingMode.resizeMode
                    keepScreenOn = true
                    setShutterBackgroundColor(android.graphics.Color.TRANSPARENT)
                    setShowBuffering(PlayerView.SHOW_BUFFERING_NEVER)
                    layoutParams = FrameLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    )
                    playerViewRef = this
                }
            },
            update = { view ->
                if (view.player != playerManager.player) {
                    view.player = playerManager.player
                }
                view.resizeMode = playerUiState.scalingMode.resizeMode
            },
            modifier = Modifier.fillMaxSize()
        )

        // 2. Gesture Detector Layer
        if (!playerUiState.isScreenLocked && !isInPipMode) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .pointerInput(Unit) {
                        detectTapGestures(
                            onTap = {
                                areControlsVisible = !areControlsVisible
                                lastInteractionTime = System.currentTimeMillis()
                            },
                            onDoubleTap = { offset ->
                                val screenWidth = size.width
                                if (offset.x < screenWidth * 0.4f) {
                                    playerManager.seekBy(-10)
                                    doubleTapFeedback = "-10s"
                                } else if (offset.x > screenWidth * 0.6f) {
                                    playerManager.seekBy(10)
                                    doubleTapFeedback = "+10s"
                                } else {
                                    playerManager.togglePlayPause()
                                }
                                lastInteractionTime = System.currentTimeMillis()
                            }
                        )
                    }
                    .pointerInput(Unit) {
                        detectVerticalDragGestures(
                            onDragEnd = {
                                hudBrightness = null
                                hudVolume = null
                            },
                            onVerticalDrag = { change, dragAmount ->
                                val screenWidth = size.width
                                val isLeftSide = change.position.x < screenWidth / 2
                                val delta = -dragAmount / 400f

                                if (isLeftSide && activity != null) {
                                    val lp = activity.window.attributes
                                    val current = if (lp.screenBrightness < 0f) 0.5f else lp.screenBrightness
                                    val newBri = (current + delta).coerceIn(0.01f, 1.0f)
                                    lp.screenBrightness = newBri
                                    activity.window.attributes = lp
                                    hudBrightness = newBri
                                } else {
                                    val curVol = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                                    val volDelta = if (delta > 0) 1 else if (delta < 0) -1 else 0
                                    val newVol = (curVol + volDelta).coerceIn(0, maxVolume)
                                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, newVol, 0)
                                    hudVolume = newVol
                                }
                                lastInteractionTime = System.currentTimeMillis()
                            }
                        )
                    }
            )
        }

        // 3. Screen Lock Floating Unlocker (Screen 17)
        if (playerUiState.isScreenLocked && !isInPipMode) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = {
                            playerManager.unlockScreen()
                            areControlsVisible = true
                        }
                    )
            ) {
                // Floating subtle Lock pill in top corner
                Box(
                    modifier = Modifier
                        .statusBarsPadding()
                        .displayCutoutPadding()
                        .padding(20.dp)
                        .clip(RoundedCornerShape(24.dp))
                        .background(Color.Black.copy(alpha = 0.75f))
                        .border(1.dp, AppColors.electricBlueGlow, RoundedCornerShape(24.dp))
                        .clickable {
                            playerManager.unlockScreen()
                            areControlsVisible = true
                        }
                        .padding(horizontal = 16.dp, vertical = 10.dp)
                        .align(Alignment.TopStart)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Lock,
                            contentDescription = "Screen Locked",
                            tint = AppColors.electricBlueBright,
                            modifier = Modifier.size(18.dp)
                        )
                        Text(
                            text = "Locked • Tap to unlock",
                            style = AppTypography.caption.copy(
                                color = AppColors.textPrimary,
                                fontWeight = FontWeight.SemiBold
                            )
                        )
                    }
                }
            }
        }

        // 4. Gesture HUD Overlays (Screen 09)
        if (!isInPipMode) {
            GestureHudOverlay(
                brightness = hudBrightness,
                volume = hudVolume,
                maxVolume = maxVolume,
                doubleTapText = doubleTapFeedback,
                modifier = Modifier.align(Alignment.Center)
            )
        }

        // 5. On-Screen Tech Statistics Overlay
        if (showStatsOverlay && playerUiState.currentVideo != null && !isInPipMode) {
            val vid = playerUiState.currentVideo!!
            PichiGlassCard(
                modifier = Modifier
                    .statusBarsPadding()
                    .displayCutoutPadding()
                    .padding(16.dp)
                    .widthIn(max = 260.dp)
                    .align(Alignment.TopEnd),
                backgroundColor = Color.Black.copy(alpha = 0.85f),
                borderColor = AppColors.electricBlueGlow
            ) {
                Column(
                    modifier = Modifier.padding(12.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text(text = "Statistics", style = AppTypography.caption.copy(color = AppColors.electricBlueBright, fontWeight = FontWeight.Bold))
                    Text(text = "Resolution: ${vid.width}x${vid.height} (${vid.resolutionLabel})", style = AppTypography.caption.copy(fontSize = 11.sp))
                    Text(text = "Video Codec: ${vid.videoCodec ?: "Auto"}", style = AppTypography.caption.copy(fontSize = 11.sp))
                    Text(text = "Audio Codec: ${vid.audioCodec ?: "Auto"}", style = AppTypography.caption.copy(fontSize = 11.sp))
                    Text(text = "Decoder: ${if (isSoftwareDecoder) "Software" else "Hardware (Default)"}", style = AppTypography.caption.copy(fontSize = 11.sp))
                    Text(text = "File Size: ${vid.formattedFileSize}", style = AppTypography.caption.copy(fontSize = 11.sp))
                }
            }
        }

        // 6. Professional Controls Overlay (Screen 07)
        AnimatedVisibility(
            visible = areControlsVisible && !playerUiState.isScreenLocked && !isInPipMode,
            enter = fadeIn(tween(180)),
            exit = fadeOut(tween(140)),
            modifier = Modifier.fillMaxSize()
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.45f))
            ) {
                // TOP BAR (With Subtitles & PiP beside animated Rotate and 3-dots)
                AnimatedVisibility(
                    visible = areControlsVisible && !playerUiState.isScreenLocked && !isInPipMode,
                    enter = slideInVertically(
                        initialOffsetY = { -it },
                        animationSpec = spring(stiffness = Spring.StiffnessMediumLow)
                    ) + fadeIn(),
                    exit = slideOutVertically(
                        targetOffsetY = { -it },
                        animationSpec = spring(stiffness = Spring.StiffnessMediumLow)
                    ) + fadeOut(),
                    modifier = Modifier.align(Alignment.TopCenter)
                ) {
                    val curVid = playerUiState.currentVideo
                    val resColor = when {
                        curVid?.is8K == true -> Color(0xFFFF5252)
                        curVid?.is4K == true -> AppColors.brandPrimary
                        curVid?.is2K == true -> AppColors.cyanAccent
                        curVid?.is1080p == true -> AppColors.emerald
                        curVid?.is720p == true -> AppColors.blueAccent
                        curVid?.is3gp == true -> Color(0xFFFF9800)
                        else -> AppColors.cyanAccent
                    }
                    PlayerTopBar(
                        title = curVid?.displayName ?: "Video",
                        resolutionBadge = curVid?.resolutionBadge,
                        resolutionColor = resColor,
                        formatBadge = curVid?.formatBadge,
                        isHdr = curVid?.isHdr == true,
                        isSleepTimerActive = playerUiState.isSleepTimerActive,
                        hasActiveSubtitles = playerUiState.subtitleTracks.any { it.isSelected },
                        isLandscape = orientationMode == 1,
                        onBackClick = onBackClick,
                        onToggleRotation = {
                            if (orientationMode == 2) {
                                activity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
                                orientationMode = 1
                                doubleTapFeedback = "Landscape"
                            } else {
                                activity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
                                orientationMode = 2
                                doubleTapFeedback = "Portrait"
                            }
                            lastInteractionTime = System.currentTimeMillis()
                        },
                        onSubtitlesClick = {
                            showSubtitleSheet = true
                            lastInteractionTime = System.currentTimeMillis()
                        },
                        onEnterPiP = handleEnterPiP,
                        onAdvancedClick = { showAdvancedSheet = true }
                    )
                }

                // CENTER PLAY / PAUSE & SKIP CONTROLS (Spring scale micro-animation)
                val playPausePulse by animateFloatAsState(
                    targetValue = if (playerUiState.isPlaying) 1f else 1.08f,
                    animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy, stiffness = Spring.StiffnessMedium),
                    label = "playPausePulse"
                )

                AnimatedVisibility(
                    visible = areControlsVisible && !playerUiState.isScreenLocked && !isInPipMode,
                    enter = scaleIn(
                        initialScale = 0.85f,
                        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy)
                    ) + fadeIn(),
                    exit = scaleOut(
                        targetScale = 0.88f,
                        animationSpec = spring(stiffness = Spring.StiffnessMedium)
                    ) + fadeOut(),
                    modifier = Modifier.align(Alignment.Center)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 24.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(24.dp)
                    ) {
                        // Previous
                        PichiIconButton(
                            icon = Icons.Default.SkipPrevious,
                            contentDescription = "Previous",
                            onClick = {
                                playerManager.playPrevious()
                                lastInteractionTime = System.currentTimeMillis()
                            },
                            size = 46.dp,
                            iconSize = 24.dp
                        )

                        // Rewind 10s
                        PichiIconButton(
                            icon = Icons.Default.Replay10,
                            contentDescription = "Rewind 10s",
                            onClick = {
                                playerManager.seekBy(-10)
                                lastInteractionTime = System.currentTimeMillis()
                            },
                            size = 50.dp,
                            iconSize = 26.dp
                        )

                        // Center Glowing Play/Pause Badge with pulse micro-animation
                        Box(
                            modifier = Modifier
                                .scale(playPausePulse)
                                .size(72.dp)
                                .clip(CircleShape)
                                .background(AppColors.brandGradient)
                                .border(2.dp, AppColors.electricBlueBright, CircleShape)
                                .clickable {
                                    playerManager.togglePlayPause()
                                    lastInteractionTime = System.currentTimeMillis()
                                },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = if (playerUiState.isPlaying) Icons.Filled.Pause else Icons.Filled.PlayArrow,
                                contentDescription = if (playerUiState.isPlaying) "Pause" else "Play",
                                tint = Color.White,
                                modifier = Modifier.size(38.dp)
                            )
                        }

                        // Forward 10s
                        PichiIconButton(
                            icon = Icons.Default.Forward10,
                            contentDescription = "Forward 10s",
                            onClick = {
                                playerManager.seekBy(10)
                                lastInteractionTime = System.currentTimeMillis()
                            },
                            size = 50.dp,
                            iconSize = 26.dp
                        )

                        // Next
                        PichiIconButton(
                            icon = Icons.Default.SkipNext,
                            contentDescription = "Next",
                            onClick = {
                                playerManager.playNext()
                                lastInteractionTime = System.currentTimeMillis()
                            },
                            size = 46.dp,
                            iconSize = 24.dp
                        )
                    }
                }

                // BOTTOM TIMELINE SCRUBBER & QUICK CONTROLS (Screen 07 style)
                AnimatedVisibility(
                    visible = areControlsVisible && !playerUiState.isScreenLocked && !isInPipMode,
                    enter = slideInVertically(
                        initialOffsetY = { it },
                        animationSpec = spring(stiffness = Spring.StiffnessMediumLow)
                    ) + fadeIn(),
                    exit = slideOutVertically(
                        targetOffsetY = { it },
                        animationSpec = spring(stiffness = Spring.StiffnessMediumLow)
                    ) + fadeOut(),
                    modifier = Modifier.align(Alignment.BottomCenter)
                ) {
                    PlayerBottomControls(
                        currentPosMs = playerUiState.currentPositionMs,
                        durationMs = playerUiState.durationMs,
                        bufferedPosMs = playerUiState.bufferedPositionMs,
                        scalingMode = playerUiState.scalingMode,
                        repeatMode = playerUiState.repeatMode,
                        isAbRepeatActive = playerUiState.abRepeat.isEnabled,
                        playbackSpeed = playerUiState.playbackSpeed,
                        decoderMode = playerUiState.decoderMode,
                        onSeek = { targetMs ->
                            playerManager.seekTo(targetMs)
                            lastInteractionTime = System.currentTimeMillis()
                        },
                        onToggleLock = { playerManager.toggleScreenLock() },
                        onCycleScaling = {
                            val next = playerManager.cycleScalingMode()
                            doubleTapFeedback = next.shortName
                            lastInteractionTime = System.currentTimeMillis()
                        },
                        onCycleRepeat = {
                            val next = playerManager.cycleRepeatMode()
                            doubleTapFeedback = when (next) {
                                Player.REPEAT_MODE_ONE -> "Repeat One"
                                Player.REPEAT_MODE_ALL -> "Repeat All"
                                else -> "Repeat Off"
                            }
                            lastInteractionTime = System.currentTimeMillis()
                        },
                        onCycleDecoder = {
                            val next = playerManager.cycleDecoderMode()
                            doubleTapFeedback = "Decoder: ${next.shortName}"
                            lastInteractionTime = System.currentTimeMillis()
                        },
                        onSpeedClick = {
                            showSpeedSheet = true
                            lastInteractionTime = System.currentTimeMillis()
                        }
                    )
                }
            }
        }

        // 7. MODAL BOTTOM SHEETS (Screen 08, 10, 11, 12, 13, 14, 15, 16)
        if (showAdvancedSheet && !isInPipMode) {
            AdvancedControlsBottomSheet(
                currentSpeed = playerUiState.playbackSpeed,
                scalingMode = playerUiState.scalingMode,
                isSleepTimerActive = playerUiState.isSleepTimerActive,
                sleepTimerSecs = playerUiState.sleepTimerRemainingSeconds,
                abRepeatActive = playerUiState.abRepeat.isEnabled,
                audioTracksCount = playerUiState.audioTracks.size,
                selectedAudioTrack = playerUiState.audioTracks.firstOrNull { it.isSelected }?.name ?: "Default (Stereo)",
                selectedSubtitle = playerUiState.subtitleTracks.firstOrNull { it.isSelected }?.name ?: "Off",
                isSoftwareDecoder = isSoftwareDecoder,
                statsActive = showStatsOverlay,
                onOpenAudioTracks = {
                    showAdvancedSheet = false
                    showAudioSheet = true
                },
                onOpenSubtitles = {
                    showAdvancedSheet = false
                    showSubtitleSheet = true
                },
                onOpenSpeed = {
                    showAdvancedSheet = false
                    showSpeedSheet = true
                },
                onOpenScaling = {
                    showAdvancedSheet = false
                    showScalingSheet = true
                },
                onOpenSleepTimer = {
                    showAdvancedSheet = false
                    showSleepTimerSheet = true
                },
                onOpenAbRepeat = {
                    showAdvancedSheet = false
                    showAbRepeatSheet = true
                },
                onToggleLock = {
                    showAdvancedSheet = false
                    playerManager.toggleScreenLock()
                },
                onToggleDecoder = {
                    val nextMode = playerManager.cycleDecoderMode()
                    doubleTapFeedback = "Decoder: ${nextMode.title}"
                },
                onToggleStats = {
                    showStatsOverlay = !showStatsOverlay
                },
                onOpenPiP = {
                    showAdvancedSheet = false
                    handleEnterPiP()
                },
                onDismiss = { showAdvancedSheet = false }
            )
        }

        // Screen 12: Audio Track Selection Sheet
        if (showAudioSheet) {
            AudioTrackSelectionBottomSheet(
                tracks = playerUiState.audioTracks,
                onSelectTrack = { index ->
                    playerManager.selectAudioTrack(index)
                    showAudioSheet = false
                },
                onDismiss = { showAudioSheet = false }
            )
        }

        // Screen 10: Subtitle Selection Sheet
        if (showSubtitleSheet) {
            SubtitleSelectionBottomSheet(
                tracks = playerUiState.subtitleTracks,
                onSelectSubtitle = { index ->
                    playerManager.selectSubtitleTrack(index)
                    showSubtitleSheet = false
                },
                onOpenStyle = {
                    showSubtitleSheet = false
                    showSubtitleStyleSheet = true
                },
                onDismiss = { showSubtitleSheet = false }
            )
        }

        // Screen 11: Subtitle Style Customization Sheet
        if (showSubtitleStyleSheet) {
            SubtitleStyleBottomSheet(
                onDismiss = { showSubtitleStyleSheet = false }
            )
        }

        // Screen 13: Playback Speed Sheet
        if (showSpeedSheet) {
            PlaybackSpeedBottomSheet(
                currentSpeed = playerUiState.playbackSpeed,
                onSelectSpeed = { spd ->
                    playerManager.setPlaybackSpeed(spd)
                    showSpeedSheet = false
                },
                onDismiss = { showSpeedSheet = false }
            )
        }

        // Screen 14: Video Scaling Sheet
        if (showScalingSheet) {
            VideoScalingBottomSheet(
                currentMode = playerUiState.scalingMode,
                onSelectMode = { mode ->
                    playerManager.setScalingMode(mode)
                    showScalingSheet = false
                },
                onDismiss = { showScalingSheet = false }
            )
        }

        // Screen 15: Sleep Timer Sheet
        if (showSleepTimerSheet) {
            SleepTimerBottomSheet(
                isActive = playerUiState.isSleepTimerActive,
                remainingSeconds = playerUiState.sleepTimerRemainingSeconds,
                onSetMinutes = { mins -> playerManager.setSleepTimerMinutes(mins) },
                onSetEndOfVideo = { playerManager.setSleepTimerEndOfVideo() },
                onExtend = { playerManager.extendSleepTimer(15) },
                onCancel = { playerManager.cancelSleepTimer() },
                onDismiss = { showSleepTimerSheet = false }
            )
        }

        // Screen 16: A-B Repeat Sheet
        if (showAbRepeatSheet) {
            AbRepeatBottomSheet(
                state = playerUiState.abRepeat,
                currentPositionMs = playerUiState.currentPositionMs,
                onSetA = { playerManager.setPointA() },
                onSetB = { playerManager.setPointB() },
                onToggle = { playerManager.toggleAbRepeat() },
                onClear = { playerManager.clearAbRepeat() },
                onDismiss = { showAbRepeatSheet = false }
            )
        }
    }
}

// -------------------------------------------------------------
// PLAYER SUBCOMPONENTS (Screens 07, 08, 09, etc.)
// -------------------------------------------------------------

@Composable
private fun PlayerTopBar(
    title: String,
    resolutionBadge: String?,
    resolutionColor: Color,
    formatBadge: String?,
    isHdr: Boolean,
    isSleepTimerActive: Boolean,
    hasActiveSubtitles: Boolean,
    isLandscape: Boolean,
    onBackClick: () -> Unit,
    onToggleRotation: () -> Unit,
    onSubtitlesClick: () -> Unit,
    onEnterPiP: () -> Unit,
    onAdvancedClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val rotateAngle by animateFloatAsState(
        targetValue = if (isLandscape) 90f else 0f,
        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy, stiffness = Spring.StiffnessMediumLow),
        label = "rotateAngle"
    )

    Row(
        modifier = modifier
            .fillMaxWidth()
            .statusBarsPadding()
            .displayCutoutPadding()
            .padding(horizontal = 14.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.weight(1f)
        ) {
            PichiIconButton(
                icon = Icons.AutoMirrored.Filled.ArrowBack,
                contentDescription = "Back",
                onClick = onBackClick,
                size = 38.dp
            )

            Text(
                text = title,
                style = AppTypography.cardTitle.copy(
                    fontSize = 15.sp,
                    fontWeight = FontWeight.SemiBold
                ),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            if (!resolutionBadge.isNullOrEmpty()) {
                PichiBadge(text = resolutionBadge, highlight = true, color = resolutionColor)
            }
            if (!formatBadge.isNullOrEmpty() && formatBadge != resolutionBadge) {
                PichiBadge(text = formatBadge, color = Color(0xFFCE93D8))
            }
            if (isHdr) {
                PichiBadge(text = "HDR", highlight = true, color = AppColors.violetAccent)
            }
        }

        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            // Subtitles toggle / chooser
            PichiIconButton(
                icon = Icons.Outlined.Subtitles,
                contentDescription = "Subtitles",
                onClick = onSubtitlesClick,
                tint = if (hasActiveSubtitles) AppColors.electricBlueBright else AppColors.textPrimary,
                size = 38.dp
            )

            // Picture in Picture
            PichiIconButton(
                icon = Icons.Outlined.PictureInPictureAlt,
                contentDescription = "Picture in Picture",
                onClick = onEnterPiP,
                size = 38.dp
            )

            // Orientation rotate button with bouncy swivel micro-animation
            Box(modifier = Modifier.graphicsLayer { rotationZ = rotateAngle }) {
                PichiIconButton(
                    icon = Icons.Default.ScreenRotation,
                    contentDescription = "Rotate Screen",
                    onClick = onToggleRotation,
                    size = 38.dp
                )
            }

            // 3-dots Menu button -> Screen 08 Advanced Controls
            PichiIconButton(
                icon = Icons.Default.MoreVert,
                contentDescription = "Advanced Controls",
                onClick = onAdvancedClick,
                tint = if (isSleepTimerActive) AppColors.electricBlueBright else AppColors.textPrimary,
                size = 38.dp
            )
        }
    }
}

@Composable
private fun PlayerBottomControls(
    currentPosMs: Long,
    durationMs: Long,
    bufferedPosMs: Long,
    scalingMode: VideoScalingMode,
    repeatMode: Int,
    isAbRepeatActive: Boolean,
    playbackSpeed: Float,
    decoderMode: DecoderMode,
    onSeek: (Long) -> Unit,
    onToggleLock: () -> Unit,
    onCycleScaling: () -> Unit,
    onCycleRepeat: () -> Unit,
    onCycleDecoder: () -> Unit,
    onSpeedClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .displayCutoutPadding()
            .padding(horizontal = 16.dp, vertical = 6.dp)
    ) {
        // Scrubber Timeline Slider
        val progress = if (durationMs > 0) (currentPosMs.toFloat() / durationMs).coerceIn(0f, 1f) else 0f
        var isDragging by remember { mutableStateOf(false) }
        var dragProgress by remember { mutableFloatStateOf(0f) }

        Slider(
            value = if (isDragging) dragProgress else progress,
            onValueChange = {
                isDragging = true
                dragProgress = it
            },
            onValueChangeFinished = {
                isDragging = false
                onSeek((dragProgress * durationMs).toLong())
            },
            colors = SliderDefaults.colors(
                thumbColor = AppColors.electricBlueBright,
                activeTrackColor = AppColors.electricBlue,
                inactiveTrackColor = AppColors.progressTrack
            ),
            modifier = Modifier.fillMaxWidth()
        )

        // Time indicators Row
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 4.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            val curFormatted = formatDuration(if (isDragging) (dragProgress * durationMs).toLong() else currentPosMs)
            val durFormatted = formatDuration(durationMs)
            Text(
                text = "$curFormatted / $durFormatted",
                style = AppTypography.caption.copy(
                    fontSize = 12.sp,
                    color = AppColors.textSecondary,
                    fontWeight = FontWeight.Medium
                )
            )
        }

        Spacer(modifier = Modifier.height(6.dp))

        // Clean & Balanced Visible Quick Controls Strip
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .horizontalScroll(rememberScrollState()),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // 1. Video Scaling Quick Pill (Fit, Fill, Crop, 100%)
            QuickActionPill(
                icon = Icons.Outlined.AspectRatio,
                label = scalingMode.shortName,
                isActive = scalingMode != VideoScalingMode.FIT,
                onClick = onCycleScaling
            )

            // 2. Repeat / Loop Quick Pill
            val repeatLabel = when {
                isAbRepeatActive -> "A-B: On"
                repeatMode == Player.REPEAT_MODE_ONE -> "Loop: 1"
                repeatMode == Player.REPEAT_MODE_ALL -> "Loop: All"
                else -> "Loop: Off"
            }
            QuickActionPill(
                icon = Icons.Outlined.Repeat,
                label = repeatLabel,
                isActive = repeatMode != Player.REPEAT_MODE_OFF || isAbRepeatActive,
                onClick = onCycleRepeat
            )

            // 3. Playback Speed Quick Pill
            QuickActionPill(
                icon = Icons.Outlined.Speed,
                label = "${playbackSpeed}×",
                isActive = playbackSpeed != 1.0f,
                onClick = onSpeedClick
            )

            // 4. Hardware / Software / Auto Decoder Pill
            QuickActionPill(
                icon = Icons.Outlined.Memory,
                label = "Decoder: ${decoderMode.shortName}",
                isActive = decoderMode != DecoderMode.AUTO,
                onClick = onCycleDecoder
            )

            // 5. Quick Screen Lock Pill
            QuickActionPill(
                icon = Icons.Outlined.Lock,
                label = "Lock",
                isActive = false,
                onClick = onToggleLock
            )
        }
    }
}

@Composable
private fun QuickActionPill(
    icon: ImageVector,
    label: String,
    isActive: Boolean = false,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(if (isActive) AppColors.electricBlue.copy(alpha = 0.25f) else Color.Black.copy(alpha = 0.65f))
            .border(
                1.dp,
                if (isActive) AppColors.electricBlueBright else AppColors.glassBorderSubtle,
                RoundedCornerShape(12.dp)
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 11.dp, vertical = 6.dp),
        contentAlignment = Alignment.Center
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(5.dp)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = label,
                tint = if (isActive) AppColors.electricBlueBright else AppColors.textPrimary,
                modifier = Modifier.size(15.dp)
            )
            Text(
                text = label,
                style = AppTypography.caption.copy(
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = if (isActive) AppColors.electricBlueBright else AppColors.textPrimary
                ),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@Composable
private fun GestureHudOverlay(
    brightness: Float?,
    volume: Int?,
    maxVolume: Int,
    doubleTapText: String?,
    modifier: Modifier = Modifier
) {
    if (brightness != null) {
        PichiGlassCard(
            modifier = modifier.size(110.dp),
            backgroundColor = Color.Black.copy(alpha = 0.8f),
            borderColor = AppColors.electricBlueGlow,
            shape = RoundedCornerShape(22.dp)
        ) {
            Column(
                modifier = Modifier.fillMaxSize(),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Icon(
                    imageVector = Icons.Default.BrightnessMedium,
                    contentDescription = null,
                    tint = AppColors.electricBlueBright,
                    modifier = Modifier.size(34.dp)
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "${(brightness * 100).roundToInt()}%",
                    style = AppTypography.cardTitle.copy(fontWeight = FontWeight.Bold)
                )
            }
        }
    } else if (volume != null) {
        val volPct = if (maxVolume > 0) ((volume.toFloat() / maxVolume) * 100).roundToInt() else 0
        PichiGlassCard(
            modifier = modifier.size(110.dp),
            backgroundColor = Color.Black.copy(alpha = 0.8f),
            borderColor = AppColors.electricBlueGlow,
            shape = RoundedCornerShape(22.dp)
        ) {
            Column(
                modifier = Modifier.fillMaxSize(),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Icon(
                    imageVector = if (volume == 0) Icons.AutoMirrored.Filled.VolumeMute else if (volPct < 50) Icons.AutoMirrored.Filled.VolumeDown else Icons.AutoMirrored.Filled.VolumeUp,
                    contentDescription = null,
                    tint = AppColors.electricBlueBright,
                    modifier = Modifier.size(34.dp)
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "$volPct%",
                    style = AppTypography.cardTitle.copy(fontWeight = FontWeight.Bold)
                )
            }
        }
    } else if (doubleTapText != null) {
        Box(
            modifier = modifier
                .clip(RoundedCornerShape(20.dp))
                .background(Color.Black.copy(alpha = 0.75f))
                .border(1.dp, AppColors.electricBlueBright, RoundedCornerShape(20.dp))
                .padding(horizontal = 22.dp, vertical = 14.dp)
        ) {
            Text(
                text = doubleTapText,
                style = AppTypography.cardTitle.copy(
                    fontWeight = FontWeight.Bold,
                    color = AppColors.textPrimary
                )
            )
        }
    }
}

// -------------------------------------------------------------
// SCREEN 08: ADVANCED CONTROLS BOTTOM SHEET
// -------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AdvancedControlsBottomSheet(
    currentSpeed: Float,
    scalingMode: VideoScalingMode,
    isSleepTimerActive: Boolean,
    sleepTimerSecs: Long?,
    abRepeatActive: Boolean,
    audioTracksCount: Int,
    selectedAudioTrack: String,
    selectedSubtitle: String,
    isSoftwareDecoder: Boolean,
    statsActive: Boolean,
    onOpenAudioTracks: () -> Unit,
    onOpenSubtitles: () -> Unit,
    onOpenSpeed: () -> Unit,
    onOpenScaling: () -> Unit,
    onOpenSleepTimer: () -> Unit,
    onOpenAbRepeat: () -> Unit,
    onToggleLock: () -> Unit,
    onToggleDecoder: () -> Unit,
    onToggleStats: () -> Unit,
    onOpenPiP: () -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppColors.surface,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppColors.textMuted) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = "Advanced Controls",
                style = AppTypography.sectionHeader.copy(fontSize = 18.sp),
                modifier = Modifier.padding(bottom = 8.dp)
            )

            // 1. Audio tracks
            AdvancedControlRow(
                icon = Icons.Outlined.Audiotrack,
                title = "Audio tracks",
                subtitle = selectedAudioTrack,
                onClick = onOpenAudioTracks
            )

            // 2. Subtitles
            AdvancedControlRow(
                icon = Icons.Outlined.Subtitles,
                title = "Subtitles",
                subtitle = selectedSubtitle,
                onClick = onOpenSubtitles
            )

            // 3. Playback speed
            AdvancedControlRow(
                icon = Icons.Outlined.Speed,
                title = "Playback speed",
                subtitle = "${currentSpeed}x",
                onClick = onOpenSpeed
            )

            // 4. Video scaling
            AdvancedControlRow(
                icon = Icons.Outlined.AspectRatio,
                title = "Video scaling",
                subtitle = scalingMode.title,
                onClick = onOpenScaling
            )

            // 5. Sleep timer
            AdvancedControlRow(
                icon = Icons.Outlined.Bedtime,
                title = "Sleep timer",
                subtitle = if (isSleepTimerActive && sleepTimerSecs != null) "${sleepTimerSecs / 60}m left" else if (isSleepTimerActive) "End of video" else "Off",
                onClick = onOpenSleepTimer
            )

            // 6. A-B repeat
            AdvancedControlRow(
                icon = Icons.Outlined.Repeat,
                title = "A-B repeat",
                subtitle = if (abRepeatActive) "Active" else "Off",
                onClick = onOpenAbRepeat
            )

            // 7. Screen lock
            AdvancedControlRow(
                icon = Icons.Outlined.Lock,
                title = "Screen lock",
                subtitle = "Off",
                onClick = onToggleLock
            )

            // 8. Decoder
            AdvancedControlRow(
                icon = Icons.Outlined.Memory,
                title = "Decoder",
                subtitle = if (isSoftwareDecoder) "Software" else "Hardware (default)",
                onClick = onToggleDecoder
            )

            // 9. Statistics
            AdvancedControlRow(
                icon = Icons.Outlined.Analytics,
                title = "Statistics",
                subtitle = if (statsActive) "On" else "Off",
                onClick = onToggleStats
            )

            // 10. Picture-in-Picture
            AdvancedControlRow(
                icon = Icons.Outlined.PictureInPictureAlt,
                title = "Background & PiP",
                subtitle = "Enter PiP",
                onClick = onOpenPiP
            )

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
private fun AdvancedControlRow(
    icon: ImageVector,
    title: String,
    subtitle: String,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .clickable(onClick = onClick)
            .padding(horizontal = 8.dp, vertical = 10.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(AppColors.surfaceSubtle),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = AppColors.electricBlueBright,
                    modifier = Modifier.size(20.dp)
                )
            }
            Column {
                Text(text = title, style = AppTypography.cardTitle.copy(fontSize = 14.5.sp))
                Text(text = subtitle, style = AppTypography.caption.copy(color = AppColors.textSecondary))
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

// -------------------------------------------------------------
// SCREEN 12: AUDIO TRACK SELECTION
// -------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AudioTrackSelectionBottomSheet(
    tracks: List<TrackInfo>,
    onSelectTrack: (Int) -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppColors.surface,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppColors.textMuted) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Text(text = "Audio Track", style = AppTypography.sectionHeader)

            if (tracks.isEmpty()) {
                Text(text = "Default stereo audio (no alternative streams found)", style = AppTypography.bodyMedium)
            } else {
                tracks.forEach { track ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(if (track.isSelected) AppColors.surfaceGlass else Color.Transparent)
                            .clickable { onSelectTrack(track.index) }
                            .padding(horizontal = 12.dp, vertical = 12.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                text = track.name,
                                style = AppTypography.cardTitle.copy(
                                    color = if (track.isSelected) AppColors.electricBlueBright else AppColors.textPrimary,
                                    fontWeight = if (track.isSelected) FontWeight.Bold else FontWeight.Normal
                                )
                            )
                            val codecText = listOfNotNull(track.codec, track.channels?.let { "${it}ch" }).joinToString(" • ")
                            if (codecText.isNotBlank()) {
                                Text(text = codecText, style = AppTypography.caption.copy(color = AppColors.textSecondary))
                            }
                        }

                        if (track.isSelected) {
                            Icon(imageVector = Icons.Default.Check, contentDescription = null, tint = AppColors.electricBlueBright)
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

// -------------------------------------------------------------
// SCREEN 10: SUBTITLE SELECTION
// -------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SubtitleSelectionBottomSheet(
    tracks: List<TrackInfo>,
    onSelectSubtitle: (Int) -> Unit,
    onOpenStyle: () -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppColors.surface,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppColors.textMuted) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(text = "Subtitles", style = AppTypography.sectionHeader)
                Text(
                    text = "Style >",
                    style = AppTypography.caption.copy(
                        color = AppColors.electricBlueBright,
                        fontWeight = FontWeight.Bold,
                        fontSize = 13.sp
                    ),
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .clickable(onClick = onOpenStyle)
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                )
            }

            val noneSelected = tracks.none { it.isSelected }

            // Off option
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(if (noneSelected) AppColors.surfaceGlass else Color.Transparent)
                    .clickable { onSelectSubtitle(-1) }
                    .padding(horizontal = 12.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Off",
                    style = AppTypography.cardTitle.copy(
                        color = if (noneSelected) AppColors.electricBlueBright else AppColors.textPrimary,
                        fontWeight = if (noneSelected) FontWeight.Bold else FontWeight.Normal
                    )
                )
                if (noneSelected) {
                    Icon(imageVector = Icons.Default.Check, contentDescription = null, tint = AppColors.electricBlueBright)
                }
            }

            tracks.forEach { sub ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(if (sub.isSelected) AppColors.surfaceGlass else Color.Transparent)
                        .clickable { onSelectSubtitle(sub.index) }
                        .padding(horizontal = 12.dp, vertical = 12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "${sub.name} (${sub.language})",
                        style = AppTypography.cardTitle.copy(
                            color = if (sub.isSelected) AppColors.electricBlueBright else AppColors.textPrimary,
                            fontWeight = if (sub.isSelected) FontWeight.Bold else FontWeight.Normal
                        )
                    )
                    if (sub.isSelected) {
                        Icon(imageVector = Icons.Default.Check, contentDescription = null, tint = AppColors.electricBlueBright)
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

// -------------------------------------------------------------
// SCREEN 11: SUBTITLE STYLE CUSTOMIZATION
// -------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SubtitleStyleBottomSheet(
    onDismiss: () -> Unit
) {
    var selectedPreset by remember { mutableStateOf("Cinema") }
    val presets = listOf("Default", "Cinema", "Bold", "Highlight", "Custom")

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppColors.surface,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppColors.textMuted) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(text = "Subtitle Style", style = AppTypography.sectionHeader)

            // Preview Box
            PichiGlassCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(120.dp),
                shape = RoundedCornerShape(16.dp),
                backgroundColor = Color.Black.copy(alpha = 0.8f)
            ) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "This is a subtitle preview",
                        style = AppTypography.cardTitle.copy(
                            fontSize = 15.sp,
                            fontWeight = if (selectedPreset == "Bold") FontWeight.Bold else FontWeight.Medium,
                            color = if (selectedPreset == "Highlight") Color(0xFFFFD54F) else Color.White
                        ),
                        modifier = Modifier
                            .background(
                                if (selectedPreset == "Cinema") Color.Black.copy(alpha = 0.7f) else Color.Transparent,
                                RoundedCornerShape(4.dp)
                            )
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    )
                }
            }

            Text(text = "Presets", style = AppTypography.caption.copy(color = AppColors.textSecondary))

            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                items(presets) { preset ->
                    val isSel = preset == selectedPreset
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(12.dp))
                            .background(if (isSel) AppColors.electricBlue else AppColors.surfaceSubtle)
                            .border(1.dp, if (isSel) AppColors.electricBlueBright else AppColors.glassBorderSubtle, RoundedCornerShape(12.dp))
                            .clickable { selectedPreset = preset }
                            .padding(horizontal = 16.dp, vertical = 10.dp)
                    ) {
                        Text(
                            text = preset,
                            style = AppTypography.cardTitle.copy(
                                color = if (isSel) Color.White else AppColors.textPrimary,
                                fontSize = 13.sp
                            )
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

// -------------------------------------------------------------
// SCREEN 13: PLAYBACK SPEED
// -------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun PlaybackSpeedBottomSheet(
    currentSpeed: Float,
    onSelectSpeed: (Float) -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppColors.surface,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppColors.textMuted) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Playback Speed",
                style = AppTypography.sectionHeader,
                modifier = Modifier.align(Alignment.Start)
            )

            Text(
                text = "${currentSpeed}×",
                style = AppTypography.heroTitle.copy(
                    fontSize = 36.sp,
                    color = AppColors.electricBlueBright
                )
            )

            // Presets Grid
            val speeds = listOf(0.25f, 0.5f, 0.75f, 1.0f, 1.25f, 1.5f, 1.75f, 2.0f, 3.0f)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                speeds.take(5).forEach { spd ->
                    val isSel = spd == currentSpeed
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(12.dp))
                            .background(if (isSel) AppColors.electricBlue else AppColors.surfaceSubtle)
                            .border(1.dp, if (isSel) AppColors.electricBlueBright else AppColors.glassBorderSubtle, RoundedCornerShape(12.dp))
                            .clickable { onSelectSpeed(spd) }
                            .padding(horizontal = 12.dp, vertical = 8.dp)
                    ) {
                        Text(text = "${spd}x", style = AppTypography.cardTitle.copy(fontSize = 12.sp, color = if (isSel) Color.White else AppColors.textPrimary))
                    }
                }
            }

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                speeds.drop(5).forEach { spd ->
                    val isSel = spd == currentSpeed
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(12.dp))
                            .background(if (isSel) AppColors.electricBlue else AppColors.surfaceSubtle)
                            .border(1.dp, if (isSel) AppColors.electricBlueBright else AppColors.glassBorderSubtle, RoundedCornerShape(12.dp))
                            .clickable { onSelectSpeed(spd) }
                            .padding(horizontal = 12.dp, vertical = 8.dp)
                    ) {
                        Text(text = "${spd}x", style = AppTypography.cardTitle.copy(fontSize = 12.sp, color = if (isSel) Color.White else AppColors.textPrimary))
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

// -------------------------------------------------------------
// SCREEN 14: VIDEO SCALING
// -------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun VideoScalingBottomSheet(
    currentMode: VideoScalingMode,
    onSelectMode: (VideoScalingMode) -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppColors.surface,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppColors.textMuted) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(text = "Video Scaling", style = AppTypography.sectionHeader)

            VideoScalingMode.entries.forEach { mode ->
                val isSel = mode == currentMode
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(if (isSel) AppColors.surfaceGlass else Color.Transparent)
                        .clickable { onSelectMode(mode) }
                        .padding(horizontal = 12.dp, vertical = 14.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = mode.title,
                        style = AppTypography.cardTitle.copy(
                            color = if (isSel) AppColors.electricBlueBright else AppColors.textPrimary,
                            fontWeight = if (isSel) FontWeight.Bold else FontWeight.Normal
                        )
                    )
                    if (isSel) {
                        Icon(imageVector = Icons.Default.Check, contentDescription = null, tint = AppColors.electricBlueBright)
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

// -------------------------------------------------------------
// SCREEN 15: SLEEP TIMER
// -------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SleepTimerBottomSheet(
    isActive: Boolean,
    remainingSeconds: Long?,
    onSetMinutes: (Int) -> Unit,
    onSetEndOfVideo: () -> Unit,
    onExtend: () -> Unit,
    onCancel: () -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppColors.surface,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppColors.textMuted) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(text = "Sleep Timer", style = AppTypography.sectionHeader)
                if (isActive) {
                    Text(
                        text = "Cancel Timer",
                        style = AppTypography.caption.copy(color = AppColors.errorBright, fontWeight = FontWeight.Bold),
                        modifier = Modifier.clickable { onCancel() }
                    )
                }
            }

            if (isActive && remainingSeconds != null) {
                val mins = remainingSeconds / 60
                val secs = remainingSeconds % 60
                PichiGlassCard(modifier = Modifier.fillMaxWidth()) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(text = "Timer Active", style = AppTypography.caption.copy(color = AppColors.electricBlueBright))
                            Text(
                                text = "%02d:%02d remaining".format(mins, secs),
                                style = AppTypography.cardTitle.copy(fontSize = 18.sp, fontWeight = FontWeight.Bold)
                            )
                        }
                        PichiButton(text = "+15 min", onClick = onExtend, isSecondary = true)
                    }
                }
            }

            Text(text = "Quick Presets", style = AppTypography.caption.copy(color = AppColors.textSecondary))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                listOf(15, 30, 45, 60).forEach { mins ->
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(12.dp))
                            .background(AppColors.surfaceSubtle)
                            .border(1.dp, AppColors.glassBorderSubtle, RoundedCornerShape(12.dp))
                            .clickable {
                                onSetMinutes(mins)
                                onDismiss()
                            }
                            .padding(vertical = 12.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(text = "${mins}m", style = AppTypography.cardTitle)
                    }
                }
            }

            PichiButton(
                text = "Stop at End of Video",
                onClick = {
                    onSetEndOfVideo()
                    onDismiss()
                },
                modifier = Modifier.fillMaxWidth(),
                isSecondary = true
            )

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

// -------------------------------------------------------------
// SCREEN 16: A-B REPEAT
// -------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AbRepeatBottomSheet(
    state: com.pichiplayer.media.playback.ABRepeatState,
    currentPositionMs: Long,
    onSetA: () -> Unit,
    onSetB: () -> Unit,
    onToggle: () -> Unit,
    onClear: () -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = AppColors.surface,
        dragHandle = { BottomSheetDefaults.DragHandle(color = AppColors.textMuted) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(text = "A-B Repeat", style = AppTypography.sectionHeader)
                if (state.pointA != null || state.pointB != null) {
                    Text(
                        text = "Reset",
                        style = AppTypography.caption.copy(color = AppColors.errorBright, fontWeight = FontWeight.Bold),
                        modifier = Modifier.clickable { onClear() }
                    )
                }
            }

            Text(
                text = "Select two timestamps to loop a specific section of the video continuously.",
                style = AppTypography.bodyMedium
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                PichiGlassCard(
                    modifier = Modifier.weight(1f),
                    borderColor = if (state.pointA != null) AppColors.electricBlue else AppColors.glassBorder
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(12.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(text = "Point A (Start)", style = AppTypography.caption)
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = if (state.pointA != null) formatDuration(state.pointA) else "--:--",
                            style = AppTypography.cardTitle.copy(fontSize = 16.sp, fontWeight = FontWeight.Bold)
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        PichiButton(
                            text = "Set A",
                            onClick = onSetA,
                            modifier = Modifier.fillMaxWidth(),
                            contentPadding = PaddingValues(vertical = 6.dp)
                        )
                    }
                }

                PichiGlassCard(
                    modifier = Modifier.weight(1f),
                    borderColor = if (state.pointB != null) AppColors.electricBlue else AppColors.glassBorder
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(12.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(text = "Point B (End)", style = AppTypography.caption)
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = if (state.pointB != null) formatDuration(state.pointB) else "--:--",
                            style = AppTypography.cardTitle.copy(fontSize = 16.sp, fontWeight = FontWeight.Bold)
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        PichiButton(
                            text = "Set B",
                            onClick = onSetB,
                            modifier = Modifier.fillMaxWidth(),
                            contentPadding = PaddingValues(vertical = 6.dp)
                        )
                    }
                }
            }

            if (state.pointA != null && state.pointB != null) {
                PichiButton(
                    text = if (state.isEnabled) "Pause Loop" else "Start Loop",
                    onClick = onToggle,
                    modifier = Modifier.fillMaxWidth()
                )
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

private fun formatDuration(durationMs: Long): String {
    val totalSeconds = (durationMs / 1000).coerceAtLeast(0)
    val hours = totalSeconds / 3600
    val minutes = (totalSeconds % 3600) / 60
    val seconds = totalSeconds % 60
    return if (hours > 0) {
        "%02d:%02d:%02d".format(hours, minutes, seconds)
    } else {
        "%02d:%02d".format(minutes, seconds)
    }
}
