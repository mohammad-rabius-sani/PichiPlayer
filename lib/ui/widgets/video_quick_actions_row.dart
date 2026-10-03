import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Compact horizontal quick actions row for subtitles, audio tracks, and playback speed
class VideoQuickActionsRow extends StatelessWidget {
  final String activeSubtitle;
  final String activeAudio;
  final String activeSpeed;
  final VoidCallback onSubtitlesTap;
  final VoidCallback onAudioTap;
  final VoidCallback onSpeedTap;
  final VoidCallback onMoreTap;

  const VideoQuickActionsRow({
    super.key,
    required this.activeSubtitle,
    required this.activeAudio,
    required this.activeSpeed,
    required this.onSubtitlesTap,
    required this.onAudioTap,
    required this.onSpeedTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // 1. Subtitles Action
          Expanded(
            child: _QuickActionButton(
              icon: Icons.subtitles_outlined,
              label: 'Subtitles',
              value: activeSubtitle,
              onTap: onSubtitlesTap,
            ),
          ),
          const SizedBox(width: 8),

          // 2. Audio Action
          Expanded(
            child: _QuickActionButton(
              icon: Icons.audiotrack_outlined,
              label: 'Audio',
              value: activeAudio,
              onTap: onAudioTap,
            ),
          ),
          const SizedBox(width: 8),

          // 3. Playback Speed Action
          Expanded(
            child: _QuickActionButton(
              icon: Icons.speed_rounded,
              label: 'Speed',
              value: activeSpeed,
              onTap: onSpeedTap,
            ),
          ),
          const SizedBox(width: 8),

          // 4. More Options Action
          Expanded(
            child: _QuickActionButton(
              icon: Icons.tune_rounded,
              label: 'Aspect',
              value: '16:9',
              onTap: onMoreTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.electricBlue.withOpacity(0.12),
        highlightColor: AppColors.electricBlue.withOpacity(0.06),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.glassBorderSubtle,
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.electricBlueBright,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
