import 'package:flutter/material.dart';

/// Outline thickness options for subtitles
enum SubtitleOutlineStyle {
  off('Off', 0.0),
  thin('Thin', 1.2),
  medium('Medium', 2.2),
  thick('Thick', 3.6);

  final String label;
  final double strokeWidth;

  const SubtitleOutlineStyle(this.label, this.strokeWidth);
}

/// Shadow styles for subtitle depth
enum SubtitleShadowStyle {
  off('Off'),
  soft('Soft'),
  strong('Strong');

  final String label;

  const SubtitleShadowStyle(this.label);
}

/// Background backing styles for subtitle readability
enum SubtitleBackgroundType {
  none('None'),
  solid('Solid'),
  translucent('Translucent');

  final String label;

  const SubtitleBackgroundType(this.label);
}

/// Complete configuration model for subtitle styling in PIchiPlayer.
/// Contains all parameters for typography, colors, shadows, backgrounds,
/// positioning, and format compatibility.
class SubtitleStyleConfig {
  final String presetName;
  final int fontSizePercent;
  final String fontFamily;
  final Color textColor;
  final SubtitleOutlineStyle outlineStyle;
  final SubtitleShadowStyle shadowStyle;
  final SubtitleBackgroundType backgroundType;
  final double backgroundOpacity;
  final double cornerRadius;
  final double verticalPositionRatio; // 0.0 (top) to 1.0 (bottom)
  final TextAlign alignment;
  final FontWeight fontWeight;
  final bool isItalic;
  final double letterSpacing;
  final double lineSpacing;
  final double bottomMargin;
  final double horizontalMargin;
  final bool useSafeArea;
  final bool useEmbeddedStyling;

  const SubtitleStyleConfig({
    this.presetName = 'Modern',
    this.fontSizePercent = 100,
    this.fontFamily = 'System Default',
    this.textColor = Colors.white,
    this.outlineStyle = SubtitleOutlineStyle.medium,
    this.shadowStyle = SubtitleShadowStyle.soft,
    this.backgroundType = SubtitleBackgroundType.translucent,
    this.backgroundOpacity = 0.55,
    this.cornerRadius = 8.0,
    this.verticalPositionRatio = 0.88,
    this.alignment = TextAlign.center,
    this.fontWeight = FontWeight.w600,
    this.isItalic = false,
    this.letterSpacing = 0.2,
    this.lineSpacing = 1.2,
    this.bottomMargin = 24.0,
    this.horizontalMargin = 16.0,
    this.useSafeArea = true,
    this.useEmbeddedStyling = true,
  });

  /// Base font size in sp calculated from percentage
  double get fontSizeSp => 16.0 * (fontSizePercent / 100.0);

  /// Calculated background color with opacity
  Color get effectiveBackgroundColor {
    switch (backgroundType) {
      case SubtitleBackgroundType.solid:
        return Colors.black;
      case SubtitleBackgroundType.translucent:
        return Colors.black.withOpacity(backgroundOpacity.clamp(0.0, 1.0));
      case SubtitleBackgroundType.none:
      default:
        return Colors.transparent;
    }
  }

  /// Calculated shadows based on shadow style and outline style
  List<Shadow> get effectiveShadows {
    final list = <Shadow>[];

    // Outline shadows
    if (outlineStyle != SubtitleOutlineStyle.off) {
      final w = outlineStyle.strokeWidth;
      list.addAll([
        Shadow(color: Colors.black, blurRadius: 1, offset: Offset(w, w)),
        Shadow(color: Colors.black, blurRadius: 1, offset: Offset(-w, -w)),
        Shadow(color: Colors.black, blurRadius: 1, offset: Offset(w, -w)),
        Shadow(color: Colors.black, blurRadius: 1, offset: Offset(-w, w)),
      ]);
    }

    // Depth shadows
    if (shadowStyle == SubtitleShadowStyle.soft) {
      list.add(
        const Shadow(
          color: Colors.black87,
          blurRadius: 4.0,
          offset: Offset(1.5, 1.5),
        ),
      );
    } else if (shadowStyle == SubtitleShadowStyle.strong) {
      list.add(
        const Shadow(
          color: Colors.black,
          blurRadius: 8.0,
          offset: Offset(2.5, 2.5),
        ),
      );
    }

    return list;
  }

  /// Preset: Classic (Clean white text, dark outline, no background)
  factory SubtitleStyleConfig.classic() {
    return const SubtitleStyleConfig(
      presetName: 'Classic',
      fontSizePercent: 100,
      textColor: Colors.white,
      outlineStyle: SubtitleOutlineStyle.medium,
      shadowStyle: SubtitleShadowStyle.soft,
      backgroundType: SubtitleBackgroundType.none,
      backgroundOpacity: 0.0,
      cornerRadius: 6.0,
      verticalPositionRatio: 0.88,
      alignment: TextAlign.center,
      fontWeight: FontWeight.w600,
    );
  }

  /// Preset: Modern (Soft translucent backing, moderate rounded corners)
  factory SubtitleStyleConfig.modern() {
    return const SubtitleStyleConfig(
      presetName: 'Modern',
      fontSizePercent: 100,
      textColor: Colors.white,
      outlineStyle: SubtitleOutlineStyle.thin,
      shadowStyle: SubtitleShadowStyle.soft,
      backgroundType: SubtitleBackgroundType.translucent,
      backgroundOpacity: 0.55,
      cornerRadius: 8.0,
      verticalPositionRatio: 0.88,
      alignment: TextAlign.center,
      fontWeight: FontWeight.w600,
    );
  }

  /// Preset: Cinema (Warm-white text, strong outline, slightly larger)
  factory SubtitleStyleConfig.cinema() {
    return const SubtitleStyleConfig(
      presetName: 'Cinema',
      fontSizePercent: 110,
      textColor: Color(0xFFFEF3C7), // Warm amber-white
      outlineStyle: SubtitleOutlineStyle.thick,
      shadowStyle: SubtitleShadowStyle.strong,
      backgroundType: SubtitleBackgroundType.none,
      backgroundOpacity: 0.0,
      cornerRadius: 8.0,
      verticalPositionRatio: 0.88,
      alignment: TextAlign.center,
      fontWeight: FontWeight.w700,
    );
  }

  /// Preset: High Contrast (Yellow/white text, strong outline, dark background)
  factory SubtitleStyleConfig.highContrast() {
    return const SubtitleStyleConfig(
      presetName: 'High Contrast',
      fontSizePercent: 125,
      textColor: Color(0xFFFDE047), // High visibility yellow
      outlineStyle: SubtitleOutlineStyle.thick,
      shadowStyle: SubtitleShadowStyle.strong,
      backgroundType: SubtitleBackgroundType.translucent,
      backgroundOpacity: 0.80,
      cornerRadius: 6.0,
      verticalPositionRatio: 0.88,
      alignment: TextAlign.center,
      fontWeight: FontWeight.bold,
    );
  }

  /// Copy with modifications
  SubtitleStyleConfig copyWith({
    String? presetName,
    int? fontSizePercent,
    String? fontFamily,
    Color? textColor,
    SubtitleOutlineStyle? outlineStyle,
    SubtitleShadowStyle? shadowStyle,
    SubtitleBackgroundType? backgroundType,
    double? backgroundOpacity,
    double? cornerRadius,
    double? verticalPositionRatio,
    TextAlign? alignment,
    FontWeight? fontWeight,
    bool? isItalic,
    double? letterSpacing,
    double? lineSpacing,
    double? bottomMargin,
    double? horizontalMargin,
    bool? useSafeArea,
    bool? useEmbeddedStyling,
  }) {
    return SubtitleStyleConfig(
      presetName: presetName ?? 'Custom',
      fontSizePercent: fontSizePercent ?? this.fontSizePercent,
      fontFamily: fontFamily ?? this.fontFamily,
      textColor: textColor ?? this.textColor,
      outlineStyle: outlineStyle ?? this.outlineStyle,
      shadowStyle: shadowStyle ?? this.shadowStyle,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      verticalPositionRatio: verticalPositionRatio ?? this.verticalPositionRatio,
      alignment: alignment ?? this.alignment,
      fontWeight: fontWeight ?? this.fontWeight,
      isItalic: isItalic ?? this.isItalic,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      bottomMargin: bottomMargin ?? this.bottomMargin,
      horizontalMargin: horizontalMargin ?? this.horizontalMargin,
      useSafeArea: useSafeArea ?? this.useSafeArea,
      useEmbeddedStyling: useEmbeddedStyling ?? this.useEmbeddedStyling,
    );
  }
}
