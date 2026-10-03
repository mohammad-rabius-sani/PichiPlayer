import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_typography.dart';
import '../../models/local_video.dart';

/// Large 16:9 cinematic hero video card displaying the prioritized
/// continue watching or recently added video.
class HeroVideoCard extends StatefulWidget {
  final LocalVideo video;
  final VoidCallback onTap;

  const HeroVideoCard({
    super.key,
    required this.video,
    required this.onTap,
  });

  @override
  State<HeroVideoCard> createState() => _HeroVideoCardState();
}

class _HeroVideoCardState extends State<HeroVideoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.985).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;

    return Padding(
      padding: AppDimensions.homeHorizontalPadding,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: GestureDetector(
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) {
            _scaleController.reverse();
            widget.onTap();
          },
          onTapCancel: () => _scaleController.reverse(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(
                color: AppColors.glassBorderSubtle,
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 28,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              child: AspectRatio(
                aspectRatio: AppDimensions.heroAspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Cinematic Background Composition
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            video.gradientStart,
                            video.gradientEnd,
                            AppColors.backgroundElevated,
                          ],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Subtle atmospheric lighting inside thumbnail
                          Positioned(
                            top: -40,
                            right: -40,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.electricBlue.withOpacity(0.12),
                              ),
                            ),
                          ),
                          // Subtle theme visual symbol
                          Center(
                            child: Icon(
                              video.visualIcon,
                              size: 72,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Seamless dark bottom gradient for readability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              AppColors.background.withOpacity(0.5),
                              AppColors.background.withOpacity(0.88),
                              AppColors.background.withOpacity(0.98),
                            ],
                            stops: const [0.0, 0.35, 0.65, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // 3. Top Badges Row (4K, HDR, Continue Status)
                    Positioned(
                      top: 14,
                      left: 14,
                      right: 14,
                      child: Row(
                        children: [
                          if (video.resolution == '4K') ...[
                            _buildHeroBadge('4K'),
                            const SizedBox(width: 6),
                          ],
                          if (video.isHdr) ...[
                            _buildHeroBadge('HDR'),
                            const SizedBox(width: 6),
                          ],
                          if (video.fps != null && video.fps! >= 60) ...[
                            _buildHeroBadge('${video.fpsFormatted} FPS'),
                            const SizedBox(width: 6),
                          ],
                          const Spacer(),
                          if (video.isPartiallyWatched)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.electricBlueDark.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.electricBlueBright.withOpacity(0.5),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.electricBlueBright,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Resume',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // 4. Large Circular Play Button with subtle scale & glow
                    Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.logoSymbol,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.electricBlue.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // 5. Bottom Metadata & Title
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            video.title,
                            style: AppTypography.heroTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            video.heroMetadataText,
                            style: AppTypography.heroMetadata,
                          ),
                        ],
                      ),
                    ),

                    // 6. Subtle Bottom Progress Line (if partially watched)
                    if (video.isPartiallyWatched)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 3.0,
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
                                    blurRadius: 6,
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
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.qualityBadge,
      ),
    );
  }
}
