import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The official PIchiPlayer play symbol:
/// - Modern triangular play-inspired geometric symbol
/// - Blue/violet luminous gradient accent
/// - Multi-layered soft glow
/// - Sharp and premium commercial finish
class PichiLogo extends StatelessWidget {
  final double size;
  final bool enableGlow;

  const PichiLogo({
    super.key,
    this.size = 92.0,
    this.enableGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Soft atmospheric glow behind the symbol
          if (enableGlow)
            Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.35),
                    blurRadius: size * 0.55,
                    spreadRadius: size * 0.08,
                  ),
                  BoxShadow(
                    color: AppColors.violetAccent.withOpacity(0.28),
                    blurRadius: size * 0.75,
                    spreadRadius: size * 0.12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),

          // 2. High-precision vector play glyph
          CustomPaint(
            size: Size(size, size),
            painter: _PichiPlaySymbolPainter(),
          ),
        ],
      ),
    );
  }
}

class _PichiPlaySymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Define coordinates for a balanced, modern play triangular geometry
    // Center of mass adjusted slightly for visual optical centering
    final leftX = w * 0.28;
    final rightX = w * 0.78;
    final topY = h * 0.22;
    final bottomY = h * 0.78;
    final midY = h * 0.50;
    final radius = w * 0.085; // Corner roundness

    // Base rounded triangle path
    final mainPath = Path();
    
    // Top-left corner
    mainPath.moveTo(leftX + radius, topY);
    // Line to top-right corner approaching apex
    mainPath.lineTo(rightX - radius * 1.2, midY - radius * 0.8);
    // Apex corner curve
    mainPath.quadraticBezierTo(rightX, midY, rightX - radius * 1.2, midY + radius * 0.8);
    // Line to bottom-left corner
    mainPath.lineTo(leftX + radius, bottomY);
    // Bottom-left curve
    mainPath.quadraticBezierTo(leftX, bottomY, leftX, bottomY - radius);
    // Left vertical line
    mainPath.lineTo(leftX, topY + radius);
    // Top-left curve
    mainPath.quadraticBezierTo(leftX, topY, leftX + radius, topY);
    mainPath.close();

    // 1. Soft underlying neon bloom for the glyph itself
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x9900D2FF),
          Color(0x997C3AED),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(mainPath, glowPaint);

    // 2. Primary body fill with rich Electric Blue -> Violet gradient
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.electricBlueBright,
          AppColors.electricBlue,
          AppColors.electricBlueDark,
          AppColors.violetAccent,
        ],
        stops: [0.0, 0.4, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(mainPath, fillPaint);

    // 3. Precision geometric facet: subtle dynamic diagonal split
    // Gives the logo its signature faceted, modern commercial identity
    final facetPath = Path()
      ..moveTo(leftX, topY + radius)
      ..lineTo(rightX - radius * 1.2, midY - radius * 0.8)
      ..lineTo(leftX + (rightX - leftX) * 0.45, midY + (bottomY - midY) * 0.2)
      ..lineTo(leftX, midY)
      ..close();

    final facetPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.24),
          Colors.white.withOpacity(0.04),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(facetPath, facetPaint);

    // 4. Subtle specular highlight rim along top edge
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.65),
          AppColors.electricBlueBright.withOpacity(0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(mainPath, rimPaint);

    // 5. Delicate luminous apex node
    final nodePaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(rightX - radius * 0.6, midY), 1.8, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
