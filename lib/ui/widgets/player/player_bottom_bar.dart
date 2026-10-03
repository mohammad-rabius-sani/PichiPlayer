import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/player_types.dart';

/// Bottom overlay bar with current time, duration, smooth seekbar, and compact action controls
class PlayerBottomBar extends StatelessWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final Duration bufferedPosition;
  final bool isPlaying;
  final bool isMuted;
  final String activeSubtitle;
  final String activeAudioTrack;
  final String activeSpeed;
  final PlayerScalingMode activeScalingMode;

  final ValueChanged<Duration> onSeekChanged;
  final ValueChanged<Duration> onSeekEnd;
  final ValueChanged<double>? onScrubbingUpdate; // 0.0 to 1.0 for thumbnail preview
  final VoidCallback onTogglePlayPause;
  final VoidCallback onToggleMute;
  final VoidCallback onSubtitlesTap;
  final VoidCallback onAudioTap;
  final VoidCallback onSpeedTap;
  final VoidCallback onAspectTap;
  final VoidCallback onSettingsTap;

  const PlayerBottomBar({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.bufferedPosition,
    required this.isPlaying,
    required this.isMuted,
    required this.activeSubtitle,
    required this.activeAudioTrack,
    required this.activeSpeed,
    required this.activeScalingMode,
    required this.onSeekChanged,
    required this.onSeekEnd,
    this.onScrubbingUpdate,
    required this.onTogglePlayPause,
    required this.onToggleMute,
    required this.onSubtitlesTap,
    required this.onAudioTap,
    required this.onSpeedTap,
    required this.onAspectTap,
    required this.onSettingsTap,
  });

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = totalDuration.inSeconds > 0 ? totalDuration.inSeconds : 1;
    final progress = (currentPosition.inSeconds / totalSeconds).clamp(0.0, 1.0);
    final bufferedProgress = (bufferedPosition.inSeconds / totalSeconds).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xE6000000),
            Color(0x99000000),
            Colors.transparent,
          ],
          stops: [0.0, 0.70, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Time indicators Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(currentPosition),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      _formatDuration(totalDuration),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // 2. Custom Interactive Seekbar with Glow and Drag
              _buildSeekBar(progress, bufferedProgress, totalSeconds),

              const SizedBox(height: 8),

              // 3. Compact Bottom Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Play / Pause Button
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    tooltip: isPlaying ? 'Pause' : 'Play',
                    onPressed: onTogglePlayPause,
                  ),

                  // Volume Mute/Unmute
                  IconButton(
                    icon: Icon(
                      isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: isMuted ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                    tooltip: isMuted ? 'Unmute' : 'Mute',
                    onPressed: onToggleMute,
                  ),

                  // Subtitles Pill Action
                  _buildActionPill(
                    icon: Icons.subtitles_rounded,
                    label: activeSubtitle,
                    onTap: onSubtitlesTap,
                  ),

                  // Audio Track Action
                  _buildActionPill(
                    icon: Icons.audiotrack_rounded,
                    label: activeAudioTrack,
                    onTap: onAudioTap,
                  ),

                  // Playback Speed Action
                  _buildActionPill(
                    icon: Icons.speed_rounded,
                    label: activeSpeed,
                    onTap: onSpeedTap,
                  ),

                  // Aspect Ratio / Scaling Action
                  _buildActionPill(
                    icon: Icons.aspect_ratio_rounded,
                    label: activeScalingMode.label,
                    onTap: onAspectTap,
                  ),

                  // Settings Action
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                    tooltip: 'Player Settings',
                    onPressed: onSettingsTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeekBar(double progress, double bufferedProgress, int totalSeconds) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;

        void handleTouch(Offset localPosition) {
          final ratio = (localPosition.dx / barWidth).clamp(0.0, 1.0);
          final targetSeconds = (ratio * totalSeconds).toInt();
          final targetDuration = Duration(seconds: targetSeconds);
          onScrubbingUpdate?.call(ratio);
          onSeekChanged(targetDuration);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (details) => handleTouch(details.localPosition),
          onHorizontalDragUpdate: (details) => handleTouch(details.localPosition),
          onHorizontalDragEnd: (details) {
            onSeekEnd(currentPosition);
          },
          onTapDown: (details) {
            handleTouch(details.localPosition);
            onSeekEnd(currentPosition);
          },
          child: Container(
            height: 28, // Ample touch target
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Inactive track
                Container(
                  height: 4,
                  width: barWidth,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                // Buffered track
                Container(
                  height: 4,
                  width: barWidth * bufferedProgress,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                // Active progress track with glow
                Container(
                  height: 4,
                  width: barWidth * progress,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlueBright,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricBlue.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),

                // Draggable thumb indicator
                Positioned(
                  left: (barWidth * progress) - 6.5,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withOpacity(0.80),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.electricBlueBright),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 62),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
