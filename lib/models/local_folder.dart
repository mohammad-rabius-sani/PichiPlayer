import 'package:flutter/material.dart';
import 'local_video.dart';

/// Represents a physical/local folder indexed by PIchiPlayer
class LocalFolder {
  final String id;
  final String name;
  final String path;
  final int videoCount;
  final int totalSizeBytes;
  final bool isSdCard;
  final bool isHidden;
  final bool hasPermission;
  final List<LocalVideo> previewVideos;
  final IconData? customIcon;

  const LocalFolder({
    required this.id,
    required this.name,
    required this.path,
    required this.videoCount,
    required this.totalSizeBytes,
    this.isSdCard = false,
    this.isHidden = false,
    this.hasPermission = true,
    this.previewVideos = const [],
    this.customIcon,
  });

  /// Human-readable video count label, e.g. "245 videos" or "1 video"
  String get formattedVideoCount {
    if (videoCount == 1) return '1 video';
    return '$videoCount videos';
  }

  /// Human-readable storage size
  String get formattedSize {
    if (totalSizeBytes <= 0) return '0 B';
    final gb = totalSizeBytes / (1024 * 1024 * 1024);
    if (gb >= 1.0) {
      return '${gb.toStringAsFixed(1)} GB';
    }
    final mb = totalSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }

  /// Compact metadata subtitle, e.g. "245 videos • 18.7 GB"
  String get metadataSummary {
    return '$formattedVideoCount • $formattedSize';
  }

  LocalFolder copyWith({
    String? id,
    String? name,
    String? path,
    int? videoCount,
    int? totalSizeBytes,
    bool? isSdCard,
    bool? isHidden,
    bool? hasPermission,
    List<LocalVideo>? previewVideos,
    IconData? customIcon,
  }) {
    return LocalFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      videoCount: videoCount ?? this.videoCount,
      totalSizeBytes: totalSizeBytes ?? this.totalSizeBytes,
      isSdCard: isSdCard ?? this.isSdCard,
      isHidden: isHidden ?? this.isHidden,
      hasPermission: hasPermission ?? this.hasPermission,
      previewVideos: previewVideos ?? this.previewVideos,
      customIcon: customIcon ?? this.customIcon,
    );
  }
}
