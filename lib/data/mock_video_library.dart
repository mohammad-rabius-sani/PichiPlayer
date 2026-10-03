import 'package:flutter/material.dart';
import '../models/local_video.dart';

/// Curated offline media repository providing sample local video library items.
class MockVideoLibrary {
  MockVideoLibrary._();

  static List<LocalVideo> get sampleVideos => [
    // 1. Interstellar
    LocalVideo(
      id: 'vid_01',
      title: 'Interstellar',
      fileName: 'Interstellar.mkv',
      duration: const Duration(hours: 2, minutes: 49, seconds: 22),
      lastPosition: const Duration(hours: 1, minutes: 12, seconds: 16),
      resolution: '4K',
      codec: 'HEVC',
      fps: 60,
      isHdr: true,
      isFavorite: true,
      fileSizeBytes: (18.4 * 1024 * 1024 * 1024).toInt(), // 18.4 GB
      folderPath: 'Movies/Sci-Fi/',
      dateAdded: DateTime.now().subtract(const Duration(days: 2)),
      dateModified: DateTime.now().subtract(const Duration(days: 2)),
      gradientStart: const Color(0xFF0F2042),
      gradientEnd: const Color(0xFF0A0F1D),
      visualIcon: Icons.rocket_launch_rounded,
    ),

    // 2. The Batman
    LocalVideo(
      id: 'vid_02',
      title: 'The Batman',
      fileName: 'The Batman.mkv',
      duration: const Duration(hours: 2, minutes: 56, seconds: 12),
      resolution: '4K',
      codec: 'HEVC',
      fps: 60,
      isHdr: false,
      isFavorite: true,
      fileSizeBytes: (16.2 * 1024 * 1024 * 1024).toInt(), // 16.2 GB
      folderPath: 'Movies/Action/',
      dateAdded: DateTime.now().subtract(const Duration(days: 1)),
      dateModified: DateTime.now().subtract(const Duration(days: 1)),
      gradientStart: const Color(0xFF221319),
      gradientEnd: const Color(0xFF0C0709),
      visualIcon: Icons.shield_rounded,
    ),

    // 3. Dune Part Two
    LocalVideo(
      id: 'vid_03',
      title: 'Dune Part Two',
      fileName: 'Dune Part Two.mkv',
      duration: const Duration(hours: 2, minutes: 46, seconds: 0),
      lastPosition: const Duration(hours: 2, minutes: 10, seconds: 0),
      resolution: '4K',
      codec: 'AV1',
      fps: 60,
      isHdr: true,
      isFavorite: true,
      fileSizeBytes: (14.6 * 1024 * 1024 * 1024).toInt(), // 14.6 GB
      folderPath: 'Movies/Action/',
      dateAdded: DateTime.now().subtract(const Duration(days: 3)),
      dateModified: DateTime.now().subtract(const Duration(days: 3)),
      gradientStart: const Color(0xFF332008),
      gradientEnd: const Color(0xFF0D0B12),
      visualIcon: Icons.terrain_rounded,
    ),

    // 4. Avengers Endgame
    LocalVideo(
      id: 'vid_04',
      title: 'Avengers Endgame',
      fileName: 'Avengers Endgame.mkv',
      duration: const Duration(hours: 3, minutes: 1, seconds: 12),
      resolution: '1080p',
      codec: 'H.264',
      isHdr: false,
      isFavorite: false,
      fileSizeBytes: (11.2 * 1024 * 1024 * 1024).toInt(), // 11.2 GB
      folderPath: 'Movies/Action/',
      dateAdded: DateTime.now().subtract(const Duration(days: 12)),
      dateModified: DateTime.now().subtract(const Duration(days: 12)),
      gradientStart: const Color(0xFF1B1A3F),
      gradientEnd: const Color(0xFF090A14),
      visualIcon: Icons.bolt_rounded,
    ),

    // 5. Blade Runner 2049
    LocalVideo(
      id: 'vid_05',
      title: 'Blade Runner 2049',
      fileName: 'Blade Runner 2049.mkv',
      duration: const Duration(hours: 2, minutes: 44, seconds: 0),
      lastPosition: const Duration(minutes: 45, seconds: 10),
      resolution: '4K',
      codec: 'HEVC',
      isHdr: true,
      isFavorite: false,
      fileSizeBytes: (11.0 * 1024 * 1024 * 1024).toInt(),
      folderPath: 'Movies/Sci-Fi/',
      dateAdded: DateTime.now().subtract(const Duration(days: 5)),
      dateModified: DateTime.now().subtract(const Duration(days: 5)),
      gradientStart: const Color(0xFF1E1138),
      gradientEnd: const Color(0xFF090A15),
      visualIcon: Icons.memory_rounded,
    ),

    // 6. Oppenheimer
    LocalVideo(
      id: 'vid_06',
      title: 'Oppenheimer',
      fileName: 'Oppenheimer.mkv',
      duration: const Duration(hours: 3, minutes: 0, seconds: 9),
      resolution: '4K',
      codec: 'HEVC',
      isHdr: true,
      isFavorite: true,
      fileSizeBytes: (16.0 * 1024 * 1024 * 1024).toInt(),
      folderPath: 'Movies/Drama/',
      dateAdded: DateTime.now().subtract(const Duration(hours: 8)),
      dateModified: DateTime.now().subtract(const Duration(hours: 8)),
      gradientStart: const Color(0xFF2B1015),
      gradientEnd: const Color(0xFF09060B),
      visualIcon: Icons.flare_rounded,
    ),

    // 7. Spider-Man: Across the Spider-Verse
    LocalVideo(
      id: 'vid_07',
      title: 'Spider-Man Across the Spider-Verse',
      fileName: 'Spider-Man Across the Spider-Verse.mkv',
      duration: const Duration(hours: 2, minutes: 20, seconds: 35),
      resolution: '1080p',
      codec: 'H.264',
      isFavorite: false,
      fileSizeBytes: (5.2 * 1024 * 1024 * 1024).toInt(),
      folderPath: 'Movies/Animation/',
      dateAdded: DateTime.now().subtract(const Duration(hours: 18)),
      dateModified: DateTime.now().subtract(const Duration(hours: 18)),
      gradientStart: const Color(0xFF1F1142),
      gradientEnd: const Color(0xFF080C1E),
      visualIcon: Icons.auto_awesome_rounded,
    ),

    // 8. Planet Earth III - Deserts
    LocalVideo(
      id: 'vid_08',
      title: 'Planet Earth III - Deserts',
      fileName: 'Planet Earth III - Deserts.mkv',
      duration: const Duration(minutes: 58, seconds: 40),
      resolution: '4K',
      codec: 'HEVC',
      fps: 60,
      isHdr: true,
      isFavorite: false,
      fileSizeBytes: (8.4 * 1024 * 1024 * 1024).toInt(),
      folderPath: 'Movies/Documentaries/',
      dateAdded: DateTime.now().subtract(const Duration(days: 7)),
      dateModified: DateTime.now().subtract(const Duration(days: 7)),
      gradientStart: const Color(0xFF261D0C),
      gradientEnd: const Color(0xFF080D1A),
      visualIcon: Icons.public_rounded,
    ),

    // 9. Top Gun: Maverick
    LocalVideo(
      id: 'vid_09',
      title: 'Top Gun Maverick',
      fileName: 'Top Gun Maverick.mkv',
      duration: const Duration(hours: 2, minutes: 10, seconds: 45),
      resolution: '4K',
      codec: 'HEVC',
      fps: 60,
      isHdr: true,
      isFavorite: true,
      fileSizeBytes: (12.5 * 1024 * 1024 * 1024).toInt(),
      folderPath: 'Movies/Action/',
      dateAdded: DateTime.now().subtract(const Duration(days: 10)),
      dateModified: DateTime.now().subtract(const Duration(days: 10)),
      gradientStart: const Color(0xFF142035),
      gradientEnd: const Color(0xFF070B14),
      visualIcon: Icons.flight_takeoff_rounded,
    ),

    // 10. Family Vacation 2026
    LocalVideo(
      id: 'vid_10',
      title: 'Family Vacation 2026',
      fileName: 'Family Vacation 2026.mp4',
      duration: const Duration(minutes: 14, seconds: 22),
      resolution: '1080p',
      codec: 'H.264',
      fps: 60,
      isFavorite: false,
      fileSizeBytes: 950 * 1024 * 1024,
      folderPath: 'DCIM/Camera/',
      dateAdded: DateTime.now().subtract(const Duration(days: 1)),
      dateModified: DateTime.now().subtract(const Duration(days: 1)),
      gradientStart: const Color(0xFF0A2E2C),
      gradientEnd: const Color(0xFF051318),
      visualIcon: Icons.videocam_rounded,
    ),

    // 11. Drone Mountain Footage
    LocalVideo(
      id: 'vid_11',
      title: 'Drone Mountain Cinematic',
      fileName: 'Drone Mountain Footage.mp4',
      duration: const Duration(minutes: 8, seconds: 45),
      resolution: '4K',
      codec: 'HEVC',
      fps: 60,
      isHdr: true,
      isFavorite: false,
      fileSizeBytes: (2.1 * 1024 * 1024 * 1024).toInt(),
      folderPath: 'DCIM/ScreenRecorder/',
      dateAdded: DateTime.now().subtract(const Duration(days: 4)),
      dateModified: DateTime.now().subtract(const Duration(days: 4)),
      gradientStart: const Color(0xFF102830),
      gradientEnd: const Color(0xFF061017),
      visualIcon: Icons.landscape_rounded,
    ),
  ];

  /// Get the featured hero video: prioritize partially watched, otherwise most recent
  static LocalVideo getFeaturedVideo(List<LocalVideo> videos) {
    if (videos.isEmpty) {
      throw StateError('Cannot get featured video from empty library');
    }
    final continueVideos = videos.where((v) => v.isPartiallyWatched).toList();
    if (continueVideos.isNotEmpty) {
      return continueVideos.first;
    }
    return videos.first;
  }

  /// Get videos for Continue Watching row
  static List<LocalVideo> getContinueWatchingVideos(List<LocalVideo> videos) {
    return videos.where((v) => v.isPartiallyWatched).toList();
  }

  /// Get videos for Recently Added row
  static List<LocalVideo> getRecentlyAddedVideos(List<LocalVideo> videos) {
    final list = List<LocalVideo>.from(videos);
    list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return list;
  }

  /// Get 4K and High Quality collection
  static List<LocalVideo> getHighQualityVideos(List<LocalVideo> videos) {
    return videos
        .where((v) => v.resolution == '4K' || v.isHdr || (v.fps != null && v.fps! >= 60))
        .toList();
  }
}
