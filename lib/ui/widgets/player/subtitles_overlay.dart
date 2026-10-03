import 'package:flutter/material.dart';
import '../../../models/subtitle_style_config.dart';

/// Renders subtitles over the video with high legibility, clean styling,
/// and responsive vertical positioning based on controls visibility.
class SubtitlesOverlay extends StatelessWidget {
  final String activeSubtitleTrack;
  final bool controlsVisible;
  final Duration currentPosition;
  final SubtitleStyleConfig? styleConfig;

  const SubtitlesOverlay({
    super.key,
    required this.activeSubtitleTrack,
    required this.controlsVisible,
    required this.currentPosition,
    this.styleConfig,
  });

  bool get _isOff =>
      activeSubtitleTrack.toLowerCase() == 'off' ||
      activeSubtitleTrack.toLowerCase().contains('none');

  /// Dynamic dialogue simulation based on playback timestamp
  String _getCurrentDialogue() {
    if (_isOff) return '';
    final seconds = currentPosition.inSeconds % 45;

    if (seconds >= 0 && seconds <= 8) {
      if (activeSubtitleTrack == 'Bengali') {
        return 'মহাবিশ্বের সীমানা ছাড়িয়ে আমাদের গন্তব্য।';
      } else if (activeSubtitleTrack == 'Japanese') {
        return '人類の次のステップは、星々の彼方にある。';
      }
      return 'Mankind was born on Earth. It was never meant to die here.';
    } else if (seconds >= 9 && seconds <= 18) {
      if (activeSubtitleTrack == 'Bengali') {
        return 'সময় এখন সবচেয়ে মূল্যবান সম্পদ।';
      } else if (activeSubtitleTrack == 'Japanese') {
        return '時間は今や最も貴重な資源だ。';
      }
      return 'Time is relative, okay? It can stretch and it can squeeze.';
    } else if (seconds >= 19 && seconds <= 28) {
      if (activeSubtitleTrack == 'Bengali') {
        return 'ভালোবাসা একমাত্র জিনিস যা স্থান এবং কাল অতিক্রম করতে পারে।';
      } else if (activeSubtitleTrack == 'Japanese') {
        return '愛だけが時間と空間を超越できる。';
      }
      return 'Love is the one thing that transcends dimensions of time and space.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (_isOff) return const SizedBox.shrink();

    final text = _getCurrentDialogue();
    if (text.isEmpty) return const SizedBox.shrink();

    final config = styleConfig ?? SubtitleStyleConfig.modern();

    // Smoothly lift subtitles above bottom controls when they appear
    final baseBottom = controlsVisible ? (116.0 + (config.bottomMargin - 24.0).clamp(0.0, 50.0)) : config.bottomMargin;

    final alignX = config.alignment == TextAlign.left
        ? -0.85
        : (config.alignment == TextAlign.right ? 0.85 : 0.0);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      left: config.horizontalMargin,
      right: config.horizontalMargin,
      bottom: baseBottom,
      child: Align(
        alignment: Alignment(alignX, 0.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: config.effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(config.cornerRadius),
          ),
          child: Text(
            text,
            textAlign: config.alignment,
            style: TextStyle(
              color: config.textColor,
              fontSize: config.fontSizeSp,
              fontWeight: config.fontWeight,
              fontStyle: config.isItalic ? FontStyle.italic : FontStyle.normal,
              fontFamily: config.fontFamily == 'Serif'
                  ? 'serif'
                  : (config.fontFamily == 'Monospace' ? 'monospace' : null),
              letterSpacing: config.letterSpacing,
              height: config.lineSpacing,
              shadows: config.effectiveShadows,
            ),
          ),
        ),
      ),
    );
  }
}
