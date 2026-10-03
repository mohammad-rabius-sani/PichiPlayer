import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'library_top_bar.dart';

/// Skeleton placeholder loader for Library grid and list views
class LibrarySkeletonLoader extends StatefulWidget {
  final LibraryViewMode viewMode;

  const LibrarySkeletonLoader({
    super.key,
    required this.viewMode,
  });

  @override
  State<LibrarySkeletonLoader> createState() => _LibrarySkeletonLoaderState();
}

class _LibrarySkeletonLoaderState extends State<LibrarySkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.25, end: 0.60).animate(
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

        if (widget.viewMode == LibraryViewMode.grid) {
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.88,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 70,
                    height: 10,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              );
            },
          );
        }

        // List Mode Skeleton
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 8,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 108,
                    height: 108 * (9 / 16),
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 13,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 110,
                          height: 11,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
