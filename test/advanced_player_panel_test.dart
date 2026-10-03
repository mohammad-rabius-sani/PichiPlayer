import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/models/audio_track_info.dart';
import 'package:pichi_player/models/local_video.dart';
import 'package:pichi_player/models/player_types.dart';
import 'package:pichi_player/ui/widgets/player/advanced_player_panel.dart';
import 'package:pichi_player/ui/widgets/player/more_panel/ab_repeat_sheet.dart';
import 'package:pichi_player/ui/widgets/player/more_panel/delay_control_sheet.dart';
import 'package:pichi_player/ui/widgets/player/more_panel/focused_stats_sheet.dart';
import 'package:pichi_player/ui/widgets/player/more_panel/sleep_timer_sheet.dart';
import 'package:pichi_player/ui/widgets/player/more_panel/subtitle_customization_sheet.dart';
import 'package:pichi_player/ui/widgets/player/more_panel/zoom_control_sheet.dart';

void setLandscapeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 720);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  final sampleVideo = LocalVideo(
    id: 'test_vid_1',
    title: 'Interstellar',
    fileName: 'Interstellar.mkv',
    duration: const Duration(hours: 2, minutes: 49, seconds: 22),
    resolution: '4K',
    codec: 'HEVC',
    fps: 59.94,
    bitrateMbps: 24.8,
    fileSizeBytes: 24500000000,
    folderPath: '/storage/emulated/0/Movies',
    dateAdded: DateTime(2024, 1, 15),
    audioTracks: const [
      AudioTrackInfo(
        id: 'a1',
        title: 'English 5.1',
        language: 'English',
        channels: '5.1',
        codec: 'AC-3',
        bitrateKbps: 640,
        isDefault: true,
      ),
      AudioTrackInfo(
        id: 'a2',
        title: 'Bengali 2.0',
        language: 'Bengali',
        channels: '2.0',
        codec: 'AAC',
        bitrateKbps: 192,
      ),
    ],
    subtitleTracks: const ['English', 'Bengali', 'Off'],
    gradientStart: const Color(0xFF003B73),
    gradientEnd: const Color(0xFF001F3F),
  );

  Widget createPanelWrapper({
    bool isPlaying = false,
    Duration currentPosition = const Duration(hours: 1, minutes: 12, seconds: 16),
    int skipForward = 10,
    int skipBackward = 10,
    bool autoplayNext = true,
    DecoderMode decoder = DecoderMode.hardware,
    PlayerScalingMode scaling = PlayerScalingMode.fit,
    double zoom = 1.0,
    int audioDelay = 0,
    String volumeBoost = 'Off',
    int subtitleDelay = 0,
    String subtitleStyle = 'Default',
    Duration? abA,
    Duration? abB,
    bool abEnabled = false,
    SleepTimerOption sleepTimer = SleepTimerOption.off,
    bool statsOverlay = false,
    bool isLocked = false,
    ValueChanged<int>? onSkipForward,
    ValueChanged<int>? onSkipBackward,
    ValueChanged<bool>? onAutoplayNext,
    ValueChanged<DecoderMode>? onDecoder,
    ValueChanged<double>? onZoom,
    ValueChanged<int>? onAudioDelay,
    ValueChanged<String>? onVolumeBoost,
    ValueChanged<int>? onSubtitleDelay,
    ValueChanged<String>? onSubtitleStyle,
    void Function(Duration?, Duration?, bool)? onAbRepeat,
    ValueChanged<SleepTimerOption>? onSleepTimer,
    ValueChanged<bool>? onStatsOverlay,
    VoidCallback? onLock,
    VoidCallback? onStepBackward,
    VoidCallback? onStepForward,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  AdvancedPlayerPanel.show(
                    context,
                    video: sampleVideo,
                    currentPosition: currentPosition,
                    totalDuration: sampleVideo.duration,
                    isPlaying: isPlaying,
                    skipForwardSeconds: skipForward,
                    skipBackwardSeconds: skipBackward,
                    autoplayNext: autoplayNext,
                    currentDecoder: decoder,
                    scalingMode: scaling,
                    currentZoom: zoom,
                    audioDelayMs: audioDelay,
                    volumeBoost: volumeBoost,
                    activeAudioTrack: sampleVideo.audioTracks.first,
                    activeSubtitleTrack: 'English',
                    subtitleDelayMs: subtitleDelay,
                    subtitleStyleName: subtitleStyle,
                    abRepeatA: abA,
                    abRepeatB: abB,
                    abRepeatEnabled: abEnabled,
                    sleepTimerOption: sleepTimer,
                    isStatsOverlayEnabled: statsOverlay,
                    isScreenLocked: isLocked,
                    onSkipForwardChanged: onSkipForward ?? (_) {},
                    onSkipBackwardChanged: onSkipBackward ?? (_) {},
                    onAutoplayNextChanged: onAutoplayNext ?? (_) {},
                    onDecoderChanged: onDecoder ?? (_) {},
                    onScalingModeChanged: (_) {},
                    onZoomChanged: onZoom ?? (_) {},
                    onAudioDelayChanged: onAudioDelay ?? (_) {},
                    onVolumeBoostChanged: onVolumeBoost ?? (_) {},
                    onAudioTrackChanged: (_) {},
                    onSubtitleTrackChanged: (_) {},
                    onSubtitleDelayChanged: onSubtitleDelay ?? (_) {},
                    onSubtitleStyleChanged: onSubtitleStyle ?? (_) {},
                    onAbRepeatChanged: onAbRepeat ?? (_, __, ___) {},
                    onSleepTimerChanged: onSleepTimer ?? (_) {},
                    onStatsOverlayToggle: onStatsOverlay ?? (_) {},
                    onToggleScreenLock: onLock ?? () {},
                    onStepFrameBackward: onStepBackward ?? () {},
                    onStepFrameForward: onStepForward ?? () {},
                    onEnterPip: () {},
                  );
                },
                child: const Text('Open More Panel'),
              ),
            );
          },
        ),
      ),
    );
  }

  group('AdvancedPlayerPanel Core Architecture & Interactions', () {
    testWidgets('renders More Panel with header, quick tools, and all 4 sections', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(createPanelWrapper());
      await tester.pump();

      // Open panel
      await tester.tap(find.text('Open More Panel'));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Player Controls'), findsOneWidget);
      expect(find.text('Interstellar.mkv'), findsOneWidget);

      // Quick tools
      expect(find.text('Repeat'), findsOneWidget);
      expect(find.text('Timer'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
      expect(find.text('Decoder'), findsNWidgets(2)); // Quick tool & Video section

      // Section headers
      expect(find.text('PLAYBACK'), findsOneWidget);
      expect(find.text('VIDEO'), findsOneWidget);
      expect(find.text('AUDIO'), findsOneWidget);
      expect(find.text('SUBTITLES'), findsOneWidget);

      // Playback rows
      expect(find.text('Skip forward'), findsOneWidget);
      expect(find.text('Skip backward'), findsOneWidget);
      expect(find.text('Auto-play next'), findsOneWidget);
      expect(find.text('Frame Step'), findsOneWidget);

      // Video rows
      expect(find.text('Aspect ratio'), findsOneWidget);
      expect(find.text('Zoom'), findsOneWidget);
      expect(find.text('Screen Lock'), findsOneWidget);

      // Audio rows
      expect(find.text('Audio delay'), findsOneWidget);
      expect(find.text('Volume boost'), findsOneWidget);
      expect(find.text('Audio track'), findsOneWidget);

      // Subtitles rows
      expect(find.text('Subtitle track'), findsOneWidget);
      expect(find.text('Subtitle delay'), findsOneWidget);
      expect(find.text('Subtitle style'), findsOneWidget);
    });

    testWidgets('tapping Skip forward opens selection sheet and changes value', (tester) async {
      setLandscapeViewport(tester);
      int? updatedSkip;
      await tester.pumpWidget(createPanelWrapper(
        onSkipForward: (val) => updatedSkip = val,
      ));
      await tester.pump();

      // Open panel
      await tester.tap(find.text('Open More Panel'));
      await tester.pumpAndSettle();

      // Tap Skip forward row
      await tester.tap(find.text('Skip forward'));
      await tester.pumpAndSettle();

      // Options sheet
      expect(find.text('5 sec'), findsOneWidget);
      expect(find.text('15 sec'), findsOneWidget);
      expect(find.text('30 sec'), findsOneWidget);
      expect(find.text('60 sec'), findsOneWidget);

      // Select 30 sec
      await tester.tap(find.text('30 sec'));
      await tester.pumpAndSettle();

      expect(updatedSkip, equals(30));
    });

    testWidgets('quick tool A-B Repeat opens ABRepeatSheet and sets points', (tester) async {
      setLandscapeViewport(tester);
      Duration? capturedA;

      await tester.pumpWidget(createPanelWrapper(
        currentPosition: const Duration(hours: 1, minutes: 12, seconds: 16),
        onAbRepeat: (a, b, enabled) {
          capturedA = a;
        },
      ));
      await tester.pump();

      // Open panel
      await tester.tap(find.text('Open More Panel'));
      await tester.pumpAndSettle();

      // Tap Quick tool Repeat
      await tester.tap(find.text('Repeat'));
      await tester.pumpAndSettle();

      // AB Repeat Sheet appears
      expect(find.byType(ABRepeatSheet), findsOneWidget);
      expect(find.text('A-B Repeat'), findsOneWidget);
      expect(find.text('Point A'), findsOneWidget);
      expect(find.text('Point B'), findsOneWidget);

      // Tap Set A button
      await tester.tap(find.textContaining('Set A'));
      await tester.pump();

      expect(capturedA, equals(const Duration(hours: 1, minutes: 12, seconds: 16)));

      // Done
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });

    testWidgets('quick tool Sleep Timer opens SleepTimerSheet and selects option', (tester) async {
      setLandscapeViewport(tester);
      SleepTimerOption? selectedTimer;

      await tester.pumpWidget(createPanelWrapper(
        onSleepTimer: (opt) => selectedTimer = opt,
      ));
      await tester.pump();

      // Open panel
      await tester.tap(find.text('Open More Panel'));
      await tester.pumpAndSettle();

      // Tap Quick tool Timer
      await tester.tap(find.text('Timer'));
      await tester.pumpAndSettle();

      // Sleep timer sheet
      expect(find.byType(SleepTimerSheet), findsOneWidget);
      expect(find.text('Playback will stop automatically.'), findsOneWidget);
      expect(find.text('15 minutes'), findsOneWidget);
      expect(find.text('30 minutes'), findsOneWidget);
      expect(find.text('End of video'), findsOneWidget);

      // Select 45 minutes
      await tester.tap(find.text('45 minutes'));
      await tester.pumpAndSettle();

      expect(selectedTimer, equals(SleepTimerOption.fortyFive));
    });

    testWidgets('quick tool Stats opens FocusedStatsSheet and shows detailed hardware specs', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(createPanelWrapper());
      await tester.pump();

      // Open panel
      await tester.tap(find.text('Open More Panel'));
      await tester.pumpAndSettle();

      // Tap Quick tool Stats
      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();

      // Focused stats sheet
      expect(find.byType(FocusedStatsSheet), findsOneWidget);
      expect(find.text('Playback Statistics'), findsOneWidget);
      expect(find.text('3840 × 2160'), findsOneWidget);
      expect(find.text('HEVC / H.265 Main 10'), findsOneWidget);
      expect(find.text('59.94 FPS'), findsOneWidget);
      expect(find.text('Hardware'), findsOneWidget);
      expect(find.text('Floating Nerd Stats Overlay'), findsOneWidget);
    });

    testWidgets('Audio Delay row opens DelayControlSheet with smooth slider and nudge buttons', (tester) async {
      setLandscapeViewport(tester);
      int? updatedDelay;

      await tester.pumpWidget(createPanelWrapper(
        onAudioDelay: (d) => updatedDelay = d,
      ));
      await tester.pump();

      // Open panel
      await tester.tap(find.text('Open More Panel'));
      await tester.pumpAndSettle();

      // Scroll and tap Audio delay
      await tester.scrollUntilVisible(find.text('Audio delay'), 60);
      await tester.tap(find.text('Audio delay'));
      await tester.pumpAndSettle();

      // Delay sheet appears
      expect(find.byType(DelayControlSheet), findsOneWidget);
      expect(find.text('-50 ms'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('+50 ms'), findsOneWidget);

      // Tap +50ms nudge button
      await tester.tap(find.text('+50 ms'));
      await tester.pump();

      expect(updatedDelay, equals(50));

      // Done
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });

    testWidgets('Subtitle Style row opens SubtitleCustomizationSheet with live preview', (tester) async {
      setLandscapeViewport(tester);
      String? selectedStyle;

      await tester.pumpWidget(createPanelWrapper(
        onSubtitleStyle: (s) => selectedStyle = s,
      ));
      await tester.pump();

      // Open panel
      await tester.tap(find.text('Open More Panel'));
      await tester.pumpAndSettle();

      // Scroll and tap Subtitle style
      await tester.scrollUntilVisible(find.text('Subtitle style'), 60);
      await tester.tap(find.text('Subtitle style'));
      await tester.pumpAndSettle();

      // Subtitle style sheet
      expect(find.byType(SubtitleCustomizationSheet), findsOneWidget);
      expect(find.text('We used to look up at the sky and wonder.'), findsOneWidget);
      expect(find.text('FONT SIZE'), findsOneWidget);
      expect(find.text('TEXT COLOR'), findsOneWidget);
      expect(find.text('BACKGROUND'), findsOneWidget);
      expect(find.text('EDGE STYLE'), findsOneWidget);

      // Tap Large
      await tester.tap(find.text('Large'));
      await tester.pump();

      // Apply
      await tester.tap(find.text('Apply Style'));
      await tester.pumpAndSettle();

      expect(selectedStyle, equals('Large • Translucent'));
    });

    testWidgets('Zoom row opens ZoomControlSheet with presets and slider', (tester) async {
      setLandscapeViewport(tester);
      double? updatedZoom;

      await tester.pumpWidget(createPanelWrapper(
        onZoom: (z) => updatedZoom = z,
      ));
      await tester.pump();

      // Open panel
      await tester.tap(find.text('Open More Panel'));
      await tester.pumpAndSettle();

      // Scroll and tap Zoom
      await tester.scrollUntilVisible(find.text('Zoom'), 60);
      await tester.tap(find.text('Zoom'));
      await tester.pumpAndSettle();

      // Zoom sheet appears
      expect(find.byType(ZoomControlSheet), findsOneWidget);
      expect(find.text('Video Zoom'), findsOneWidget);
      expect(find.text('1.50×'), findsOneWidget);

      // Tap 1.5x preset
      await tester.tap(find.text('1.50×'));
      await tester.pump();

      expect(updatedZoom, equals(1.5));

      // Done
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });

    testWidgets('Frame Step buttons trigger stepping callbacks when video is paused', (tester) async {
      setLandscapeViewport(tester);
      int backwardCount = 0;
      int forwardCount = 0;

      await tester.pumpWidget(createPanelWrapper(
        isPlaying: false,
        onStepBackward: () => backwardCount++,
        onStepForward: () => forwardCount++,
      ));
      await tester.pump();

      // Open panel
      await tester.tap(find.text('Open More Panel'));
      await tester.pumpAndSettle();

      // Frame counter visible
      expect(find.text('Frame Step'), findsOneWidget);
      expect(find.textContaining('Frame '), findsWidgets);

      // Tap previous frame
      await tester.tap(find.byIcon(Icons.skip_previous_rounded));
      await tester.pump();
      expect(backwardCount, equals(1));

      // Tap next frame
      await tester.tap(find.byIcon(Icons.skip_next_rounded));
      await tester.pump();
      expect(forwardCount, equals(1));
    });
  });
}
