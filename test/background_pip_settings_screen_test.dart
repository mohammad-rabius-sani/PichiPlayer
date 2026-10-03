import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/models/local_video.dart';
import 'package:pichi_player/models/player_types.dart';
import 'package:pichi_player/ui/screens/background_pip_settings_screen.dart';

void setDeviceViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  final testVideo = LocalVideo(
    id: 'test_vid_pip_1',
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

  group('Background & PiP Settings Screen Tests', () {
    testWidgets('Renders top app bar, header title, and supporting text', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const BackgroundPipSettingsScreen(),
        ),
      );

      expect(find.text('Background & PiP'), findsOneWidget);
      expect(find.text('Keep watching when you leave PIchiPlayer'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('Renders re-entry Now Playing banner and handles return action', (tester) async {
      setDeviceViewport(tester);
      bool returnPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: BackgroundPipSettingsScreen(
            activeVideo: testVideo,
            activePosition: const Duration(hours: 1, minutes: 12, seconds: 16),
            onReturnToPlayer: () => returnPressed = true,
          ),
        ),
      );

      expect(find.text('Now playing'), findsOneWidget);
      expect(find.text('Interstellar.2014.2160p.mkv'), findsWidgets);
      expect(find.text('01:12:16'), findsWidgets);
      expect(find.byKey(const ValueKey('return_to_player_button')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('return_to_player_button')));
      await tester.pump();

      expect(returnPressed, isTrue);
    });

    testWidgets('Background playback toggle updates state, helper text, and triggers callback', (tester) async {
      setDeviceViewport(tester);
      BackgroundPipConfig? capturedConfig;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: BackgroundPipSettingsScreen(
            onConfigChanged: (cfg) => capturedConfig = cfg,
          ),
        ),
      );

      expect(find.text('BACKGROUND PLAYBACK'), findsOneWidget);
      expect(find.text('Background playback'), findsOneWidget);
      expect(find.text('Continue playback when PIchiPlayer is not in the foreground.'), findsOneWidget);
      expect(find.text('Background playback may use additional battery.'), findsOneWidget);

      // Default is ON, so helper text for OFF is not shown initially
      expect(find.text('Playback stops when PIchiPlayer leaves the foreground.'), findsNothing);

      // Toggle switch to OFF
      await tester.tap(find.byKey(const ValueKey('background_playback_switch')));
      await tester.pump();

      expect(capturedConfig, isNotNull);
      expect(capturedConfig!.backgroundPlaybackEnabled, isFalse);
      expect(find.text('Playback stops when PIchiPlayer leaves the foreground.'), findsOneWidget);
    });

    testWidgets('Displays unavailable warning card when device does not support PiP', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const BackgroundPipSettingsScreen(
            isPipSupported: false,
          ),
        ),
      );

      expect(find.text('PICTURE-IN-PICTURE'), findsOneWidget);
      expect(find.text('Picture-in-Picture unavailable'), findsOneWidget);
      expect(
        find.text("This device or Android configuration doesn't currently support the required PiP behavior."),
        findsOneWidget,
      );
      // PiP switch and preview are not displayed
      expect(find.byKey(const ValueKey('pip_switch')), findsNothing);
      expect(find.text('WHEN LEAVING PICHIPLAYER'), findsNothing);
    });

    testWidgets('Renders PiP controls, visual preview, leaving-app behavior, and auto-PiP', (tester) async {
      setDeviceViewport(tester);
      BackgroundPipConfig? capturedConfig;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: BackgroundPipSettingsScreen(
            onConfigChanged: (cfg) => capturedConfig = cfg,
          ),
        ),
      );

      expect(find.text('PICTURE-IN-PICTURE'), findsOneWidget);
      expect(find.byKey(const ValueKey('pip_switch')), findsOneWidget);

      // Visual preview content
      expect(find.text('PiP'), findsOneWidget);
      expect(find.textContaining('Preview: Video floats over other apps'), findsOneWidget);

      // Leaving-app behavior options
      expect(find.text('WHEN LEAVING PICHIPLAYER'), findsOneWidget);
      expect(find.text('Continue playing'), findsOneWidget);
      expect(find.text('Open Picture-in-Picture'), findsOneWidget);
      expect(find.text('RECOMMENDED'), findsOneWidget);
      expect(find.text('Audio only'), findsOneWidget);

      // Select 'Audio only'
      await tester.tap(find.byKey(const ValueKey('leaving_behavior_audioOnly')));
      await tester.pump();

      expect(capturedConfig, isNotNull);
      expect(capturedConfig!.leavingAppBehavior, equals(LeavingAppBehavior.audioOnly));

      // Auto-enter PiP toggle
      expect(find.text('Automatically enter Picture-in-Picture'), findsOneWidget);
      final autoEnterFinder = find.byKey(const ValueKey('auto_enter_pip_switch'));
      expect(autoEnterFinder, findsOneWidget);

      await tester.tap(autoEnterFinder);
      await tester.pump();

      expect(capturedConfig!.autoEnterPip, isTrue);
    });

    testWidgets('Renders Lock Screen controls, media notification toggle, and media session metadata', (tester) async {
      setDeviceViewport(tester);
      BackgroundPipConfig? capturedConfig;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: BackgroundPipSettingsScreen(
            onConfigChanged: (cfg) => capturedConfig = cfg,
          ),
        ),
      );

      expect(find.text('LOCK SCREEN'), findsOneWidget);
      expect(find.text('Show media controls'), findsOneWidget);
      expect(find.text('Control playback from the lock screen and notification panel.'), findsOneWidget);
      expect(find.text('Play / Pause'), findsOneWidget);
      expect(find.text('Seek ±10s'), findsOneWidget);
      expect(find.text('Previous / Next'), findsOneWidget);

      expect(find.text('Media notification'), findsOneWidget);

      // Media session metadata preview
      expect(find.text('MEDIA SESSION METADATA'), findsOneWidget);
      expect(find.text('Android MediaSession'), findsOneWidget);
      expect(find.text('01:12:16 / 02:49:22'), findsOneWidget);

      // Toggle lock screen controls switch
      await tester.tap(find.byKey(const ValueKey('lock_screen_controls_switch')));
      await tester.pump();

      expect(capturedConfig, isNotNull);
      expect(capturedConfig!.showLockScreenControls, isFalse);

      // Toggle media notification switch
      await tester.tap(find.byKey(const ValueKey('media_notification_switch')));
      await tester.pump();

      expect(capturedConfig!.showMediaNotification, isFalse);
    });

    testWidgets('Renders unified Single Playback Session architecture card', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const BackgroundPipSettingsScreen(),
        ),
      );

      expect(find.text('Single Playback Session'), findsOneWidget);
      expect(
        find.textContaining('Fullscreen, Picture-in-Picture, Background playback, and Lock screen controls'),
        findsOneWidget,
      );
    });

    testWidgets('BackgroundPipConfig model supports copyWith and immutability', (tester) async {
      const config = BackgroundPipConfig();

      expect(config.backgroundPlaybackEnabled, isTrue);
      expect(config.pipEnabled, isTrue);
      expect(config.leavingAppBehavior, equals(LeavingAppBehavior.openPip));
      expect(config.autoEnterPip, isFalse);
      expect(config.showLockScreenControls, isTrue);
      expect(config.showMediaNotification, isTrue);

      final updated = config.copyWith(
        backgroundPlaybackEnabled: false,
        pipEnabled: false,
        leavingAppBehavior: LeavingAppBehavior.continuePlaying,
        autoEnterPip: true,
        showLockScreenControls: false,
        showMediaNotification: false,
      );

      expect(updated.backgroundPlaybackEnabled, isFalse);
      expect(updated.pipEnabled, isFalse);
      expect(updated.leavingAppBehavior, equals(LeavingAppBehavior.continuePlaying));
      expect(updated.autoEnterPip, isTrue);
      expect(updated.showLockScreenControls, isFalse);
      expect(updated.showMediaNotification, isFalse);
    });
  });
}
