import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/local_video.dart';

/// 2-column Library Grid Card featuring 16:9 cinematic thumbnail,
/// 4K/HDR badges, duration pill, and balanced 2-line filename.
class LibraryGridCard extends StatefulWidget {
  final LocalVideo video;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMoreTap;

  const LibraryGridCard({
    super.key,
    required this.video,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
    required this.onMoreTap,
  });

  @override
  State<LibraryGridCard> createState() => _LibraryGridCardState();
}

class _LibraryGridCardState extends State<LibraryGridCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
          widget.onLongPress();
        },
        child: Container(
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.electricBlue.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.electricBlueBright
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Thumbnail (16:9 Aspect Ratio with 16dp rounded corners)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient Thumbnail Base
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

                      // Atmospheric Center Glyph
                      Center(
                        child: Icon(
                          video.visualIcon,
                          size: 32,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),

                      // Subtle Dark Bottom Gradient for duration readability
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.65),
                              ],
                              stops: const [0.55, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Badges: 4K / HDR (Top-Left)
                      if (video.resolution == '4K' || video.isHdr)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (video.resolution == '4K') ...[
                                _buildBadge('4K'),
                                const SizedBox(width: 3),
                              ],
                              if (video.isHdr) ...[
                                _buildBadge('HDR'),
                              ],
                            ],
                          ),
                        ),

                      // Duration Pill Badge (Bottom-Right)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video.durationFormatted,
                            style: AppTypography.durationBadge,
                          ),
                        ),
                      ),

                      // Selection Checkbox Overlay (when in Selection Mode)
                      if (widget.isSelectionMode)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isSelected
                                  ? AppColors.electricBlue
                                  : Colors.black.withOpacity(0.55),
                              border: Border.all(
                                color: widget.isSelected
                                    ? AppColors.electricBlueBright
                                    : Colors.white70,
                                width: 1.2,
                              ),
                            ),
                            child: widget.isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 7),

              // 2. Filename (approx 2 lines with ellipsis) & Overflow Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.displayFileName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          video.compactMetadataText,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),

                  // Compact Overflow Action Button
                  if (!widget.isSelectionMode)
                    GestureDetector(
                      onTap: widget.onMoreTap,
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 4, top: 1),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 17,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: AppColors.glassBorderSubtle,
          width: 0.6,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          color: AppColors.electricBlueBright,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
