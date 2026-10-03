/// Storage volume type
enum StorageType {
  internal,
  sdCard,
}

/// Represents an offline storage volume containing local video media
class StorageSource {
  final String id;
  final String name;
  final StorageType type;
  final int videoCount;
  final int totalVideoBytes;
  final double videoStorageRatio; // Ratio for the progress indicator (0.0 to 1.0)
  final bool isAvailable;

  const StorageSource({
    required this.id,
    required this.name,
    required this.type,
    required this.videoCount,
    required this.totalVideoBytes,
    this.videoStorageRatio = 0.35,
    this.isAvailable = true,
  });

  /// Formatted video count, e.g. "1,024 videos"
  String get formattedVideoCount {
    if (videoCount >= 1000) {
      final thousands = videoCount ~/ 1000;
      final remainder = videoCount % 1000;
      return '$thousands,${remainder.toString().padLeft(3, '0')} videos';
    }
    return '$videoCount ${videoCount == 1 ? "video" : "videos"}';
  }

  /// Formatted footprint, e.g. "42 GB used by videos"
  String get formattedUsage {
    final gb = totalVideoBytes / (1024 * 1024 * 1024);
    if (gb >= 1.0) {
      return '${gb.toStringAsFixed(0)} GB used by videos';
    }
    final mb = totalVideoBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB used by videos';
  }

  StorageSource copyWith({
    String? id,
    String? name,
    StorageType? type,
    int? videoCount,
    int? totalVideoBytes,
    double? videoStorageRatio,
    bool? isAvailable,
  }) {
    return StorageSource(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      videoCount: videoCount ?? this.videoCount,
      totalVideoBytes: totalVideoBytes ?? this.totalVideoBytes,
      videoStorageRatio: videoStorageRatio ?? this.videoStorageRatio,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
