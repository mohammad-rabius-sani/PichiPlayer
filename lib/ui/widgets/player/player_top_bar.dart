import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/local_video.dart';

/// Top overlay bar with back navigation, video title, orientation toggle, and actions
class PlayerTopBar extends StatelessWidget {
  final LocalVideo video;
  final VoidCallback onBack;
  final VoidCallback onLock;
  final VoidCallback onToggleStats;
  final bool isStatsEnabled;
  final VoidCallback onToggleOrientation;
  final VoidCallback onOverflow;
  final String? sleepTimerBadge;
  final VoidCallback? onSleepTimerTap;
  final bool isSleepTimerNearExpiration;
  final String? abRepeatBadge;
  final VoidCallback? onAbRepeatTap;

  const PlayerTopBar({
    super.key,
    required this.video,
    required this.onBack,
    required this.onLock,
    required this.onToggleStats,
    required this.isStatsEnabled,
    required this.onToggleOrientation,
    required this.onOverflow,
    this.sleepTimerBadge,
    this.onSleepTimerTap,
    this.isSleepTimerNearExpiration = false,
    this.abRepeatBadge,
    this.onAbRepeatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xCC000000),
            Color(0x80000000),
            Colors.transparent,
          ],
          stops: [0.0, 0.65, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Row(
            children: [
              // Back Button
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: 'Back',
                onPressed: onBack,
              ),

              const SizedBox(width: 4),

              // Title / Filename
              Expanded(
                child: Text(
                  video.displayFileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              // A-B Repeat Badge Indicator (A ↔ B)
              if (abRepeatBadge != null) ...[
                GestureDetector(
                  key: const ValueKey('player_ab_repeat_badge'),
                  onTap: onAbRepeatTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.electricBlueBright.withOpacity(0.50),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.repeat_rounded,
                          size: 13,
                          color: AppColors.electricBlueBright,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          abRepeatBadge!,
                          style: const TextStyle(
                            color: AppColors.electricBlueBright,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],

              // Sleep Timer Badge Indicator (◷ 29:42)
              if (sleepTimerBadge != null) ...[
                GestureDetector(
                  key: const ValueKey('player_sleep_timer_badge'),
                  onTap: onSleepTimerTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSleepTimerNearExpiration
                          ? Colors.amber.withOpacity(0.20)
                          : AppColors.electricBlue.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSleepTimerNearExpiration
                            ? Colors.amber.withOpacity(0.70)
                            : AppColors.electricBlueBright.withOpacity(0.50),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: isSleepTimerNearExpiration
                              ? Colors.amber
                              : AppColors.electricBlueBright,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sleepTimerBadge!,
                          style: TextStyle(
                            color: isSleepTimerNearExpiration
                                ? Colors.amber
                                : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],

              // Toggle Stats Button
              IconButton(
                icon: Icon(
                  isStatsEnabled
                      ? Icons.query_stats_rounded
                      : Icons.analytics_outlined,
                  color: isStatsEnabled
                      ? AppColors.electricBlueBright
                      : Colors.white.withOpacity(0.85),
                  size: 20,
                ),
                tooltip: 'Playback Statistics',
                onPressed: onToggleStats,
              ),

              // Screen Orientation Toggle
              IconButton(
                icon: Icon(
                  Icons.screen_rotation_rounded,
                  color: Colors.white.withOpacity(0.85),
                  size: 20,
                ),
                tooltip: 'Rotate Screen',
                onPressed: onToggleOrientation,
              ),

              // Screen Lock Button
              IconButton(
                icon: Icon(
                  Icons.lock_open_rounded,
                  color: Colors.white.withOpacity(0.85),
                  size: 20,
                ),
                tooltip: 'Lock Screen',
                onPressed: onLock,
              ),

              // Overflow Menu Button
              IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'More Options',
                onPressed: onOverflow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
