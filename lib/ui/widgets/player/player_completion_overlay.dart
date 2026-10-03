import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/local_video.dart';

/// Clean overlay shown when local video playback finishes
class PlayerCompletionOverlay extends StatelessWidget {
  final LocalVideo currentVideo;
  final LocalVideo? nextVideo;
  final int? nextCountdownSeconds;
  final VoidCallback onReplay;
  final VoidCallback? onPlayNext;
  final VoidCallback? onCancelNext;

  const PlayerCompletionOverlay({
    super.key,
    required this.currentVideo,
    this.nextVideo,
    this.nextCountdownSeconds,
    required this.onReplay,
    this.onPlayNext,
    this.onCancelNext,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.82),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.glassBorderSubtle,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.60),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Success Checkmark
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.electricBlueBright.withOpacity(0.50),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.electricBlueBright,
                      size: 28,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Video finished',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  currentVideo.title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 20),

                // 2. Next Video Preview Card (if next exists)
                if (nextVideo != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGlass,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.glassBorderSubtle),
                    ),
                    child: Row(
                      children: [
                        // Next video thumbnail
                        Container(
                          width: 44,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [nextVideo!.gradientStart, nextVideo!.gradientEnd],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Icon(nextVideo!.visualIcon, color: Colors.white, size: 16),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'UP NEXT',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.electricBlueBright,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                nextVideo!.title,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (nextCountdownSeconds != null)
                                Text(
                                  'Starting in $nextCountdownSeconds...',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 3. Actions Row
                Row(
                  children: [
                    // Replay button
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.replay_rounded, size: 16),
                        label: const Text('Replay'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.glassBorderSubtle),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: onReplay,
                      ),
                    ),

                    if (nextVideo != null) ...[
                      const SizedBox(width: 10),
                      // Play Next button
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.skip_next_rounded, size: 18),
                          label: const Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: onPlayNext,
                        ),
                      ),
                    ],
                  ],
                ),

                if (nextVideo != null && nextCountdownSeconds != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onCancelNext,
                    child: const Text(
                      'Cancel Autoplay',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
