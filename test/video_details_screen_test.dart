import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/models/audio_track_info.dart';
import 'package:pichi_player/models/local_video.dart';
import 'package:pichi_player/ui/screens/video_details_screen.dart';
import 'package:pichi_player/ui/widgets/video_details_hero.dart';
import 'package:pichi_player/ui/widgets/video_quick_actions_row.dart';
import 'package:pichi_player/ui/widgets/metadata_section_card.dart';

void setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  final sampleInterstellar = LocalVideo(
    id: 'vid_interstellar',
    title: 'Interstellar',
    fileName: 'Interstellar.mkv',
    folderPath: 'Movies/Sci-Fi/',
    duration: const Duration(hours: 2, minutes: 49, seconds: 22),
    fileSizeBytes: (18.4 * 1024 * 1024 * 1024).toInt(), // ~18.4 GB
    dateModified: DateTime(2026, 9, 28, 14, 20),
    dateAdded: DateTime(2026, 9, 28, 14, 25),
    resolution: '4K',
    codec: 'HEVC',
    containerFormat: 'MKV',
    bitrateMbps: 24.8,
    fps: 59.94,
    isHdr: true,
    lastPosition: const Duration(hours: 1, minutes: 12, seconds: 16),
    isFavorite: false,
    gradientStart: const Color(0xFF0F2042),
    gradientEnd: const Color(0xFF0A0F1D),
    visualIcon: Icons.rocket_launch_rounded,
    audioTracks: const [
      AudioTrackInfo(
        id: 'track_eng',
        language: 'English',
        title: 'English 5.1 (AC-3)',
        codec: 'AC-3',
        channels: '5.1',
        bitrateKbps: 640,
        sampleRateKhz: 48.0,
        isDefault: true,
      ),
      AudioTrackInfo(
        id: 'track_jpn',
        language: 'Japanese',
        title: 'Japanese 2.0 (AAC)',
        codec: 'AAC',
        channels: 'Stereo',
        bitrateKbps: 256,
        sampleRateKhz: 48.0,
      ),
    ],
    subtitleTracks: const ['English', 'Spanish', 'Off'],
  );

  final sampleUnwatched = LocalVideo(
    id: 'vid_unwatched',
    title: 'Blade Runner 2049',
    fileName: 'Blade.Runner.2049.mp4',
    folderPath: 'Movies/',
    duration: const Duration(hours: 2, minutes: 43),
    fileSizeBytes: 4294967296,
    dateModified: DateTime(2026, 8, 15),
    dateAdded: DateTime(2026, 8, 16),
    resolution: '1080p',
    codec: 'H.264',
    containerFormat: 'MP4',
    lastPosition: null,
    isFavorite: true,
    gradientStart: const Color(0xFF1E102F),
    gradientEnd: const Color(0xFF0C0714),
  );

  group('VideoDetailsScreen Core & Visual Design', () {
    testWidgets('renders top header, cinematic hero, title, summary, and progress for partially watched video', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VideoDetailsScreen(
            video: sampleInterstellar,
            enableBackgroundAnimation: false,
          ),
        ),
      );
      await tester.pump();

      // Top Header
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Video Details'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);

      // Hero Widget
      expect(find.byType(VideoDetailsHero), findsOneWidget);
      expect(find.text('4K'), findsWidgets);
      expect(find.text('HDR'), findsWidgets);

      // Title & Summary
      expect(find.text('Interstellar'), findsWidgets);
      expect(find.text('2h 49m • 4K UHD • HEVC'), findsOneWidget);

      // Progress bar & label
      expect(find.text('Progress: 1:12:16 / 2:49:22'), findsOneWidget);

      // Primary Actions
      expect(find.text('Resume'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

      // Quick Actions
      expect(find.byType(VideoQuickActionsRow), findsOneWidget);
      expect(find.text('Subtitles'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('1×'), findsOneWidget);
    });

    testWidgets('renders "Not watched yet" and "Play" button when video is unwatched', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VideoDetailsScreen(
            video: sampleUnwatched,
            enableBackgroundAnimation: false,
          ),
        ),
      );
      await tester.pump();

      // Unwatched label
      expect(find.text('Not watched yet'), findsOneWidget);
      expect(find.textContaining('Progress:'), findsNothing);

      // Primary button is "Play"
      expect(find.text('Play'), findsOneWidget);
      expect(find.text('Resume'), findsNothing);

      // Pre-existing favorite is filled heart
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('renders VIDEO, AUDIO, and FILE technical metadata sections', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VideoDetailsScreen(
            video: sampleInterstellar,
            enableBackgroundAnimation: false,
          ),
        ),
      );
      await tester.pump();

      // Section Cards
      expect(find.byType(MetadataSectionCard), findsNWidgets(3));
      expect(find.text('VIDEO'), findsOneWidget);
      expect(find.text('AUDIO'), findsOneWidget);
      expect(find.text('FILE'), findsOneWidget);

      // VIDEO values
      expect(find.text('3840 × 2160'), findsOneWidget);
      expect(find.text('HEVC / H.265'), findsOneWidget);
      expect(find.text('59.94 FPS'), findsOneWidget);
      expect(find.text('24.8 Mbps'), findsOneWidget);

      // AUDIO values
      expect(find.text('English 5.1 (AC-3)'), findsOneWidget);
      expect(find.text('AC-3'), findsOneWidget);
      expect(find.text('5.1'), findsOneWidget);
      expect(find.text('640 kbps'), findsOneWidget);
      expect(find.text('2 tracks'), findsOneWidget);

      // FILE values
      expect(find.text('MKV'), findsOneWidget);
      expect(find.text('18.4 GB'), findsOneWidget);
      expect(find.text('Movies/Sci-Fi/'), findsOneWidget);
    });

    testWidgets('tapping location reveals full device path with copy action', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VideoDetailsScreen(
            video: sampleInterstellar,
            enableBackgroundAnimation: false,
          ),
        ),
      );
      await tester.pump();

      // Initially full path is hidden
      expect(find.text('Full Device Path'), findsNothing);

      // Tap on location row
      await tester.tap(find.text('Movies/Sci-Fi/'));
      await tester.pumpAndSettle();

      // Full path is now revealed
      expect(find.text('Full Device Path'), findsOneWidget);
      expect(find.text(sampleInterstellar.fullDevicePath), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    });

    testWidgets('favorite button toggles state with smooth animation and snackbar feedback', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VideoDetailsScreen(
            video: sampleInterstellar,
            enableBackgroundAnimation: false,
          ),
        ),
      );
      await tester.pump();

      // Initially false -> border icon
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      // Tap to favorite
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      // Filled heart exists (both on screen and in snackbar)
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
      expect(find.text('Added to Favorites'), findsOneWidget);

      // Tap the favorite button to un-favorite
      final favButton = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Favorite',
      );
      await tester.tap(favButton);
      await tester.pumpAndSettle();

      expect(find.text('Removed from Favorites'), findsOneWidget);
    });

    testWidgets('quick actions open bottom sheets for Subtitles, Audio, and Speed', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VideoDetailsScreen(
            video: sampleInterstellar,
            enableBackgroundAnimation: false,
          ),
        ),
      );
      await tester.pump();

      // Open Subtitles sheet
      await tester.tap(find.text('Subtitles'));
      await tester.pumpAndSettle();
      expect(find.text('Select Subtitles'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);

      // Select Spanish
      await tester.tap(find.text('Spanish'));
      await tester.pumpAndSettle();
      expect(find.text('Select Subtitles'), findsNothing);
      expect(find.text('Spanish'), findsOneWidget); // Shown in quick action row

      // Open Speed sheet
      await tester.tap(find.text('Speed'));
      await tester.pumpAndSettle();
      expect(find.text('Playback Speed'), findsOneWidget);
      expect(find.text('1.5×'), findsOneWidget);

      // Select 1.5x
      await tester.tap(find.text('1.5×'));
      await tester.pumpAndSettle();
      expect(find.text('Playback Speed'), findsNothing);
      expect(find.text('1.5×'), findsOneWidget); // Shown in quick action row
    });

    testWidgets('overflow menu opens options sheet and delete shows confirmation dialog', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VideoDetailsScreen(
            video: sampleInterstellar,
            enableBackgroundAnimation: false,
          ),
        ),
      );
      await tester.pump();

      // Tap overflow menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      // Bottom sheet items
      expect(find.text('Add to Playlist'), findsOneWidget);
      expect(find.text('Open Folder'), findsOneWidget);
      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Show File Information'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap Delete -> Safety Confirmation Dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete File?'), findsOneWidget);
      expect(find.textContaining('Permanently delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Cancel keeps the user on the screen
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Delete File?'), findsNothing);
      expect(find.text('Interstellar'), findsWidgets);
    });

    testWidgets('displays "Video unavailable" missing state when isMissingOverride is true', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VideoDetailsScreen(
            video: sampleInterstellar,
            enableBackgroundAnimation: false,
            isMissingOverride: true,
          ),
        ),
      );
      await tester.pump();

      // Notice card
      expect(find.text('Video unavailable'), findsOneWidget);
      expect(find.text('This file is no longer available at its saved location.'), findsOneWidget);
      expect(find.text('Locate File'), findsOneWidget);
      expect(find.text('Remove from Library'), findsOneWidget);
    });

    testWidgets('displays "This video may not be playable" unsupported state when isUnsupportedOverride is true', (tester) async {
      setPhoneViewport(tester);
      final unsupportedVideo = sampleInterstellar.copyWith(
        codec: 'AV1',
        resolution: '8K',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VideoDetailsScreen(
            video: unsupportedVideo,
            enableBackgroundAnimation: false,
            isUnsupportedOverride: true,
          ),
        ),
      );
      await tester.pump();

      // Unsupported notice card
      expect(find.text('This video may not be playable'), findsOneWidget);
      expect(find.text('Codec: AV1 • Resolution: 8K'), findsOneWidget);
      expect(find.text('Your device may not support hardware decoding for this format.'), findsOneWidget);
      expect(find.text('Try Playback'), findsOneWidget);
      expect(find.text('Player Settings'), findsOneWidget);
    });
  });
}
