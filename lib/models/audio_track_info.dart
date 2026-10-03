/// Represents an audio track within an indexed local video file
class AudioTrackInfo {
  final String id;
  final String language;
  final String title;
  final String codec;
  final String channels;
  final int bitrateKbps;
  final double sampleRateKhz;
  final bool isDefault;
  final String? specialLabel;
  final bool isSupported;
  final String? unsupportedReason;

  const AudioTrackInfo({
    required this.id,
    required this.language,
    required this.title,
    required this.codec,
    required this.channels,
    this.bitrateKbps = 640,
    this.sampleRateKhz = 48.0,
    this.isDefault = false,
    this.specialLabel,
    this.isSupported = true,
    this.unsupportedReason,
  });

  String get summaryLabel => '$language • $channels • $codec';

  String get technicalBitrateText => '$bitrateKbps kbps';

  String get sampleRateText => '${sampleRateKhz.toStringAsFixed(1)} kHz';

  /// Standard formatted metadata line (e.g. "5.1 • AC-3 • 640 kbps")
  String get metadataLine {
    if (bitrateKbps > 0) {
      return '$channels • $codec • $bitrateKbps kbps';
    }
    return '$channels • $codec';
  }

  /// User-facing display title incorporating language and track title
  String get displayTitle {
    if (title.isNotEmpty) {
      if (title.toLowerCase() == language.toLowerCase()) {
        return language;
      }
      if (title.toLowerCase().startsWith(language.toLowerCase())) {
        return title;
      }
      return '$language — $title';
    }
    return language;
  }

  AudioTrackInfo copyWith({
    String? id,
    String? language,
    String? title,
    String? codec,
    String? channels,
    int? bitrateKbps,
    double? sampleRateKhz,
    bool? isDefault,
    String? specialLabel,
    bool? isSupported,
    String? unsupportedReason,
  }) {
    return AudioTrackInfo(
      id: id ?? this.id,
      language: language ?? this.language,
      title: title ?? this.title,
      codec: codec ?? this.codec,
      channels: channels ?? this.channels,
      bitrateKbps: bitrateKbps ?? this.bitrateKbps,
      sampleRateKhz: sampleRateKhz ?? this.sampleRateKhz,
      isDefault: isDefault ?? this.isDefault,
      specialLabel: specialLabel ?? this.specialLabel,
      isSupported: isSupported ?? this.isSupported,
      unsupportedReason: unsupportedReason ?? this.unsupportedReason,
    );
  }
}
