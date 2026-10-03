import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Shimmer skeleton loader for the Folders screen during scanning or database refresh
class FolderSkeletonLoader extends StatefulWidget {
  const FolderSkeletonLoader({super.key});

  @override
  State<FolderSkeletonLoader> createState() => _FolderSkeletonLoaderState();
}

class _FolderSkeletonLoaderState extends State<FolderSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _shimmerAnim = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, child) {
        final shimmerColor = AppColors.surfaceGlass.withOpacity(_shimmerAnim.value);

        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Section Header Skeleton
            _buildBox(width: 80, height: 14, color: shimmerColor),
            const SizedBox(height: 12),

            // Storage Card Skeleton
            Container(
              height: 96,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.glassBorderSubtle, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildBox(width: 38, height: 38, radius: 10, color: shimmerColor),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBox(width: 120, height: 14, color: shimmerColor),
                          const SizedBox(height: 6),
                          _buildBox(width: 70, height: 11, color: shimmerColor),
                        ],
                      ),
                      const Spacer(),
                      _buildBox(width: 80, height: 14, color: shimmerColor),
                    ],
                  ),
                  const Spacer(),
                  _buildBox(width: double.infinity, height: 5, radius: 3, color: shimmerColor),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Video Folders Section Header Skeleton
            _buildBox(width: 110, height: 14, color: shimmerColor),
            const SizedBox(height: 12),

            // Folder Rows Skeletons
            for (int i = 0; i < 5; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    _buildBox(width: 38, height: 38, radius: 10, color: shimmerColor),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBox(width: 110 + (i % 3) * 25, height: 14, color: shimmerColor),
                        const SizedBox(height: 6),
                        _buildBox(width: 75, height: 11, color: shimmerColor),
                      ],
                    ),
                    const Spacer(),
                    _buildBox(width: 44, height: 24, radius: 4, color: shimmerColor),
                    const SizedBox(width: 10),
                    _buildBox(width: 14, height: 14, radius: 7, color: shimmerColor),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBox({
    required double width,
    required double height,
    double radius = 4,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
