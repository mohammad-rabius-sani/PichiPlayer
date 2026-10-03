import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// The official Playback Speed Control bottom sheet for PIchiPlayer.
/// An offline-first local player control featuring instant speed switching,
/// prominent current speed hero readout, quick presets, smooth custom slider,
/// fine tuning (±0.05×), "Hold for 2×" gesture preference, and one-tap Reset to 1×.
class PlaybackSpeedSheet extends StatefulWidget {
  final String selectedSpeed;
  final ValueChanged<String> onSelected;
  final ValueChanged<double>? onSpeedChanged;
  final bool holdFor2xEnabled;
  final ValueChanged<bool>? onHoldFor2xChanged;
  final String? videoTitle;

  const PlaybackSpeedSheet({
    super.key,
    required this.selectedSpeed,
    required this.onSelected,
    this.onSpeedChanged,
    this.holdFor2xEnabled = true,
    this.onHoldFor2xChanged,
    this.videoTitle,
  });

  /// Static helper to display the playback speed sheet over fullscreen player
  static void show(
    BuildContext context, {
    required String selectedSpeed,
    required ValueChanged<String> onSelected,
    ValueChanged<double>? onSpeedChanged,
    bool holdFor2xEnabled = true,
    ValueChanged<bool>? onHoldFor2xChanged,
    String? videoTitle,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => PlaybackSpeedSheet(
        selectedSpeed: selectedSpeed,
        onSelected: onSelected,
        onSpeedChanged: onSpeedChanged,
        holdFor2xEnabled: holdFor2xEnabled,
        onHoldFor2xChanged: onHoldFor2xChanged,
        videoTitle: videoTitle,
      ),
    );
  }

  /// Preset speeds available for quick selection
  static const List<String> presetSpeeds = [
    '0.25×', '0.5×', '0.75×', '1×', '1.25×',
    '1.5×', '1.75×', '2×', '3×', '4×'
  ];

  /// Utility to parse a speed string (e.g. "1.25×" or "1.5x" or "1x") to a double
  static double parseSpeed(String speedStr) {
    final clean = speedStr.replaceAll('×', '').replaceAll('x', '').trim();
    return (double.tryParse(clean) ?? 1.0).clamp(0.25, 4.0);
  }

  /// Utility to format a speed double into a standard PIchiPlayer speed label
  static String formatSpeed(double speed) {
    if (speed == speed.roundToDouble()) {
      return '${speed.toInt()}×';
    }
    final fixed1 = speed.toStringAsFixed(1);
    if ((speed * 10).round() / 10 == speed) {
      return '$fixed1×';
    }
    return '${speed.toStringAsFixed(2)}×';
  }

  @override
  State<PlaybackSpeedSheet> createState() => _PlaybackSpeedSheetState();
}

class _PlaybackSpeedSheetState extends State<PlaybackSpeedSheet> {
  late double _currentSpeed;
  late bool _holdFor2x;

  String? _transientFeedback;
  Timer? _feedbackTimer;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _currentSpeed = PlaybackSpeedSheet.parseSpeed(widget.selectedSpeed);
    _holdFor2x = widget.holdFor2xEnabled;
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _applySpeed(double speed, {bool isPreset = false}) {
    final clamped = (speed * 100).round() / 100;
    final finalSpeed = clamped.clamp(0.25, 4.00);

    HapticFeedback.selectionClick();

    setState(() {
      _currentSpeed = finalSpeed;
      _transientFeedback = '${finalSpeed.toStringAsFixed(2)}×';
    });

    final speedStr = PlaybackSpeedSheet.formatSpeed(finalSpeed);
    widget.onSelected(speedStr);
    widget.onSpeedChanged?.call(finalSpeed);

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _transientFeedback = null);
    });

    if (isPreset) {
      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(milliseconds: 220), () {
        if (!mounted) return;
        Navigator.pop(context);
      });
    }
  }

  void _adjustSpeedBy(double delta) {
    final newSpeed = ((_currentSpeed + delta) * 100).round() / 100;
    _applySpeed(newSpeed);
  }

  void _handleReset() {
    HapticFeedback.mediumImpact();
    _applySpeed(1.0);
  }

  void _handleToggleHoldFor2x(bool val) {
    HapticFeedback.selectionClick();
    setState(() => _holdFor2x = val);
    widget.onHoldFor2xChanged?.call(val);
  }

  bool _isPresetSelected(String preset) {
    final pVal = PlaybackSpeedSheet.parseSpeed(preset);
    return (_currentSpeed - pVal).abs() < 0.01;
  }

  String _getSpeedStatusLabel() {
    if ((_currentSpeed - 1.0).abs() < 0.01) {
      return 'Normal speed';
    } else if (_currentSpeed < 1.0) {
      final pct = ((1.0 - _currentSpeed) * 100).round();
      return '$pct% slower';
    } else {
      final pct = ((_currentSpeed - 1.0) * 100).round();
      return '$pct% faster';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final maxSheetHeight = isLandscape
        ? mediaQuery.size.height * 0.90
        : mediaQuery.size.height * 0.78;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          decoration: BoxDecoration(
            color: AppColors.backgroundNavy.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.65),
                blurRadius: 32,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 2. Header
                _buildHeader(),

                // 3. Transient Feedback Bar (if active)
                if (_transientFeedback != null)
                  _buildTransientFeedbackBar(),

                // 4. Main Scrollable Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      // A. Prominent Current Speed Hero Display
                      _buildCurrentSpeedHero(),

                      const SizedBox(height: 16),

                      // B. Quick Presets Section
                      _buildSectionHeader('QUICK PRESETS'),
                      const SizedBox(height: 8),
                      _buildQuickPresetsGrid(),

                      const SizedBox(height: 18),
                      const Divider(color: AppColors.glassBorderSubtle, height: 1),
                      const SizedBox(height: 14),

                      // C. Custom Speed Slider Section
                      _buildSectionHeader('CUSTOM SPEED'),
                      const SizedBox(height: 8),
                      _buildCustomSpeedSlider(),

                      const SizedBox(height: 16),
                      const Divider(color: AppColors.glassBorderSubtle, height: 1),
                      const SizedBox(height: 14),

                      // D. Fine Adjustment Section (±0.05×)
                      _buildSectionHeader('FINE TUNING (±0.05×)'),
                      const SizedBox(height: 8),
                      _buildFineAdjustmentSection(),

                      const SizedBox(height: 16),
                      const Divider(color: AppColors.glassBorderSubtle, height: 1),
                      const SizedBox(height: 14),

                      // E. Hold for 2× Preference
                      _buildSectionHeader('GESTURE SHORTCUT'),
                      const SizedBox(height: 8),
                      _buildHoldFor2xTile(),

                      const SizedBox(height: 18),

                      // F. Reset to 1× Button
                      _buildResetButton(),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.speed_rounded,
            color: AppColors.electricBlueBright,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Playback Speed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                if (widget.videoTitle != null)
                  Text(
                    widget.videoTitle!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            key: const ValueKey('speed_sheet_close_btn'),
            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // --- Section Header Helper ---
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  // --- Transient Feedback Bar ---
  Widget _buildTransientFeedbackBar() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.electricBlue.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.electricBlueBright.withOpacity(0.40)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.electricBlueBright, size: 15),
          const SizedBox(width: 8),
          Text(
            'Playback speed set to $_transientFeedback',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- A. Current Speed Hero Display ---
  Widget _buildCurrentSpeedHero() {
    final statusText = _getSpeedStatusLabel();
    final isNormal = (_currentSpeed - 1.0).abs() < 0.01;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNormal
              ? AppColors.glassBorderSubtle
              : AppColors.electricBlueBright.withOpacity(0.35),
        ),
        boxShadow: isNormal
            ? null
            : [
                BoxShadow(
                  color: AppColors.electricBlue.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CURRENT RATE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isNormal ? AppColors.textMuted : AppColors.electricBlueBright,
                      boxShadow: isNormal
                          ? null
                          : [
                              BoxShadow(
                                color: AppColors.electricBlueBright.withOpacity(0.60),
                                blurRadius: 6,
                              ),
                            ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: isNormal ? AppColors.textSecondary : AppColors.electricBlueBright,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Large glowing speed typography with tabular figures
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: Container(
              key: ValueKey('hero_speed_${_currentSpeed.toStringAsFixed(2)}'),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isNormal
                    ? Colors.white.withOpacity(0.04)
                    : AppColors.electricBlue.withOpacity(0.16),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isNormal
                      ? AppColors.glassBorderSubtle
                      : AppColors.electricBlueBright.withOpacity(0.50),
                ),
              ),
              child: Text(
                '${_currentSpeed.toStringAsFixed(2)}×',
                style: TextStyle(
                  color: isNormal ? Colors.white : AppColors.electricBlueBright,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- B. Quick Presets Grid ---
  Widget _buildQuickPresetsGrid() {
    final firstRow = PlaybackSpeedSheet.presetSpeeds.sublist(0, 5);
    final secondRow = PlaybackSpeedSheet.presetSpeeds.sublist(5, 10);

    return Column(
      children: [
        Row(
          children: firstRow.map((preset) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: _buildPresetButton(preset),
            ),
          )).toList(),
        ),
        const SizedBox(height: 6),
        Row(
          children: secondRow.map((preset) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: _buildPresetButton(preset),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPresetButton(String preset) {
    final isSelected = _isPresetSelected(preset);
    final cleanNum = preset.replaceAll('×', '');

    return Semantics(
      label: '$cleanNum times playback speed',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        key: ValueKey('preset_$preset'),
        onTap: () {
          final speed = PlaybackSpeedSheet.parseSpeed(preset);
          _applySpeed(speed, isPreset: true);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.electricBlue.withOpacity(0.22)
                : AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.electricBlueBright
                  : AppColors.glassBorderSubtle,
              width: isSelected ? 1.4 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.36),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                preset,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected) ...[
                const SizedBox(height: 3),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.electricBlueBright,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- C. Custom Speed Slider ---
  Widget _buildCustomSpeedSlider() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '0.25×',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.electricBlueBright.withOpacity(0.30)),
                ),
                child: Text(
                  '${_currentSpeed.toStringAsFixed(2)}×',
                  style: const TextStyle(
                    color: AppColors.electricBlueBright,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const Text(
                '4.00×',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Semantics(
            label: 'Custom playback speed slider, currently ${PlaybackSpeedSheet.formatSpeed(_currentSpeed)}',
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.electricBlueBright,
                inactiveTrackColor: Colors.white.withOpacity(0.12),
                thumbColor: AppColors.electricBlueBright,
                overlayColor: AppColors.electricBlue.withOpacity(0.24),
                trackHeight: 3.5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
              ),
              child: Slider(
                key: const ValueKey('custom_speed_slider'),
                value: _currentSpeed.clamp(0.25, 4.00),
                min: 0.25,
                max: 4.00,
                divisions: 75, // 0.05 step intervals
                onChanged: (val) {
                  final rounded = (val * 20).round() / 20; // 0.05 precision
                  _applySpeed(rounded);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- D. Fine Adjustment Section (±0.05×) ---
  Widget _buildFineAdjustmentSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          // Step row: [ - ]  [ 1.25× ]  [ + ]
          Row(
            children: [
              // Decrement Button
              Semantics(
                label: 'Decrease speed by 0.05',
                button: true,
                child: _buildStepButton(
                  key: const ValueKey('speed_decrement_btn'),
                  icon: Icons.remove_rounded,
                  onTap: () => _adjustSpeedBy(-0.05),
                  enabled: _currentSpeed > 0.25,
                ),
              ),

              const SizedBox(width: 10),

              // Value Display Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.glassBorderSubtle),
                  ),
                  child: Text(
                    '${_currentSpeed.toStringAsFixed(2)}×',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Increment Button
              Semantics(
                label: 'Increase speed by 0.05',
                button: true,
                child: _buildStepButton(
                  key: const ValueKey('speed_increment_btn'),
                  icon: Icons.add_rounded,
                  onTap: () => _adjustSpeedBy(0.05),
                  enabled: _currentSpeed < 4.00,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Secondary quick-nudge chips: [-0.10×] [-0.05×] [+0.05×] [+0.10×]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNudgeChip('-0.10×', () => _adjustSpeedBy(-0.10)),
              _buildNudgeChip('-0.05×', () => _adjustSpeedBy(-0.05)),
              _buildNudgeChip('+0.05×', () => _adjustSpeedBy(0.05)),
              _buildNudgeChip('+0.10×', () => _adjustSpeedBy(0.10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required Key key,
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 40,
          decoration: BoxDecoration(
            color: enabled ? AppColors.electricBlue.withOpacity(0.15) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled ? AppColors.electricBlueBright.withOpacity(0.40) : AppColors.glassBorderSubtle,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.electricBlueBright : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }

  Widget _buildNudgeChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // --- E. Hold for 2× Tile ---
  Widget _buildHoldFor2xTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              color: AppColors.electricBlueBright,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hold for 2×',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.5),
                Text(
                  'Temporarily play at 2× while holding the video.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'Hold for 2x speed toggle',
            child: Switch(
              key: const ValueKey('hold_for_2x_switch'),
              value: _holdFor2x,
              activeColor: AppColors.electricBlueBright,
              onChanged: _handleToggleHoldFor2x,
            ),
          ),
        ],
      ),
    );
  }

  // --- F. Reset to 1× Button ---
  Widget _buildResetButton() {
    final isAlready1x = (_currentSpeed - 1.0).abs() < 0.01;

    return Semantics(
      label: 'Reset speed to 1x',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('reset_speed_btn'),
          onTap: isAlready1x ? null : _handleReset,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isAlready1x ? Colors.white.withOpacity(0.03) : AppColors.surfaceGlass,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isAlready1x ? AppColors.glassBorderSubtle : AppColors.electricBlueBright.withOpacity(0.35),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restart_alt_rounded,
                  size: 18,
                  color: isAlready1x ? AppColors.textMuted : AppColors.electricBlueBright,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reset to 1.00×',
                  style: TextStyle(
                    color: isAlready1x ? AppColors.textMuted : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
