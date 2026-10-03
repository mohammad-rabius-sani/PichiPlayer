import 'player_types.dart';

/// Central application preferences and configuration state for PIchiPlayer.
///
/// 100% offline, local-first settings model supporting playback, appearance,
/// subtitles, library scanning, background & PiP, and storage management.
class AppPreferences {
  // Playback
  final bool resumePlayback;
  final bool autoPlayNext;
  final double defaultSpeed;
  final PlayerOrientationMode defaultOrientation;
  final int doubleTapSeekSeconds;
  final bool hardwareDecoding;

  // Appearance
  final String themeMode;
  final String accentColorName;
  final String uiDensity;
  final bool enableGlowEffects;

  // Subtitles
  final String preferredLanguage;
  final String subtitleStyleName;
  final bool externalSubtitlesEnabled;
  final bool autoSelectSubtitles;

  // Library
  final bool autoScanLibrary;
  final bool showHiddenFolders;
  final int scannedFolderCount;
  final int excludedFolderCount;

  // Background & PiP
  final bool backgroundPlayback;
  final bool pictureInPicture;
  final bool autoEnterPip;
  final LeavingAppBehavior leavingAppBehavior;
  final bool showMediaControls;
  final bool showMediaNotification;

  // Storage & Cache
  final bool hasInternalStoragePermission;
  final bool hasSdCardPermission;
  final bool sdCardDetected;
  final int foldersNeedingAccessCount;
  final int thumbnailCacheSizeBytes;
  final int playbackHistoryCount;

  const AppPreferences({
    this.resumePlayback = true,
    this.autoPlayNext = true,
    this.defaultSpeed = 1.0,
    this.defaultOrientation = PlayerOrientationMode.auto,
    this.doubleTapSeekSeconds = 10,
    this.hardwareDecoding = true,
    this.themeMode = 'Dark Cinematic',
    this.accentColorName = 'Electric Blue',
    this.uiDensity = 'Comfortable',
    this.enableGlowEffects = true,
    this.preferredLanguage = 'Auto',
    this.subtitleStyleName = 'Cinema',
    this.externalSubtitlesEnabled = true,
    this.autoSelectSubtitles = true,
    this.autoScanLibrary = true,
    this.showHiddenFolders = false,
    this.scannedFolderCount = 4,
    this.excludedFolderCount = 1,
    this.backgroundPlayback = true,
    this.pictureInPicture = true,
    this.autoEnterPip = false,
    this.leavingAppBehavior = LeavingAppBehavior.openPip,
    this.showMediaControls = true,
    this.showMediaNotification = true,
    this.hasInternalStoragePermission = true,
    this.hasSdCardPermission = true,
    this.sdCardDetected = true,
    this.foldersNeedingAccessCount = 0,
    this.thumbnailCacheSizeBytes = 48 * 1024 * 1024, // 48 MB
    this.playbackHistoryCount = 18,
  });

  /// Factory for clean default configuration
  factory AppPreferences.defaults() => const AppPreferences();

  String get formattedThumbnailCacheSize {
    if (thumbnailCacheSizeBytes <= 0) return '0 MB';
    final mb = thumbnailCacheSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get formattedSpeed {
    if (defaultSpeed == 1.0) return '1×';
    final s = defaultSpeed.toStringAsFixed(2);
    final clean = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return '$clean×';
  }

  AppPreferences copyWith({
    bool? resumePlayback,
    bool? autoPlayNext,
    double? defaultSpeed,
    PlayerOrientationMode? defaultOrientation,
    int? doubleTapSeekSeconds,
    bool? hardwareDecoding,
    String? themeMode,
    String? accentColorName,
    String? uiDensity,
    bool? enableGlowEffects,
    String? preferredLanguage,
    String? subtitleStyleName,
    bool? externalSubtitlesEnabled,
    bool? autoSelectSubtitles,
    bool? autoScanLibrary,
    bool? showHiddenFolders,
    int? scannedFolderCount,
    int? excludedFolderCount,
    bool? backgroundPlayback,
    bool? pictureInPicture,
    bool? autoEnterPip,
    LeavingAppBehavior? leavingAppBehavior,
    bool? showMediaControls,
    bool? showMediaNotification,
    bool? hasInternalStoragePermission,
    bool? hasSdCardPermission,
    bool? sdCardDetected,
    int? foldersNeedingAccessCount,
    int? thumbnailCacheSizeBytes,
    int? playbackHistoryCount,
  }) {
    return AppPreferences(
      resumePlayback: resumePlayback ?? this.resumePlayback,
      autoPlayNext: autoPlayNext ?? this.autoPlayNext,
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
      defaultOrientation: defaultOrientation ?? this.defaultOrientation,
      doubleTapSeekSeconds: doubleTapSeekSeconds ?? this.doubleTapSeekSeconds,
      hardwareDecoding: hardwareDecoding ?? this.hardwareDecoding,
      themeMode: themeMode ?? this.themeMode,
      accentColorName: accentColorName ?? this.accentColorName,
      uiDensity: uiDensity ?? this.uiDensity,
      enableGlowEffects: enableGlowEffects ?? this.enableGlowEffects,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      subtitleStyleName: subtitleStyleName ?? this.subtitleStyleName,
      externalSubtitlesEnabled:
          externalSubtitlesEnabled ?? this.externalSubtitlesEnabled,
      autoSelectSubtitles: autoSelectSubtitles ?? this.autoSelectSubtitles,
      autoScanLibrary: autoScanLibrary ?? this.autoScanLibrary,
      showHiddenFolders: showHiddenFolders ?? this.showHiddenFolders,
      scannedFolderCount: scannedFolderCount ?? this.scannedFolderCount,
      excludedFolderCount: excludedFolderCount ?? this.excludedFolderCount,
      backgroundPlayback: backgroundPlayback ?? this.backgroundPlayback,
      pictureInPicture: pictureInPicture ?? this.pictureInPicture,
      autoEnterPip: autoEnterPip ?? this.autoEnterPip,
      leavingAppBehavior: leavingAppBehavior ?? this.leavingAppBehavior,
      showMediaControls: showMediaControls ?? this.showMediaControls,
      showMediaNotification:
          showMediaNotification ?? this.showMediaNotification,
      hasInternalStoragePermission:
          hasInternalStoragePermission ?? this.hasInternalStoragePermission,
      hasSdCardPermission: hasSdCardPermission ?? this.hasSdCardPermission,
      sdCardDetected: sdCardDetected ?? this.sdCardDetected,
      foldersNeedingAccessCount:
          foldersNeedingAccessCount ?? this.foldersNeedingAccessCount,
      thumbnailCacheSizeBytes:
          thumbnailCacheSizeBytes ?? this.thumbnailCacheSizeBytes,
      playbackHistoryCount: playbackHistoryCount ?? this.playbackHistoryCount,
    );
  }
}
