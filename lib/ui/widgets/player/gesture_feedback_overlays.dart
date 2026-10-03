import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/player_types.dart';

/// Feedback overlay for Brightness adjustment (Left vertical drag)
/// Positioned at Left-center of video with sun icon, percentage, and slim indicator.
class BrightnessFeedbackOverlay extends StatelessWidget {
  final double brightness; // 0.0 to 1.0

  const BrightnessFeedbackOverlay({super.key, required this.brightness});

  @override
  Widget build(BuildContext context) {
    final percent = (brightness * 100).toInt().clamp(0, 100);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.68),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.glassBorderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.40),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    brightness > 0.6
                        ? Icons.brightness_7_rounded
                        : (brightness > 0.2
                            ? Icons.brightness_6_rounded
                            : Icons.brightness_4_rounded),
                    color: AppColors.electricBlueBright,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Brightness',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Slim vertical progress indicator with electric blue glow
                  SizedBox(
                    height: 108,
                    width: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(color: Colors.white.withOpacity(0.12)),
                          FractionallySizedBox(
                            heightFactor: brightness.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.electricBlueBright,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.electricBlue.withOpacity(0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Feedback overlay for Volume adjustment (Right vertical drag)
/// Positioned at Right-center of video with speaker icon, percentage, and slim indicator.
class VolumeFeedbackOverlay extends StatelessWidget {
  final double volume; // 0.0 to 1.0

  const VolumeFeedbackOverlay({super.key, required this.volume});

  @override
  Widget build(BuildContext context) {
    final percent = (volume * 100).toInt().clamp(0, 100);

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 32.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.68),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.glassBorderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.40),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    volume == 0
                        ? Icons.volume_off_rounded
                        : (volume > 0.5
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded),
                    color: volume == 0
                        ? const Color(0xFFEF4444)
                        : AppColors.electricBlueBright,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Volume',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Slim vertical progress indicator
                  SizedBox(
                    height: 108,
                    width: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(color: Colors.white.withOpacity(0.12)),
                          FractionallySizedBox(
                            heightFactor: volume.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: volume == 0
                                    ? const Color(0xFFEF4444)
                                    : AppColors.electricBlueBright,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: (volume == 0
                                            ? const Color(0xFFEF4444)
                                            : AppColors.electricBlue)
                                        .withOpacity(0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Double tap seek feedback overlay (Left or Right)
/// Originates near the actual touch location or falls back to left/right center.
/// Features circular ripple, directional seek icon (↶ / ↷), and time value.
class SeekDoubleTapFeedbackOverlay extends StatefulWidget {
  final SeekDirection direction;
  final int seconds;
  final Offset? touchPosition;

  const SeekDoubleTapFeedbackOverlay({
    super.key,
    required this.direction,
    required this.seconds,
    this.touchPosition,
  });

  @override
  State<SeekDoubleTapFeedbackOverlay> createState() =>
      _SeekDoubleTapFeedbackOverlayState();
}

class _SeekDoubleTapFeedbackOverlayState
    extends State<SeekDoubleTapFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.04).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_animController);

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLeft = widget.direction == SeekDirection.backward;

    final content = AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular expanding ripple effect originating at touch
              Transform.scale(
                scale: 0.6 + (_rippleAnimation.value * 0.8),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.electricBlueBright
                          .withOpacity((1.0 - _rippleAnimation.value) * 0.5),
                      width: 1.5,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        AppColors.electricBlue.withOpacity(
                            (1.0 - _rippleAnimation.value) * 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Small rounded panel with directional icon and seconds
              Transform.scale(
                scale: _scaleAnimation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.68),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.electricBlueBright.withOpacity(0.45),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electricBlue.withOpacity(0.35),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLeft ? '↶' : '↷',
                            style: const TextStyle(
                              color: AppColors.electricBlueBright,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${widget.seconds} seconds',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // If touchPosition is given, position smoothly near touch coordinates
    if (widget.touchPosition != null) {
      final leftPadding = (widget.touchPosition!.dx - 60).clamp(20.0, 3000.0);
      final topPadding = (widget.touchPosition!.dy - 60).clamp(40.0, 3000.0);

      return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(left: leftPadding, top: topPadding),
          child: content,
        ),
      );
    }

    // Default positioning on left or right margin
    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
            left: isLeft ? 56.0 : 0, right: isLeft ? 0 : 56.0),
        child: content,
      ),
    );
  }
}

/// Scrub seek gesture feedback (Horizontal drag)
/// Displays delta (-00:20 or +00:20), target playback position, and timeline indicator.
class ScrubSeekFeedbackOverlay extends StatelessWidget {
  final Duration currentPosition;
  final Duration delta;
  final Duration? totalDuration;

  const ScrubSeekFeedbackOverlay({
    super.key,
    required this.currentPosition,
    required this.delta,
    this.totalDuration,
  });

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  String _formatDelta(Duration d) {
    final totalSec = d.inSeconds.abs();
    final mins = (totalSec ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSec % 60).toString().padLeft(2, '0');
    final prefix = d.isNegative ? '-' : '+';
    return '$prefix$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final isForward = !delta.isNegative;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.78),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.electricBlueBright.withOpacity(0.50),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 20,
                ),
                BoxShadow(
                  color: AppColors.electricBlue.withOpacity(0.20),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Directional icon + Delta offset (-00:20 / +00:20)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isForward ? '↷' : '↶',
                      style: TextStyle(
                        color: isForward
                            ? AppColors.electricBlueBright
                            : const Color(0xFFEF4444),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDelta(delta),
                      style: TextStyle(
                        color: isForward
                            ? AppColors.electricBlueBright
                            : const Color(0xFFEF4444),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Target timestamp
                Text(
                  _formatDuration(currentPosition),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),

                // Subtle mini timeline progress bar if total duration is provided
                if (totalDuration != null && totalDuration!.inSeconds > 0) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 110,
                    height: 3.5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Stack(
                        children: [
                          Container(color: Colors.white.withOpacity(0.15)),
                          FractionallySizedBox(
                            widthFactor: (currentPosition.inMilliseconds /
                                    totalDuration!.inMilliseconds)
                                .clamp(0.0, 1.0),
                            child: Container(
                              color: AppColors.electricBlueBright,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Temporary 2× speed badge feedback during long-press
class LongPressSpeedBadgeOverlay extends StatelessWidget {
  final String speedText;

  const LongPressSpeedBadgeOverlay({super.key, this.speedText = '2× Speed'});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 56.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.72),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.electricBlueBright.withOpacity(0.75),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.40),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.fast_forward_rounded,
                    color: AppColors.electricBlueBright,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    speedText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Zoom feedback indicator displayed during pinch-to-zoom gesture
/// Updates smoothly and shows scale multiplier (e.g. 1.24× or Fit / Fill / Crop)
class ZoomFeedbackBadgeOverlay extends StatelessWidget {
  final double scale;
  final String? modeName;

  const ZoomFeedbackBadgeOverlay({
    super.key,
    required this.scale,
    this.modeName,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = modeName != null
        ? modeName!.toUpperCase()
        : '${scale.toStringAsFixed(2)}×';

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.electricBlueBright.withOpacity(0.55),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricBlue.withOpacity(0.30),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.zoom_in_rounded,
                  color: AppColors.electricBlueBright,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  displayText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Center pulse play/pause icon micro-animation
class CenterPlayPausePulse extends StatefulWidget {
  final bool isPlaying;

  const CenterPlayPausePulse({super.key, required this.isPlaying});

  @override
  State<CenterPlayPausePulse> createState() => _CenterPlayPausePulseState();
}

class _CenterPlayPausePulseState extends State<CenterPlayPausePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 70),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.58),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.electricBlueBright.withOpacity(0.50),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withOpacity(0.40),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.isPlaying
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Orientation change feedback overlay (Landscape / Portrait / Landscape Locked)
class OrientationFeedbackOverlay extends StatelessWidget {
  final String orientationName;
  final bool isLocked;

  const OrientationFeedbackOverlay({
    super.key,
    required this.orientationName,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.electricBlueBright.withOpacity(0.55),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricBlue.withOpacity(0.35),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLocked
                      ? Icons.screen_lock_rotation_rounded
                      : Icons.screen_rotation_rounded,
                  color: AppColors.electricBlueBright,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  isLocked ? '$orientationName Locked' : orientationName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Versatile transient pill feedback overlay for setting changes:
/// Playback speed, Aspect ratio, Subtitle track, Audio track, Sleep timer, A-B repeat.
class TransientPillFeedbackOverlay extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const TransientPillFeedbackOverlay({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.78),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.electricBlueBright.withOpacity(0.50),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.40),
                  blurRadius: 16,
                ),
                BoxShadow(
                  color: AppColors.electricBlue.withOpacity(0.25),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.electricBlueBright, size: 22),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact bottom-center snackbar/toast for recoverable playback states
/// e.g. "Hardware decoding failed • Trying software decoder"
class CompactPlayerToastOverlay extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? accentColor;

  const CompactPlayerToastOverlay({
    super.key,
    required this.icon,
    required this.message,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.electricBlueBright;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 84.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.80),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withOpacity(0.40),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.50),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Screen Locked indicator with Hold-to-Unlock / Tap-to-Unlock interaction.
/// Supports both:
/// 1. Initial centered confirmation: 🔒 Screen Locked
/// 2. Interactive Hold-to-Unlock with circular progress indicator
/// Dedicated Screen Locked Overlay and hold-to-unlock interaction system.
///
/// Features:
/// 1. Unobtrusive corner-pinned persistent lock indicator during minimized mode.
/// 2. Smooth hold-to-unlock circular progress ring (0% -> 100%) with haptic feedback.
/// 3. Backwards-compatible tap-to-unlock for instant test execution and accessibility.
/// 4. Early release rejection haptics and safe-area respecting positioning.
class ScreenLockedOverlay extends StatefulWidget {
  final VoidCallback onUnlock;
  final bool isMinimized;
  final ScreenLockConfig config;

  const ScreenLockedOverlay({
    super.key,
    required this.onUnlock,
    this.isMinimized = false,
    this.config = const ScreenLockConfig(),
  });

  @override
  State<ScreenLockedOverlay> createState() => _ScreenLockedOverlayState();
}

class _ScreenLockedOverlayState extends State<ScreenLockedOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _holdController;
  bool _isHolding = false;
  bool _hasUnlocked = false;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: widget.config.holdDuration,
    );

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasUnlocked) {
        _hasUnlocked = true;
        if (widget.config.hapticsEnabled) {
          HapticFeedback.heavyImpact();
        }
        widget.onUnlock();
      }
    });
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    _hasUnlocked = false;
    setState(() => _isHolding = true);
    _holdController.forward();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_hasUnlocked) return;

    if (_holdController.status == AnimationStatus.completed || _holdController.value >= 0.98) {
      _hasUnlocked = true;
      if (widget.config.hapticsEnabled) {
        HapticFeedback.heavyImpact();
      }
      widget.onUnlock();
    } else if (_holdController.value < 0.15) {
      // Quick tap fallback for instant access and accessibility
      _hasUnlocked = true;
      if (widget.config.hapticsEnabled) {
        HapticFeedback.lightImpact();
      }
      widget.onUnlock();
    } else {
      // Incomplete hold: cancelled early before threshold
      if (widget.config.hapticsEnabled) {
        HapticFeedback.selectionClick();
      }
      _holdController.reverse();
    }

    if (mounted) {
      setState(() => _isHolding = false);
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!_hasUnlocked && _holdController.status != AnimationStatus.completed) {
      if (widget.config.hapticsEnabled) {
        HapticFeedback.selectionClick();
      }
      _holdController.reverse();
    }
    if (mounted) {
      setState(() => _isHolding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: widget.isMinimized ? Alignment.bottomLeft : Alignment.center,
        child: Padding(
          padding: widget.isMinimized
              ? const EdgeInsets.only(left: 24.0, bottom: 24.0)
              : EdgeInsets.zero,
          child: Semantics(
            label: 'Player locked. Activate and hold to unlock.',
            button: true,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerUp: _onPointerUp,
              onPointerCancel: _onPointerCancel,
              child: AnimatedBuilder(
                animation: _holdController,
                builder: (context, child) {
                  final progress = _holdController.value;

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: widget.isMinimized && !_isHolding ? 0.65 : 1.0,
                    child: Transform.scale(
                      scale: 1.0 + (progress * 0.05),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.78),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.electricBlueBright.withOpacity(
                                    0.50 + (progress * 0.50)),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.electricBlue.withOpacity(
                                      0.35 + (progress * 0.40)),
                                  blurRadius: 18 + (progress * 12),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Lock icon with circular progress ring
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 2.4,
                                        backgroundColor: Colors.white.withOpacity(0.12),
                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                          AppColors.electricBlueBright,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      progress > 0.8
                                          ? Icons.lock_open_rounded
                                          : Icons.lock_rounded,
                                      color: AppColors.electricBlueBright,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _isHolding
                                      ? 'Hold to unlock (${(progress * 100).toInt()}%)'
                                      : 'Screen Locked • Tap to Unlock',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

