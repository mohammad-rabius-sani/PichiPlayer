import 'package:flutter/material.dart';

/// Categories of subtitle sources in PIchiPlayer
enum SubtitleSource {
  embedded,
  externalFile,
  none,
}

/// Supported subtitle formats for offline rendering
enum SubtitleFormat {
  srt,
  ass,
  ssa,
  vtt,
  utf8,
  unknown,
}

/// Rich metadata model representing an offline subtitle track in PIchiPlayer.
/// Supports embedded tracks, auto-discovered companion files, and manually imported files.
class SubtitleTrackInfo {
  final String id;
  final String language;
  final String? languageCode;
  final SubtitleSource source;
  final SubtitleFormat format;
  final String formatLabel;
  final String? filePath;
  final bool isForced;
  final bool isSdh;
  final bool isCommentary;
  final bool isOff;

  const SubtitleTrackInfo({
    required this.id,
    required this.language,
    this.languageCode,
    this.source = SubtitleSource.embedded,
    this.format = SubtitleFormat.utf8,
    required this.formatLabel,
    this.filePath,
    this.isForced = false,
    this.isSdh = false,
    this.isCommentary = false,
    this.isOff = false,
  });

  /// Factory for the special "Off" state track
  factory SubtitleTrackInfo.off() {
    return const SubtitleTrackInfo(
      id: 'sub_off',
      language: 'Off',
      source: SubtitleSource.none,
      format: SubtitleFormat.unknown,
      formatLabel: 'None',
      isOff: true,
    );
  }

  /// Create from simple track string (e.g. from LocalVideo.subtitleTracks)
  factory SubtitleTrackInfo.fromString(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'none (off)' || lower == 'off' || lower == 'none' || lower == 'disabled') {
      return SubtitleTrackInfo.off();
    }

    final isForced = lower.contains('forced');
    final isSdh = lower.contains('sdh');
    final isCommentary = lower.contains('commentary');
    final isExternal = lower.contains('external') || lower.endsWith('.srt') || lower.endsWith('.ass') || lower.endsWith('.vtt');

    // Extract format
    SubtitleFormat format = SubtitleFormat.utf8;
    String formatLabel = 'UTF-8';
    if (lower.contains('ass') || lower.endsWith('.ass')) {
      format = SubtitleFormat.ass;
      formatLabel = 'ASS';
    } else if (lower.contains('ssa') || lower.endsWith('.ssa')) {
      format = SubtitleFormat.ssa;
      formatLabel = 'SSA';
    } else if (lower.contains('vtt') || lower.endsWith('.vtt')) {
      format = SubtitleFormat.vtt;
      formatLabel = 'VTT';
    } else if (lower.contains('srt') || lower.endsWith('.srt')) {
      format = SubtitleFormat.srt;
      formatLabel = 'SRT';
    } else if (raw.contains('Japanese')) {
      format = SubtitleFormat.vtt;
      formatLabel = 'VTT';
    }

    // Clean language name
    String cleanLang = raw
        .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
        .replaceAll(RegExp(r'\s*\[[^\]]*\]'), '')
        .replaceAll(RegExp(r'•.*'), '')
        .trim();

    cleanLang = normalizeLanguage(cleanLang);

    return SubtitleTrackInfo(
      id: 'sub_${raw.hashCode}',
      language: cleanLang,
      source: isExternal ? SubtitleSource.externalFile : SubtitleSource.embedded,
      format: format,
      formatLabel: formatLabel,
      isForced: isForced,
      isSdh: isSdh,
      isCommentary: isCommentary,
      isOff: false,
    );
  }

  /// Map common ISO language codes to readable full language names
  static String normalizeLanguage(String codeOrName) {
    final code = codeOrName.trim().toLowerCase();
    switch (code) {
      case 'en':
      case 'eng':
        return 'English';
      case 'bn':
      case 'ben':
        return 'Bengali';
      case 'ja':
      case 'jpn':
        return 'Japanese';
      case 'es':
      case 'spa':
        return 'Spanish';
      case 'fr':
      case 'fra':
      case 'fre':
        return 'French';
      case 'de':
      case 'deu':
      case 'ger':
        return 'German';
      case 'ko':
      case 'kor':
        return 'Korean';
      case 'zh':
      case 'zho':
      case 'chi':
        return 'Chinese';
      case 'hi':
      case 'hin':
        return 'Hindi';
      case 'ar':
      case 'ara':
        return 'Arabic';
      case 'pt':
      case 'por':
        return 'Portuguese';
      case 'ru':
      case 'rus':
        return 'Russian';
      case 'it':
      case 'ita':
        return 'Italian';
      case 'tr':
      case 'tur':
        return 'Turkish';
      case 'vi':
      case 'vie':
        return 'Vietnamese';
      default:
        // Capitalize first letter if needed
        if (codeOrName.isNotEmpty) {
          return codeOrName[0].toUpperCase() + codeOrName.substring(1);
        }
        return codeOrName;
    }
  }

  /// Compact metadata string displayed below track name
  /// e.g. "Embedded • UTF-8", "Embedded • ASS", "External • SRT"
  String get metadataLine {
    if (isOff) return 'Disable subtitles';

    final sourcePrefix = source == SubtitleSource.embedded ? 'Embedded' : 'External';
    final parts = <String>['$sourcePrefix • $formatLabel'];

    if (isForced) parts.add('Forced');
    if (isSdh) parts.add('SDH');
    if (isCommentary) parts.add('Commentary');

    return parts.join(' • ');
  }

  /// Icon representation based on state
  IconData get icon {
    if (isOff) return Icons.subtitles_off_rounded;
    if (source == SubtitleSource.externalFile) return Icons.insert_drive_file_rounded;
    return Icons.subtitles_rounded;
  }
}
