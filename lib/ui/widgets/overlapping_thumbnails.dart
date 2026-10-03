import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/local_video.dart';

/// Renders 2–3 compact overlapping 16:9 cinematic video thumbnails for folder preview
class OverlappingThumbnails extends StatelessWidget {
  final List<LocalVideo> previewVideos;
  final double width;
  final double height;

  const OverlappingThumbnails({
    super.key,
    required this.previewVideos,
    this.width = 38,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (previewVideos.isEmpty) {
      return const SizedBox.shrink();
    }

    final videos = previewVideos.take(3).toList();
    final count = videos.length;
    final totalWidth = width + (count - 1) * 12.0;

    return SizedBox(
      width: totalWidth,
      height: height,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: List.generate(count, (index) {
          final video = videos[index];
          final leftOffset = index * 12.0;

          return Positioned(
            left: leftOffset,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.background,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.55),
                    blurRadius: 4,
                    offset: const Offset(1, 1),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    video.gradientStart,
                    video.gradientEnd,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  video.visualIcon,
                  size: 11,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
