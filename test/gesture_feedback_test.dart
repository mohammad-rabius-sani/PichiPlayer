import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/models/local_video.dart';
import 'package:pichi_player/models/player_types.dart';
import 'package:pichi_player/ui/screens/player_screen.dart';
import 'package:pichi_player/ui/widgets/player/gesture_feedback_overlays.dart';

void main() {
  void setLandscapeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
  }

  final sampleVideo = LocalVideo(
    id: 'gesture_test_vid',
    title: 'Interstellar',
    fileName: 'Interstellar.mkv',
    duration: const Duration(hours: 2, minutes: 49, seconds: 22),
    resolution: '4K',
    codec: 'HEVC',
    fileSizeBytes: 14500000000,
    folderPath: 'Movies/Sci-Fi/',
    dateAdded: DateTime(2026, 9, 28),
    lastPosition: const Duration(hours: 1, minutes: 12, seconds: 16),
    gradientStart: const Color(0xFF101C38),
    gradientEnd: const Color(0xFF070B14),
    visualIcon: Icons.movie_filter_rounded,
  );

  group('BrightnessFeedbackOverlay Unit & Widget Tests', () {
    testWidgets('renders left-center with sun icon, Brightness label, and 72%', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: BrightnessFeedbackOverlay(brightness: 0.72),
          ),
        ),
      );

      expect(find.byType(BrightnessFeedbackOverlay), findsOneWidget);
      expect(find.text('Brightness'), findsOneWidget);
      expect(find.text('72%'), findsOneWidget);
      expect(find.byIcon(Icons.brightness_7_rounded), findsOneWidget);
    });

    testWidgets('adapts sun icon for low and medium brightness levels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: BrightnessFeedbackOverlay(brightness: 0.15),
          ),
        ),
      );

      expect(find.text('15%'), findsOneWidget);
      expect(find.byIcon(Icons.brightness_4_rounded), findsOneWidget);
    });
  });

  group('VolumeFeedbackOverlay Unit & Widget Tests', () {
    testWidgets('renders right-center with speaker icon, Volume label, and 68%', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: VolumeFeedbackOverlay(volume: 0.68),
          ),
        ),
      );

      expect(find.byType(VolumeFeedbackOverlay), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
      expect(find.text('68%'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    });

    testWidgets('displays mute icon when volume is 0%', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: VolumeFeedbackOverlay(volume: 0.0),
          ),
        ),
      );

      expect(find.text('0%'), findsOneWidget);
      expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
    });
  });

  group('SeekDoubleTapFeedbackOverlay Unit & Widget Tests', () {
    testWidgets('renders backward seek with ↶ and 10 seconds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: SeekDoubleTapFeedbackOverlay(
              direction: SeekDirection.backward,
              seconds: 10,
            ),
          ),
        ),
      );

      expect(find.text('↶'), findsOneWidget);
      expect(find.text('10 seconds'), findsOneWidget);
    });

    testWidgets('renders forward seek with ↷ and 10 seconds near touch position', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: SeekDoubleTapFeedbackOverlay(
              direction: SeekDirection.forward,
              seconds: 10,
              touchPosition: Offset(950, 320),
            ),
          ),
        ),
      );

      expect(find.text('↷'), findsOneWidget);
      expect(find.text('10 seconds'), findsOneWidget);
    });
  });

  group('ScrubSeekFeedbackOverlay Unit & Widget Tests', () {
    testWidgets('renders backward delta -00:20 and target timestamp 01:12:16', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: ScrubSeekFeedbackOverlay(
              currentPosition: Duration(hours: 1, minutes: 12, seconds: 16),
              delta: Duration(seconds: -20),
              totalDuration: Duration(hours: 2, minutes: 49, seconds: 22),
            ),
          ),
        ),
      );

      expect(find.text('-00:20'), findsOneWidget);
      expect(find.text('01:12:16'), findsOneWidget);
      expect(find.text('↶'), findsOneWidget);
    });

    testWidgets('renders forward delta +00:20 and target timestamp 01:12:56', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: ScrubSeekFeedbackOverlay(
              currentPosition: Duration(hours: 1, minutes: 12, seconds: 56),
              delta: Duration(seconds: 20),
              totalDuration: Duration(hours: 2, minutes: 49, seconds: 22),
            ),
          ),
        ),
      );

      expect(find.text('+00:20'), findsOneWidget);
      expect(find.text('01:12:56'), findsOneWidget);
      expect(find.text('↷'), findsOneWidget);
    });
  });

  group('ZoomFeedbackBadgeOverlay Unit & Widget Tests', () {
    testWidgets('renders zoom factor multiplier (1.24×)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: ZoomFeedbackBadgeOverlay(scale: 1.24),
          ),
        ),
      );

      expect(find.byIcon(Icons.zoom_in_rounded), findsOneWidget);
      expect(find.text('1.24×'), findsOneWidget);
    });

    testWidgets('renders preset mode name when supplied (FIT, FILL, CROP)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: ZoomFeedbackBadgeOverlay(scale: 1.0, modeName: 'Fit'),
          ),
        ),
      );

      expect(find.text('FIT'), findsOneWidget);
    });
  });

  group('OrientationFeedbackOverlay Unit & Widget Tests', () {
    testWidgets('renders Landscape orientation and rotation icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: OrientationFeedbackOverlay(orientationName: 'Landscape'),
          ),
        ),
      );

      expect(find.byIcon(Icons.screen_rotation_rounded), findsOneWidget);
      expect(find.text('Landscape'), findsOneWidget);
    });

    testWidgets('renders Landscape Locked when locked is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: OrientationFeedbackOverlay(
              orientationName: 'Landscape',
              isLocked: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.screen_lock_rotation_rounded), findsOneWidget);
      expect(find.text('Landscape Locked'), findsOneWidget);
    });
  });

  group('ScreenLockedOverlay & Hold-to-Unlock Tests', () {
    testWidgets('renders lock icon and Screen Locked text, supports tap unlock', (tester) async {
      bool unlocked = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ScreenLockedOverlay(onUnlock: () => unlocked = true),
          ),
        ),
      );

      expect(find.text('Screen Locked • Tap to Unlock'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

      await tester.tap(find.text('Screen Locked • Tap to Unlock'));
      await tester.pump();
      expect(unlocked, isTrue);
    });

    testWidgets('holding lock fills progress and triggers unlock on completion', (tester) async {
      bool unlocked = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ScreenLockedOverlay(onUnlock: () => unlocked = true),
          ),
        ),
      );

      // Long press / hold the lock widget
      final gesture = await tester.startGesture(tester.getCenter(find.byType(ScreenLockedOverlay)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('Hold to unlock'), findsOneWidget);

      // Finish 800ms hold duration
      await tester.pump(const Duration(milliseconds: 500));
      await gesture.up();
      await tester.pump();

      expect(unlocked, isTrue);
    });
  });

  group('TransientPillFeedbackOverlay Unit & Widget Tests', () {
    testWidgets('renders Speed setting feedback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: TransientPillFeedbackOverlay(
              icon: Icons.speed_rounded,
              title: '1.5× Speed',
              subtitle: 'Playback Speed',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
      expect(find.text('1.5× Speed'), findsOneWidget);
      expect(find.text('Playback Speed'), findsOneWidget);
    });

    testWidgets('renders A-B repeat feedback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: TransientPillFeedbackOverlay(
              icon: Icons.repeat_on_rounded,
              title: 'A ↔ B',
              subtitle: 'Loop Active (01:12:16 - 01:14:42)',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.repeat_on_rounded), findsOneWidget);
      expect(find.text('A ↔ B'), findsOneWidget);
      expect(find.text('Loop Active (01:12:16 - 01:14:42)'), findsOneWidget);
    });
  });

  group('CompactPlayerToastOverlay Unit & Widget Tests', () {
    testWidgets('renders recoverable notice toast message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: CompactPlayerToastOverlay(
              icon: Icons.memory_rounded,
              message: 'Hardware decoding failed • Trying software decoder',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.memory_rounded), findsOneWidget);
      expect(find.text('Hardware decoding failed • Trying software decoder'), findsOneWidget);
    });
  });

  group('PlayerScreen Gesture Integration Tests', () {
    testWidgets('vertical drag on left side activates BrightnessFeedbackOverlay', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: sampleVideo),
        ),
      );
      await tester.pump();

      // Drag up on left side (x=200, y=400 -> y=200)
      final gesture = await tester.startGesture(const Offset(200, 400));
      await gesture.moveBy(const Offset(0, -100));
      await tester.pump();

      expect(find.byType(BrightnessFeedbackOverlay), findsOneWidget);
      expect(find.text('Brightness'), findsOneWidget);

      await gesture.up();
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(BrightnessFeedbackOverlay), findsNothing);
    });

    testWidgets('vertical drag on right side activates VolumeFeedbackOverlay', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: sampleVideo),
        ),
      );
      await tester.pump();

      // Drag down on right side (x=1050, y=300 -> y=450)
      final gesture = await tester.startGesture(const Offset(1050, 300));
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();

      expect(find.byType(VolumeFeedbackOverlay), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);

      await gesture.up();
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(VolumeFeedbackOverlay), findsNothing);
    });

    testWidgets('horizontal scrub drag activates ScrubSeekFeedbackOverlay', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: sampleVideo),
        ),
      );
      await tester.pump();

      // Horizontal scrub drag from center
      final gesture = await tester.startGesture(const Offset(640, 360));
      await gesture.moveBy(const Offset(80, 0));
      await tester.pump();

      expect(find.byType(ScrubSeekFeedbackOverlay), findsOneWidget);

      await gesture.up();
      await tester.pump();
      expect(find.byType(ScrubSeekFeedbackOverlay), findsNothing);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('long press activates 2× LongPressSpeedBadgeOverlay and release removes it', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: sampleVideo),
        ),
      );
      await tester.pump();

      final gesture = await tester.startGesture(const Offset(640, 360));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(LongPressSpeedBadgeOverlay), findsOneWidget);
      expect(find.text('2× Speed'), findsOneWidget);

      await gesture.up();
      await tester.pump();
      expect(find.byType(LongPressSpeedBadgeOverlay), findsNothing);
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
