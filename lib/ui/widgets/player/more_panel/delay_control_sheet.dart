import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Reusable focused sheet for adjusting Audio Delay or Subtitle Delay with smooth slider
class DelayControlSheet extends StatefulWidget {
  final String title;
  final IconData icon;
  final int initialDelayMs;
  final ValueChanged<int> onDelayChanged;

  const DelayControlSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.initialDelayMs,
    required this.onDelayChanged,
  });

  static void show(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int initialDelayMs,
    required ValueChanged<int> onDelayChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DelayControlSheet(
        title: title,
        icon: icon,
        initialDelayMs: initialDelayMs,
        onDelayChanged: onDelayChanged,
      ),
    );
  }

  @override
  State<DelayControlSheet> createState() => _DelayControlSheetState();
}

class _DelayControlSheetState extends State<DelayControlSheet> {
  late double _currentDelay;

  @override
  void initState() {
    super.initState();
    _currentDelay = widget.initialDelayMs.toDouble().clamp(-500.0, 500.0);
  }

  String _formatDelay(int delay) {
    if (delay > 0) return '+$delay ms';
    if (delay < 0) return '$delay ms';
    return '0 ms (Synchronized)';
  }

  @override
  Widget build(BuildContext context) {
    final int delayInt = _currentDelay.round();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.only(top: 14, bottom: 28),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(
            top: BorderSide(color: AppColors.glassBorderSubtle, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.60),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        color: AppColors.electricBlueBright,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Fine-tune sync offset from -500 ms to +500 ms',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.glassBorderSubtle, height: 1),
              const SizedBox(height: 20),

              // Live delay value display
              Center(
                child: Column(
                  children: [
                    Text(
                      _formatDelay(delayInt),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.electricBlueBright,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      delayInt > 0
                          ? 'Playback shifted later'
                          : delayInt < 0
                              ? 'Playback shifted earlier'
                              : 'Exact zero latency offset',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Range labels and Slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '-500 ms',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '0 ms',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '+500 ms',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.electricBlueBright,
                  inactiveTrackColor: Colors.white12,
                  thumbColor: Colors.white,
                  overlayColor: AppColors.electricBlue.withOpacity(0.20),
                  trackHeight: 3.5,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.5),
                ),
                child: Slider(
                  value: _currentDelay,
                  min: -500.0,
                  max: 500.0,
                  divisions: 100, // 10ms steps
                  onChanged: (val) {
                    setState(() => _currentDelay = val);
                    widget.onDelayChanged(val.round());
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Quick nudge buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final newVal = (_currentDelay - 50).clamp(-500.0, 500.0);
                          setState(() => _currentDelay = newVal);
                          widget.onDelayChanged(newVal.round());
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('-50 ms', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _currentDelay = 0.0);
                          widget.onDelayChanged(0);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceGlass,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.glassBorderSubtle),
                          ),
                        ),
                        child: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final newVal = (_currentDelay + 50).clamp(-500.0, 500.0);
                          setState(() => _currentDelay = newVal);
                          widget.onDelayChanged(newVal.round());
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('+50 ms', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
