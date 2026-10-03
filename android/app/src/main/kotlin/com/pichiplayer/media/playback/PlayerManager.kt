package com.pichiplayer.media.playback

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import androidx.annotation.OptIn
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.PlaybackException
import androidx.media3.common.PlaybackParameters
import androidx.media3.common.Player
import androidx.media3.common.TrackSelectionOverride
import androidx.media3.common.Tracks
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.DefaultLoadControl
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector
import androidx.media3.ui.AspectRatioFrameLayout
import com.pichiplayer.data.database.VideoEntity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

enum class VideoScalingMode(val title: String, val shortName: String, val resizeMode: Int) {
    FIT("Fit Screen", "Fit", AspectRatioFrameLayout.RESIZE_MODE_FIT),
    FILL("Fill Screen", "Fill", AspectRatioFrameLayout.RESIZE_MODE_FILL),
    ZOOM("Zoom / Crop", "Crop", AspectRatioFrameLayout.RESIZE_MODE_ZOOM),
    ORIGINAL("Original 100%", "100%", AspectRatioFrameLayout.RESIZE_MODE_FIXED_WIDTH)
}

data class ABRepeatState(
    val pointA: Long? = null,
    val pointB: Long? = null,
    val isEnabled: Boolean = false
)

data class TrackInfo(
    val index: Int,
    val name: String,
    val language: String,
    val codec: String?,
    val channels: Int?,
    val isSelected: Boolean
)

data class PlayerUiState(
    val currentVideo: VideoEntity? = null,
    val isPlaying: Boolean = false,
    val currentPositionMs: Long = 0L,
    val durationMs: Long = 0L,
    val bufferedPositionMs: Long = 0L,
    val playbackSpeed: Float = 1.0f,
    val scalingMode: VideoScalingMode = VideoScalingMode.FIT,
    val isScreenLocked: Boolean = false,
    val repeatMode: Int = Player.REPEAT_MODE_OFF,
    val abRepeat: ABRepeatState = ABRepeatState(),
    val sleepTimerRemainingSeconds: Long? = null,
    val isSleepTimerActive: Boolean = false,
    val stopAtEndOfVideo: Boolean = false,
    val audioDelayMs: Long = 0L,
    val audioTracks: List<TrackInfo> = emptyList(),
    val subtitleTracks: List<TrackInfo> = emptyList(),
    val isDecoderError: Boolean = false,
    val decoderErrorMessage: String? = null,
    val decoderMode: DecoderMode = DecoderMode.AUTO
)

@OptIn(UnstableApi::class)
class PlayerManager private constructor(private val context: Context) : Player.Listener {

    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private val handler = Handler(Looper.getMainLooper())

    private var currentDecoderMode: DecoderMode = DecoderMode.AUTO

    // Enhanced renderers factory with dynamic Auto / HW / SW decoder selector and fallback
    private var renderersFactory = DefaultRenderersFactory(context)
        .setExtensionRendererMode(DefaultRenderersFactory.EXTENSION_RENDERER_MODE_PREFER)
        .setEnableDecoderFallback(true)
        .forceEnableMediaCodecAsynchronousQueueing()
        .setAllowedVideoJoiningTimeMs(5000L)
        .setMediaCodecSelector { mimeType, requiresSecureDecoder, requiresTunnelingDecoder ->
            val decoders = androidx.media3.exoplayer.mediacodec.MediaCodecSelector.DEFAULT.getDecoderInfos(
                mimeType,
                requiresSecureDecoder,
                requiresTunnelingDecoder
            )
            when (currentDecoderMode) {
                DecoderMode.AUTO -> decoders.sortedByDescending { it.hardwareAccelerated }
                DecoderMode.HW -> decoders.sortedByDescending { it.hardwareAccelerated }
                DecoderMode.SW -> decoders.sortedByDescending { it.softwareOnly || !it.hardwareAccelerated }
            }
        }

    // Track selector configured to allow high-res / 4K / 8K playback even if exceeding reported device caps
    private val trackSelector = DefaultTrackSelector(context).apply {
        setParameters(
            buildUponParameters()
                .setExceedRendererCapabilitiesIfNecessary(true)
                .setAllowVideoMixedMimeTypeAdaptiveness(true)
                .setAllowVideoNonSeamlessAdaptiveness(true)
                .setAllowMultipleAdaptiveSelections(true)
        )
    }

    // High performance load control optimized for smooth 2K / 4K / 8K playback without stutter or OOM
    private val loadControl = DefaultLoadControl.Builder()
        .setBufferDurationsMs(
            15_000, // minBufferMs: 15s provides generous buffer for 4K bitrates
            50_000, // maxBufferMs: 50s headroom for uninterrupted playback
            500,    // bufferForPlaybackMs: Instant startup (<500ms)
            1_000   // bufferForPlaybackAfterRebufferMs: Fast recovery
        )
        .setTargetBufferBytes(64 * 1024 * 1024) // 64MB buffer headroom for 4K bitrates (largeHeap=true enabled)
        .setPrioritizeTimeOverSizeThresholds(true)
        .build()

    val player: ExoPlayer = ExoPlayer.Builder(context, renderersFactory)
        .setTrackSelector(trackSelector)
        .setLoadControl(loadControl)
        .setVideoChangeFrameRateStrategy(C.VIDEO_CHANGE_FRAME_RATE_STRATEGY_ONLY_IF_SEAMLESS)
        .setWakeMode(C.WAKE_MODE_LOCAL)
        .setSeekBackIncrementMs(10_000)
        .setSeekForwardIncrementMs(10_000)
        .build().apply {
            addListener(this@PlayerManager)
        }

    private val _uiState = MutableStateFlow(PlayerUiState())
    val uiState: StateFlow<PlayerUiState> = _uiState.asStateFlow()

    private val _isInPipMode = MutableStateFlow(false)
    val isInPipMode: StateFlow<Boolean> = _isInPipMode.asStateFlow()

    fun setInPipMode(inPip: Boolean) {
        _isInPipMode.value = inPip
    }

    private var currentPlaylist: List<VideoEntity> = emptyList()
    private var currentPlaylistIndex: Int = -1

    private var onPositionUpdated: ((videoId: Long, posMs: Long, durMs: Long) -> Unit)? = null

    init {
        startProgressTracking()
    }

    fun setPositionUpdateListener(listener: (videoId: Long, posMs: Long, durMs: Long) -> Unit) {
        onPositionUpdated = listener
    }

    fun playVideo(video: VideoEntity, playlist: List<VideoEntity> = listOf(video), resumePosition: Long? = null) {
        currentPlaylist = playlist
        currentPlaylistIndex = playlist.indexOfFirst { it.id == video.id }.coerceAtLeast(0)

        // If this video is ALREADY the active media item in the player, resume seamlessly from current spot!
        if (_uiState.value.currentVideo?.id == video.id && player.currentMediaItem != null) {
            if (!player.isPlaying) {
                player.play()
            }
            return
        }

        _uiState.value = _uiState.value.copy(
            currentVideo = video,
            isDecoderError = false,
            decoderErrorMessage = null,
            durationMs = video.durationMs
        )

        val mediaMetadata = MediaMetadata.Builder()
            .setTitle(video.displayName)
            .setDisplayTitle(video.displayName)
            .setArtist("PIchiPlayer")
            .build()

        val mediaItem = MediaItem.Builder()
            .setUri(Uri.parse(video.contentUri))
            .setMediaId(video.id.toString())
            .setMediaMetadata(mediaMetadata)
            .build()

        player.setMediaItem(mediaItem)
        player.prepare()

        val startPos = resumePosition ?: if (video.lastPositionMs > 1000L && video.watchedPercentage < 0.95f) {
            video.lastPositionMs
        } else 0L

        if (startPos > 0) {
            player.seekTo(startPos)
        }
        player.playWhenReady = true
    }

    fun togglePlayPause() {
        if (player.isPlaying) {
            player.pause()
        } else {
            player.play()
        }
    }

    fun seekTo(positionMs: Long) {
        player.seekTo(positionMs.coerceIn(0L, player.duration.coerceAtLeast(0L)))
    }

    fun seekBy(deltaSeconds: Int) {
        val target = player.currentPosition + (deltaSeconds * 1000L)
        seekTo(target)
    }

    fun setPlaybackSpeed(speed: Float) {
        player.playbackParameters = PlaybackParameters(speed)
        _uiState.value = _uiState.value.copy(playbackSpeed = speed)
    }

    fun setScalingMode(mode: VideoScalingMode) {
        _uiState.value = _uiState.value.copy(scalingMode = mode)
    }

    fun cycleScalingMode(): VideoScalingMode {
        val modes = VideoScalingMode.entries
        val nextIndex = (modes.indexOf(_uiState.value.scalingMode) + 1) % modes.size
        val nextMode = modes[nextIndex]
        setScalingMode(nextMode)
        return nextMode
    }

    fun toggleScreenLock() {
        _uiState.value = _uiState.value.copy(isScreenLocked = !_uiState.value.isScreenLocked)
    }

    fun unlockScreen() {
        _uiState.value = _uiState.value.copy(isScreenLocked = false)
    }

    fun playNext() {
        if (currentPlaylist.isNotEmpty() && currentPlaylistIndex < currentPlaylist.size - 1) {
            currentPlaylistIndex++
            playVideo(currentPlaylist[currentPlaylistIndex], currentPlaylist)
        }
    }

    fun playPrevious() {
        if (currentPlaylist.isNotEmpty() && currentPlaylistIndex > 0) {
            currentPlaylistIndex--
            playVideo(currentPlaylist[currentPlaylistIndex], currentPlaylist)
        }
    }

    // --- A-B Repeat ---
    fun setPointA() {
        val current = player.currentPosition
        val ab = _uiState.value.abRepeat.copy(pointA = current, isEnabled = _uiState.value.abRepeat.pointB != null)
        _uiState.value = _uiState.value.copy(abRepeat = ab)
    }

    fun setPointB() {
        val current = player.currentPosition
        val a = _uiState.value.abRepeat.pointA ?: 0L
        if (current > a) {
            val ab = _uiState.value.abRepeat.copy(pointB = current, isEnabled = true)
            _uiState.value = _uiState.value.copy(abRepeat = ab)
        }
    }

    fun toggleAbRepeat() {
        val ab = _uiState.value.abRepeat
        if (ab.pointA != null && ab.pointB != null) {
            _uiState.value = _uiState.value.copy(abRepeat = ab.copy(isEnabled = !ab.isEnabled))
        }
    }

    fun clearAbRepeat() {
        _uiState.value = _uiState.value.copy(abRepeat = ABRepeatState())
    }

    // --- Loop & Repeat Modes ---
    fun cycleRepeatMode(): Int {
        val newMode = when (player.repeatMode) {
            Player.REPEAT_MODE_OFF -> Player.REPEAT_MODE_ONE
            Player.REPEAT_MODE_ONE -> Player.REPEAT_MODE_ALL
            else -> Player.REPEAT_MODE_OFF
        }
        player.repeatMode = newMode
        _uiState.value = _uiState.value.copy(repeatMode = newMode)
        return newMode
    }

    fun setRepeatMode(mode: Int) {
        player.repeatMode = mode
        _uiState.value = _uiState.value.copy(repeatMode = mode)
    }

    // --- Decoder Switching (Auto / HW / SW) ---
    fun setDecoderMode(mode: DecoderMode) {
        if (currentDecoderMode == mode) return
        currentDecoderMode = mode
        _uiState.value = _uiState.value.copy(decoderMode = mode)
        val item = player.currentMediaItem
        if (item != null) {
            val currentPos = player.currentPosition
            val wasPlaying = player.isPlaying
            player.stop()
            player.setMediaItem(item, currentPos)
            player.prepare()
            if (wasPlaying) {
                player.play()
            }
        }
    }

    fun cycleDecoderMode(): DecoderMode {
        val nextMode = when (currentDecoderMode) {
            DecoderMode.AUTO -> DecoderMode.HW
            DecoderMode.HW -> DecoderMode.SW
            DecoderMode.SW -> DecoderMode.AUTO
        }
        setDecoderMode(nextMode)
        return nextMode
    }

    // --- Sleep Timer ---
    private var sleepTimerRunnable: Runnable? = null

    fun setSleepTimerMinutes(minutes: Int) {
        cancelSleepTimer()
        val totalSecs = minutes * 60L
        _uiState.value = _uiState.value.copy(
            sleepTimerRemainingSeconds = totalSecs,
            isSleepTimerActive = true,
            stopAtEndOfVideo = false
        )
        scheduleSleepTimerTick()
    }

    fun setSleepTimerEndOfVideo() {
        cancelSleepTimer()
        _uiState.value = _uiState.value.copy(
            sleepTimerRemainingSeconds = null,
            isSleepTimerActive = true,
            stopAtEndOfVideo = true
        )
    }

    fun extendSleepTimer(extraMinutes: Int) {
        val currentSecs = _uiState.value.sleepTimerRemainingSeconds ?: 0L
        _uiState.value = _uiState.value.copy(
            sleepTimerRemainingSeconds = currentSecs + (extraMinutes * 60L),
            isSleepTimerActive = true
        )
    }

    fun cancelSleepTimer() {
        sleepTimerRunnable?.let { handler.removeCallbacks(it) }
        sleepTimerRunnable = null
        _uiState.value = _uiState.value.copy(
            sleepTimerRemainingSeconds = null,
            isSleepTimerActive = false,
            stopAtEndOfVideo = false
        )
    }

    private fun scheduleSleepTimerTick() {
        sleepTimerRunnable = object : Runnable {
            override fun run() {
                val current = _uiState.value.sleepTimerRemainingSeconds
                if (current != null && current > 1) {
                    _uiState.value = _uiState.value.copy(sleepTimerRemainingSeconds = current - 1)
                    handler.postDelayed(this, 1000L)
                } else if (current != null && current <= 1) {
                    // Timer expired: stop playback cleanly
                    player.pause()
                    cancelSleepTimer()
                }
            }
        }
        handler.postDelayed(sleepTimerRunnable!!, 1000L)
    }

    // --- Subtitles & Audio Track Switcher ---
    fun selectAudioTrack(trackIndex: Int) {
        val tracks = player.currentTracks
        for (group in tracks.groups) {
            if (group.type == C.TRACK_TYPE_AUDIO) {
                if (trackIndex in 0 until group.length) {
                    val override = TrackSelectionOverride(group.mediaTrackGroup, trackIndex)
                    player.trackSelectionParameters = player.trackSelectionParameters
                        .buildUpon()
                        .setOverrideForType(override)
                        .setTrackTypeDisabled(C.TRACK_TYPE_AUDIO, false)
                        .build()
                    break
                }
            }
        }
        updateTrackLists(player.currentTracks)
    }

    fun selectSubtitleTrack(trackIndex: Int) {
        if (trackIndex == -1) {
            // Disable subtitles
            player.trackSelectionParameters = player.trackSelectionParameters
                .buildUpon()
                .setTrackTypeDisabled(C.TRACK_TYPE_TEXT, true)
                .build()
        } else {
            val tracks = player.currentTracks
            for (group in tracks.groups) {
                if (group.type == C.TRACK_TYPE_TEXT) {
                    if (trackIndex in 0 until group.length) {
                        val override = TrackSelectionOverride(group.mediaTrackGroup, trackIndex)
                        player.trackSelectionParameters = player.trackSelectionParameters
                            .buildUpon()
                            .setOverrideForType(override)
                            .setTrackTypeDisabled(C.TRACK_TYPE_TEXT, false)
                            .build()
                        break
                    }
                }
            }
        }
        updateTrackLists(player.currentTracks)
    }

    private fun startProgressTracking() {
        handler.post(object : Runnable {
            override fun run() {
                val pos = player.currentPosition
                val dur = player.duration.coerceAtLeast(0L)
                val isPlaying = player.isPlaying

                // A-B Repeat check
                val ab = _uiState.value.abRepeat
                if (ab.isEnabled && ab.pointA != null && ab.pointB != null) {
                    if (pos >= ab.pointB) {
                        player.seekTo(ab.pointA)
                    }
                }

                _uiState.value = _uiState.value.copy(
                    isPlaying = isPlaying,
                    currentPositionMs = pos,
                    durationMs = dur,
                    bufferedPositionMs = player.bufferedPosition
                )

                _uiState.value.currentVideo?.let { vid ->
                    if (isPlaying && dur > 0 && pos > 0) {
                        onPositionUpdated?.invoke(vid.id, pos, dur)
                    }
                }

                handler.postDelayed(this, 300L)
            }
        })
    }

    override fun onTracksChanged(tracks: Tracks) {
        updateTrackLists(tracks)
    }

    private fun updateTrackLists(tracks: Tracks) {
        val audios = mutableListOf<TrackInfo>()
        val subs = mutableListOf<TrackInfo>()

        for (group in tracks.groups) {
            if (group.type == C.TRACK_TYPE_AUDIO) {
                for (i in 0 until group.length) {
                    val format = group.getTrackFormat(i)
                    audios.add(
                        TrackInfo(
                            index = i,
                            name = format.label ?: format.language ?: "Track ${i + 1}",
                            language = format.language?.uppercase() ?: "UND",
                            codec = format.sampleMimeType?.substringAfter('/'),
                            channels = format.channelCount,
                            isSelected = group.isTrackSelected(i)
                        )
                    )
                }
            } else if (group.type == C.TRACK_TYPE_TEXT) {
                for (i in 0 until group.length) {
                    val format = group.getTrackFormat(i)
                    subs.add(
                        TrackInfo(
                            index = i,
                            name = format.label ?: format.language ?: "Subtitle ${i + 1}",
                            language = format.language?.uppercase() ?: "UND",
                            codec = format.sampleMimeType?.substringAfter('/'),
                            channels = null,
                            isSelected = group.isTrackSelected(i)
                        )
                    )
                }
            }
        }

        _uiState.value = _uiState.value.copy(
            audioTracks = audios,
            subtitleTracks = subs
        )
    }

    override fun onPlaybackStateChanged(playbackState: Int) {
        if (playbackState == Player.STATE_ENDED) {
            if (_uiState.value.stopAtEndOfVideo) {
                cancelSleepTimer()
            } else {
                playNext()
            }
        }
    }

    override fun onPlayerError(error: PlaybackException) {
        android.util.Log.e("PlayerManager", "Player playback error [${error.errorCodeName}]: ${error.message}", error)
        val cause = error.cause
        val isCodecError = cause is androidx.media3.exoplayer.mediacodec.MediaCodecRenderer.DecoderInitializationException ||
                cause is androidx.media3.exoplayer.mediacodec.MediaCodecDecoderException
        _uiState.value = _uiState.value.copy(
            isDecoderError = true,
            decoderErrorMessage = if (isCodecError) {
                "Codec error on high-res stream (${error.errorCodeName}). Decoder fallback engaged."
            } else {
                error.localizedMessage ?: "Playback error (${error.errorCodeName})"
            }
        )
    }

    companion object {
        @Volatile
        private var INSTANCE: PlayerManager? = null

        fun getInstance(context: Context): PlayerManager {
            return INSTANCE ?: synchronized(this) {
                val instance = PlayerManager(context.applicationContext)
                INSTANCE = instance
                instance
            }
        }
    }
}
