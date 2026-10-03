import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/audio_track_info.dart';
import '../../../models/local_video.dart';
import '../../../models/player_types.dart';
import 'more_panel/ab_repeat_sheet.dart';
import 'more_panel/delay_control_sheet.dart';
import 'more_panel/focused_stats_sheet.dart';
import 'more_panel/sleep_timer_sheet.dart';
import 'more_panel/subtitle_customization_sheet.dart';
import 'more_panel/zoom_control_sheet.dart';
import 'player_sheets.dart';

/// Master bottom sheet for Advanced Player Controls / More Panel
class AdvancedPlayerPanel extends StatefulWidget {
  final LocalVideo video;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;
  final int skipForwardSeconds;
  final int skipBackwardSeconds;
  final bool autoplayNext;
  final DecoderMode currentDecoder;
  final PlayerScalingMode scalingMode;
  final double currentZoom;
  final int audioDelayMs;
  final String volumeBoost;
  final AudioTrackInfo activeAudioTrack;
  final String activeSubtitleTrack;
  final int subtitleDelayMs;
  final String subtitleStyleName;
  final Duration? abRepeatA;
  final Duration? abRepeatB;
  final bool abRepeatEnabled;
  final SleepTimerOption sleepTimerOption;
  final DateTime? sleepTimerEndTime;
  final bool isStatsOverlayEnabled;
  final bool isScreenLocked;

  // Callbacks
  final ValueChanged<int> onSkipForwardChanged;
  final ValueChanged<int> onSkipBackwardChanged;
  final ValueChanged<bool> onAutoplayNextChanged;
  final ValueChanged<DecoderMode> onDecoderChanged;
  final ValueChanged<PlayerScalingMode> onScalingModeChanged;
  final ValueChanged<double> onZoomChanged;
  final ValueChanged<int> onAudioDelayChanged;
  final ValueChanged<String> onVolumeBoostChanged;
  final ValueChanged<AudioTrackInfo> onAudioTrackChanged;
  final ValueChanged<String> onSubtitleTrackChanged;
  final ValueChanged<int> onSubtitleDelayChanged;
  final ValueChanged<String> onSubtitleStyleChanged;
  final void Function(Duration? a, Duration? b, bool enabled) onAbRepeatChanged;
  final ValueChanged<SleepTimerOption> onSleepTimerChanged;
  final ValueChanged<Duration>? onCustomSleepDuration;
  final ValueChanged<Duration>? onExtendSleepTimer;
  final VoidCallback? onCancelSleepTimer;
  final ValueChanged<bool> onStatsOverlayToggle;
  final VoidCallback onToggleScreenLock;
  final VoidCallback onStepFrameBackward;
  final VoidCallback onStepFrameForward;
  final VoidCallback onEnterPip;

  const AdvancedPlayerPanel({
    super.key,
    required this.video,
    required this.currentPosition,
    required this.totalDuration,
    required this.isPlaying,
    required this.skipForwardSeconds,
    required this.skipBackwardSeconds,
    required this.autoplayNext,
    required this.currentDecoder,
    required this.scalingMode,
    required this.currentZoom,
    required this.audioDelayMs,
    required this.volumeBoost,
    required this.activeAudioTrack,
    required this.activeSubtitleTrack,
    required this.subtitleDelayMs,
    required this.subtitleStyleName,
    required this.abRepeatA,
    required this.abRepeatB,
    required this.abRepeatEnabled,
    required this.sleepTimerOption,
    this.sleepTimerEndTime,
    this.onCustomSleepDuration,
    this.onExtendSleepTimer,
    this.onCancelSleepTimer,
    required this.isStatsOverlayEnabled,
    required this.isScreenLocked,
    required this.onSkipForwardChanged,
    required this.onSkipBackwardChanged,
    required this.onAutoplayNextChanged,
    required this.onDecoderChanged,
    required this.onScalingModeChanged,
    required this.onZoomChanged,
    required this.onAudioDelayChanged,
    required this.onVolumeBoostChanged,
    required this.onAudioTrackChanged,
    required this.onSubtitleTrackChanged,
    required this.onSubtitleDelayChanged,
    required this.onSubtitleStyleChanged,
    required this.onAbRepeatChanged,
    required this.onSleepTimerChanged,
    required this.onStatsOverlayToggle,
    required this.onToggleScreenLock,
    required this.onStepFrameBackward,
    required this.onStepFrameForward,
    required this.onEnterPip,
  });

  static void show(
    BuildContext context, {
    required LocalVideo video,
    required Duration currentPosition,
    required Duration totalDuration,
    required bool isPlaying,
    required int skipForwardSeconds,
    required int skipBackwardSeconds,
    required bool autoplayNext,
    required DecoderMode currentDecoder,
    required PlayerScalingMode scalingMode,
    required double currentZoom,
    required int audioDelayMs,
    required String volumeBoost,
    required AudioTrackInfo activeAudioTrack,
    required String activeSubtitleTrack,
    required int subtitleDelayMs,
    required String subtitleStyleName,
    required Duration? abRepeatA,
    required Duration? abRepeatB,
    required bool abRepeatEnabled,
    required SleepTimerOption sleepTimerOption,
    DateTime? sleepTimerEndTime,
    ValueChanged<Duration>? onCustomSleepDuration,
    ValueChanged<Duration>? onExtendSleepTimer,
    VoidCallback? onCancelSleepTimer,
    required bool isStatsOverlayEnabled,
    required bool isScreenLocked,
    required ValueChanged<int> onSkipForwardChanged,
    required ValueChanged<int> onSkipBackwardChanged,
    required ValueChanged<bool> onAutoplayNextChanged,
    required ValueChanged<DecoderMode> onDecoderChanged,
    required ValueChanged<PlayerScalingMode> onScalingModeChanged,
    required ValueChanged<double> onZoomChanged,
    required ValueChanged<int> onAudioDelayChanged,
    required ValueChanged<String> onVolumeBoostChanged,
    required ValueChanged<AudioTrackInfo> onAudioTrackChanged,
    required ValueChanged<String> onSubtitleTrackChanged,
    required ValueChanged<int> onSubtitleDelayChanged,
    required ValueChanged<String> onSubtitleStyleChanged,
    required void Function(Duration? a, Duration? b, bool enabled) onAbRepeatChanged,
    required ValueChanged<SleepTimerOption> onSleepTimerChanged,
    required ValueChanged<bool> onStatsOverlayToggle,
    required VoidCallback onToggleScreenLock,
    required VoidCallback onStepFrameBackward,
    required VoidCallback onStepFrameForward,
    required VoidCallback onEnterPip,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => AdvancedPlayerPanel(
        video: video,
        currentPosition: currentPosition,
        totalDuration: totalDuration,
        isPlaying: isPlaying,
        skipForwardSeconds: skipForwardSeconds,
        skipBackwardSeconds: skipBackwardSeconds,
        autoplayNext: autoplayNext,
        currentDecoder: currentDecoder,
        scalingMode: scalingMode,
        currentZoom: currentZoom,
        audioDelayMs: audioDelayMs,
        volumeBoost: volumeBoost,
        activeAudioTrack: activeAudioTrack,
        activeSubtitleTrack: activeSubtitleTrack,
        subtitleDelayMs: subtitleDelayMs,
        subtitleStyleName: subtitleStyleName,
        abRepeatA: abRepeatA,
        abRepeatB: abRepeatB,
        abRepeatEnabled: abRepeatEnabled,
        sleepTimerOption: sleepTimerOption,
        sleepTimerEndTime: sleepTimerEndTime,
        onCustomSleepDuration: onCustomSleepDuration,
        onExtendSleepTimer: onExtendSleepTimer,
        onCancelSleepTimer: onCancelSleepTimer,
        isStatsOverlayEnabled: isStatsOverlayEnabled,
        isScreenLocked: isScreenLocked,
        onSkipForwardChanged: onSkipForwardChanged,
        onSkipBackwardChanged: onSkipBackwardChanged,
        onAutoplayNextChanged: onAutoplayNextChanged,
        onDecoderChanged: onDecoderChanged,
        onScalingModeChanged: onScalingModeChanged,
        onZoomChanged: onZoomChanged,
        onAudioDelayChanged: onAudioDelayChanged,
        onVolumeBoostChanged: onVolumeBoostChanged,
        onAudioTrackChanged: onAudioTrackChanged,
        onSubtitleTrackChanged: onSubtitleTrackChanged,
        onSubtitleDelayChanged: onSubtitleDelayChanged,
        onSubtitleStyleChanged: onSubtitleStyleChanged,
        onAbRepeatChanged: onAbRepeatChanged,
        onSleepTimerChanged: onSleepTimerChanged,
        onStatsOverlayToggle: onStatsOverlayToggle,
        onToggleScreenLock: onToggleScreenLock,
        onStepFrameBackward: onStepFrameBackward,
        onStepFrameForward: onStepFrameForward,
        onEnterPip: onEnterPip,
      ),
    );
  }

  @override
  State<AdvancedPlayerPanel> createState() => _AdvancedPlayerPanelState();
}

class _AdvancedPlayerPanelState extends State<AdvancedPlayerPanel> {
  late int _skipForward;
  late int _skipBackward;
  late bool _autoplayNext;
  late DecoderMode _decoder;
  late PlayerScalingMode _scalingMode;
  late double _zoom;
  late int _audioDelay;
  late String _volumeBoost;
  late AudioTrackInfo _audioTrack;
  late String _subtitleTrack;
  late int _subtitleDelay;
  late String _subtitleStyle;
  late Duration? _abA;
  late Duration? _abB;
  late bool _abEnabled;
  late SleepTimerOption _sleepTimer;
  late bool _statsOverlay;

  @override
  void initState() {
    super.initState();
    _skipForward = widget.skipForwardSeconds;
    _skipBackward = widget.skipBackwardSeconds;
    _autoplayNext = widget.autoplayNext;
    _decoder = widget.currentDecoder;
    _scalingMode = widget.scalingMode;
    _zoom = widget.currentZoom;
    _audioDelay = widget.audioDelayMs;
    _volumeBoost = widget.volumeBoost;
    _audioTrack = widget.activeAudioTrack;
    _subtitleTrack = widget.activeSubtitleTrack;
    _subtitleDelay = widget.subtitleDelayMs;
    _subtitleStyle = widget.subtitleStyleName;
    _abA = widget.abRepeatA;
    _abB = widget.abRepeatB;
    _abEnabled = widget.abRepeatEnabled;
    _sleepTimer = widget.sleepTimerOption;
    _statsOverlay = widget.isStatsOverlayEnabled;
  }

  // Calculate current approximate frame number based on position & FPS
  int get _currentFrameNumber {
    final double fps = (widget.video.fps != null && widget.video.fps! > 0)
        ? widget.video.fps!
        : 24.0;
    return (widget.currentPosition.inMilliseconds * fps / 1000).toInt();
  }

  void _showSkipSelectDialog({required bool isForward}) {
    const options = [5, 10, 15, 30, 60];
    final currentVal = isForward ? _skipForward : _skipBackward;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: const Border(top: BorderSide(color: AppColors.glassBorderSubtle)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isForward ? 'Skip Forward' : 'Skip Backward',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 12),
                for (final sec in options)
                  ListTile(
                    title: Text(
                      '$sec sec',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: sec == currentVal ? FontWeight.w700 : FontWeight.w500,
                        color: sec == currentVal ? AppColors.electricBlueBright : Colors.white,
                      ),
                    ),
                    trailing: sec == currentVal
                        ? const Icon(Icons.check_rounded, color: AppColors.electricBlueBright, size: 20)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isForward) {
                          _skipForward = sec;
                          widget.onSkipForwardChanged(sec);
                        } else {
                          _skipBackward = sec;
                          widget.onSkipBackwardChanged(sec);
                        }
                      });
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDecoderDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: const Border(top: BorderSide(color: AppColors.glassBorderSubtle)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Decoder',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hardware decoding requires device SoC decoder profile',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                for (final mode in DecoderMode.values)
                  ListTile(
                    title: Text(
                      mode.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: mode == _decoder ? FontWeight.w700 : FontWeight.w500,
                        color: mode == _decoder ? AppColors.electricBlueBright : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      mode.description,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    trailing: mode == _decoder
                        ? const Icon(Icons.check_rounded, color: AppColors.electricBlueBright, size: 20)
                        : null,
                    onTap: () {
                      setState(() => _decoder = mode);
                      widget.onDecoderChanged(mode);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVolumeBoostDialog() {
    const boosts = ['Off', '+25%', '+50%', '+75%', '+100%'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: const Border(top: BorderSide(color: AppColors.glassBorderSubtle)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Volume Boost',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Software pre-amplification for quiet audio tracks',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                for (final val in boosts)
                  ListTile(
                    title: Text(
                      val,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: val == _volumeBoost ? FontWeight.w700 : FontWeight.w500,
                        color: val == _volumeBoost ? AppColors.electricBlueBright : Colors.white,
                      ),
                    ),
                    trailing: val == _volumeBoost
                        ? const Icon(Icons.check_rounded, color: AppColors.electricBlueBright, size: 20)
                        : null,
                    onTap: () {
                      setState(() => _volumeBoost = val);
                      widget.onVolumeBoostChanged(val);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.82;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.94),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(
            top: BorderSide(color: AppColors.glassBorderSubtle, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.65),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Drag handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Player Controls',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.video.displayFileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close panel',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Divider(color: AppColors.glassBorderSubtle, height: 1),

              // 3. Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),

                      // Quick tools row
                      _buildQuickToolsRow(),

                      const SizedBox(height: 18),

                      // PLAYBACK SECTION
                      _buildSectionHeader('PLAYBACK'),
                      _buildActionRow(
                        icon: Icons.fast_forward_rounded,
                        label: 'Skip forward',
                        value: '$_skipForward sec',
                        onTap: () => _showSkipSelectDialog(isForward: true),
                      ),
                      _buildActionRow(
                        icon: Icons.fast_rewind_rounded,
                        label: 'Skip backward',
                        value: '$_skipBackward sec',
                        onTap: () => _showSkipSelectDialog(isForward: false),
                      ),
                      _buildSwitchRow(
                        icon: Icons.playlist_play_rounded,
                        label: 'Auto-play next',
                        description: 'Automatically begin playing next video in folder',
                        value: _autoplayNext,
                        onChanged: (val) {
                          setState(() => _autoplayNext = val);
                          widget.onAutoplayNextChanged(val);
                        },
                      ),

                      // Frame Step (when paused)
                      _buildFrameStepControl(),

                      const SizedBox(height: 16),

                      // VIDEO SECTION
                      _buildSectionHeader('VIDEO'),
                      _buildActionRow(
                        icon: Icons.memory_rounded,
                        label: 'Decoder',
                        value: _decoder.label,
                        onTap: _showDecoderDialog,
                      ),
                      _buildActionRow(
                        icon: Icons.aspect_ratio_rounded,
                        label: 'Aspect ratio',
                        value: _scalingMode.label,
                        onTap: () {
                          PlayerSheets.showAspectRatioSheet(
                            context,
                            selectedMode: _scalingMode,
                            onSelected: (mode) {
                              setState(() => _scalingMode = mode);
                              widget.onScalingModeChanged(mode);
                            },
                          );
                        },
                      ),
                      _buildActionRow(
                        icon: Icons.zoom_in_rounded,
                        label: 'Zoom',
                        value: '${_zoom.toStringAsFixed(2)}×',
                        onTap: () {
                          ZoomControlSheet.show(
                            context,
                            currentZoom: _zoom,
                            onZoomChanged: (z) {
                              setState(() => _zoom = z);
                              widget.onZoomChanged(z);
                            },
                          );
                        },
                      ),
                      _buildActionRow(
                        icon: Icons.lock_outline_rounded,
                        label: 'Screen Lock',
                        value: widget.isScreenLocked ? 'Active' : 'Off',
                        onTap: () {
                          Navigator.pop(context);
                          widget.onToggleScreenLock();
                        },
                      ),

                      const SizedBox(height: 16),

                      // AUDIO SECTION
                      _buildSectionHeader('AUDIO'),
                      _buildActionRow(
                        icon: Icons.sync_rounded,
                        label: 'Audio delay',
                        value: '$_audioDelay ms',
                        onTap: () {
                          DelayControlSheet.show(
                            context,
                            title: 'Audio Delay',
                            icon: Icons.audiotrack_rounded,
                            initialDelayMs: _audioDelay,
                            onDelayChanged: (ms) {
                              setState(() => _audioDelay = ms);
                              widget.onAudioDelayChanged(ms);
                            },
                          );
                        },
                      ),
                      _buildActionRow(
                        icon: Icons.volume_up_rounded,
                        label: 'Volume boost',
                        value: _volumeBoost,
                        onTap: _showVolumeBoostDialog,
                      ),
                      _buildActionRow(
                        icon: Icons.audiotrack_outlined,
                        label: 'Audio track',
                        value: _audioTrack.title,
                        onTap: () {
                          PlayerSheets.showAudioTracksSheet(
                            context,
                            videoTitle: widget.video.title,
                            audioTracks: widget.video.effectiveAudioTracks,
                            selectedTrack: _audioTrack,
                            onSelected: (track) {
                              setState(() => _audioTrack = track);
                              widget.onAudioTrackChanged(track);
                            },
                            audioDelayMs: _audioDelay,
                            onAudioDelayChanged: (delay) {
                              setState(() => _audioDelay = delay);
                              widget.onAudioDelayChanged(delay);
                            },
                            volumeBoost: _volumeBoost,
                            onVolumeBoostChanged: (boost) {
                              setState(() => _volumeBoost = boost);
                              widget.onVolumeBoostChanged(boost);
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // SUBTITLES SECTION
                      _buildSectionHeader('SUBTITLES'),
                      _buildActionRow(
                        icon: Icons.subtitles_rounded,
                        label: 'Subtitle track',
                        value: _subtitleTrack,
                        onTap: () {
                          PlayerSheets.showSubtitlesSheet(
                            context,
                            subtitleTracks: widget.video.effectiveSubtitleTracks,
                            selectedTrack: _subtitleTrack,
                            onSelected: (track) {
                              setState(() => _subtitleTrack = track);
                              widget.onSubtitleTrackChanged(track);
                            },
                            videoTitle: widget.video.title,
                            onOpenCustomization: () {
                              SubtitleCustomizationSheet.show(
                                context,
                                currentStyleName: _subtitleStyle,
                                onStyleSelected: (style) {
                                  setState(() => _subtitleStyle = style);
                                  widget.onSubtitleStyleChanged(style);
                                },
                              );
                            },
                          );
                        },
                      ),
                      _buildActionRow(
                        icon: Icons.tune_rounded,
                        label: 'Subtitle delay',
                        value: '$_subtitleDelay ms',
                        onTap: () {
                          DelayControlSheet.show(
                            context,
                            title: 'Subtitle Delay',
                            icon: Icons.subtitles_rounded,
                            initialDelayMs: _subtitleDelay,
                            onDelayChanged: (ms) {
                              setState(() => _subtitleDelay = ms);
                              widget.onSubtitleDelayChanged(ms);
                            },
                          );
                        },
                      ),
                      _buildActionRow(
                        icon: Icons.format_paint_rounded,
                        label: 'Subtitle style',
                        value: _subtitleStyle,
                        onTap: () {
                          SubtitleCustomizationSheet.show(
                            context,
                            currentStyleName: _subtitleStyle,
                            onStyleSelected: (style) {
                              setState(() => _subtitleStyle = style);
                              widget.onSubtitleStyleChanged(style);
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Picture-in-Picture action
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.picture_in_picture_alt_rounded, size: 18),
                          label: const Text('Picture-in-Picture (PiP)'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.glassBorderSubtle),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            minimumSize: const Size(double.infinity, 44),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onEnterPip();
                          },
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
    );
  }

  // --- Quick Tools Row ---
  Widget _buildQuickToolsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          // 1. A-B Repeat
          Expanded(
            child: _QuickToolCard(
              icon: Icons.repeat_rounded,
              label: 'Repeat',
              badge: _abEnabled ? 'ON' : null,
              isActive: _abEnabled,
              onTap: () {
                ABRepeatSheet.show(
                  context,
                  video: widget.video,
                  currentPosition: widget.currentPosition,
                  totalDuration: widget.totalDuration,
                  initialA: _abA,
                  initialB: _abB,
                  initialEnabled: _abEnabled,
                  onPointsChanged: (a, b, enabled) {
                    setState(() {
                      _abA = a;
                      _abB = b;
                      _abEnabled = enabled;
                    });
                    widget.onAbRepeatChanged(a, b, enabled);
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 10),

          // 2. Sleep Timer
          Expanded(
            child: _QuickToolCard(
              icon: Icons.timer_outlined,
              label: 'Timer',
              badge: _sleepTimer != SleepTimerOption.off ? 'Active' : null,
              isActive: _sleepTimer != SleepTimerOption.off,
              onTap: () {
                SleepTimerSheet.show(
                  context,
                  currentOption: _sleepTimer,
                  targetEndTime: widget.sleepTimerEndTime,
                  onOptionSelected: (option) {
                    setState(() => _sleepTimer = option);
                    widget.onSleepTimerChanged(option);
                  },
                  onCustomDurationSelected: widget.onCustomSleepDuration,
                  onExtendTimer: widget.onExtendSleepTimer,
                  onCancelTimer: widget.onCancelSleepTimer,
                );
              },
            ),
          ),
          const SizedBox(width: 10),

          // 3. Playback Statistics
          Expanded(
            child: _QuickToolCard(
              icon: Icons.analytics_outlined,
              label: 'Stats',
              badge: _statsOverlay ? 'ON' : null,
              isActive: _statsOverlay,
              onTap: () {
                FocusedStatsSheet.show(
                  context,
                  video: widget.video,
                  decoderMode: _decoder,
                  activeAudioTrack: _audioTrack,
                  isOverlayEnabled: _statsOverlay,
                  onOverlayToggle: (enabled) {
                    setState(() => _statsOverlay = enabled);
                    widget.onStatsOverlayToggle(enabled);
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 10),

          // 4. Decoder
          Expanded(
            child: _QuickToolCard(
              icon: Icons.memory_rounded,
              label: 'Decoder',
              badge: _decoder == DecoderMode.hardware ? 'HW' : _decoder == DecoderMode.auto ? 'Auto' : 'SW',
              isActive: true,
              onTap: _showDecoderDialog,
            ),
          ),
        ],
      ),
    );
  }

  // --- Frame Stepping Widget ---
  Widget _buildFrameStepControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Frame Step',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isPlaying
                      ? 'Pause video to step frames'
                      : 'Frame ${_currentFrameNumber.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isPlaying ? AppColors.textMuted : AppColors.electricBlueBright,
                    fontWeight: widget.isPlaying ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, size: 20),
                  color: widget.isPlaying ? Colors.white24 : Colors.white,
                  onPressed: widget.isPlaying ? null : widget.onStepFrameBackward,
                  tooltip: 'Previous frame',
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 20),
                  color: widget.isPlaying ? Colors.white24 : Colors.white,
                  onPressed: widget.isPlaying ? null : widget.onStepFrameForward,
                  tooltip: 'Next frame',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Section Header ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.electricBlueBright,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // --- Action Row with Value & Chevron ---
  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.electricBlueBright,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  // --- Switch Row ---
  Widget _buildSwitchRow({
    required IconData icon,
    required String label,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.electricBlueBright,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _QuickToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickToolCard({
    required this.icon,
    required this.label,
    this.badge,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.electricBlue.withOpacity(0.14) : AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? AppColors.electricBlueBright.withOpacity(0.40) : AppColors.glassBorderSubtle,
            ),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isActive ? AppColors.electricBlueBright : Colors.white70,
                  ),
                  if (badge != null)
                    Positioned(
                      top: -6,
                      right: -14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlueBright,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
