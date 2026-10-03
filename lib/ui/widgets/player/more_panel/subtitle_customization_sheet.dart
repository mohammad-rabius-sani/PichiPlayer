import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Dedicated focused bottom sheet for customizing subtitle appearance
class SubtitleCustomizationSheet extends StatefulWidget {
  final String currentStyleName;
  final ValueChanged<String> onStyleSelected;

  const SubtitleCustomizationSheet({
    super.key,
    required this.currentStyleName,
    required this.onStyleSelected,
  });

  static void show(
    BuildContext context, {
    required String currentStyleName,
    required ValueChanged<String> onStyleSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SubtitleCustomizationSheet(
        currentStyleName: currentStyleName,
        onStyleSelected: onStyleSelected,
      ),
    );
  }

  @override
  State<SubtitleCustomizationSheet> createState() => _SubtitleCustomizationSheetState();
}

class _SubtitleCustomizationSheetState extends State<SubtitleCustomizationSheet> {
  String _fontSize = 'Normal';
  Color _textColor = Colors.white;
  String _bgStyle = 'Translucent';
  String _edgeStyle = 'Drop Shadow';

  final List<String> _fontSizes = ['Small', 'Normal', 'Large', 'Extra Large'];
  final List<Map<String, dynamic>> _colors = [
    {'name': 'White', 'color': Colors.white},
    {'name': 'Yellow', 'color': const Color(0xFFFFD54F)},
    {'name': 'Cyan', 'color': const Color(0xFF4DD0E1)},
    {'name': 'Green', 'color': const Color(0xFF81C784)},
  ];
  final List<String> _backgrounds = ['None', 'Translucent', 'Solid'];
  final List<String> _edges = ['None', 'Drop Shadow', 'Outline'];

  double get _fontSizeSp {
    switch (_fontSize) {
      case 'Small':
        return 13.0;
      case 'Large':
        return 19.0;
      case 'Extra Large':
        return 22.0;
      case 'Normal':
      default:
        return 16.0;
    }
  }

  Color get _bgColor {
    switch (_bgStyle) {
      case 'Solid':
        return Colors.black;
      case 'Translucent':
        return Colors.black.withOpacity(0.60);
      case 'None':
      default:
        return Colors.transparent;
    }
  }

  List<Shadow>? get _shadows {
    if (_edgeStyle == 'Drop Shadow') {
      return [
        const Shadow(
          color: Colors.black87,
          blurRadius: 4.0,
          offset: Offset(1.5, 1.5),
        ),
      ];
    } else if (_edgeStyle == 'Outline') {
      return [
        const Shadow(color: Colors.black, blurRadius: 1, offset: Offset(1, 1)),
        const Shadow(color: Colors.black, blurRadius: 1, offset: Offset(-1, -1)),
        const Shadow(color: Colors.black, blurRadius: 1, offset: Offset(1, -1)),
        const Shadow(color: Colors.black, blurRadius: 1, offset: Offset(-1, 1)),
      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
                        Icons.text_format_rounded,
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
                            'Subtitle Style',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Customize size, colors, and legibility',
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

              const SizedBox(height: 14),
              const Divider(color: AppColors.glassBorderSubtle, height: 1),

              // Scrollable options
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Live Preview Box
                      Container(
                        width: double.infinity,
                        height: 90,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D111A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorderSubtle),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _bgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'We used to look up at the sky and wonder.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _fontSizeSp,
                              color: _textColor,
                              fontWeight: FontWeight.w600,
                              shadows: _shadows,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Font Size
                      const Text(
                        'FONT SIZE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.electricBlueBright,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _fontSizes.map((size) {
                          final isSelected = size == _fontSize;
                          return ChoiceChip(
                            label: Text(size),
                            selected: isSelected,
                            selectedColor: AppColors.electricBlue,
                            backgroundColor: AppColors.surfaceGlass,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.electricBlueBright : AppColors.glassBorderSubtle,
                            ),
                            onSelected: (_) => setState(() => _fontSize = size),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Text Color
                      const Text(
                        'TEXT COLOR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.electricBlueBright,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _colors.map((item) {
                          final Color color = item['color'] as Color;
                          final bool isSelected = _textColor == color;
                          return GestureDetector(
                            onTap: () => setState(() => _textColor = color),
                            child: Container(
                              margin: const EdgeInsets.only(right: 14),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.electricBlueBright : Colors.white24,
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: color == Colors.white ? Colors.black : Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Background
                      const Text(
                        'BACKGROUND',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.electricBlueBright,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _backgrounds.map((bg) {
                          final isSelected = bg == _bgStyle;
                          return ChoiceChip(
                            label: Text(bg),
                            selected: isSelected,
                            selectedColor: AppColors.electricBlue,
                            backgroundColor: AppColors.surfaceGlass,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.electricBlueBright : AppColors.glassBorderSubtle,
                            ),
                            onSelected: (_) => setState(() => _bgStyle = bg),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Text Edge / Shadow
                      const Text(
                        'EDGE STYLE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.electricBlueBright,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _edges.map((edge) {
                          final isSelected = edge == _edgeStyle;
                          return ChoiceChip(
                            label: Text(edge),
                            selected: isSelected,
                            selectedColor: AppColors.electricBlue,
                            backgroundColor: AppColors.surfaceGlass,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.electricBlueBright : AppColors.glassBorderSubtle,
                            ),
                            onSelected: (_) => setState(() => _edgeStyle = edge),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 22),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            final styleName = '$_fontSize • $_bgStyle';
                            widget.onStyleSelected(styleName);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Apply Style', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
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
