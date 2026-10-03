import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Focused bottom sheet for adjusting video scaling & zoom magnification
class ZoomControlSheet extends StatefulWidget {
  final double currentZoom;
  final ValueChanged<double> onZoomChanged;

  const ZoomControlSheet({
    super.key,
    required this.currentZoom,
    required this.onZoomChanged,
  });

  static void show(
    BuildContext context, {
    required double currentZoom,
    required ValueChanged<double> onZoomChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ZoomControlSheet(
        currentZoom: currentZoom,
        onZoomChanged: onZoomChanged,
      ),
    );
  }

  @override
  State<ZoomControlSheet> createState() => _ZoomControlSheetState();
}

class _ZoomControlSheetState extends State<ZoomControlSheet> {
  late double _zoom;

  @override
  void initState() {
    super.initState();
    _zoom = widget.currentZoom.clamp(0.8, 3.0);
  }

  @override
  Widget build(BuildContext context) {
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
                      child: const Icon(
                        Icons.zoom_in_rounded,
                        color: AppColors.electricBlueBright,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Video Zoom',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Scale video surface from 0.8× to 3.0×',
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
              const SizedBox(height: 18),

              // Live zoom readout
              Center(
                child: Text(
                  '${_zoom.toStringAsFixed(2)}×',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.electricBlueBright,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0.8×', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                    Text('1.0× (Fit)', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                    Text('3.0×', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
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
                  value: _zoom,
                  min: 0.8,
                  max: 3.0,
                  divisions: 44, // 0.05 step
                  onChanged: (val) {
                    setState(() => _zoom = val);
                    widget.onZoomChanged(val);
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Quick preset chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [0.8, 1.0, 1.25, 1.5, 2.0, 3.0].map((preset) {
                    final isSelected = (_zoom - preset).abs() < 0.04;
                    return ActionChip(
                      label: Text(
                        '${preset.toStringAsFixed(preset == 1.0 ? 1 : 2)}×',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      backgroundColor: isSelected ? AppColors.electricBlue : AppColors.surfaceGlass,
                      side: BorderSide(
                        color: isSelected ? AppColors.electricBlueBright : AppColors.glassBorderSubtle,
                      ),
                      onPressed: () {
                        setState(() => _zoom = preset);
                        widget.onZoomChanged(preset);
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Done Button
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
