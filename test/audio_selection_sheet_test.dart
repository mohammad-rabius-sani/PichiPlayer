import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/models/audio_track_info.dart';
import 'package:pichi_player/ui/widgets/player/audio_selection_sheet.dart';

void setViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  final sampleTracks = [
    const AudioTrackInfo(
      id: 'track_en_main',
      language: 'English',
      title: 'English — Main',
      codec: 'AC-3',
      channels: '5.1',
      bitrateKbps: 640,
      isDefault: true,
      specialLabel: 'Main',
    ),
    const AudioTrackInfo(
      id: 'track_bn_dub',
      language: 'Bengali',
      title: 'Bengali — Dub',
      codec: 'AAC',
      channels: '2.0',
      bitrateKbps: 192,
      isDefault: false,
      specialLabel: 'Dub',
    ),
    const AudioTrackInfo(
      id: 'track_ja_alt',
      language: 'Japanese',
      title: 'Japanese',
      codec: 'E-AC3',
      channels: '5.1',
      bitrateKbps: 448,
      isDefault: false,
      specialLabel: 'Alternate',
    ),
    const AudioTrackInfo(
      id: 'track_en_comm',
      language: 'English',
      title: 'English — Commentary',
      codec: 'AAC',
      channels: '2.0',
      bitrateKbps: 160,
      isDefault: false,
      specialLabel: 'Commentary',
    ),
  ];

  Widget buildTestSheet({
    List<AudioTrackInfo>? audioTracks,
    AudioTrackInfo? selectedTrack,
    ValueChanged<AudioTrackInfo>? onSelected,
    String? videoTitle = 'Interstellar.mkv',
    double volume = 0.72,
    bool isMuted = false,
    ValueChanged<double>? onVolumeChanged,
    VoidCallback? onToggleMute,
    int audioDelayMs = 0,
    ValueChanged<int>? onAudioDelayChanged,
    String volumeBoost = 'Off',
    ValueChanged<String>? onVolumeBoostChanged,
    bool normalizeVolume = false,
    ValueChanged<bool>? onNormalizeVolumeChanged,
    String downmixOption = 'Auto',
    ValueChanged<String>? onDownmixChanged,
    String audioOutputDevice = 'Phone speaker',
  }) {
    final tracks = audioTracks ?? sampleTracks;
    final current = selectedTrack ?? tracks.first;

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AudioSelectionSheet.show(
                  context,
                  audioTracks: tracks,
                  selectedTrack: current,
                  onSelected: onSelected ?? (_) {},
                  videoTitle: videoTitle,
                  volume: volume,
                  isMuted: isMuted,
                  onVolumeChanged: onVolumeChanged,
                  onToggleMute: onToggleMute,
                  audioDelayMs: audioDelayMs,
                  onAudioDelayChanged: onAudioDelayChanged,
                  volumeBoost: volumeBoost,
                  onVolumeBoostChanged: onVolumeBoostChanged,
                  normalizeVolume: normalizeVolume,
                  onNormalizeVolumeChanged: onNormalizeVolumeChanged,
                  downmixOption: downmixOption,
                  onDownmixChanged: onDownmixChanged,
                  audioOutputDevice: audioOutputDevice,
                );
              },
              child: const Text('Open Audio Sheet'),
            ),
          ),
        ),
      ),
    );
  }

  group('AudioSelectionSheet Tests', () {
    testWidgets('Renders header with title, filename, and close button', (tester) async {
      setViewport(tester);
      await tester.pumpWidget(buildTestSheet(videoTitle: 'Interstellar.mkv'));

      // Open sheet
      await tester.tap(find.text('Open Audio Sheet'));
      await tester.pumpAndSettle();

      // Check header items
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Interstellar.mkv'), findsOneWidget);
      expect(find.byKey(const ValueKey('audio_sheet_close_btn')), findsOneWidget);

      // Tap close button
      await tester.tap(find.byKey(const ValueKey('audio_sheet_close_btn')));
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.text('Interstellar.mkv'), findsNothing);
    });

    testWidgets('Renders all audio tracks with metadata and special badges', (tester) async {
      setViewport(tester);
      await tester.pumpWidget(buildTestSheet());

      await tester.tap(find.text('Open Audio Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('AVAILABLE TRACKS'), findsOneWidget);

      // Check titles / languages
      expect(find.text('English — Main'), findsOneWidget);
      expect(find.text('Bengali — Dub'), findsOneWidget);
      expect(find.text('Japanese'), findsOneWidget);
      expect(find.text('English — Commentary'), findsOneWidget);

      // Check metadata formatted lines
      expect(find.text('5.1 • AC-3 • 640 kbps'), findsOneWidget);
      expect(find.text('2.0 • AAC • 192 kbps'), findsOneWidget);
      expect(find.text('5.1 • E-AC3 • 448 kbps'), findsOneWidget);
      expect(find.text('2.0 • AAC • 160 kbps'), findsOneWidget);

      // Check special badges
      expect(find.text('Main'), findsOneWidget);
      expect(find.text('Dub'), findsOneWidget);
      expect(find.text('Alternate'), findsOneWidget);
      expect(find.text('Commentary'), findsOneWidget);

      // Check selected track has checkmark icon
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('Instant track switching without Save or Apply buttons', (tester) async {
      setViewport(tester);
      AudioTrackInfo? switchedTrack;

      await tester.pumpWidget(buildTestSheet(
        onSelected: (track) => switchedTrack = track,
      ));

      await tester.tap(find.text('Open Audio Sheet'));
      await tester.pumpAndSettle();

      // Verify no Save or Apply buttons exist
      expect(find.text('Save'), findsNothing);
      expect(find.text('Apply'), findsNothing);

      // Tap Bengali Dub track
      await tester.tap(find.byKey(const ValueKey('audio_track_track_bn_dub')));
      await tester.pump();

      // Callback invoked immediately
      expect(switchedTrack, isNotNull);
      expect(switchedTrack!.id, equals('track_bn_dub'));
      expect(switchedTrack!.language, equals('Bengali'));

      // Check switching indicator
      expect(find.text('Switching audio to Bengali...'), findsOneWidget);

      // Advance timer for transition completion
      await tester.pump(const Duration(milliseconds: 350));

      // Transient feedback bar appears
      expect(find.text('Audio: Bengali 2.0'), findsOneWidget);

      // Advance timer for transient feedback to dismiss
      await tester.pump(const Duration(milliseconds: 2000));
      expect(find.text('Audio: Bengali 2.0'), findsNothing);
    });

    testWidgets('Volume control slider and mute toggle behave correctly', (tester) async {
      setViewport(tester);
      double? changedVolume;
      bool muteToggled = false;

      await tester.pumpWidget(buildTestSheet(
        volume: 0.72,
        isMuted: false,
        onVolumeChanged: (vol) => changedVolume = vol,
        onToggleMute: () => muteToggled = true,
      ));

      await tester.tap(find.text('Open Audio Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('VOLUME'), findsOneWidget);
      expect(find.text('72%'), findsOneWidget);

      // Tap mute toggle
      await tester.tap(find.byKey(const ValueKey('mute_toggle_btn')));
      await tester.pumpAndSettle();

      expect(muteToggled, isTrue);
      expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);

      // Tap unmute
      await tester.tap(find.byKey(const ValueKey('mute_toggle_btn')));
      await tester.pumpAndSettle();
      expect(find.text('72%'), findsOneWidget);

      // Drag slider
      await tester.drag(find.byType(Slider).first, const Offset(60, 0));
      await tester.pumpAndSettle();
      expect(changedVolume, isNotNull);
    });

    testWidgets('Audio delay expandable section operates with slider and nudge buttons', (tester) async {
      setViewport(tester);
      int? changedDelay;

      await tester.pumpWidget(buildTestSheet(
        audioDelayMs: 0,
        onAudioDelayChanged: (delay) => changedDelay = delay,
      ));

      await tester.tap(find.text('Open Audio Sheet'));
      await tester.pumpAndSettle();

      // Scroll to Audio delay tile if needed
      final delayTile = find.byKey(const ValueKey('audio_delay_tile'));
      await tester.scrollUntilVisible(delayTile, 100);
      expect(find.text('Audio delay'), findsOneWidget);
      expect(find.text('+0 ms'), findsOneWidget);

      // Tap audio delay tile to expand
      await tester.tap(delayTile);
      await tester.pumpAndSettle();

      // Sliders and nudge buttons are visible
      expect(find.text('-500 ms'), findsOneWidget);
      expect(find.text('+500 ms'), findsOneWidget);
      expect(find.text('-50 ms'), findsOneWidget);
      expect(find.text('Reset (0 ms)'), findsOneWidget);
      expect(find.text('+50 ms'), findsOneWidget);

      // Tap +50 ms nudge button
      await tester.tap(find.text('+50 ms'));
      await tester.pumpAndSettle();

      expect(changedDelay, equals(50));
      expect(find.text('+50 ms'), findsAtLeastNWidgets(2)); // Tile and header
    });

    testWidgets('Advanced audio expandable section shows Volume Boost, Normalize, Downmix and Route', (tester) async {
      setViewport(tester);
      String? changedBoost;
      bool? changedNormalize;
      String? changedDownmix;

      await tester.pumpWidget(buildTestSheet(
        onVolumeBoostChanged: (b) => changedBoost = b,
        onNormalizeVolumeChanged: (n) => changedNormalize = n,
        onDownmixChanged: (d) => changedDownmix = d,
        audioOutputDevice: 'Phone speaker',
      ));

      await tester.tap(find.text('Open Audio Sheet'));
      await tester.pumpAndSettle();

      // Scroll to Advanced Audio tile and expand it
      final advancedTile = find.byKey(const ValueKey('advanced_audio_tile'));
      await tester.scrollUntilVisible(advancedTile, 100);
      await tester.tap(advancedTile);
      await tester.pumpAndSettle();

      // Scroll to Volume boost if needed
      final boostFinder = find.text('Volume boost');
      await tester.scrollUntilVisible(boostFinder, 100);
      expect(boostFinder, findsOneWidget);
      expect(find.text('Off'), findsOneWidget);
      expect(find.text('+25%'), findsOneWidget);
      expect(find.text('+50%'), findsOneWidget);
      expect(find.text('+75%'), findsOneWidget);
      expect(find.text('+100%'), findsOneWidget);

      // Tap +50% volume boost
      await tester.tap(find.byKey(const ValueKey('chip_+50%')));
      await tester.pumpAndSettle();
      expect(changedBoost, equals('+50%'));

      // Check normalize volume switch
      final normFinder = find.text('Normalize volume');
      await tester.scrollUntilVisible(normFinder, 100);
      expect(normFinder, findsOneWidget);
      expect(find.text('Evens out sudden loud sounds and quiet dialogue'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('normalize_volume_switch')));
      await tester.pumpAndSettle();
      expect(changedNormalize, isTrue);

      // Check downmix options
      final downmixFinder = find.text('Downmix surround');
      await tester.scrollUntilVisible(downmixFinder, 100);
      expect(downmixFinder, findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
      expect(find.text('Stereo'), findsOneWidget);
      expect(find.text('Preserve surround'), findsOneWidget);

      // Tap Stereo
      await tester.tap(find.byKey(const ValueKey('chip_Stereo')));
      await tester.pumpAndSettle();
      expect(changedDownmix, equals('Stereo'));

      // Check Audio output route display
      final routeFinder = find.text('Audio output');
      await tester.scrollUntilVisible(routeFinder, 100);
      expect(routeFinder, findsOneWidget);
      expect(find.text('Phone speaker'), findsOneWidget);
    });

    testWidgets('Empty state appears when no audio tracks exist', (tester) async {
      setViewport(tester);
      await tester.pumpWidget(buildTestSheet(
        audioTracks: [],
        selectedTrack: const AudioTrackInfo(
          id: 'dummy',
          language: 'None',
          title: 'None',
          codec: 'None',
          channels: '0.0',
        ),
      ));

      await tester.tap(find.text('Open Audio Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('No audio tracks'), findsOneWidget);
      expect(find.text("This video doesn't contain a supported audio track."), findsOneWidget);
      expect(find.byKey(const ValueKey('try_playback_btn')), findsOneWidget);

      // Tap Try playback button dismisses sheet
      await tester.tap(find.byKey(const ValueKey('try_playback_btn')));
      await tester.pumpAndSettle();

      expect(find.text('No audio tracks'), findsNothing);
    });

    testWidgets('Shows warning banner for unsupported audio track and prevents selection', (tester) async {
      setViewport(tester);
      AudioTrackInfo? switchedTrack;

      final tracksWithUnsupported = [
        const AudioTrackInfo(
          id: 'track_1',
          language: 'English',
          title: 'English',
          codec: 'AAC',
          channels: '2.0',
          isSupported: true,
        ),
        const AudioTrackInfo(
          id: 'track_2',
          language: 'English',
          title: 'English DTS-HD',
          codec: 'DTS-HD MA',
          channels: '7.1',
          isSupported: false,
          unsupportedReason: 'Decoder not available on this device',
        ),
      ];

      await tester.pumpWidget(buildTestSheet(
        audioTracks: tracksWithUnsupported,
        selectedTrack: tracksWithUnsupported.first,
        onSelected: (track) => switchedTrack = track,
      ));

      await tester.tap(find.text('Open Audio Sheet'));
      await tester.pumpAndSettle();

      // Tap unsupported track
      await tester.tap(find.byKey(const ValueKey('audio_track_track_2')));
      await tester.pumpAndSettle();

      // Did not switch track
      expect(switchedTrack, isNull);

      // Warning banner appears
      expect(find.text('Audio track unavailable'), findsOneWidget);
      expect(find.text('Try another track'), findsOneWidget);

      // Tapping "Try another track" clears notice
      await tester.tap(find.text('Try another track'));
      await tester.pumpAndSettle();

      expect(find.text('Audio track unavailable'), findsNothing);
    });
  });
}
