import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_typography.dart';
import '../../models/local_video.dart';

/// Reusable horizontal video thumbnail card for Continue Watching,
/// Recently Added, and 4K Collections.
class VideoThumbnailCard extends StatefulWidget {
  final LocalVideo video;
  final bool showProgress;
  final bool showQualityBadges;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double cardWidth;

  const VideoThumbnailCard({
    super.key,
    required this.video,
    this.showProgress = false,
    this.showQualityBadges = false,
    required this.onTap,
    this.onLongPress,
    this.cardWidth = AppDimensions.videoCardWidth,
  });

  @override
  State<VideoThumbnailCard> createState() => _VideoThumbnailCardState();
}

class _VideoThumbnailCardState extends State<VideoThumbnailCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.965).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressController.reverse(),
        onLongPress: () {
          _pressController.reverse();
          widget.onLongPress?.call();
        },
        child: Container(
          width: widget.cardWidth,
          margin: const EdgeInsets.only(right: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Thumbnail Container (16:9 ratio with 18dp rounded corners)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: widget.cardWidth * (9 / 16),
                  width: widget.cardWidth,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(
                      color: AppColors.glassBorderSubtle,
                      width: 0.8,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Generative Cinematic Thumbnail Background
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              video.gradientStart,
                              video.gradientEnd,
                              AppColors.backgroundNavy,
                            ],
                          ),
                        ),
                      ),

                      // Center atmospheric symbol
                      Center(
                        child: Icon(
                          video.visualIcon,
                          size: 34,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),

                      // Small Play Glyph
                      Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.4),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 0.8,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Quality Badges Top-Left (4K, HDR, 60 FPS)
                      if (widget.showQualityBadges)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Row(
                            children: [
                              if (video.resolution == '4K') ...[
                                _buildBadge('4K'),
                                const SizedBox(width: 4),
                              ],
                              if (video.isHdr) ...[
                                _buildBadge('HDR'),
                                const SizedBox(width: 4),
                              ],
                              if (video.fps != null && video.fps! >= 60) ...[
                                _buildBadge('${video.fpsFormatted} FPS'),
                              ],
                            ],
                          ),
                        ),

                      // Duration Pill Badge Bottom-Right
                      Positioned(
                        bottom: widget.showProgress ? 6 : 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            video.durationFormatted,
                            style: AppTypography.durationBadge,
                          ),
                        ),
                      ),

                      // Thin Playback Progress Indicator pinned to bottom
                      if (widget.showProgress && video.isPartiallyWatched)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 2.8,
                            color: AppColors.progressTrack,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: video.progressRatio,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: AppGradients.progressBar,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.electricBlueBright,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 2. Video Title
              Text(
                video.title,
                style: AppTypography.videoCardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 3),

              // 3. Subtitle: Watched position / total duration OR Duration
              Text(
                widget.showProgress && video.isPartiallyWatched
                    ? video.progressText
                    : video.durationFormatted,
                style: AppTypography.videoCardProgress,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.glassBorderSubtle,
          width: 0.6,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.qualityBadge,
      ),
    );
  }
}
