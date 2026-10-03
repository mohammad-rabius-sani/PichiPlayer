import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/models/local_video.dart';
import 'package:pichi_player/models/player_types.dart';
import 'package:pichi_player/ui/screens/player_screen.dart';
import 'package:pichi_player/ui/widgets/player/gesture_feedback_overlays.dart';
import 'package:pichi_player/ui/widgets/player/player_top_bar.dart';
import 'package:pichi_player/ui/widgets/player/subtitles_overlay.dart';

void setLandscapeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  final testVideo = LocalVideo(
    id: 'lock_test_vid_1',
    title: 'Interstellar.2014.2160p.mkv',
    fileName: 'Interstellar.2014.2160p.mkv',
    duration: const Duration(hours: 2, minutes: 49, seconds: 22),
    resolution: '4K',
    codec: 'HEVC',
    fileSizeBytes: 1024 * 1024 * 1024 * 12,
    folderPath: '/storage/emulated/0/Movies',
    dateAdded: DateTime.now(),
    subtitleTracks: const ['English [CC]', 'Spanish', 'Off'],
    gradientStart: const Color(0xFF0F172A),
    gradientEnd: const Color(0xFF1E293B),
  );

  group('Screen Lock State & Interaction System Tests', () {
    testWidgets('Tapping lock in top bar locks screen, shows confirmation, and reveals lock overlay', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: testVideo),
        ),
      );
      await tester.pump();

      // Top bar has lock button
      expect(find.byIcon(Icons.lock_open_rounded), findsOneWidget);

      // Tap lock button
      await tester.tap(find.byIcon(Icons.lock_open_rounded));
      await tester.pump();

      // Screen is locked
      expect(find.byType(ScreenLockedOverlay), findsOneWidget);
      expect(find.text('Screen Locked'), findsWidgets);
      expect(find.text('Touch controls disabled'), findsOneWidget);

      // Controls are hidden
      expect(find.byType(PlayerTopBar), findsNothing);
    });

    testWidgets('While locked, random taps and swipes do not seek, toggle playback, or change volume', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: testVideo),
        ),
      );
      await tester.pump();

      // Lock player
      await tester.tap(find.byIcon(Icons.lock_open_rounded));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Tap center of screen (accidental touch)
      await tester.tapAt(const Offset(800, 450));
      await tester.pump();

      // Verify no play/pause pulse overlay was created
      expect(find.byType(CenterPlayPausePulse), findsNothing);

      // Double-tap left side (accidental seek gesture)
      await tester.tapAt(const Offset(200, 450));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(const Offset(200, 450));
      await tester.pump();

      // Verify no seek double-tap overlay
      expect(find.byType(SeekDoubleTapFeedbackOverlay), findsNothing);

      // Vertical drag (accidental brightness/volume gesture)
      await tester.dragFrom(const Offset(300, 600), const Offset(0, -200));
      await tester.pump();

      // Verify no brightness overlay
      expect(find.byType(BrightnessFeedbackOverlay), findsNothing);
      expect(find.byType(VolumeFeedbackOverlay), findsNothing);

      // Screen remains locked
      expect(find.byType(ScreenLockedOverlay), findsOneWidget);
    });

    testWidgets('Subtitles continue rendering during locked state', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: testVideo),
        ),
      );
      await tester.pump();

      // Subtitles overlay is present
      expect(find.byType(SubtitlesOverlay), findsOneWidget);

      // Lock the player
      await tester.tap(find.byIcon(Icons.lock_open_rounded));
      await tester.pump();

      // Subtitles overlay remains active and visible
      expect(find.byType(SubtitlesOverlay), findsOneWidget);
      expect(find.byType(ScreenLockedOverlay), findsOneWidget);
    });

    testWidgets('PopScope intercepts back navigation when locked and displays explanation', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PlayerScreen(video: testVideo),
        ),
      );
      await tester.pump();

      // Lock player
      await tester.tap(find.byIcon(Icons.lock_open_rounded));
      await tester.pump();

      // Trigger back navigation via system PopScope
      final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
      expect(popScopeFinder, findsOneWidget);
      final dynamic popScopeWidget = tester.widget(popScopeFinder);
      popScopeWidget.onPopInvokedWithResult(false, null);
      await tester.pump();

      // Intercept message displayed
      expect(find.text('Player locked'), findsOneWidget);
      expect(find.text('Hold the lock icon to unlock'), findsOneWidget);
      expect(find.byType(PlayerScreen), findsOneWidget);
    });

    testWidgets('Holding the lock indicator fills circular progress and triggers unlock on completion', (tester) async {
      setLandscapeViewport(tester);
      bool unlocked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ScreenLockedOverlay(
              config: const ScreenLockConfig(holdDuration: Duration(milliseconds: 800)),
              onUnlock: () => unlocked = true,
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('Screen Locked • Tap to Unlock'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

      // Start holding the lock overlay
      final gesture = await tester.startGesture(tester.getCenter(find.byType(ScreenLockedOverlay)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Circular progress active, text shows Hold to unlock with percentage
      expect(find.textContaining('Hold to unlock'), findsOneWidget);
      expect(unlocked, isFalse);

      // Complete hold past 800ms
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.up();
      await tester.pump();

      expect(unlocked, isTrue);
    });

    testWidgets('Early release before hold completion cancels unlock and keeps screen locked', (tester) async {
      setLandscapeViewport(tester);
      bool unlocked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ScreenLockedOverlay(
              config: const ScreenLockConfig(holdDuration: Duration(milliseconds: 1000)),
              onUnlock: () => unlocked = true,
            ),
          ),
        ),
      );

      // Start hold
      final gesture = await tester.startGesture(tester.getCenter(find.byType(ScreenLockedOverlay)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('Hold to unlock'), findsOneWidget);

      // Release early at 400ms (< 1000ms)
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 500));

      // Did not unlock
      expect(unlocked, isFalse);
      expect(find.text('Screen Locked • Tap to Unlock'), findsOneWidget);
    });

    testWidgets('Tap to unlock functions for accessibility and instant action', (tester) async {
      setLandscapeViewport(tester);
      bool unlocked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ScreenLockedOverlay(
              onUnlock: () => unlocked = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Screen Locked • Tap to Unlock'));
      await tester.pump();

      expect(unlocked, isTrue);
    });

    testWidgets('ScreenLockConfig data model supports preferences architecture', (tester) async {
      const config = ScreenLockConfig(
        unlockMethod: UnlockMethod.longPress,
        indicatorVisibility: LockIndicatorVisibility.visible,
        hapticsEnabled: true,
        holdDuration: Duration(milliseconds: 1200),
      );

      expect(config.unlockMethod, equals(UnlockMethod.longPress));
      expect(config.indicatorVisibility, equals(LockIndicatorVisibility.visible));
      expect(config.hapticsEnabled, isTrue);
      expect(config.holdDuration.inMilliseconds, equals(1200));

      expect(UnlockMethod.longPress.label, equals('Hold to unlock'));
      expect(UnlockMethod.tap.label, equals('Tap to unlock'));
      expect(LockIndicatorVisibility.visible.label, equals('Always visible'));
      expect(LockIndicatorVisibility.temporary.label, equals('Auto-hide when idle'));
    });
  });
}
