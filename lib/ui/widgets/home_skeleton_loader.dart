import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Elegant skeleton placeholder loader for the Home screen.
/// Prevents layout shift without resorting to generic circular spinners.
class HomeSkeletonLoader extends StatefulWidget {
  const HomeSkeletonLoader({super.key});

  @override
  State<HomeSkeletonLoader> createState() => _HomeSkeletonLoaderState();
}

class _HomeSkeletonLoaderState extends State<HomeSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        final shimmerColor = AppColors.surfaceSubtle.withOpacity(_shimmerAnimation.value);

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Featured Hero Skeleton (16:9)
              Padding(
                padding: AppDimensions.homeHorizontalPadding,
                child: AspectRatio(
                  aspectRatio: AppDimensions.heroAspectRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                      border: Border.all(
                        color: AppColors.glassBorderSubtle,
                        width: 0.8,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 2. Section 1 Title Skeleton
              Padding(
                padding: AppDimensions.homeHorizontalPadding,
                child: Container(
                  width: 160,
                  height: 20,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. Section 1 Horizontal Cards Row Skeleton
              SizedBox(
                height: AppDimensions.videoCardThumbnailHeight + 46,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: AppDimensions.homeHorizontalPadding,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      width: AppDimensions.videoCardWidth,
                      margin: const EdgeInsets.only(right: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: AppDimensions.videoCardWidth * (9 / 16),
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 140,
                            height: 14,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 90,
                            height: 12,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // 4. Section 2 Title Skeleton
              Padding(
                padding: AppDimensions.homeHorizontalPadding,
                child: Container(
                  width: 130,
                  height: 20,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 5. Section 2 Horizontal Cards Skeleton
              SizedBox(
                height: AppDimensions.videoCardThumbnailHeight + 46,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: AppDimensions.homeHorizontalPadding,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      width: AppDimensions.videoCardWidth,
                      margin: const EdgeInsets.only(right: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: AppDimensions.videoCardWidth * (9 / 16),
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 120,
                            height: 14,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
