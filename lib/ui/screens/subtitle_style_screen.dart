import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/subtitle_style_config.dart';

/// The official Subtitle Customization / Subtitle Style screen for PIchiPlayer.
/// An offline-first live subtitle styling studio with real-time video-frame preview,
/// instant preset switching, typography, color, outline, shadow, background,
/// and positioning controls.
class SubtitleStyleScreen extends StatefulWidget {
  final SubtitleStyleConfig? initialConfig;
  final ValueChanged<SubtitleStyleConfig>? onConfigChanged;

  const SubtitleStyleScreen({
    super.key,
    this.initialConfig,
    this.onConfigChanged,
  });

  @override
  State<SubtitleStyleScreen> createState() => _SubtitleStyleScreenState();
}

class _SubtitleStyleScreenState extends State<SubtitleStyleScreen> {
  late SubtitleStyleConfig _config;

  // Expandable sections state
  bool _isAdvancedTypographyExpanded = false;
  bool _isAdvancedPositioningExpanded = false;

  // Preset definitions
  final List<SubtitleStyleConfig> _presets = [
    SubtitleStyleConfig.classic(),
    SubtitleStyleConfig.modern(),
    SubtitleStyleConfig.cinema(),
    SubtitleStyleConfig.highContrast(),
  ];

  // Predefined color palette
  final List<Map<String, dynamic>> _colorPalette = [
    {'name': 'White', 'color': Colors.white},
    {'name': 'Soft White', 'color': const Color(0xFFF1F5F9)},
    {'name': 'Yellow', 'color': const Color(0xFFFDE047)},
    {'name': 'Cyan', 'color': const Color(0xFF22D3EE)},
    {'name': 'Light Blue', 'color': const Color(0xFF60A5FA)},
  ];

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig ?? SubtitleStyleConfig.modern();
  }

  void _updateConfig(SubtitleStyleConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
    widget.onConfigChanged?.call(newConfig);
  }

  void _applyPreset(SubtitleStyleConfig preset) {
    HapticFeedback.selectionClick();
    _updateConfig(preset);
  }

  void _resetToDefault() {
    HapticFeedback.mediumImpact();
    _updateConfig(SubtitleStyleConfig.modern());
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: AppColors.electricBlueBright, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reset to default subtitle style',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFontPicker() {
    const fonts = ['System Default', 'Sans Serif', 'Serif', 'Monospace'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundNavy.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.24),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Select Subtitle Font',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final f in fonts)
                ListTile(
                  key: ValueKey('font_$f'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    f,
                    style: TextStyle(
                      color: _config.fontFamily == f
                          ? AppColors.electricBlueBright
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: _config.fontFamily == f
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontFamily: f == 'Serif'
                          ? 'serif'
                          : (f == 'Monospace' ? 'monospace' : null),
                    ),
                  ),
                  trailing: _config.fontFamily == f
                      ? const Icon(Icons.check_rounded, color: AppColors.electricBlueBright)
                      : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _updateConfig(_config.copyWith(fontFamily: f));
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCustomColorPicker() {
    final customColors = [
      const Color(0xFFF97316), // Orange
      const Color(0xFF10B981), // Emerald
      const Color(0xFFA855F7), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFFE2E8F0), // Platinum
      const Color(0xFF93C5FD), // Sky
      const Color(0xFFFDE68A), // Cream
      const Color(0xFF86EFAC), // Mint
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundNavy.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.24),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Custom Text Color',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final c in customColors)
                    GestureDetector(
                      key: ValueKey('custom_color_${customColors.indexOf(c)}'),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _updateConfig(_config.copyWith(textColor: c));
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _config.textColor.value == c.value
                                ? AppColors.electricBlueBright
                                : Colors.white.withOpacity(0.3),
                            width: _config.textColor.value == c.value ? 2.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: c.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Screen App Bar
            _buildTopAppBar(),

            // 2. Main Live Studio Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = constraints.maxWidth > 700;

                  if (isLandscape) {
                    // Two-column landscape studio layout
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Sticky Cinematic Live Preview
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 10, 20),
                            child: _buildLivePreviewPanel(),
                          ),
                        ),

                        // Right Column: Scrollable Studio Controls
                        Expanded(
                          flex: 6,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(10, 10, 20, 30),
                            children: _buildControlsList(),
                          ),
                        ),
                      ],
                    );
                  }

                  // Vertical Portrait layout
                  return Column(
                    children: [
                      // Fixed Top Preview
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: _buildLivePreviewPanel(),
                      ),

                      // Scrollable Customization Controls
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                          children: _buildControlsList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Top App Bar ---
  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Subtitle Style',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Reset Button
          TextButton.icon(
            onPressed: _resetToDefault,
            icon: const Icon(
              Icons.restart_alt_rounded,
              color: AppColors.electricBlueBright,
              size: 18,
            ),
            label: const Text(
              'Reset',
              style: TextStyle(
                color: AppColors.electricBlueBright,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: AppColors.electricBlue.withOpacity(0.12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  // --- Cinematic Live Preview Panel ---
  Widget _buildLivePreviewPanel() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF090D18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.50),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Dark cinematic backdrop simulating a 4K movie frame
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF131D36),
                    Color(0xFF0B101E),
                    Color(0xFF05080E),
                  ],
                ),
              ),
            ),

            // Subtle ambient stars / lighting particles simulation
            CustomPaint(
              painter: _CinematicStarsPainter(),
            ),

            // Top-left preview badge
            Positioned(
              top: 12,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.remove_red_eye_rounded, color: AppColors.electricBlueBright, size: 12),
                    SizedBox(width: 5),
                    Text(
                      'LIVE PREVIEW',
                      style: TextStyle(
                        color: AppColors.electricBlueBright,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Real-time reactive Subtitle text positioned vertically
            Align(
              alignment: Alignment(
                _config.alignment == TextAlign.left
                    ? -0.85
                    : (_config.alignment == TextAlign.right ? 0.85 : 0.0),
                (_config.verticalPositionRatio * 2.0) - 1.0,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _config.horizontalMargin,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _config.effectiveBackgroundColor,
                    borderRadius: BorderRadius.circular(_config.cornerRadius),
                  ),
                  child: Text(
                    '“The stars are beautiful.”',
                    textAlign: _config.alignment,
                    style: TextStyle(
                      color: _config.textColor,
                      fontSize: _config.fontSizeSp,
                      fontWeight: _config.fontWeight,
                      fontStyle: _config.isItalic ? FontStyle.italic : FontStyle.normal,
                      fontFamily: _config.fontFamily == 'Serif'
                          ? 'serif'
                          : (_config.fontFamily == 'Monospace' ? 'monospace' : null),
                      letterSpacing: _config.letterSpacing,
                      height: _config.lineSpacing,
                      shadows: _config.effectiveShadows,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- List of Customization Controls ---
  List<Widget> _buildControlsList() {
    return [
      // 1. Presets Carousel
      _buildSectionHeader('PRESETS'),
      const SizedBox(height: 8),
      _buildPresetsCarousel(),

      const SizedBox(height: 18),
      const Divider(color: AppColors.glassBorderSubtle, height: 1),
      const SizedBox(height: 14),

      // 2. Text Size Slider
      _buildSectionHeader('TEXT SIZE'),
      _buildTextSizeControl(),

      const SizedBox(height: 18),
      const Divider(color: AppColors.glassBorderSubtle, height: 1),
      const SizedBox(height: 14),

      // 3. Font Selector Row
      _buildSectionHeader('FONT'),
      _buildFontSelectorTile(),

      const SizedBox(height: 18),
      const Divider(color: AppColors.glassBorderSubtle, height: 1),
      const SizedBox(height: 14),

      // 4. Text Color Chips
      _buildSectionHeader('TEXT COLOR'),
      _buildTextColorSelector(),

      const SizedBox(height: 18),
      const Divider(color: AppColors.glassBorderSubtle, height: 1),
      const SizedBox(height: 14),

      // 5. Outline Segmented Control
      _buildSectionHeader('OUTLINE'),
      _buildOutlineSelector(),

      const SizedBox(height: 18),
      const Divider(color: AppColors.glassBorderSubtle, height: 1),
      const SizedBox(height: 14),

      // 6. Shadow Segmented Control
      _buildSectionHeader('SHADOW'),
      _buildShadowSelector(),

      const SizedBox(height: 18),
      const Divider(color: AppColors.glassBorderSubtle, height: 1),
      const SizedBox(height: 14),

      // 7. Background & Opacity
      _buildSectionHeader('BACKGROUND'),
      _buildBackgroundControl(),

      const SizedBox(height: 18),
      const Divider(color: AppColors.glassBorderSubtle, height: 1),
      const SizedBox(height: 14),

      // 8. Subtitle Position (Vertical)
      _buildSectionHeader('POSITION'),
      _buildPositionControl(),

      const SizedBox(height: 18),
      const Divider(color: AppColors.glassBorderSubtle, height: 1),
      const SizedBox(height: 14),

      // 9. Horizontal Alignment
      _buildSectionHeader('ALIGNMENT'),
      _buildAlignmentControl(),

      const SizedBox(height: 18),
      const Divider(color: AppColors.glassBorderSubtle, height: 1),
      const SizedBox(height: 14),

      // 10. Advanced Typography (Expandable)
      _buildAdvancedTypographySection(),

      const SizedBox(height: 14),
      const Divider(color: AppColors.glassBorderSubtle, height: 1),
      const SizedBox(height: 14),

      // 11. Advanced Positioning (Expandable)
      _buildAdvancedPositioningSection(),

      const SizedBox(height: 14),
      const Divider(color: AppColors.glassBorderSubtle, height: 1),
      const SizedBox(height: 14),

      // 12. Subtitle Source Styling (ASS/SSA)
      _buildSourceStylingControl(),

      const SizedBox(height: 20),
    ];
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

  // --- Presets Carousel ---
  Widget _buildPresetsCarousel() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _presets.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isCustom = index == _presets.length;
          final preset = isCustom ? null : _presets[index];
          final isSelected = isCustom
              ? _config.presetName == 'Custom'
              : _config.presetName == preset!.presetName;

          final label = isCustom ? 'Custom' : preset!.presetName;

          return GestureDetector(
            key: ValueKey('preset_$label'),
            onTap: () {
              if (!isCustom) _applyPreset(preset!);
            },
            child: Container(
              width: 110,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.electricBlue.withOpacity(0.14)
                    : AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(14),
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
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tiny visual subtitle sample
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCustom
                          ? _config.effectiveBackgroundColor
                          : preset!.effectiveBackgroundColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Aa',
                      style: TextStyle(
                        color: isCustom ? _config.textColor : preset!.textColor,
                        fontSize: 12,
                        fontWeight: isCustom ? _config.fontWeight : preset!.fontWeight,
                        shadows: isCustom ? _config.effectiveShadows : preset!.effectiveShadows,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Text Size Control ---
  Widget _buildTextSizeControl() {
    return Column(
      children: [
        Row(
          children: [
            const Text('A', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
            Expanded(
              child: Slider(
                value: _config.fontSizePercent.toDouble(),
                min: 60,
                max: 180,
                divisions: 24,
                activeColor: AppColors.electricBlueBright,
                inactiveColor: Colors.white.withOpacity(0.12),
                onChanged: (val) {
                  _updateConfig(_config.copyWith(
                    fontSizePercent: val.toInt(),
                    presetName: 'Custom',
                  ));
                },
              ),
            ),
            const Text('A', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 14),
            Container(
              width: 52,
              alignment: Alignment.centerRight,
              child: Text(
                '${_config.fontSizePercent}%',
                style: const TextStyle(
                  color: AppColors.electricBlueBright,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Font Selector Tile ---
  Widget _buildFontSelectorTile() {
    return InkWell(
      onTap: _openFontPicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: Row(
          children: [
            const Icon(Icons.font_download_rounded, color: AppColors.electricBlueBright, size: 20),
            const SizedBox(width: 12),
            Text(
              _config.fontFamily,
              style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  // --- Text Color Selector ---
  Widget _buildTextColorSelector() {
    return Row(
      children: [
        for (final item in _colorPalette) ...[
          GestureDetector(
            key: ValueKey('color_${item['name']}'),
            onTap: () {
              HapticFeedback.selectionClick();
              _updateConfig(_config.copyWith(
                textColor: item['color'] as Color,
                presetName: 'Custom',
              ));
            },
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: item['color'] as Color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _config.textColor.value == (item['color'] as Color).value
                      ? AppColors.electricBlueBright
                      : Colors.white.withOpacity(0.2),
                  width: _config.textColor.value == (item['color'] as Color).value ? 2.5 : 1.0,
                ),
                boxShadow: _config.textColor.value == (item['color'] as Color).value
                    ? [
                        BoxShadow(
                          color: AppColors.electricBlue.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: _config.textColor.value == (item['color'] as Color).value
                  ? const Center(
                      child: Icon(Icons.check_rounded, color: Colors.black, size: 16),
                    )
                  : null,
            ),
          ),
        ],

        // Custom Color Button
        GestureDetector(
          key: const ValueKey('color_custom_btn'),
          onTap: _openCustomColorPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceGlass,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorderSubtle),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.palette_outlined, color: AppColors.electricBlueBright, size: 15),
                SizedBox(width: 5),
                Text(
                  'Custom',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Outline Selector ---
  Widget _buildOutlineSelector() {
    return Row(
      children: SubtitleOutlineStyle.values.map((style) {
        final isSelected = _config.outlineStyle == style;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildChoiceChip(
              label: style.label,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                _updateConfig(_config.copyWith(
                  outlineStyle: style,
                  presetName: 'Custom',
                ));
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Shadow Selector ---
  Widget _buildShadowSelector() {
    return Row(
      children: SubtitleShadowStyle.values.map((shadow) {
        final isSelected = _config.shadowStyle == shadow;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildChoiceChip(
              label: shadow.label,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                _updateConfig(_config.copyWith(
                  shadowStyle: shadow,
                  presetName: 'Custom',
                ));
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Background & Opacity ---
  Widget _buildBackgroundControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: SubtitleBackgroundType.values.map((bg) {
            final isSelected = _config.backgroundType == bg;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildChoiceChip(
                  label: bg.label,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _updateConfig(_config.copyWith(
                      backgroundType: bg,
                      presetName: 'Custom',
                    ));
                  },
                ),
              ),
            );
          }).toList(),
        ),

        // Live Opacity Slider if background is enabled
        if (_config.backgroundType != SubtitleBackgroundType.none) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Opacity', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _config.backgroundOpacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  activeColor: AppColors.electricBlueBright,
                  inactiveColor: Colors.white.withOpacity(0.12),
                  onChanged: (val) {
                    _updateConfig(_config.copyWith(
                      backgroundOpacity: val,
                      presetName: 'Custom',
                    ));
                  },
                ),
              ),
              Container(
                width: 44,
                alignment: Alignment.centerRight,
                child: Text(
                  '${(_config.backgroundOpacity * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppColors.electricBlueBright,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // --- Position Slider (Vertical) ---
  Widget _buildPositionControl() {
    return Row(
      children: [
        const Text('Top', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600)),
        Expanded(
          child: Slider(
            value: _config.verticalPositionRatio,
            min: 0.15,
            max: 0.95,
            divisions: 20,
            activeColor: AppColors.electricBlueBright,
            inactiveColor: Colors.white.withOpacity(0.12),
            onChanged: (val) {
              _updateConfig(_config.copyWith(
                verticalPositionRatio: val,
                presetName: 'Custom',
              ));
            },
          ),
        ),
        const Text('Bottom', style: TextStyle(color: AppColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // --- Alignment Control (Horizontal) ---
  Widget _buildAlignmentControl() {
    return Row(
      children: [
        Expanded(
          child: _buildChoiceChip(
            label: 'Left',
            icon: Icons.format_align_left_rounded,
            isSelected: _config.alignment == TextAlign.left,
            onTap: () {
              HapticFeedback.selectionClick();
              _updateConfig(_config.copyWith(alignment: TextAlign.left, presetName: 'Custom'));
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildChoiceChip(
            label: 'Center',
            icon: Icons.format_align_center_rounded,
            isSelected: _config.alignment == TextAlign.center,
            onTap: () {
              HapticFeedback.selectionClick();
              _updateConfig(_config.copyWith(alignment: TextAlign.center, presetName: 'Custom'));
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildChoiceChip(
            label: 'Right',
            icon: Icons.format_align_right_rounded,
            isSelected: _config.alignment == TextAlign.right,
            onTap: () {
              HapticFeedback.selectionClick();
              _updateConfig(_config.copyWith(alignment: TextAlign.right, presetName: 'Custom'));
            },
          ),
        ),
      ],
    );
  }

  // --- Advanced Typography Section ---
  Widget _buildAdvancedTypographySection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Advanced typography',
              style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Weight, italic, letter and line spacing',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            trailing: Icon(
              _isAdvancedTypographyExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: AppColors.textSecondary,
            ),
            onTap: () => setState(() => _isAdvancedTypographyExpanded = !_isAdvancedTypographyExpanded),
          ),
          if (_isAdvancedTypographyExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.glassBorderSubtle, height: 1),
                  const SizedBox(height: 12),
                  const Text('Font Weight', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildWeightChip('Regular', FontWeight.normal),
                      const SizedBox(width: 8),
                      _buildWeightChip('Medium', FontWeight.w500),
                      const SizedBox(width: 8),
                      _buildWeightChip('SemiBold', FontWeight.w600),
                      const SizedBox(width: 8),
                      _buildWeightChip('Bold', FontWeight.bold),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Italic', style: TextStyle(color: Colors.white, fontSize: 13)),
                      Switch(
                        value: _config.isItalic,
                        activeColor: AppColors.electricBlueBright,
                        onChanged: (val) {
                          _updateConfig(_config.copyWith(isItalic: val, presetName: 'Custom'));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Letter spacing', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: _config.letterSpacing,
                          min: -0.5,
                          max: 3.0,
                          divisions: 14,
                          activeColor: AppColors.electricBlueBright,
                          onChanged: (val) {
                            _updateConfig(_config.copyWith(letterSpacing: val, presetName: 'Custom'));
                          },
                        ),
                      ),
                      Text('${_config.letterSpacing.toStringAsFixed(1)}px', style: const TextStyle(color: AppColors.electricBlueBright, fontSize: 11)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Line spacing', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: _config.lineSpacing,
                          min: 0.8,
                          max: 2.2,
                          divisions: 14,
                          activeColor: AppColors.electricBlueBright,
                          onChanged: (val) {
                            _updateConfig(_config.copyWith(lineSpacing: val, presetName: 'Custom'));
                          },
                        ),
                      ),
                      Text('${_config.lineSpacing.toStringAsFixed(1)}×', style: const TextStyle(color: AppColors.electricBlueBright, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeightChip(String label, FontWeight weight) {
    final isSelected = _config.fontWeight == weight;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _updateConfig(_config.copyWith(fontWeight: weight, presetName: 'Custom'));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.electricBlue : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // --- Advanced Positioning Section ---
  Widget _buildAdvancedPositioningSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Advanced positioning',
              style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Margins, corner radius, safe area',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            trailing: Icon(
              _isAdvancedPositioningExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: AppColors.textSecondary,
            ),
            onTap: () => setState(() => _isAdvancedPositioningExpanded = !_isAdvancedPositioningExpanded),
          ),
          if (_isAdvancedPositioningExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(color: AppColors.glassBorderSubtle, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Corner radius', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: _config.cornerRadius,
                          min: 0.0,
                          max: 20.0,
                          divisions: 20,
                          activeColor: AppColors.electricBlueBright,
                          onChanged: (val) {
                            _updateConfig(_config.copyWith(cornerRadius: val, presetName: 'Custom'));
                          },
                        ),
                      ),
                      Text('${_config.cornerRadius.toInt()}dp', style: const TextStyle(color: AppColors.electricBlueBright, fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Bottom margin', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: _config.bottomMargin,
                          min: 8.0,
                          max: 64.0,
                          divisions: 14,
                          activeColor: AppColors.electricBlueBright,
                          onChanged: (val) {
                            _updateConfig(_config.copyWith(bottomMargin: val, presetName: 'Custom'));
                          },
                        ),
                      ),
                      Text('${_config.bottomMargin.toInt()}dp', style: const TextStyle(color: AppColors.electricBlueBright, fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Horizontal margin', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: _config.horizontalMargin,
                          min: 8.0,
                          max: 48.0,
                          divisions: 10,
                          activeColor: AppColors.electricBlueBright,
                          onChanged: (val) {
                            _updateConfig(_config.copyWith(horizontalMargin: val, presetName: 'Custom'));
                          },
                        ),
                      ),
                      Text('${_config.horizontalMargin.toInt()}dp', style: const TextStyle(color: AppColors.electricBlueBright, fontSize: 12)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Respect safe area', style: TextStyle(color: Colors.white, fontSize: 13)),
                      Switch(
                        value: _config.useSafeArea,
                        activeColor: AppColors.electricBlueBright,
                        onChanged: (val) {
                          _updateConfig(_config.copyWith(useSafeArea: val, presetName: 'Custom'));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Subtitle Source Styling Setting ---
  Widget _buildSourceStylingControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('SUBTITLE APPEARANCE'),
        const SizedBox(height: 4),
        const Text(
          'For formats with embedded styles (e.g. ASS/SSA)',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildChoiceChip(
                label: 'Use embedded styling',
                isSelected: _config.useEmbeddedStyling,
                onTap: () {
                  HapticFeedback.selectionClick();
                  _updateConfig(_config.copyWith(useEmbeddedStyling: true));
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildChoiceChip(
                label: 'Use PIchiPlayer styling',
                isSelected: !_config.useEmbeddedStyling,
                onTap: () {
                  HapticFeedback.selectionClick();
                  _updateConfig(_config.copyWith(useEmbeddedStyling: false));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper chip widget for segmented selections
  Widget _buildChoiceChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: ValueKey('chip_$label'),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.electricBlue.withOpacity(0.18)
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
                    color: AppColors.electricBlue.withOpacity(0.25),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.electricBlueBright : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to generate subtle cinematic stars and ambient lighting in the preview
class _CinematicStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.25);
    final glowPaint = Paint()..color = AppColors.electricBlue.withOpacity(0.12);

    // Ambient space nebula glow in corner
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.2), 60, glowPaint);

    // Star dots
    final offsets = [
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.28, size.height * 0.18),
      Offset(size.width * 0.45, size.height * 0.35),
      Offset(size.width * 0.62, size.height * 0.15),
      Offset(size.width * 0.78, size.height * 0.42),
      Offset(size.width * 0.88, size.height * 0.22),
      Offset(size.width * 0.35, size.height * 0.65),
      Offset(size.width * 0.72, size.height * 0.75),
    ];

    for (final pt in offsets) {
      canvas.drawCircle(pt, 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
