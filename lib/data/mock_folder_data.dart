import 'package:flutter/material.dart';
import '../models/local_folder.dart';
import '../models/local_video.dart';
import '../models/storage_source.dart';
import 'mock_video_library.dart';

/// Provides curated realistic mock data for PIchiPlayer folders and storage volumes
class MockFolderData {
  MockFolderData._();

  static List<StorageSource> get sampleStorageSources => [
    const StorageSource(
      id: 'storage_internal',
      name: 'Internal Storage',
      type: StorageType.internal,
      videoCount: 1024,
      totalVideoBytes: 42 * 1024 * 1024 * 1024, // 42 GB
      videoStorageRatio: 0.38,
      isAvailable: true,
    ),
    const StorageSource(
      id: 'storage_sdcard',
      name: 'SD Card',
      type: StorageType.sdCard,
      videoCount: 384,
      totalVideoBytes: 18 * 1024 * 1024 * 1024, // 18 GB
      videoStorageRatio: 0.24,
      isAvailable: true,
    ),
  ];

  static List<LocalFolder> get sampleFolders {
    final allVideos = MockVideoLibrary.sampleVideos;

    // Filter preview videos for Movies
    final movieVideos = allVideos
        .where((v) => v.folderPath.contains('Movies'))
        .toList();

    // Filter preview videos for Camera
    final cameraVideos = allVideos
        .where((v) => v.folderPath.contains('DCIM'))
        .toList();

    return [
      LocalFolder(
        id: 'folder_movies',
        name: 'Movies',
        path: '/storage/emulated/0/Movies',
        videoCount: 245,
        totalSizeBytes: (18.7 * 1024 * 1024 * 1024).toInt(),
        previewVideos: movieVideos.isNotEmpty
            ? movieVideos.take(3).toList()
            : allVideos.take(3).toList(),
        customIcon: Icons.movie_filter_rounded,
      ),
      LocalFolder(
        id: 'folder_downloads',
        name: 'Downloads',
        path: '/storage/emulated/0/Download',
        videoCount: 186,
        totalSizeBytes: (14.2 * 1024 * 1024 * 1024).toInt(),
        previewVideos: allVideos.skip(2).take(3).toList(),
        customIcon: Icons.download_rounded,
      ),
      LocalFolder(
        id: 'folder_camera',
        name: 'Camera',
        path: '/storage/emulated/0/DCIM/Camera',
        videoCount: 92,
        totalSizeBytes: (8.6 * 1024 * 1024 * 1024).toInt(),
        previewVideos: cameraVideos.isNotEmpty
            ? cameraVideos.take(2).toList()
            : allVideos.skip(4).take(2).toList(),
        customIcon: Icons.photo_camera_rounded,
      ),
      LocalFolder(
        id: 'folder_screen_recordings',
        name: 'Screen Recordings',
        path: '/storage/emulated/0/DCIM/ScreenRecorder',
        videoCount: 47,
        totalSizeBytes: (3.4 * 1024 * 1024 * 1024).toInt(),
        previewVideos: allVideos.skip(6).take(2).toList(),
        customIcon: Icons.screenshot_monitor_rounded,
      ),
      LocalFolder(
        id: 'folder_whatsapp',
        name: 'WhatsApp',
        path: '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video',
        videoCount: 36,
        totalSizeBytes: (1.9 * 1024 * 1024 * 1024).toInt(),
        hasPermission: false, // Demonstrates permission-loss state
        previewVideos: const [],
        customIcon: Icons.chat_bubble_outline_rounded,
      ),
      LocalFolder(
        id: 'folder_hidden_vault',
        name: '.hidden_vault',
        path: '/storage/emulated/0/.hidden_vault',
        videoCount: 14,
        totalSizeBytes: (2.1 * 1024 * 1024 * 1024).toInt(),
        isHidden: true,
        previewVideos: allVideos.skip(1).take(2).toList(),
        customIcon: Icons.visibility_off_rounded,
      ),
    ];
  }

  /// Get videos belonging to a specific folder
  static List<LocalVideo> getVideosForFolder(LocalFolder folder) {
    final all = MockVideoLibrary.sampleVideos;
    if (folder.name.toLowerCase() == 'movies') {
      return all.where((v) => v.folderPath.contains('Movies')).toList();
    }
    if (folder.name.toLowerCase() == 'camera' || folder.name.toLowerCase() == 'screen recordings') {
      return all.where((v) => v.folderPath.contains('DCIM')).toList();
    }
    // Return appropriate sample subset
    return all.take(folder.videoCount.clamp(0, all.length)).toList();
  }
}
