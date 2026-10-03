import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/audio_track_info.dart';
import '../../../models/local_video.dart';
import '../../../models/player_types.dart';
import 'audio_selection_sheet.dart';
import 'display_control_sheet.dart';
import 'playback_speed_sheet.dart';
import 'subtitle_selection_sheet.dart';

/// Bottom sheets helper for player settings, subtitles, audio, speed, and aspect ratio
class PlayerSheets {
  PlayerSheets._();

  // --- Subtitles Bottom Sheet ---
  static void showSubtitlesSheet(
    BuildContext context, {
    required List<String> subtitleTracks,
    required String selectedTrack,
    required ValueChanged<String> onSelected,
    VoidCallback? onAddSubtitleFile,
    VoidCallback? onOpenCustomization,
    String? videoTitle,
  }) {
    SubtitleSelectionSheet.show(
      context,
      subtitleTracks: subtitleTracks,
      selectedTrack: selectedTrack,
      onSelected: onSelected,
      onAddSubtitleFile: onAddSubtitleFile,
      onOpenCustomization: onOpenCustomization,
      videoTitle: videoTitle,
    );
  }

  // --- Audio Track Bottom Sheet ---
  static void showAudioTracksSheet(
    BuildContext context, {
    required List<AudioTrackInfo> audioTracks,
    required AudioTrackInfo selectedTrack,
    required ValueChanged<AudioTrackInfo> onSelected,
    String? videoTitle,
    double volume = 0.75,
    bool isMuted = false,
    ValueChanged<double>? onVolumeChanged,
    VoidCallback? onToggleMute,
    int audioDelayMs = 0,
    ValueChanged<int>? onAudioDelayChanged,
    String volumeBoost = 'Off',
    ValueChanged<String>? onVolumeBoostChanged,
    bool normalizeVolume = false,
    ValueChanged<bool>? onNormalizeVolumeChanged,
    String downmixOption = 'Auto',
    ValueChanged<String>? onDownmixChanged,
    String audioOutputDevice = 'Phone speaker',
  }) {
    AudioSelectionSheet.show(
      context,
      audioTracks: audioTracks,
      selectedTrack: selectedTrack,
      onSelected: onSelected,
      videoTitle: videoTitle,
      volume: volume,
      isMuted: isMuted,
      onVolumeChanged: onVolumeChanged,
      onToggleMute: onToggleMute,
      audioDelayMs: audioDelayMs,
      onAudioDelayChanged: onAudioDelayChanged,
      volumeBoost: volumeBoost,
      onVolumeBoostChanged: onVolumeBoostChanged,
      normalizeVolume: normalizeVolume,
      onNormalizeVolumeChanged: onNormalizeVolumeChanged,
      downmixOption: downmixOption,
      onDownmixChanged: onDownmixChanged,
      audioOutputDevice: audioOutputDevice,
    );
  }

  // --- Playback Speed Bottom Sheet ---
  static void showSpeedSheet(
    BuildContext context, {
    required String selectedSpeed,
    required ValueChanged<String> onSelected,
    ValueChanged<double>? onSpeedChanged,
    bool holdFor2xEnabled = true,
    ValueChanged<bool>? onHoldFor2xChanged,
    String? videoTitle,
  }) {
    PlaybackSpeedSheet.show(
      context,
      selectedSpeed: selectedSpeed,
      onSelected: onSelected,
      onSpeedChanged: onSpeedChanged,
      holdFor2xEnabled: holdFor2xEnabled,
      onHoldFor2xChanged: onHoldFor2xChanged,
      videoTitle: videoTitle,
    );
  }

  // --- Aspect Ratio & Display Bottom Sheet ---
  static void showAspectRatioSheet(
    BuildContext context, {
    required PlayerScalingMode selectedMode,
    required ValueChanged<PlayerScalingMode> onSelected,
    String selectedAspectRatio = 'Auto',
    ValueChanged<String>? onAspectRatioChanged,
    double userZoomScale = 1.0,
    ValueChanged<double>? onZoomChanged,
    Alignment cropAlignment = Alignment.center,
    ValueChanged<Alignment>? onCropAlignmentChanged,
    VoidCallback? onResetDisplay,
    String? videoTitle,
  }) {
    DisplayControlSheet.show(
      context,
      selectedMode: selectedMode,
      onSelected: onSelected,
      selectedAspectRatio: selectedAspectRatio,
      onAspectRatioChanged: onAspectRatioChanged,
      userZoomScale: userZoomScale,
      onZoomChanged: onZoomChanged,
      cropAlignment: cropAlignment,
      onCropAlignmentChanged: onCropAlignmentChanged,
      onResetDisplay: onResetDisplay,
      videoTitle: videoTitle,
    );
  }

  // --- Player Settings Bottom Sheet ---
  static void showSettingsSheet(
    BuildContext context, {
    required LocalVideo video,
    required DecoderMode currentDecoder,
    required ValueChanged<DecoderMode> onDecoderChanged,
    required bool backgroundPlaybackEnabled,
    required ValueChanged<bool> onBackgroundPlaybackChanged,
    required bool isStatsEnabled,
    required ValueChanged<bool> onStatsChanged,
    required VoidCallback onEnterPip,
    required VoidCallback onRestartFromBeginning,
    VoidCallback? onOpenPipSettings,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => _PlayerSheetWrapper(
          title: 'Player Settings',
          icon: Icons.tune_rounded,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Hardware Decoder Toggle
              SwitchListTile(
                secondary: const Icon(Icons.memory_rounded, color: AppColors.electricBlueBright),
                title: const Text('Hardware Decoding', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text(
                  currentDecoder.description,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                value: currentDecoder == DecoderMode.hardware,
                activeColor: AppColors.electricBlueBright,
                onChanged: (val) {
                  final newMode = val ? DecoderMode.hardware : DecoderMode.software;
                  setSheetState(() {});
                  onDecoderChanged(newMode);
                },
              ),

              const Divider(color: AppColors.glassBorderSubtle, height: 1),

              // 2. Background Playback Toggle
              SwitchListTile(
                secondary: const Icon(Icons.headset_rounded, color: AppColors.electricBlueBright),
                title: const Text('Background Playback', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text(
                  'Continue audio playback when exiting app',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                value: backgroundPlaybackEnabled,
                activeColor: AppColors.electricBlueBright,
                onChanged: (val) {
                  setSheetState(() {});
                  onBackgroundPlaybackChanged(val);
                },
              ),

              const Divider(color: AppColors.glassBorderSubtle, height: 1),

              // 3. Playback Statistics Toggle
              SwitchListTile(
                secondary: const Icon(Icons.query_stats_rounded, color: AppColors.electricBlueBright),
                title: const Text('Playback Statistics Overlay', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text(
                  'Show live FPS, codec, resolution, and bitrate',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                value: isStatsEnabled,
                activeColor: AppColors.electricBlueBright,
                onChanged: (val) {
                  setSheetState(() {});
                  onStatsChanged(val);
                },
              ),

              const Divider(color: AppColors.glassBorderSubtle, height: 1),

              // 4. Picture-in-Picture
              ListTile(
                leading: const Icon(Icons.picture_in_picture_alt_rounded, color: AppColors.electricBlueBright),
                title: const Text('Picture-in-Picture (PiP)', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text(
                  'Shrink player into floating Android window',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onEnterPip();
                },
              ),

              const Divider(color: AppColors.glassBorderSubtle, height: 1),

              // 5. Background & PiP Settings
              ListTile(
                leading: const Icon(Icons.settings_suggest_rounded, color: AppColors.electricBlueBright),
                title: const Text('Background & PiP Settings', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text(
                  'Configure background audio, auto-PiP & notifications',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onOpenPipSettings?.call();
                },
              ),

              const Divider(color: AppColors.glassBorderSubtle, height: 1),

              // 6. Restart from Beginning
              ListTile(
                leading: const Icon(Icons.replay_rounded, color: Colors.white70),
                title: const Text('Restart from Beginning', style: TextStyle(color: Colors.white, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  onRestartFromBeginning();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Base wrapper for player bottom sheets
class _PlayerSheetWrapper extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _PlayerSheetWrapper({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.only(top: 14, bottom: 28),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: const Border(
            top: BorderSide(color: AppColors.glassBorderSubtle, width: 1.0),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              const SizedBox(height: 14),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.electricBlueBright, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: AppColors.glassBorderSubtle, height: 1),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

