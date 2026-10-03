import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Ambient cinematic background with extremely slow, elegant abstract flowing lighting.
/// Completely restrained: no distracting particles, just deep atmosphere and subtle glow.
class AmbientBackground extends StatefulWidget {
  final Widget child;
  final bool enableAnimation;

  const AmbientBackground({
    super.key,
    required this.child,
    this.enableAnimation = true,
  });

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    // 10-second ultra-slow loop for organic, imperceptible ambient breathing
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    if (widget.enableAnimation) {
      _ambientController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, _) {
        final t = _ambientController.value;
        final subtleShiftX = math.sin(t * 2 * math.pi) * 0.08;
        final subtleShiftY = math.cos(t * 2 * math.pi) * 0.06;
        final radiusPulse = 0.85 + (t * 0.15);

        return Container(
          color: AppColors.background,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Deep subtle corner violet gradient (bottom right)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.85 + subtleShiftX, 0.85 + subtleShiftY),
                      radius: 0.9,
                      colors: const [
                        Color(0x187C3AED), // 9.5% violet
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),

              // 2. Deep subtle corner blue gradient (top left)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.85 - subtleShiftX, -0.85 - subtleShiftY),
                      radius: 0.85,
                      colors: const [
                        Color(0x150091FF), // 8% electric blue
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Central ambient glow behind branding (slow breathing)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(subtleShiftX * 0.5, -0.15 + subtleShiftY * 0.5),
                      radius: radiusPulse,
                      colors: const [
                        Color(0x1F0070F3), // 12% subtle blue glow
                        Color(0x0A0F172A), // Faint navy
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Child content
              widget.child,
            ],
          ),
        );
      },
    );
  }
}
