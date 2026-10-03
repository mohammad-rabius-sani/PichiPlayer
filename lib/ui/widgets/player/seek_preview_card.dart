import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/local_video.dart';

/// Small video thumbnail preview card displayed above the seekbar while dragging
class SeekPreviewCard extends StatelessWidget {
  final Duration previewPosition;
  final LocalVideo video;
  final double horizontalRatio; // 0.0 to 1.0 position on the seekbar

  const SeekPreviewCard({
    super.key,
    required this.previewPosition,
    required this.video,
    required this.horizontalRatio,
  });

  String _formatTimestamp(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    const previewWidth = 120.0;
    const previewHeight = 72.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Clamp the horizontal offset so the preview doesn't go off-screen
        final rawOffset = (availableWidth * horizontalRatio) - (previewWidth / 2);
        final clampedOffset = rawOffset.clamp(16.0, availableWidth - previewWidth - 16.0);

        return Positioned(
          left: clampedOffset,
          bottom: 74, // positioned above the seekbar
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview Frame
              Container(
                width: previewWidth,
                height: previewHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.electricBlueBright.withOpacity(0.55),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.65),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.25),
                      blurRadius: 12,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [video.gradientStart, video.gradientEnd],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Mini visual icon
                    Icon(
                      video.visualIcon,
                      size: 26,
                      color: Colors.white.withOpacity(0.35),
                    ),
                    // Fine resolution watermark in preview
                    Positioned(
                      top: 4,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.resolution,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Timestamp Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.glassBorderSubtle,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  _formatTimestamp(previewPosition),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.4,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
