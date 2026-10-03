import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/local_video.dart';
import '../../../models/player_types.dart';

/// The cinematic video playback surface.
/// Renders the local video frame with aspect-ratio management,
/// letterboxing/pillarboxing, and pinch-to-zoom support.
class VideoSurface extends StatelessWidget {
  final LocalVideo video;
  final PlayerScalingMode scalingMode;
  final double userZoomScale;
  final bool isPlaying;
  final String activeAspectRatio;
  final Alignment cropAlignment;

  const VideoSurface({
    super.key,
    required this.video,
    required this.scalingMode,
    this.userZoomScale = 1.0,
    required this.isPlaying,
    this.activeAspectRatio = 'Auto',
    this.cropAlignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Calculate aspect ratio from active aspect ratio, scaling mode, or video dimensions
        double videoAspect = 16 / 9;
        if (activeAspectRatio == '16:9' || scalingMode == PlayerScalingMode.sixteenNine) {
          videoAspect = 16 / 9;
        } else if (activeAspectRatio == '4:3' || scalingMode == PlayerScalingMode.fourThree) {
          videoAspect = 4 / 3;
        } else if (activeAspectRatio == '21:9') {
          videoAspect = 21 / 9;
        } else if (activeAspectRatio == '1:1') {
          videoAspect = 1.0;
        } else if (activeAspectRatio == '9:16') {
          videoAspect = 9 / 16;
        } else {
          videoAspect = (video.pixelWidth > 0 && video.pixelHeight > 0)
              ? (video.pixelWidth / video.pixelHeight)
              : (16 / 9);
        }

        BoxFit fit;
        switch (scalingMode) {
          case PlayerScalingMode.fit:
          case PlayerScalingMode.sixteenNine:
          case PlayerScalingMode.fourThree:
            fit = BoxFit.contain;
            break;
          case PlayerScalingMode.fill:
            fit = BoxFit.fill;
            break;
          case PlayerScalingMode.crop:
            fit = BoxFit.cover;
            break;
          case PlayerScalingMode.original:
            fit = BoxFit.none;
            break;
        }

        return Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.black,
          child: Center(
            child: Transform.scale(
              scale: userZoomScale,
              alignment: cropAlignment,
              child: AspectRatio(
                aspectRatio: scalingMode == PlayerScalingMode.fill
                    ? (screenWidth / screenHeight)
                    : videoAspect,
                child: FittedBox(
                  fit: fit,
                  alignment: cropAlignment,
                  child: SizedBox(
                    width: video.pixelWidth.toDouble(),
                    height: video.pixelHeight.toDouble(),
                    child: _buildCinematicFrameContent(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCinematicFrameContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Deep cinematic film gradient simulation
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.1,
              colors: [
                video.gradientStart.withOpacity(0.92),
                video.gradientEnd.withOpacity(0.98),
                const Color(0xFF030508),
              ],
              stops: const [0.0, 0.65, 1.0],
            ),
          ),
        ),

        // 2. Subtle motion grain overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _CinematicGridPainter(
              accentColor: AppColors.electricBlue.withOpacity(0.08),
            ),
          ),
        ),

        // 3. Central cinematic watermark silhouette (very subtle, non-intrusive)
        Center(
          child: Opacity(
            opacity: 0.12,
            child: Icon(
              video.visualIcon,
              size: 160,
              color: Colors.white,
            ),
          ),
        ),

        // 4. Subtle cinematic anamorphic flare line
        Center(
          child: Container(
            height: 1.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.electricBlueBright.withOpacity(0.18),
                  AppColors.violetAccent.withOpacity(0.25),
                  AppColors.electricBlueBright.withOpacity(0.18),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Draws an ultra-subtle cinematic grain grid on the video canvas
class _CinematicGridPainter extends CustomPainter {
  final Color accentColor;

  _CinematicGridPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor
      ..strokeWidth = 0.5;

    const step = 80.0;
    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CinematicGridPainter oldDelegate) => false;
}
