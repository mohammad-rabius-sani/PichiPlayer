import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/audio_track_info.dart';
import '../../models/local_video.dart';
import '../../models/player_types.dart';
import '../../models/subtitle_style_config.dart';
import '../widgets/player/advanced_player_panel.dart';
import '../widgets/player/gesture_feedback_overlays.dart';
import '../widgets/player/more_panel/ab_repeat_sheet.dart';
import '../widgets/player/more_panel/sleep_timer_sheet.dart';
import '../widgets/player/playback_statistics_overlay.dart';
import '../widgets/player/player_bottom_bar.dart';
import '../widgets/player/player_completion_overlay.dart';
import '../widgets/player/player_error_overlay.dart';
import '../widgets/player/player_sheets.dart';
import '../widgets/player/player_top_bar.dart';
import '../widgets/player/seek_preview_card.dart';
import '../widgets/player/subtitles_overlay.dart';
import '../widgets/player/video_surface.dart';
import 'background_pip_settings_screen.dart';
import 'subtitle_style_screen.dart';

/// Enum to isolate active gesture mode and prevent conflict between
/// horizontal scrub seeking, vertical volume/brightness, and pinch-zoom.
enum _ActiveGestureMode {
  none,
  pinchZoom,
  horizontalSeek,
  verticalBrightness,
  verticalVolume,
}

/// The official Fullscreen Video Player screen for PIchiPlayer.
/// An offline-first, cinematic video player with auto-hiding controls,
/// responsive gestures (volume, brightness, seek, pinch-zoom, 2x hold),
/// and comprehensive local media controls.
class PlayerScreen extends StatefulWidget {
  final LocalVideo video;
  final LocalVideo? nextVideo;
  final bool autoPlay;
  final bool isErrorOverride;
  final bool isCompletedOverride;
  final Duration? initialPosition;

  const PlayerScreen({
    super.key,
    required this.video,
    this.nextVideo,
    this.autoPlay = true,
    this.isErrorOverride = false,
    this.isCompletedOverride = false,
    this.initialPosition,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with TickerProviderStateMixin {
  // Core Playback State
  late LocalVideo _video;
  late Duration _currentPosition;
  late Duration _totalDuration;
  Duration _bufferedPosition = Duration.zero;
  bool _isPlaying = true;
  String _activeSpeed = '1×';
  bool _isTempFastForward = false;
  bool _holdFor2xEnabled = true;
  bool _isMuted = false;
  double _volume = 0.75;
  double _brightness = 0.70;

  // Track & Format State
  late String _activeSubtitle;
  late AudioTrackInfo _activeAudioTrack;
  PlayerScalingMode _scalingMode = PlayerScalingMode.fit;
  String _activeAspectRatio = 'Auto';
  Alignment _cropAlignment = Alignment.center;
  double _userZoomScale = 1.0;
  double _baseZoomScale = 1.0;
  DecoderMode _decoderMode = DecoderMode.hardware;
  bool _backgroundPlaybackEnabled = true;

  // Advanced Player Controls & More Panel State
  int _skipForwardSeconds = 10;
  int _skipBackwardSeconds = 10;
  bool _autoplayNext = true;
  int _audioDelayMs = 0;
  String _volumeBoost = 'Off';
  int _subtitleDelayMs = 0;
  String _subtitleStyleName = 'Modern';
  SubtitleStyleConfig _subtitleConfig = SubtitleStyleConfig.modern();
  Duration? _abRepeatA;
  Duration? _abRepeatB;
  bool _abRepeatEnabled = false;
  int _abRepeatCount = 0;
  int _abRepeatCurrentLoop = 0;
  SleepTimerOption _sleepTimerOption = SleepTimerOption.off;
  Timer? _sleepTimer;
  DateTime? _sleepTimerEndTime;
  bool _showSleepTimerFinishedOverlay = false;

  // UI Visibility & Timers
  bool _controlsVisible = true;
  Timer? _controlsTimer;
  Timer? _playbackTicker;

  // Screen Lock State
  bool _isLocked = false;
  bool _showLockIndicator = false;
  Timer? _lockIndicatorTimer;

  // Gesture Feedback States
  bool _showBrightnessFeedback = false;
  Timer? _brightnessFeedbackTimer;

  bool _showVolumeFeedback = false;
  Timer? _volumeFeedbackTimer;

  bool _showSeekDoubleTapFeedback = false;
  SeekDirection? _doubleTapSeekDirection;
  int _doubleTapSeekSeconds = 10;
  Offset? _lastDoubleTapPosition;
  Timer? _seekDoubleTapTimer;

  bool _isScrubbing = false;
  Duration? _scrubTargetPosition;
  Duration? _scrubDelta;

  bool _showPlayPausePulse = false;
  Timer? _playPausePulseTimer;

  // Zoom feedback state
  bool _showZoomFeedback = false;
  Timer? _zoomFeedbackTimer;

  // Orientation feedback state
  bool _showOrientationFeedback = false;
  String _orientationLabel = 'Landscape';
  bool _isOrientationLocked = false;
  Timer? _orientationTimer;

  // Transient pill feedback state
  bool _showTransientPill = false;
  IconData _transientPillIcon = Icons.info_rounded;
  String _transientPillTitle = '';
  String? _transientPillSubtitle;
  Timer? _transientPillTimer;

  // Compact player toast state
  bool _showCompactToast = false;
  IconData _compactToastIcon = Icons.info_outline_rounded;
  String _compactToastMessage = '';
  Timer? _compactToastTimer;

  // Timeline Preview Dragging State
  bool _isDraggingSeekbar = false;
  Duration _previewPosition = Duration.zero;
  double _previewRatio = 0.0;

  // Stats & End States
  bool _showStats = false;
  bool _hasError = false;
  bool _isCompleted = false;
  int? _nextAutoplayCountdown;
  Timer? _autoplayTimer;

  // Touch Tracking & Gesture Conflict Handling
  _ActiveGestureMode _activeGestureMode = _ActiveGestureMode.none;
  double? _gestureStartX;
  double _accumulatedDx = 0.0;
  double _accumulatedDy = 0.0;

  @override
  void initState() {
    super.initState();
    _video = widget.video;
    _totalDuration = _video.duration;
    _currentPosition = widget.initialPosition ?? _video.lastPosition ?? Duration.zero;
    _isPlaying = widget.autoPlay;

    _activeSubtitle = _video.effectiveSubtitleTracks.first;
    _activeAudioTrack = _video.effectiveAudioTracks.first;

    _hasError = widget.isErrorOverride;
    _isCompleted = widget.isCompletedOverride;

    // Buffer is simulated ahead of current position
    _bufferedPosition = Duration(
      seconds: (_currentPosition.inSeconds + 45).clamp(0, _totalDuration.inSeconds),
    );

    // Initial controls auto-hide after 3 seconds
    _startControlsTimer();

    // Playback progress simulation ticker
    _startPlaybackTicker();

    // If initial is completed, start countdown if next exists
    if (_isCompleted && widget.nextVideo != null) {
      _startNextCountdown();
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _playbackTicker?.cancel();
    _lockIndicatorTimer?.cancel();
    _brightnessFeedbackTimer?.cancel();
    _volumeFeedbackTimer?.cancel();
    _seekDoubleTapTimer?.cancel();
    _playPausePulseTimer?.cancel();
    _zoomFeedbackTimer?.cancel();
    _orientationTimer?.cancel();
    _transientPillTimer?.cancel();
    _compactToastTimer?.cancel();
    _autoplayTimer?.cancel();
    _sleepTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  // --- Auto-Hide Controls Timer ---
  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying && !_isDraggingSeekbar && !_isScrubbing) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _resetControlsTimer() {
    setState(() {
      _controlsVisible = true;
    });
    _startControlsTimer();
  }

  // --- Transient Feedback Emitters ---
  void _triggerTransientPill({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    setState(() {
      _transientPillIcon = icon;
      _transientPillTitle = title;
      _transientPillSubtitle = subtitle;
      _showTransientPill = true;
    });

    _transientPillTimer?.cancel();
    _transientPillTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showTransientPill = false);
    });
  }

  void _triggerOrientationFeedback(String label, {bool isLocked = false}) {
    setState(() {
      _orientationLabel = label;
      _isOrientationLocked = isLocked;
      _showOrientationFeedback = true;
    });

    _orientationTimer?.cancel();
    _orientationTimer = Timer(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _showOrientationFeedback = false);
    });
  }

  void _triggerCompactToast({
    required IconData icon,
    required String message,
  }) {
    setState(() {
      _compactToastIcon = icon;
      _compactToastMessage = message;
      _showCompactToast = true;
    });

    _compactToastTimer?.cancel();
    _compactToastTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showCompactToast = false);
    });
  }

  // --- Playback Simulation Engine ---
  void _startPlaybackTicker() {
    _playbackTicker?.cancel();
    _playbackTicker = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!_isPlaying || _isCompleted || _hasError || _isDraggingSeekbar) return;

      final double speedFactor = _isTempFastForward
          ? 2.0
          : (double.tryParse(_activeSpeed.replaceAll('×', '')) ?? 1.0);

      final addedMs = (250 * speedFactor).toInt();
      final newPos = _currentPosition + Duration(milliseconds: addedMs);

      // A-B Repeat Loop Check
      if (_abRepeatEnabled && _abRepeatA != null && _abRepeatB != null) {
        if (newPos >= _abRepeatB!) {
          if (_abRepeatCount > 0) {
            _abRepeatCurrentLoop++;
            if (_abRepeatCurrentLoop >= _abRepeatCount) {
              setState(() {
                _abRepeatEnabled = false;
                _abRepeatCurrentLoop = 0;
              });
              _triggerCompactToast(
                icon: Icons.repeat_rounded,
                message: 'A-B repeat finished ($_abRepeatCount loops)',
              );
            } else {
              setState(() {
                _currentPosition = _abRepeatA!;
              });
            }
          } else {
            setState(() {
              _currentPosition = _abRepeatA!;
            });
          }
          return;
        }
      }

      if (newPos >= _totalDuration) {
        final wasEndOfVideoTimer = _sleepTimerOption == SleepTimerOption.endOfVideo;
        setState(() {
          _currentPosition = _totalDuration;
          _isPlaying = false;
          _isCompleted = true;
          if (wasEndOfVideoTimer) {
            _sleepTimerOption = SleepTimerOption.off;
            _showSleepTimerFinishedOverlay = true;
          }
        });
        if (!wasEndOfVideoTimer && widget.nextVideo != null && _autoplayNext) {
          _startNextCountdown();
        }
      } else {
        setState(() {
          _currentPosition = newPos;
          _bufferedPosition = Duration(
            seconds: (_currentPosition.inSeconds + 45).clamp(0, _totalDuration.inSeconds),
          );
        });
      }
    });
  }

  void _startNextCountdown() {
    if (_sleepTimerOption == SleepTimerOption.endOfVideo) {
      _isPlaying = false;
      _nextAutoplayCountdown = null;
      return;
    }
    _autoplayTimer?.cancel();
    _nextAutoplayCountdown = 5;
    _autoplayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_nextAutoplayCountdown != null && _nextAutoplayCountdown! > 1) {
        setState(() {
          _nextAutoplayCountdown = _nextAutoplayCountdown! - 1;
        });
      } else {
        timer.cancel();
        _handlePlayNext();
      }
    });
  }

  void _handlePlayNext() {
    _autoplayTimer?.cancel();
    if (widget.nextVideo != null) {
      setState(() {
        _video = widget.nextVideo!;
        _totalDuration = _video.duration;
        _currentPosition = Duration.zero;
        _isPlaying = true;
        _isCompleted = false;
        _nextAutoplayCountdown = null;
      });
      _resetControlsTimer();
    }
  }

  // --- Playback Toggles ---
  void _togglePlayPause() {
    if (_isCompleted) {
      _handleReplay();
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      _isPlaying = !_isPlaying;
      _showPlayPausePulse = true;
    });

    _playPausePulseTimer?.cancel();
    _playPausePulseTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showPlayPausePulse = false);
    });

    if (_isPlaying) {
      _startControlsTimer();
    } else {
      _controlsTimer?.cancel();
      setState(() => _controlsVisible = true);
    }
  }

  void _handleReplay() {
    setState(() {
      _currentPosition = Duration.zero;
      _isCompleted = false;
      _isPlaying = true;
      _nextAutoplayCountdown = null;
    });
    _autoplayTimer?.cancel();
    _resetControlsTimer();
  }

  void _seekBy(int seconds) {
    final targetSecs = (_currentPosition.inSeconds + seconds).clamp(0, _totalDuration.inSeconds);
    setState(() {
      _currentPosition = Duration(seconds: targetSecs);
      _doubleTapSeekDirection = seconds < 0 ? SeekDirection.backward : SeekDirection.forward;
      _doubleTapSeekSeconds = seconds.abs();
      _showSeekDoubleTapFeedback = true;
    });

    _seekDoubleTapTimer?.cancel();
    _seekDoubleTapTimer = Timer(const Duration(milliseconds: 750), () {
      if (mounted) setState(() => _showSeekDoubleTapFeedback = false);
    });

    _resetControlsTimer();
  }

  void _handleSeekChanged(Duration position) {
    setState(() {
      _currentPosition = position;
      _isDraggingSeekbar = true;
    });
  }

  void _handleSeekEnd(Duration position) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentPosition = position;
      _isDraggingSeekbar = false;
    });
    _resetControlsTimer();
  }

  void _handleScrubbingUpdate(double ratio) {
    final targetSeconds = (ratio * _totalDuration.inSeconds).toInt();
    setState(() {
      _previewRatio = ratio;
      _previewPosition = Duration(seconds: targetSeconds);
    });
  }

  // --- Lock Handling ---
  void _toggleLock() {
    final willLock = !_isLocked;
    if (willLock) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    setState(() {
      _isLocked = willLock;
      _controlsVisible = false;
      _showLockIndicator = true;
    });

    _lockIndicatorTimer?.cancel();
    if (_isLocked) {
      _triggerTransientPill(
        icon: Icons.lock_rounded,
        title: 'Screen Locked',
        subtitle: 'Touch controls disabled',
      );
      _lockIndicatorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showLockIndicator = false);
      });
    } else {
      _triggerTransientPill(
        icon: Icons.lock_open_rounded,
        title: 'Screen Unlocked',
        subtitle: 'Controls restored',
      );
      _resetControlsTimer();
    }
  }

  void _handleLockedBackPress() {
    HapticFeedback.selectionClick();
    setState(() => _showLockIndicator = true);
    _lockIndicatorTimer?.cancel();
    _lockIndicatorTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showLockIndicator = false);
    });
    _triggerTransientPill(
      icon: Icons.lock_rounded,
      title: 'Player locked',
      subtitle: 'Hold the lock icon to unlock',
    );
  }

  // --- Orientation Toggle ---
  void _handleToggleOrientation() {
    HapticFeedback.selectionClick();
    _triggerOrientationFeedback('Landscape');
  }

  // --- Picture-in-Picture ---
  void _handleEnterPip() {
    _triggerCompactToast(
      icon: Icons.picture_in_picture_alt_rounded,
      message: 'Entered Picture-in-Picture Mode',
    );
  }

  // --- Background & PiP Settings ---
  void _handleOpenBackgroundPipSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BackgroundPipSettingsScreen(
          activeVideo: _video,
          activePosition: _currentPosition,
          onReturnToPlayer: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // --- External Subtitle Picker Simulation ---
  void _handleAddSubtitleFile() {
    _triggerCompactToast(
      icon: Icons.file_open_rounded,
      message: 'Offline file picker: Select .srt or .vtt file',
    );
  }

  // --- Frame Stepping ---
  void _stepFrame({required bool forward}) {
    if (_isPlaying) return;
    HapticFeedback.lightImpact();
    final double fps = (_video.fps != null && _video.fps! > 0) ? _video.fps! : 24.0;
    final int frameDurationMs = (1000 / fps).round();
    final newMs = forward
        ? (_currentPosition.inMilliseconds + frameDurationMs).clamp(0, _totalDuration.inMilliseconds)
        : (_currentPosition.inMilliseconds - frameDurationMs).clamp(0, _totalDuration.inMilliseconds);
    setState(() {
      _currentPosition = Duration(milliseconds: newMs);
    });
  }

  // --- Setting Change Handlers with Transient Feedback ---
  void _onSpeedSelected(String speed) {
    HapticFeedback.lightImpact();
    setState(() => _activeSpeed = speed);
    _triggerTransientPill(
      icon: Icons.speed_rounded,
      title: '$speed Speed',
      subtitle: 'Playback Speed',
    );
  }

  void _onScalingModeSelected(PlayerScalingMode mode) {
    HapticFeedback.selectionClick();
    setState(() {
      _scalingMode = mode;
      _userZoomScale = 1.0;
    });
    _triggerTransientPill(
      icon: Icons.aspect_ratio_rounded,
      title: mode.label.toUpperCase(),
      subtitle: 'Aspect Ratio',
    );
  }

  void _onSubtitleSelected(String track) {
    HapticFeedback.selectionClick();
    setState(() => _activeSubtitle = track);
    _triggerTransientPill(
      icon: Icons.subtitles_rounded,
      title: 'Subtitles',
      subtitle: track == 'None' ? 'Subtitles Off' : 'Track: $track',
    );
  }

  void _onAudioTrackSelected(AudioTrackInfo track) {
    HapticFeedback.selectionClick();
    setState(() => _activeAudioTrack = track);
    _triggerTransientPill(
      icon: Icons.audiotrack_rounded,
      title: 'Audio',
      subtitle: 'Track: ${track.title}',
    );
  }

  void _onDecoderChanged(DecoderMode mode) {
    setState(() => _decoderMode = mode);
    if (mode == DecoderMode.software) {
      _triggerCompactToast(
        icon: Icons.memory_rounded,
        message: 'Using software decoder (CPU fallback)',
      );
    } else {
      _triggerCompactToast(
        icon: Icons.bolt_rounded,
        message: 'Hardware acceleration enabled',
      );
    }
  }

  void _onAbRepeatChanged(Duration? a, Duration? b, bool enabled) {
    HapticFeedback.lightImpact();
    setState(() {
      _abRepeatA = a;
      _abRepeatB = b;
      _abRepeatEnabled = enabled;
      _abRepeatCurrentLoop = 0;
    });

    if (enabled && a != null && b != null) {
      _triggerTransientPill(
        icon: Icons.repeat_on_rounded,
        title: 'A ↔ B',
        subtitle: 'Loop Active (${_formatDuration(a)} - ${_formatDuration(b)})',
      );
    } else if (a != null && b == null) {
      _triggerTransientPill(
        icon: Icons.repeat_rounded,
        title: 'A Set',
        subtitle: _formatDuration(a),
      );
    } else if (b != null) {
      _triggerTransientPill(
        icon: Icons.repeat_rounded,
        title: 'B Set',
        subtitle: _formatDuration(b),
      );
    }
  }

  void _openAbRepeatSheet() {
    _controlsTimer?.cancel();
    ABRepeatSheet.show(
      context,
      video: _video,
      currentPosition: _currentPosition,
      totalDuration: _totalDuration,
      initialA: _abRepeatA,
      initialB: _abRepeatB,
      initialEnabled: _abRepeatEnabled,
      repeatCount: _abRepeatCount,
      onRepeatCountChanged: (count) {
        setState(() {
          _abRepeatCount = count;
          _abRepeatCurrentLoop = 0;
        });
      },
      onSeek: (pos) {
        setState(() {
          _currentPosition = pos;
        });
      },
      onPointsChanged: _onAbRepeatChanged,
    );
  }

  // --- Sleep Timer ---
  void _setSleepTimer(SleepTimerOption option, [Duration? customDuration]) {
    _sleepTimer?.cancel();
    setState(() {
      _sleepTimerOption = option;
      _showSleepTimerFinishedOverlay = false;
    });

    if (option == SleepTimerOption.off) {
      _sleepTimerEndTime = null;
      _triggerTransientPill(
        icon: Icons.timer_off_outlined,
        title: 'Sleep Timer',
        subtitle: 'Timer Off',
      );
      return;
    }

    if (option == SleepTimerOption.endOfVideo) {
      _sleepTimerEndTime = null;
      _triggerTransientPill(
        icon: Icons.stop_circle_outlined,
        title: 'Sleep Timer',
        subtitle: 'Stops when video ends',
      );
      return;
    }

    final dur = customDuration ?? option.duration ?? const Duration(minutes: 30);
    _sleepTimerEndTime = DateTime.now().add(dur);
    _triggerTransientPill(
      icon: Icons.timer_outlined,
      title: 'Sleep Timer',
      subtitle: '${dur.inMinutes} minutes',
    );

    // Periodic 1-second ticker to check expiration and update indicator
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_sleepTimerEndTime != null) {
        final diff = _sleepTimerEndTime!.difference(DateTime.now());
        if (diff <= Duration.zero) {
          timer.cancel();
          _sleepTimer?.cancel();
          setState(() {
            _isPlaying = false;
            _sleepTimerOption = SleepTimerOption.off;
            _sleepTimerEndTime = null;
            _showSleepTimerFinishedOverlay = true;
          });
          HapticFeedback.heavyImpact();
          _triggerCompactToast(
            icon: Icons.bedtime_rounded,
            message: 'Sleep timer finished: Playback stopped',
          );
        } else {
          // Re-render when controls are visible or near expiration (< 2m)
          if (_controlsVisible || diff <= const Duration(minutes: 2)) {
            setState(() {});
          }
        }
      }
    });
  }

  void _extendSleepTimer(Duration extension) {
    if (_sleepTimerEndTime != null) {
      setState(() {
        _sleepTimerEndTime = _sleepTimerEndTime!.add(extension);
      });
      HapticFeedback.lightImpact();
      _triggerTransientPill(
        icon: Icons.more_time_rounded,
        title: 'Sleep Timer',
        subtitle: 'Extended (+${extension.inMinutes}m)',
      );
    }
  }

  String _formatSleepRemaining(Duration diff) {
    if (diff <= Duration.zero) return '00:00';
    final hours = diff.inHours;
    final mins = diff.inMinutes.remainder(60);
    final secs = diff.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _openSleepTimerSheet() {
    _controlsTimer?.cancel();
    SleepTimerSheet.show(
      context,
      currentOption: _sleepTimerOption,
      targetEndTime: _sleepTimerEndTime,
      onOptionSelected: (opt) => _setSleepTimer(opt),
      onCustomDurationSelected: (dur) => _setSleepTimer(SleepTimerOption.custom, dur),
      onExtendTimer: _extendSleepTimer,
      onCancelTimer: () => _setSleepTimer(SleepTimerOption.off),
    );
  }

  // --- Advanced Player Controls / More Panel ---
  void _openAdvancedPanel() {
    _controlsTimer?.cancel();
    AdvancedPlayerPanel.show(
      context,
      video: _video,
      currentPosition: _currentPosition,
      totalDuration: _totalDuration,
      isPlaying: _isPlaying,
      skipForwardSeconds: _skipForwardSeconds,
      skipBackwardSeconds: _skipBackwardSeconds,
      autoplayNext: _autoplayNext,
      currentDecoder: _decoderMode,
      scalingMode: _scalingMode,
      currentZoom: _userZoomScale,
      audioDelayMs: _audioDelayMs,
      volumeBoost: _volumeBoost,
      activeAudioTrack: _activeAudioTrack,
      activeSubtitleTrack: _activeSubtitle,
      subtitleDelayMs: _subtitleDelayMs,
      subtitleStyleName: _subtitleStyleName,
      abRepeatA: _abRepeatA,
      abRepeatB: _abRepeatB,
      abRepeatEnabled: _abRepeatEnabled,
      sleepTimerOption: _sleepTimerOption,
      sleepTimerEndTime: _sleepTimerEndTime,
      onCustomSleepDuration: (dur) => _setSleepTimer(SleepTimerOption.custom, dur),
      onExtendSleepTimer: _extendSleepTimer,
      onCancelSleepTimer: () => _setSleepTimer(SleepTimerOption.off),
      isStatsOverlayEnabled: _showStats,
      isScreenLocked: _isLocked,
      onSkipForwardChanged: (val) => setState(() => _skipForwardSeconds = val),
      onSkipBackwardChanged: (val) => setState(() => _skipBackwardSeconds = val),
      onAutoplayNextChanged: (val) => setState(() => _autoplayNext = val),
      onDecoderChanged: _onDecoderChanged,
      onScalingModeChanged: _onScalingModeSelected,
      onZoomChanged: (zoom) => setState(() => _userZoomScale = zoom),
      onAudioDelayChanged: (ms) => setState(() => _audioDelayMs = ms),
      onVolumeBoostChanged: (boost) => setState(() => _volumeBoost = boost),
      onAudioTrackChanged: _onAudioTrackSelected,
      onSubtitleTrackChanged: _onSubtitleSelected,
      onSubtitleDelayChanged: (ms) => setState(() => _subtitleDelayMs = ms),
      onSubtitleStyleChanged: (style) => setState(() => _subtitleStyleName = style),
      onAbRepeatChanged: _onAbRepeatChanged,
      onSleepTimerChanged: _setSleepTimer,
      onStatsOverlayToggle: (enabled) => setState(() => _showStats = enabled),
      onToggleScreenLock: _toggleLock,
      onStepFrameBackward: () => _stepFrame(forward: false),
      onStepFrameForward: () => _stepFrame(forward: true),
      onEnterPip: _handleEnterPip,
    );
  }

  // --- Gesture Handlers ---
  void _handleScreenTap() {
    if (_isLocked) {
      HapticFeedback.selectionClick();
      setState(() => _showLockIndicator = true);
      _lockIndicatorTimer?.cancel();
      _lockIndicatorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showLockIndicator = false);
      });
      return;
    }

    if (_controlsVisible) {
      _togglePlayPause();
    } else {
      _resetControlsTimer();
    }
  }

  void _handleDoubleTapDown(TapDownDetails details, double screenWidth) {
    if (_isLocked) {
      setState(() => _showLockIndicator = true);
      _lockIndicatorTimer?.cancel();
      _lockIndicatorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showLockIndicator = false);
      });
      return;
    }

    _lastDoubleTapPosition = details.localPosition;
    final x = details.localPosition.dx;
    if (x < screenWidth * 0.35) {
      HapticFeedback.lightImpact();
      _seekBy(-_skipBackwardSeconds);
    } else if (x > screenWidth * 0.65) {
      HapticFeedback.lightImpact();
      _seekBy(_skipForwardSeconds);
    } else {
      _togglePlayPause();
    }
  }

  void _handleLongPressStart() {
    if (_isLocked || !_holdFor2xEnabled) return;
    HapticFeedback.lightImpact();
    setState(() => _isTempFastForward = true);
  }

  void _handleLongPressEnd() {
    if (_isLocked) return;
    setState(() => _isTempFastForward = false);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_isLocked) return;
    _baseZoomScale = _userZoomScale;
    _gestureStartX = details.localFocalPoint.dx;
    _accumulatedDx = 0.0;
    _accumulatedDy = 0.0;
    _activeGestureMode = _ActiveGestureMode.none;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, double screenWidth) {
    if (_isLocked) return;

    // 1. Multi-finger pinch-to-zoom detection
    if (details.pointerCount > 1 || (details.scale - 1.0).abs() > 0.06) {
      _activeGestureMode = _ActiveGestureMode.pinchZoom;
      final newScale = (_baseZoomScale * details.scale).clamp(0.75, 3.5);
      if ((_userZoomScale - 1.0).abs() > 0.05 && (newScale - 1.0).abs() <= 0.05) {
        HapticFeedback.selectionClick();
      }
      setState(() {
        _userZoomScale = newScale;
        _showZoomFeedback = true;
      });
      _zoomFeedbackTimer?.cancel();
      return;
    }

    if (_activeGestureMode == _ActiveGestureMode.pinchZoom) return;

    final dx = details.focalPointDelta.dx;
    final dy = details.focalPointDelta.dy;
    _accumulatedDx += dx;
    _accumulatedDy += dy;

    // 2. Dominant Axis Detection with Movement Threshold (Prevents conflict)
    if (_activeGestureMode == _ActiveGestureMode.none) {
      const threshold = 6.0;
      if (_accumulatedDx.abs() > threshold && _accumulatedDx.abs() > _accumulatedDy.abs() * 1.3) {
        _activeGestureMode = _ActiveGestureMode.horizontalSeek;
        setState(() {
          _isScrubbing = true;
          _scrubDelta = Duration.zero;
          _scrubTargetPosition = _currentPosition;
        });
      } else if (_accumulatedDy.abs() > threshold && _accumulatedDy.abs() > _accumulatedDx.abs() * 1.3) {
        if ((_gestureStartX ?? 0) < screenWidth * 0.5) {
          _activeGestureMode = _ActiveGestureMode.verticalBrightness;
        } else {
          _activeGestureMode = _ActiveGestureMode.verticalVolume;
        }
      }
    }

    // 3. Horizontal Scrub Seek Active
    if (_activeGestureMode == _ActiveGestureMode.horizontalSeek) {
      final seconds = (dx * 1.5).toInt();
      final newDelta = (_scrubDelta ?? Duration.zero) + Duration(seconds: seconds);
      final targetSecs = (_currentPosition.inSeconds + newDelta.inSeconds).clamp(0, _totalDuration.inSeconds);
      setState(() {
        _scrubDelta = newDelta;
        _scrubTargetPosition = Duration(seconds: targetSecs);
      });
      return;
    }

    // 4. Vertical Drag: Left Half = Brightness
    if (_activeGestureMode == _ActiveGestureMode.verticalBrightness) {
      final delta = -dy / 200;
      final oldVal = _brightness;
      final newVal = (_brightness + delta).clamp(0.05, 1.0);
      if ((newVal == 1.0 && oldVal < 1.0) || (newVal == 0.05 && oldVal > 0.05)) {
        HapticFeedback.selectionClick();
      }
      setState(() {
        _brightness = newVal;
        _showBrightnessFeedback = true;
      });
      _brightnessFeedbackTimer?.cancel();
      _brightnessFeedbackTimer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) setState(() => _showBrightnessFeedback = false);
      });
      return;
    }

    // 5. Vertical Drag: Right Half = Volume
    if (_activeGestureMode == _ActiveGestureMode.verticalVolume) {
      final delta = -dy / 200;
      final oldVal = _volume;
      final newVal = (_volume + delta).clamp(0.0, 1.0);
      if ((newVal == 1.0 && oldVal < 1.0) || (newVal == 0.0 && oldVal > 0.0)) {
        HapticFeedback.selectionClick();
      }
      setState(() {
        _volume = newVal;
        _isMuted = _volume == 0;
        _showVolumeFeedback = true;
      });
      _volumeFeedbackTimer?.cancel();
      _volumeFeedbackTimer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) setState(() => _showVolumeFeedback = false);
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_isLocked) return;
    if (_activeGestureMode == _ActiveGestureMode.horizontalSeek && _scrubTargetPosition != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentPosition = _scrubTargetPosition!;
        _isScrubbing = false;
        _scrubDelta = null;
        _scrubTargetPosition = null;
      });
      _resetControlsTimer();
    }

    if (_activeGestureMode == _ActiveGestureMode.pinchZoom) {
      _zoomFeedbackTimer?.cancel();
      _zoomFeedbackTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _showZoomFeedback = false);
      });
    }

    _activeGestureMode = _ActiveGestureMode.none;
    _gestureStartX = null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLocked,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isLocked) {
          _handleLockedBackPress();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Interactive Video Surface (Renders cinematic offline frame)
              VideoSurface(
                video: _video,
                scalingMode: _scalingMode,
                userZoomScale: _userZoomScale,
                isPlaying: _isPlaying,
                activeAspectRatio: _activeAspectRatio,
                cropAlignment: _cropAlignment,
              ),

              // 2. Gesture Detection Layer
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _handleScreenTap,
                  onDoubleTapDown: (details) => _handleDoubleTapDown(details, screenWidth),
                  onDoubleTap: () {},
                  onLongPressStart: (_) => _handleLongPressStart(),
                  onLongPressEnd: (_) => _handleLongPressEnd(),
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: (details) => _handleScaleUpdate(details, screenWidth),
                  onScaleEnd: _handleScaleEnd,
                ),
              ),

              // 3. Subtitles Overlay (Always visible; elevates when controls are visible)
              SubtitlesOverlay(
                activeSubtitleTrack: _activeSubtitle,
                controlsVisible: _controlsVisible && !_isLocked,
                currentPosition: _currentPosition,
                styleConfig: _subtitleConfig,
              ),

              // 4. Temporary Gesture Feedback Overlays
              if (_showBrightnessFeedback)
                BrightnessFeedbackOverlay(brightness: _brightness),

              if (_showVolumeFeedback)
                VolumeFeedbackOverlay(volume: _volume),

              if (_showSeekDoubleTapFeedback && _doubleTapSeekDirection != null)
                SeekDoubleTapFeedbackOverlay(
                  direction: _doubleTapSeekDirection!,
                  seconds: _doubleTapSeekSeconds,
                  touchPosition: _lastDoubleTapPosition,
                ),

              if (_isScrubbing && _scrubTargetPosition != null && _scrubDelta != null)
                ScrubSeekFeedbackOverlay(
                  currentPosition: _scrubTargetPosition!,
                  delta: _scrubDelta!,
                  totalDuration: _totalDuration,
                ),

              if (_isTempFastForward)
                const LongPressSpeedBadgeOverlay(),

              if (_showZoomFeedback)
                ZoomFeedbackBadgeOverlay(
                  scale: _userZoomScale,
                  modeName: _scalingMode != PlayerScalingMode.fit && _userZoomScale == 1.0
                      ? _scalingMode.label
                      : null,
                ),

              if (_showOrientationFeedback)
                OrientationFeedbackOverlay(
                  orientationName: _orientationLabel,
                  isLocked: _isOrientationLocked,
                ),

              if (_showTransientPill)
                TransientPillFeedbackOverlay(
                  icon: _transientPillIcon,
                  title: _transientPillTitle,
                  subtitle: _transientPillSubtitle,
                ),

              if (_showPlayPausePulse)
                CenterPlayPausePulse(isPlaying: _isPlaying),

              if (_showCompactToast)
                CompactPlayerToastOverlay(
                  icon: _compactToastIcon,
                  message: _compactToastMessage,
                ),

              if (_isLocked)
                ScreenLockedOverlay(
                  onUnlock: _toggleLock,
                  isMinimized: !_showLockIndicator,
                ),

              // 5. Seek Thumbnail Preview Card
              if (_isDraggingSeekbar)
                SeekPreviewCard(
                  previewPosition: _previewPosition,
                  video: _video,
                  horizontalRatio: _previewRatio,
                ),

              // 6. Playback Statistics Overlay (Nerd stats)
              if (_showStats)
                PlaybackStatisticsOverlay(
                  video: _video,
                  decoderMode: _decoderMode,
                  onClose: () => setState(() => _showStats = false),
                ),

              // 7. Top Control Bar (Fades in / out)
              if (!_isLocked)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _controlsVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    child: IgnorePointer(
                      ignoring: !_controlsVisible,
                      child: PlayerTopBar(
                        video: _video,
                        onBack: () => Navigator.pop(context),
                        onLock: _toggleLock,
                        onToggleStats: () => setState(() => _showStats = !_showStats),
                        isStatsEnabled: _showStats,
                        onToggleOrientation: _handleToggleOrientation,
                        onOverflow: _openAdvancedPanel,
                        sleepTimerBadge: _sleepTimerOption == SleepTimerOption.off
                            ? null
                            : (_sleepTimerOption == SleepTimerOption.endOfVideo
                                ? 'End of video'
                                : (_sleepTimerEndTime != null
                                    ? _formatSleepRemaining(_sleepTimerEndTime!.difference(DateTime.now()))
                                    : null)),
                        isSleepTimerNearExpiration: _sleepTimerEndTime != null &&
                            _sleepTimerEndTime!.difference(DateTime.now()) <= const Duration(minutes: 2),
                        onSleepTimerTap: _openSleepTimerSheet,
                        abRepeatBadge: (_abRepeatEnabled && _abRepeatA != null && _abRepeatB != null)
                            ? 'A ↔ B'
                            : null,
                        onAbRepeatTap: _openAbRepeatSheet,
                      ),
                    ),
                  ),
                ),

              // 8. Bottom Control Bar (Fades in / out)
              if (!_isLocked)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _controlsVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    child: IgnorePointer(
                      ignoring: !_controlsVisible,
                      child: PlayerBottomBar(
                        currentPosition: _currentPosition,
                        totalDuration: _totalDuration,
                        bufferedPosition: _bufferedPosition,
                        isPlaying: _isPlaying,
                        isMuted: _isMuted,
                        activeSubtitle: _activeSubtitle,
                        activeAudioTrack: _activeAudioTrack.title,
                        activeSpeed: _activeSpeed,
                        activeScalingMode: _scalingMode,
                        onSeekChanged: _handleSeekChanged,
                        onSeekEnd: _handleSeekEnd,
                        onScrubbingUpdate: _handleScrubbingUpdate,
                        onTogglePlayPause: _togglePlayPause,
                        onToggleMute: () => setState(() => _isMuted = !_isMuted),
                        onSubtitlesTap: () {
                          PlayerSheets.showSubtitlesSheet(
                            context,
                            subtitleTracks: _video.effectiveSubtitleTracks,
                            selectedTrack: _activeSubtitle,
                            onSelected: _onSubtitleSelected,
                            onAddSubtitleFile: _handleAddSubtitleFile,
                            videoTitle: _video.title,
                            onOpenCustomization: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubtitleStyleScreen(
                                    initialConfig: _subtitleConfig,
                                    onConfigChanged: (config) {
                                      setState(() {
                                        _subtitleConfig = config;
                                        _subtitleStyleName = config.presetName;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        onAudioTap: () {
                          PlayerSheets.showAudioTracksSheet(
                            context,
                            videoTitle: _video.title,
                            audioTracks: _video.effectiveAudioTracks,
                            selectedTrack: _activeAudioTrack,
                            onSelected: _onAudioTrackSelected,
                            volume: _volume,
                            isMuted: _isMuted,
                            onVolumeChanged: (vol) {
                              setState(() => _volume = vol);
                            },
                            onToggleMute: () {
                              setState(() => _isMuted = !_isMuted);
                            },
                            audioDelayMs: _audioDelayMs,
                            onAudioDelayChanged: (delay) {
                              setState(() => _audioDelayMs = delay);
                            },
                            volumeBoost: _volumeBoost,
                            onVolumeBoostChanged: (boost) {
                              setState(() => _volumeBoost = boost);
                            },
                          );
                        },
                        onSpeedTap: () {
                          PlayerSheets.showSpeedSheet(
                            context,
                            videoTitle: _video.title,
                            selectedSpeed: _activeSpeed,
                            onSelected: _onSpeedSelected,
                            holdFor2xEnabled: _holdFor2xEnabled,
                            onHoldFor2xChanged: (enabled) {
                              setState(() => _holdFor2xEnabled = enabled);
                            },
                          );
                        },
                        onAspectTap: () {
                          PlayerSheets.showAspectRatioSheet(
                            context,
                            videoTitle: _video.title,
                            selectedMode: _scalingMode,
                            onSelected: _onScalingModeSelected,
                            selectedAspectRatio: _activeAspectRatio,
                            onAspectRatioChanged: (ratio) {
                              setState(() => _activeAspectRatio = ratio);
                            },
                            userZoomScale: _userZoomScale,
                            onZoomChanged: (zoom) {
                              setState(() => _userZoomScale = zoom);
                            },
                            cropAlignment: _cropAlignment,
                            onCropAlignmentChanged: (alignment) {
                              setState(() => _cropAlignment = alignment);
                            },
                            onResetDisplay: () {
                              setState(() {
                                _scalingMode = PlayerScalingMode.fit;
                                _activeAspectRatio = 'Auto';
                                _userZoomScale = 1.0;
                                _cropAlignment = Alignment.center;
                              });
                            },
                          );
                        },
                        onSettingsTap: _openAdvancedPanel,
                      ),
                    ),
                  ),
                ),

              // 9. Playback Completion State
              if (_isCompleted)
                PlayerCompletionOverlay(
                  currentVideo: _video,
                  nextVideo: widget.nextVideo,
                  nextCountdownSeconds: _nextAutoplayCountdown,
                  onReplay: _handleReplay,
                  onPlayNext: _handlePlayNext,
                  onCancelNext: () {
                    _autoplayTimer?.cancel();
                    setState(() => _nextAutoplayCountdown = null);
                  },
                ),

              // 10. Playback Error State
              if (_hasError)
                PlayerErrorOverlay(
                  video: _video,
                  onTryAgain: () {
                    setState(() {
                      _hasError = false;
                      _isPlaying = true;
                    });
                  },
                  onOpenSettings: () {
                    PlayerSheets.showSettingsSheet(
                      context,
                      video: _video,
                      currentDecoder: _decoderMode,
                      onDecoderChanged: (mode) => setState(() => _decoderMode = mode),
                      backgroundPlaybackEnabled: _backgroundPlaybackEnabled,
                      onBackgroundPlaybackChanged: (val) =>
                          setState(() => _backgroundPlaybackEnabled = val),
                      isStatsEnabled: _showStats,
                      onStatsChanged: (val) => setState(() => _showStats = val),
                      onEnterPip: _handleEnterPip,
                      onRestartFromBeginning: _handleReplay,
                      onOpenPipSettings: _handleOpenBackgroundPipSettings,
                    );
                  },
                  onShowTechnicalDetails: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('Playback Technical Error', style: TextStyle(color: Colors.white, fontSize: 16)),
                        content: Text(
                          'Decoder: ${_decoderMode.label}\nCodec: ${_video.codec}\nResolution: ${_video.effectiveDimensions}\nBitrate: ${_video.effectiveBitrateMbps} Mbps\n\nDirect hardware codec pipe failed to initialize.',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Dismiss', style: TextStyle(color: AppColors.electricBlueBright)),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              // 11. Near-Expiration Floating Sleep Timer Indicator (when controls are hidden)
              if (!_controlsVisible &&
                  !_isLocked &&
                  _sleepTimerEndTime != null &&
                  _sleepTimerEndTime!.difference(DateTime.now()) <= const Duration(minutes: 2))
                Positioned(
                  top: 14,
                  right: 16,
                  child: SafeArea(
                    child: GestureDetector(
                      key: const ValueKey('near_expiration_floating_badge'),
                      onTap: _openSleepTimerSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.80), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.35),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, size: 13, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              _formatSleepRemaining(_sleepTimerEndTime!.difference(DateTime.now())),
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // 12. Sleep Timer Finished Calm Overlay
              if (_showSleepTimerFinishedOverlay)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.75),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundNavy.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.glassBorderSubtle),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.60),
                              blurRadius: 28,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.violetAccent.withOpacity(0.18),
                              ),
                              child: const Icon(
                                Icons.nightlight_round,
                                size: 28,
                                color: AppColors.violetAccent,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Playback stopped',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Sleep timer finished',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 18),
                            GestureDetector(
                              key: const ValueKey('sleep_timer_resume_btn'),
                              onTap: () {
                                setState(() {
                                  _showSleepTimerFinishedOverlay = false;
                                  _isPlaying = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.electricBlue.withOpacity(0.22),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.electricBlueBright),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Resume',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}
}
