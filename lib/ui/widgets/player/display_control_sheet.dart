import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/player_types.dart';

/// The official Video Scaling / Aspect Ratio / Zoom control bottom sheet for PIchiPlayer.
/// An offline-first local display studio that treats scaling, aspect ratio, and zoom
/// as one coherent, intuitive system: "Fit it. Fill it. Crop it. Zoom it. Watch."
class DisplayControlSheet extends StatefulWidget {
  final PlayerScalingMode selectedMode;
  final ValueChanged<PlayerScalingMode> onSelected;
  final String selectedAspectRatio;
  final ValueChanged<String>? onAspectRatioChanged;
  final double userZoomScale;
  final ValueChanged<double>? onZoomChanged;
  final Alignment cropAlignment;
  final ValueChanged<Alignment>? onCropAlignmentChanged;
  final VoidCallback? onResetDisplay;
  final String? videoTitle;

  const DisplayControlSheet({
    super.key,
    required this.selectedMode,
    required this.onSelected,
    this.selectedAspectRatio = 'Auto',
    this.onAspectRatioChanged,
    this.userZoomScale = 1.0,
    this.onZoomChanged,
    this.cropAlignment = Alignment.center,
    this.onCropAlignmentChanged,
    this.onResetDisplay,
    this.videoTitle,
  });

  /// Static helper to display the sheet over fullscreen player
  static void show(
    BuildContext context, {
    required PlayerScalingMode selectedMode,
    required ValueChanged<PlayerScalingMode> onSelected,
    String selectedAspectRatio = 'Auto',
    ValueChanged<String>? onAspectRatioChanged,
    double userZoomScale = 1.0,
    ValueChanged<double>? onZoomChanged,
    Alignment cropAlignment = Alignment.center,
    ValueChanged<Alignment>? onCropAlignmentChanged,
    VoidCallback? onResetDisplay,
    String? videoTitle,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DisplayControlSheet(
        selectedMode: selectedMode,
        onSelected: onSelected,
        selectedAspectRatio: selectedAspectRatio,
        onAspectRatioChanged: onAspectRatioChanged,
        userZoomScale: userZoomScale,
        onZoomChanged: onZoomChanged,
        cropAlignment: cropAlignment,
        onCropAlignmentChanged: onCropAlignmentChanged,
        onResetDisplay: onResetDisplay,
        videoTitle: videoTitle,
      ),
    );
  }

  static const List<String> aspectRatios = [
    'Auto',
    '16:9',
    '4:3',
    '21:9',
    '1:1',
    '9:16',
  ];

  @override
  State<DisplayControlSheet> createState() => _DisplayControlSheetState();
}

class _DisplayControlSheetState extends State<DisplayControlSheet> {
  late PlayerScalingMode _currentMode;
  late String _currentAspectRatio;
  late double _currentZoom;
  late Alignment _currentAlignment;

  String? _transientFeedback;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.selectedMode;
    _currentAspectRatio = widget.selectedAspectRatio;
    _currentZoom = widget.userZoomScale.clamp(1.0, 3.0);
    _currentAlignment = widget.cropAlignment;
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _showFeedback(String msg) {
    setState(() => _transientFeedback = msg);
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _transientFeedback = null);
    });
  }

  void _handleScalingSelected(PlayerScalingMode mode) {
    HapticFeedback.selectionClick();
    setState(() => _currentMode = mode);
    widget.onSelected(mode);
    _showFeedback('Scaling: ${mode.label.toUpperCase()}');
  }

  void _handleAspectRatioSelected(String ratio) {
    HapticFeedback.selectionClick();
    setState(() => _currentAspectRatio = ratio);
    widget.onAspectRatioChanged?.call(ratio);
    _showFeedback('Aspect Ratio: $ratio');
  }

  void _handleZoomChanged(double zoom) {
    // Subtle snapping near 1.00x and 2.00x
    double targetZoom = zoom;
    if ((zoom - 1.00).abs() <= 0.04) {
      targetZoom = 1.00;
    } else if ((zoom - 2.00).abs() <= 0.04) {
      targetZoom = 2.00;
    }

    final rounded = (targetZoom * 100).round() / 100;
    final clamped = rounded.clamp(1.00, 3.00);

    if ((_currentZoom - 1.0).abs() > 0.02 && clamped == 1.00) {
      HapticFeedback.lightImpact();
    } else if ((_currentZoom - 2.0).abs() > 0.02 && clamped == 2.00) {
      HapticFeedback.lightImpact();
    }

    setState(() => _currentZoom = clamped);
    widget.onZoomChanged?.call(clamped);
  }

  void _adjustZoomBy(double delta) {
    HapticFeedback.selectionClick();
    _handleZoomChanged(_currentZoom + delta);
    _showFeedback('${_currentZoom.toStringAsFixed(2)}× Zoom');
  }

  void _handleAlignmentSelected(Alignment alignment) {
    HapticFeedback.selectionClick();
    setState(() => _currentAlignment = alignment);
    widget.onCropAlignmentChanged?.call(alignment);
  }

  void _handleReset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentMode = PlayerScalingMode.fit;
      _currentAspectRatio = 'Auto';
      _currentZoom = 1.00;
      _currentAlignment = Alignment.center;
    });

    widget.onSelected(PlayerScalingMode.fit);
    widget.onAspectRatioChanged?.call('Auto');
    widget.onZoomChanged?.call(1.00);
    widget.onCropAlignmentChanged?.call(Alignment.center);
    widget.onResetDisplay?.call();

    _showFeedback('Display reset to Fit (1.00×)');
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final maxSheetHeight = isLandscape
        ? mediaQuery.size.height * 0.90
        : mediaQuery.size.height * 0.80;

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

                // 3. Transient Feedback Bar
                if (_transientFeedback != null)
                  _buildTransientFeedbackBar(),

                // 4. Main Scrollable Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                    children: [
                      // A. Primary Scaling Section with Visual Diagram Previews
                      _buildSectionHeader('SCALING'),
                      const SizedBox(height: 8),
                      _buildScalingModesGrid(),

                      const SizedBox(height: 18),
                      const Divider(color: AppColors.glassBorderSubtle, height: 1),
                      const SizedBox(height: 14),

                      // B. Aspect Ratio Section
                      _buildSectionHeader('ASPECT RATIO'),
                      const SizedBox(height: 8),
                      _buildAspectRatioChips(),

                      const SizedBox(height: 18),
                      const Divider(color: AppColors.glassBorderSubtle, height: 1),
                      const SizedBox(height: 14),

                      // C. Zoom Section
                      _buildSectionHeader('ZOOM'),
                      const SizedBox(height: 8),
                      _buildZoomSection(),

                      const SizedBox(height: 18),
                      const Divider(color: AppColors.glassBorderSubtle, height: 1),
                      const SizedBox(height: 14),

                      // D. Crop Positioning (Advanced Alignment)
                      _buildSectionHeader('CROP POSITIONING'),
                      const SizedBox(height: 8),
                      _buildCropPositioningRow(),

                      const SizedBox(height: 20),

                      // E. Reset Display Action Button
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
            Icons.aspect_ratio_rounded,
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
                  'Display',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Aspect Ratio / Display',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.videoTitle != null) ...[
                      const Text(
                        ' • ',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                      ),
                      Flexible(
                        child: Text(
                          widget.videoTitle!,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        ' • Video scaling & presentation',
                        style: TextStyle(
                          color: AppColors.textMuted,
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
          IconButton(
            key: const ValueKey('display_sheet_close_btn'),
            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

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
            _transientFeedback!,
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

  // --- A. Scaling Modes Grid with Visual Preview Diagrams ---
  Widget _buildScalingModesGrid() {
    final modes = [
      PlayerScalingMode.fit,
      PlayerScalingMode.fill,
      PlayerScalingMode.crop,
      PlayerScalingMode.original,
    ];

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildScalingCard(modes[0]),
              const SizedBox(height: 8),
              _buildScalingCard(modes[2]),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              _buildScalingCard(modes[1]),
              const SizedBox(height: 8),
              _buildScalingCard(modes[3]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScalingCard(PlayerScalingMode mode) {
    final isSelected = _currentMode == mode;

    return Semantics(
      label: '${mode.label} scaling mode',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        key: ValueKey('scaling_mode_${mode.name}'),
        onTap: () => _handleScalingSelected(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.electricBlue.withOpacity(0.18)
                : AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.electricBlueBright
                  : AppColors.glassBorderSubtle,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual Preview Diagram
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildVisualDiagram(mode, isSelected),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.electricBlueBright : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.electricBlueBright
                            : Colors.white.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.black, size: 12)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                mode.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),

              // Description
              Text(
                mode.description,
                style: TextStyle(
                  color: isSelected ? AppColors.electricBlueBright.withOpacity(0.9) : AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Miniature visual diagram representing each scaling mode
  Widget _buildVisualDiagram(PlayerScalingMode mode, bool isSelected) {
    const frameW = 62.0;
    const frameH = 38.0;

    return Container(
      width: frameW,
      height: frameH,
      decoration: BoxDecoration(
        color: const Color(0xFF070B14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected
              ? AppColors.electricBlueBright.withOpacity(0.60)
              : Colors.white.withOpacity(0.16),
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Center(
        child: _buildDiagramInner(mode, frameW, frameH, isSelected),
      ),
    );
  }

  Widget _buildDiagramInner(PlayerScalingMode mode, double frameW, double frameH, bool isSelected) {
    final videoColor = isSelected
        ? AppColors.electricBlue.withOpacity(0.55)
        : Colors.white.withOpacity(0.24);
    final borderColor = isSelected ? AppColors.electricBlueBright : Colors.white.withOpacity(0.50);

    switch (mode) {
      case PlayerScalingMode.fit:
        // Complete 16:9 rectangle centered inside screen, showing clear top/bottom letterbox bars
        return Container(
          width: frameW * 0.76,
          height: frameH * 0.58,
          decoration: BoxDecoration(
            color: videoColor,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: const Center(
            child: Icon(Icons.crop_landscape_rounded, size: 11, color: Colors.white),
          ),
        );

      case PlayerScalingMode.fill:
        // Stretches to fill entire frame edge-to-edge
        return Container(
          width: frameW,
          height: frameH,
          decoration: BoxDecoration(
            color: videoColor,
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: const Center(
            child: Icon(Icons.fullscreen_rounded, size: 14, color: Colors.white),
          ),
        );

      case PlayerScalingMode.crop:
        // Zoomed in, overflowing boundary with dashed crop lines
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: frameW * 1.35,
              height: frameH * 1.35,
              decoration: BoxDecoration(
                color: videoColor,
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: const Center(
                child: Icon(Icons.crop_free_rounded, size: 14, color: Colors.white),
              ),
            ),
            // Subtle crop edge indicators
            Positioned(
              left: 2,
              child: Container(width: 1, height: frameH, color: Colors.white.withOpacity(0.40)),
            ),
            Positioned(
              right: 2,
              child: Container(width: 1, height: frameH, color: Colors.white.withOpacity(0.40)),
            ),
          ],
        );

      case PlayerScalingMode.original:
      case PlayerScalingMode.sixteenNine:
      case PlayerScalingMode.fourThree:
        // 1:1 Pixel Native representation centered
        return Container(
          width: frameW * 0.50,
          height: frameH * 0.50,
          decoration: BoxDecoration(
            color: videoColor,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: const Center(
            child: Icon(Icons.fit_screen_rounded, size: 11, color: Colors.white),
          ),
        );
    }
  }

  // --- B. Aspect Ratio Chips Section ---
  Widget _buildAspectRatioChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: DisplayControlSheet.aspectRatios.map((ratio) {
          final isSelected = _currentAspectRatio == ratio;
          return Semantics(
            label: '$ratio aspect ratio',
            selected: isSelected,
            button: true,
            child: GestureDetector(
              key: ValueKey('ratio_$ratio'),
              onTap: () => _handleAspectRatioSelected(ratio),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.electricBlue.withOpacity(0.22)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.electricBlueBright
                        : AppColors.glassBorderSubtle,
                    width: isSelected ? 1.4 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.electricBlue.withOpacity(0.30),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  ratio == 'Auto' ? 'Auto (Native)' : ratio,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- C. Zoom Section ---
  Widget _buildZoomSection() {
    final isNormal = (_currentZoom - 1.00).abs() < 0.01;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          // Zoom Header: Stepper [ - ]  [ 1.25× ]  [ + ]
          Row(
            children: [
              // Minus Button
              _buildStepButton(
                key: const ValueKey('zoom_decrement_btn'),
                icon: Icons.remove_rounded,
                onTap: () => _adjustZoomBy(-0.05),
                enabled: _currentZoom > 1.00,
                tooltip: 'Zoom out by 0.05×',
              ),

              const SizedBox(width: 10),

              // Glowing Zoom Value Display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isNormal ? Colors.white.withOpacity(0.04) : AppColors.electricBlue.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isNormal ? AppColors.glassBorderSubtle : AppColors.electricBlueBright.withOpacity(0.40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_currentZoom.toStringAsFixed(2)}×',
                        style: TextStyle(
                          color: isNormal ? Colors.white : AppColors.electricBlueBright,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        isNormal ? 'Default scale (100%)' : 'Pinch or drag video to pan',
                        style: TextStyle(
                          color: isNormal ? AppColors.textMuted : AppColors.electricBlueBright.withOpacity(0.85),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Plus Button
              _buildStepButton(
                key: const ValueKey('zoom_increment_btn'),
                icon: Icons.add_rounded,
                onTap: () => _adjustZoomBy(0.05),
                enabled: _currentZoom < 3.00,
                tooltip: 'Zoom in by 0.05×',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Zoom Slider with Min/Max
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('1.00×', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
              Text(
                '${_currentZoom.toStringAsFixed(2)}×',
                style: const TextStyle(
                  color: AppColors.electricBlueBright,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Text('3.00×', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),

          Semantics(
            label: 'Video zoom slider, currently ${_currentZoom.toStringAsFixed(2)} times',
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
                key: const ValueKey('zoom_slider'),
                value: _currentZoom.clamp(1.00, 3.00),
                min: 1.00,
                max: 3.00,
                onChanged: _handleZoomChanged,
              ),
            ),
          ),

          // Quick Zoom Presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1.00, 1.25, 1.50, 2.00, 3.00].map((preset) {
              final isSelected = (_currentZoom - preset).abs() < 0.01;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _handleZoomChanged(preset);
                  _showFeedback('${preset.toStringAsFixed(2)}× Zoom');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.electricBlue.withOpacity(0.20) : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? AppColors.electricBlueBright : AppColors.glassBorderSubtle,
                    ),
                  ),
                  child: Text(
                    '${preset.toStringAsFixed(2)}×',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
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
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
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

  // --- D. Crop Positioning Row ---
  Widget _buildCropPositioningRow() {
    final alignments = [
      {'label': 'Top', 'val': Alignment.topCenter},
      {'label': 'Center', 'val': Alignment.center},
      {'label': 'Bottom', 'val': Alignment.bottomCenter},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alignment anchor',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'Focus area for cropped/zoomed video',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: alignments.map((item) {
              final alignVal = item['val'] as Alignment;
              final label = item['label'] as String;
              final isSelected = _currentAlignment == alignVal;

              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: GestureDetector(
                  key: ValueKey('align_$label'),
                  onTap: () => _handleAlignmentSelected(alignVal),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.electricBlue.withOpacity(0.20) : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.electricBlueBright : AppColors.glassBorderSubtle,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- E. Reset Display Action Button ---
  Widget _buildResetButton() {
    final isDefault = _currentMode == PlayerScalingMode.fit &&
        _currentAspectRatio == 'Auto' &&
        _currentZoom == 1.00 &&
        _currentAlignment == Alignment.center;

    return Semantics(
      label: 'Reset display settings to Fit and 1x zoom',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('reset_display_btn'),
          onTap: isDefault ? null : _handleReset,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDefault ? Colors.white.withOpacity(0.03) : AppColors.surfaceGlass,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDefault ? AppColors.glassBorderSubtle : AppColors.electricBlueBright.withOpacity(0.40),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restart_alt_rounded,
                  size: 18,
                  color: isDefault ? AppColors.textMuted : AppColors.electricBlueBright,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reset Display',
                  style: TextStyle(
                    color: isDefault ? AppColors.textMuted : Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
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
