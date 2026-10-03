import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_typography.dart';
import '../../models/scan_state.dart';

/// Compact scanning status section with a thin, luminous progress indicator
/// and dynamic scan statistics.
class ScanningProgressCard extends StatelessWidget {
  final ScanState scanState;
  final VoidCallback? onCompletedAction;

  const ScanningProgressCard({
    super.key,
    required this.scanState,
    this.onCompletedAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scanState.isCompleted 
              ? AppColors.electricBlue.withOpacity(0.3)
              : AppColors.glassBorderSubtle,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Status title: "Scanning local videos..."
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              scanState.isCompleted ? 'All Videos Indexed' : scanState.statusMessage,
              key: ValueKey(scanState.isCompleted ? 'done' : 'scanning'),
              style: AppTypography.scanHeader.copyWith(
                color: scanState.isCompleted
                    ? AppColors.electricBlueBright
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 18),

          // 2. Thin premium progress indicator
          _LuminousProgressBar(
            progress: scanState.progress,
            isCompleted: scanState.isCompleted,
          ),

          const SizedBox(height: 14),

          // 3. Dynamic percentage readout e.g. "68%"
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: scanState.progress),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            builder: (context, animValue, _) {
              final pct = (animValue * 100).toInt().clamp(0, 100);
              return Text(
                '$pct%',
                style: AppTypography.scanPercentage,
              );
            },
          ),

          const SizedBox(height: 10),

          // 4. Videos found count e.g. "1,248 videos found"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.movie_outlined,
                size: 14,
                color: scanState.isCompleted
                    ? AppColors.electricBlueBright
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                scanState.videosFoundText,
                style: AppTypography.scanVideoCount,
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 5. Current folder path: "Scanning Movies/"
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Row(
              key: ValueKey(scanState.currentFolder),
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.folder_outlined,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    scanState.isCompleted
                        ? 'Indexed in internal storage'
                        : 'Scanning ${scanState.currentFolder}',
                    style: AppTypography.scanCurrentFolder,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),

          // Optional completion button when 100% finished
          if (scanState.isCompleted && onCompletedAction != null) ...[
            const SizedBox(height: 18),
            _ContinueButton(onPressed: onCompletedAction!),
          ],
        ],
      ),
    );
  }
}

/// Custom thin progress bar with luminous electric blue & violet glow
class _LuminousProgressBar extends StatelessWidget {
  final double progress;
  final bool isCompleted;

  const _LuminousProgressBar({
    required this.progress,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.progressTrack,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.progressTrackBorder,
          width: 0.8,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              final activeW = maxW * animatedProgress;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Active luminous gradient fill
                  Container(
                    width: activeW,
                    height: 4.0,
                    decoration: BoxDecoration(
                      gradient: AppGradients.progressBar,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withOpacity(0.55),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                        if (isCompleted)
                          BoxShadow(
                            color: AppColors.violetAccent.withOpacity(0.4),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                  ),

                  // Soft leading edge highlight beacon
                  if (activeW > 4 && animatedProgress < 1.0)
                    Positioned(
                      left: activeW - 4,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.electricBlueBright,
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ContinueButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.electricBlue,
              AppColors.violetAccent,
            ],
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricBlue.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter Player',
              style: AppTypography.buttonLabel,
            ),
            SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
