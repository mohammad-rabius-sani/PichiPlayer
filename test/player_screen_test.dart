import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/models/audio_track_info.dart';
import 'package:pichi_player/models/local_video.dart';
import 'package:pichi_player/ui/screens/player_screen.dart';
import 'package:pichi_player/ui/widgets/player/gesture_feedback_overlays.dart';
import 'package:pichi_player/ui/widgets/player/playback_statistics_overlay.dart';
import 'package:pichi_player/ui/widgets/player/player_bottom_bar.dart';
import 'package:pichi_player/ui/widgets/player/player_completion_overlay.dart';
import 'package:pichi_player/ui/widgets/player/player_error_overlay.dart';
import 'package:pichi_player/ui/widgets/player/player_top_bar.dart';
import 'package:pichi_player/ui/widgets/player/subtitles_overlay.dart';
import 'package:pichi_player/ui/widgets/player/video_surface.dart';

void setLandscapeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 720);
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
    fileSizeBytes: (18.4 * 1024 * 1024 * 1024).toInt(),
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
    subtitleTracks: const ['English', 'Bengali', 'Japanese', 'Off'],
  );

  final sampleBatman = LocalVideo(
    id: 'vid_batman',
    title: 'The Batman',
    fileName: 'The Batman.mkv',
    duration: const Duration(hours: 2, minutes: 56, seconds: 12),
    resolution: '4K',
    codec: 'HEVC',
    fileSizeBytes: 16000000000,
    folderPath: 'Movies/Action/',
    dateAdded: DateTime(2026, 9, 27),
    gradientStart: const Color(0xFF221319),
    gradientEnd: const Color(0xFF0C0709),
    visualIcon: Icons.shield_rounded,
  );

  group('PlayerScreen Core Architecture & Visual Design', () {
    testWidgets('renders video surface, top bar with filename, bottom bar, and subtitles', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: sampleInterstellar),
        ),
      );
      await tester.pump();

      // Video Surface
      expect(find.byType(VideoSurface), findsOneWidget);

      // Top Control Bar
      expect(find.byType(PlayerTopBar), findsOneWidget);
      expect(find.text('Interstellar.mkv'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_open_rounded), findsOneWidget);

      // Bottom Control Bar
      expect(find.byType(PlayerBottomBar), findsOneWidget);
      expect(find.text('01:12:16'), findsOneWidget);
      expect(find.text('02:49:22'), findsOneWidget);
      expect(find.text('1×'), findsOneWidget);
      expect(find.text('Fit'), findsOneWidget);

      // Subtitles Overlay
      expect(find.byType(SubtitlesOverlay), findsOneWidget);
    });

    testWidgets('single tap toggles play/pause with centered icon animation', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: sampleInterstellar),
        ),
      );
      await tester.pump();

      // Tap center of screen
      await tester.tapAt(const Offset(640, 360));
      await tester.pump(const Duration(milliseconds: 350));

      // Center play/pause pulse appears
      expect(find.byType(CenterPlayPausePulse), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('double tap on left seeks backward -10s with visual feedback', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: sampleInterstellar),
        ),
      );
      await tester.pump();

      // Double tap left zone (< 35% of 1280 = 448)
      await tester.tapAt(const Offset(200, 360));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(const Offset(200, 360));
      await tester.pump();

      // Double tap seek feedback appears
      expect(find.byType(SeekDoubleTapFeedbackOverlay), findsOneWidget);
      expect(find.text('10 seconds'), findsOneWidget);
      expect(find.text('↶'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('double tap on right seeks forward +10s with visual feedback', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: sampleInterstellar),
        ),
      );
      await tester.pump();

      // Double tap right zone (> 65% of 1280 = 832)
      await tester.tapAt(const Offset(1050, 360));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(const Offset(1050, 360));
      await tester.pump();

      // Double tap seek feedback appears
      expect(find.byType(SeekDoubleTapFeedbackOverlay), findsOneWidget);
      expect(find.text('10 seconds'), findsOneWidget);
      expect(find.text('↷'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('screen lock disables normal controls and allows unlocking', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: sampleInterstellar),
        ),
      );
      await tester.pump();

      // Tap lock button in top bar
      await tester.tap(find.byIcon(Icons.lock_open_rounded));
      await tester.pump();

      // Controls are locked
      expect(find.byType(ScreenLockedOverlay), findsOneWidget);
      expect(find.text('Screen Locked • Tap to Unlock'), findsOneWidget);

      // Tap to unlock
      await tester.tap(find.text('Screen Locked • Tap to Unlock'));
      await tester.pump();

      // Controls restored
      expect(find.byType(PlayerTopBar), findsOneWidget);
      expect(find.byType(PlayerBottomBar), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('playback statistics overlay displays nerd metrics and closes', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: sampleInterstellar),
        ),
      );
      await tester.pump();

      // Toggle stats button in top bar
      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pump();

      // Statistics overlay is visible
      expect(find.byType(PlaybackStatisticsOverlay), findsOneWidget);
      expect(find.text('NERD STATS'), findsOneWidget);
      expect(find.text('3840 × 2160'), findsOneWidget);
      expect(find.text('HEVC / H.265'), findsOneWidget);
      expect(find.text('Hardware Decoder'), findsOneWidget);

      // Close stats overlay
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(find.byType(PlaybackStatisticsOverlay), findsNothing);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('subtitles, audio, speed, and aspect ratio sheets open properly', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: sampleInterstellar),
        ),
      );
      await tester.pump();

      // Open Subtitles sheet
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('Subtitles'), findsOneWidget);
      expect(find.text('Bengali'), findsOneWidget);
      expect(find.text('Add subtitle file'), findsOneWidget);

      // Select Bengali
      await tester.tap(find.text('Bengali'));
      await tester.pumpAndSettle();
      expect(find.text('Bengali'), findsOneWidget);

      // Open Speed sheet
      await tester.tap(find.text('1×'));
      await tester.pumpAndSettle();
      expect(find.text('Playback Speed'), findsOneWidget);
      expect(find.text('1.5×'), findsOneWidget);

      // Select 1.5x
      await tester.tap(find.text('1.5×'));
      await tester.pumpAndSettle();
      expect(find.text('1.5×'), findsOneWidget);

      // Open Aspect Ratio sheet
      await tester.tap(find.text('Fit'));
      await tester.pumpAndSettle();
      expect(find.text('Aspect Ratio / Display'), findsOneWidget);
      expect(find.text('Fill'), findsOneWidget);
      expect(find.text('Crop / Zoom'), findsOneWidget);

      // Select Fill
      await tester.tap(find.byKey(const ValueKey('scaling_mode_fill')));
      await tester.pumpAndSettle();
      // Close Display sheet to return to video
      await tester.tap(find.byKey(const ValueKey('display_sheet_close_btn')));
      await tester.pumpAndSettle();
      expect(find.text('Fill'), findsOneWidget);
    });

    testWidgets('renders completion overlay when video finishes with replay and next video countdown', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(
            video: sampleInterstellar,
            nextVideo: sampleBatman,
            isCompletedOverride: true,
          ),
        ),
      );
      await tester.pump();

      // Completion Overlay
      expect(find.byType(PlayerCompletionOverlay), findsOneWidget);
      expect(find.text('Video finished'), findsOneWidget);
      expect(find.text('UP NEXT'), findsOneWidget);
      expect(find.text('The Batman'), findsOneWidget);
      expect(find.text('Replay'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('renders custom error overlay with Try Again and Settings on playback error', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(
            video: sampleInterstellar,
            isErrorOverride: true,
          ),
        ),
      );
      await tester.pump();

      // Error Overlay
      expect(find.byType(PlayerErrorOverlay), findsOneWidget);
      expect(find.text("Can't play this video"), findsOneWidget);
      expect(find.text("PIchiPlayer couldn't start playback for this file."), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Technical details'), findsOneWidget);
    });
  });
}
