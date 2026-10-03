import 'package:flutter/material.dart';
import 'audio_track_info.dart';

/// Data model representing a local offline video file on the device.
class LocalVideo {
  final String id;
  final String title;
  final String? fileName;
  final Duration duration;
  final Duration? lastPosition;
  final String resolution; // "4K", "1080p", "720p"
  final String codec; // "HEVC", "H.264", "AV1"
  final double? fps; // 23.976, 59.94, 60, 120
  final bool isHdr;
  final bool isFavorite;
  final int fileSizeBytes;
  final String folderPath;
  final DateTime dateAdded;
  final DateTime? dateModified;

  // Technical metadata
  final double? bitrateMbps;
  final List<AudioTrackInfo> audioTracks;
  final List<String> subtitleTracks;
  final String? containerFormat;
  final String? dimensionPixels;
  final bool isMissing;
  final bool isUnsupported;

  // High-fidelity cinematic theme styling for offline thumbnail generation
  final Color gradientStart;
  final Color gradientEnd;
  final IconData visualIcon;

  const LocalVideo({
    required this.id,
    required this.title,
    this.fileName,
    required this.duration,
    this.lastPosition,
    required this.resolution,
    required this.codec,
    this.fps,
    this.isHdr = false,
    this.isFavorite = false,
    required this.fileSizeBytes,
    required this.folderPath,
    required this.dateAdded,
    this.dateModified,
    this.bitrateMbps,
    this.audioTracks = const [],
    this.subtitleTracks = const [],
    this.containerFormat,
    this.dimensionPixels,
    this.isMissing = false,
    this.isUnsupported = false,
    required this.gradientStart,
    required this.gradientEnd,
    this.visualIcon = Icons.movie_filter_rounded,
  });

  /// Display filename e.g. "Interstellar.mkv"
  String get displayFileName => fileName ?? '$title.mkv';

  /// True if video has a saved watched position
  bool get isPartiallyWatched =>
      lastPosition != null &&
      lastPosition!.inSeconds > 0 &&
      lastPosition! < duration;

  /// True if never watched
  bool get isUnwatched => lastPosition == null || lastPosition!.inSeconds == 0;

  /// Effective date modified
  DateTime get effectiveDateModified => dateModified ?? dateAdded;

  /// Progress ratio from 0.0 to 1.0
  double get progressRatio {
    if (duration.inMilliseconds == 0 || lastPosition == null) return 0.0;
    return (lastPosition!.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Compact duration string e.g. "2h 49m" or "14m 22s"
  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  /// Exact position formatting e.g. "1:12:16" or "04:12"
  String _formatTimestamp(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      final mStr = minutes.toString().padLeft(2, '0');
      final sStr = seconds.toString().padLeft(2, '0');
      return '$hours:$mStr:$sStr';
    } else {
      final sStr = seconds.toString().padLeft(2, '0');
      return '$minutes:$sStr';
    }
  }

  /// Exact progress text e.g. "1:12:16 / 2:49:22"
  String get progressText {
    if (lastPosition == null) return _formatTimestamp(duration);
    return '${_formatTimestamp(lastPosition!)} / ${_formatTimestamp(duration)}';
  }

  /// Formatted FPS string, e.g. "60" or "59.94"
  String get fpsFormatted {
    if (fps == null) return '';
    return fps! == fps!.roundToDouble() ? '${fps!.toInt()}' : '$fps';
  }

  /// Hero metadata string e.g. "2h 49m • 4K • HEVC"
  String get heroMetadataText {
    final parts = <String>[durationFormatted, resolution, codec];
    if (fps != null && fps! >= 60) {
      parts.add('${fpsFormatted}fps');
    }
    return parts.join(' • ');
  }

  /// Quick summary line below title: e.g. "2h 49m • 4K UHD • HEVC"
  String get quickSummaryText {
    final resLabel = resolution == '4K' ? '4K UHD' : resolution;
    return '$durationFormatted • $resLabel • $codec';
  }

  /// Container format e.g. "MKV"
  String get effectiveContainer {
    if (containerFormat != null) return containerFormat!;
    if (displayFileName.toLowerCase().endsWith('.mp4')) return 'MP4';
    return 'MKV';
  }

  /// Pixel dimensions e.g. "3840 × 2160"
  String get effectiveDimensions {
    if (dimensionPixels != null) return dimensionPixels!;
    if (resolution == '4K') return '3840 × 2160';
    if (resolution == '1080p') return '1920 × 1080';
    if (resolution == '720p') return '1280 × 720';
    return '3840 × 2160';
  }

  /// Extracted or deduced pixel width
  int get pixelWidth {
    if (resolution == '4K') return 3840;
    if (resolution == '1080p') return 1920;
    if (resolution == '720p') return 1280;
    return 1920;
  }

  /// Extracted or deduced pixel height
  int get pixelHeight {
    if (resolution == '4K') return 2160;
    if (resolution == '1080p') return 1080;
    if (resolution == '720p') return 720;
    return 1080;
  }

  /// Effective Bitrate e.g. 24.8 Mbps
  double get effectiveBitrateMbps {
    if (bitrateMbps != null) return bitrateMbps!;
    if (duration.inSeconds > 0) {
      final calculated = (fileSizeBytes * 8.0) / duration.inSeconds / 1000000.0;
      return double.parse(calculated.toStringAsFixed(1));
    }
    return 18.4;
  }

  /// Effective Audio Tracks
  List<AudioTrackInfo> get effectiveAudioTracks {
    if (audioTracks.isNotEmpty) return audioTracks;
    return [
      AudioTrackInfo(
        id: 'audio_01',
        language: 'English',
        title: 'English',
        codec: codec == 'HEVC' ? 'AC-3' : 'E-AC3',
        channels: '5.1',
        bitrateKbps: 640,
        sampleRateKhz: 48.0,
        isDefault: true,
        specialLabel: 'Main',
      ),
      const AudioTrackInfo(
        id: 'audio_02',
        language: 'Bengali',
        title: 'Bengali',
        codec: 'AAC',
        channels: '2.0',
        bitrateKbps: 192,
        sampleRateKhz: 48.0,
        isDefault: false,
        specialLabel: 'Dub',
      ),
      const AudioTrackInfo(
        id: 'audio_03',
        language: 'Japanese',
        title: 'Japanese',
        codec: 'E-AC3',
        channels: '5.1',
        bitrateKbps: 448,
        sampleRateKhz: 48.0,
        isDefault: false,
        specialLabel: 'Alternate',
      ),
      const AudioTrackInfo(
        id: 'audio_04',
        language: 'English',
        title: 'English',
        codec: 'AAC',
        channels: '2.0',
        bitrateKbps: 160,
        sampleRateKhz: 48.0,
        isDefault: false,
        specialLabel: 'Commentary',
      ),
    ];
  }

  /// Effective Subtitles
  List<String> get effectiveSubtitleTracks {
    if (subtitleTracks.isNotEmpty) return subtitleTracks;
    return const ['English', 'Spanish', 'French', 'None (Off)'];
  }

  /// Dynamic Range label
  String get dynamicRangeText => isHdr ? 'HDR' : 'SDR';

  /// Full absolute device path
  String get fullDevicePath => '/storage/emulated/0/$folderPath$displayFileName';

  /// Compact metadata string for grid/list e.g. "4K • HEVC"
  String get compactMetadataText => '$resolution • $codec';

  /// List metadata line e.g. "2:49:22 • 4K • HEVC • 18.4 GB"
  String get listMetadataText =>
      '${_formatTimestamp(duration)} • $resolution • $codec • $fileSizeFormatted';

  /// Formatted file size e.g. "18.4 GB"
  String get fileSizeFormatted {
    if (fileSizeBytes >= 1024 * 1024 * 1024) {
      final gb = fileSizeBytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(1)} GB';
    }
    final mb = fileSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }

  LocalVideo copyWith({
    String? title,
    String? fileName,
    Duration? duration,
    Duration? lastPosition,
    String? resolution,
    String? codec,
    double? fps,
    bool? isHdr,
    bool? isFavorite,
    int? fileSizeBytes,
    String? folderPath,
    DateTime? dateAdded,
    DateTime? dateModified,
    double? bitrateMbps,
    List<AudioTrackInfo>? audioTracks,
    List<String>? subtitleTracks,
    String? containerFormat,
    String? dimensionPixels,
    bool? isMissing,
    bool? isUnsupported,
    Color? gradientStart,
    Color? gradientEnd,
    IconData? visualIcon,
  }) {
    return LocalVideo(
      id: id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      duration: duration ?? this.duration,
      lastPosition: lastPosition ?? this.lastPosition,
      resolution: resolution ?? this.resolution,
      codec: codec ?? this.codec,
      fps: fps ?? this.fps,
      isHdr: isHdr ?? this.isHdr,
      isFavorite: isFavorite ?? this.isFavorite,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      folderPath: folderPath ?? this.folderPath,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      bitrateMbps: bitrateMbps ?? this.bitrateMbps,
      audioTracks: audioTracks ?? this.audioTracks,
      subtitleTracks: subtitleTracks ?? this.subtitleTracks,
      containerFormat: containerFormat ?? this.containerFormat,
      dimensionPixels: dimensionPixels ?? this.dimensionPixels,
      isMissing: isMissing ?? this.isMissing,
      isUnsupported: isUnsupported ?? this.isUnsupported,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      visualIcon: visualIcon ?? this.visualIcon,
    );
  }
}
