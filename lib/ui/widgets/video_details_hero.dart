import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/local_video.dart';

/// Large 16:9 cinematic video hero thumbnail with centered play button and quality badges
class VideoDetailsHero extends StatefulWidget {
  final LocalVideo video;
  final VoidCallback onPlay;

  const VideoDetailsHero({
    super.key,
    required this.video,
    required this.onPlay,
  });

  @override
  State<VideoDetailsHero> createState() => _VideoDetailsHeroState();
}

class _VideoDetailsHeroState extends State<VideoDetailsHero>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onPlay();
        },
        onTapCancel: () => _pressController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Cinematic Background Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            video.gradientStart,
                            video.gradientEnd,
                          ],
                        ),
                      ),
                    ),

                    // 2. Subtle Atmospheric Disc / Lighting Pattern
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.electricBlue.withOpacity(0.08),
                        ),
                      ),
                    ),

                    // 3. Dark Bottom Vignette Gradient
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.20),
                              Colors.black.withOpacity(0.75),
                            ],
                            stops: const [0.4, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // 4. Centered Premium Play Button Affordance
                    Center(
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface.withOpacity(0.85),
                          border: Border.all(
                            color: AppColors.electricBlue.withOpacity(0.60),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.electricBlue.withOpacity(0.35),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // 5. Technical Badges (4K, HDR) in Upper Left
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (video.resolution == '4K')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.70),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.electricBlue.withOpacity(0.60),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                '4K',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.electricBlueBright,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          if (video.isHdr)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.70),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.violetAccent.withOpacity(0.60),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                'HDR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFC4B5FD),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // 6. Inset Duration Pill (Bottom Right)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.80),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          video.durationFormatted,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
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
}
