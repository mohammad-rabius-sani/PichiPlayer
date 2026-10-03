import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/models/local_video.dart';
import 'package:pichi_player/ui/widgets/player/more_panel/ab_repeat_sheet.dart';
import 'package:pichi_player/ui/widgets/player/player_top_bar.dart';

void setViewport(WidgetTester tester, {bool isLandscape = false}) {
  tester.view.physicalSize = isLandscape ? const Size(1600, 900) : const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  final sampleVideo = LocalVideo(
    id: 'test_vid_1',
    title: 'Cinematic_Sample.mp4',
    fileName: 'Cinematic_Sample.mp4',
    duration: const Duration(hours: 1, minutes: 30, seconds: 0),
    resolution: '4K',
    codec: 'HEVC',
    fileSizeBytes: 1024 * 1024 * 500,
    folderPath: '/storage/emulated/0/Movies',
    dateAdded: DateTime.now(),
    gradientStart: const Color(0xFF1E3A8A),
    gradientEnd: const Color(0xFF0F172A),
  );

  Widget buildTestSheet({
    Duration currentPosition = const Duration(minutes: 12, seconds: 30),
    Duration totalDuration = const Duration(hours: 1, minutes: 30, seconds: 0),
    Duration? initialA,
    Duration? initialB,
    bool initialEnabled = false,
    int repeatCount = 0,
    void Function(Duration?, Duration?, bool)? onPointsChanged,
    void Function(int)? onRepeatCountChanged,
    void Function(Duration)? onSeek,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                ABRepeatSheet.show(
                  context,
                  video: sampleVideo,
                  currentPosition: currentPosition,
                  totalDuration: totalDuration,
                  initialA: initialA,
                  initialB: initialB,
                  initialEnabled: initialEnabled,
                  repeatCount: repeatCount,
                  onPointsChanged: onPointsChanged ?? (_, __, ___) {},
                  onRepeatCountChanged: onRepeatCountChanged,
                  onSeek: onSeek,
                );
              },
              child: const Text('Open A-B Repeat'),
            ),
          ),
        ),
      ),
    );
  }

  group('ABRepeatSheet Comprehensive Unit & Widget Tests', () {
    testWidgets('Renders header with title, subtitle, close button, and cinematic preview', (tester) async {
      setViewport(tester);
      await tester.pumpWidget(buildTestSheet());

      await tester.tap(find.text('Open A-B Repeat'));
      await tester.pumpAndSettle();

      // Header verification
      expect(find.text('A-B Repeat'), findsOneWidget);
      expect(find.text('Repeat a section of video'), findsOneWidget);
      expect(find.byKey(const ValueKey('ab_repeat_close_btn')), findsOneWidget);

      // Video preview verification (resolution 4K, video timestamp preview)
      expect(find.text('4K'), findsOneWidget);
      expect(find.text('Playback Position'), findsOneWidget);

      // Close sheet via close button
      await tester.tap(find.byKey(const ValueKey('ab_repeat_close_btn')));
      await tester.pumpAndSettle();
      expect(find.byType(ABRepeatSheet), findsNothing);
    });

    testWidgets('Initial state shows Points not set and Set A primary action', (tester) async {
      setViewport(tester);
      await tester.pumpWidget(buildTestSheet(
        currentPosition: const Duration(minutes: 5, seconds: 20),
      ));

      await tester.tap(find.text('Open A-B Repeat'));
      await tester.pumpAndSettle();

      expect(find.text('Point A'), findsOneWidget);
      expect(find.text('Point B'), findsOneWidget);
      expect(find.text('Not set'), findsNWidgets(2));

      // Primary button is Set A with formatted current timestamp
      expect(find.textContaining('Set A (05:20)'), findsOneWidget);
    });

    testWidgets('Setting Point A updates A, triggers callback, and reveals Set B', (tester) async {
      setViewport(tester);
      Duration? capturedA;
      Duration? capturedB;
      bool? capturedEnabled;

      await tester.pumpWidget(buildTestSheet(
        currentPosition: const Duration(minutes: 10, seconds: 15),
        onPointsChanged: (a, b, enabled) {
          capturedA = a;
          capturedB = b;
          capturedEnabled = enabled;
        },
      ));

      await tester.tap(find.text('Open A-B Repeat'));
      await tester.pumpAndSettle();

      // Tap Set A
      await tester.tap(find.textContaining('Set A'));
      await tester.pumpAndSettle();

      expect(capturedA, equals(const Duration(minutes: 10, seconds: 15)));
      expect(capturedB, isNull);
      expect(capturedEnabled, isFalse);

      // Brief feedback text displayed
      expect(find.text('A point set'), findsOneWidget);

      // Point A readout updated
      expect(find.text('10:15'), findsWidgets);

      // Primary action changed to Set B
      expect(find.textContaining('Set B'), findsOneWidget);
    });

    testWidgets('Setting Point B enables repeat, shows active range, and action buttons', (tester) async {
      setViewport(tester);
      Duration? capturedA;
      Duration? capturedB;
      bool? capturedEnabled;

      await tester.pumpWidget(buildTestSheet(
        currentPosition: const Duration(minutes: 15, seconds: 45),
        initialA: const Duration(minutes: 10, seconds: 0),
        onPointsChanged: (a, b, enabled) {
          capturedA = a;
          capturedB = b;
          capturedEnabled = enabled;
        },
      ));

      await tester.tap(find.text('Open A-B Repeat'));
      await tester.pumpAndSettle();

      // Tap Set B
      await tester.tap(find.textContaining('Set B'));
      await tester.pumpAndSettle();

      expect(capturedA, equals(const Duration(minutes: 10, seconds: 0)));
      expect(capturedB, equals(const Duration(minutes: 15, seconds: 45)));
      expect(capturedEnabled, isTrue);

      // Brief feedback text
      expect(find.text('B point set'), findsOneWidget);

      // Repeat Section card active with ON badge
      expect(find.text('Repeat section'), findsOneWidget);
      expect(find.text('ON'), findsOneWidget);

      // Actions available: Disable Repeat & Clear Points
      expect(find.text('Disable Repeat'), findsOneWidget);
      expect(find.text('Clear Points'), findsOneWidget);
    });

    testWidgets('Disable Repeat stops looping but keeps A and B positions intact', (tester) async {
      setViewport(tester);
      Duration? capturedA;
      Duration? capturedB;
      bool? capturedEnabled;

      await tester.pumpWidget(buildTestSheet(
        initialA: const Duration(minutes: 12, seconds: 0),
        initialB: const Duration(minutes: 18, seconds: 30),
        initialEnabled: true,
        onPointsChanged: (a, b, enabled) {
          capturedA = a;
          capturedB = b;
          capturedEnabled = enabled;
        },
      ));

      await tester.tap(find.text('Open A-B Repeat'));
      await tester.pumpAndSettle();

      // Initially enabled
      expect(find.text('Disable Repeat'), findsOneWidget);
      expect(find.text('ON'), findsOneWidget);

      // Tap Disable Repeat
      await tester.tap(find.text('Disable Repeat'));
      await tester.pumpAndSettle();

      expect(capturedA, equals(const Duration(minutes: 12, seconds: 0)));
      expect(capturedB, equals(const Duration(minutes: 18, seconds: 30)));
      expect(capturedEnabled, isFalse);

      expect(find.text('Enable Repeat'), findsOneWidget);
      expect(find.text('OFF'), findsOneWidget);

      // Re-enable repeat
      await tester.tap(find.text('Enable Repeat'));
      await tester.pumpAndSettle();

      expect(capturedEnabled, isTrue);
      expect(find.text('Disable Repeat'), findsOneWidget);
      expect(find.text('ON'), findsOneWidget);
    });

    testWidgets('Clear Points resets A, B, and loop state completely without confirmation', (tester) async {
      setViewport(tester);
      Duration? capturedA;
      Duration? capturedB;
      bool? capturedEnabled;

      await tester.pumpWidget(buildTestSheet(
        initialA: const Duration(minutes: 12, seconds: 0),
        initialB: const Duration(minutes: 18, seconds: 30),
        initialEnabled: true,
        onPointsChanged: (a, b, enabled) {
          capturedA = a;
          capturedB = b;
          capturedEnabled = enabled;
        },
      ));

      await tester.tap(find.text('Open A-B Repeat'));
      await tester.pumpAndSettle();

      // Tap Clear Points
      await tester.tap(find.text('Clear Points'));
      await tester.pumpAndSettle();

      expect(capturedA, isNull);
      expect(capturedB, isNull);
      expect(capturedEnabled, isFalse);

      expect(find.text('Points cleared'), findsOneWidget);
      expect(find.text('Not set'), findsNWidgets(2));
      expect(find.textContaining('Set A'), findsOneWidget);
    });

    testWidgets('Repeat Count Selector allows choosing Continuous, 2x, 3x, and 5x', (tester) async {
      setViewport(tester);
      int? selectedCount;

      await tester.pumpWidget(buildTestSheet(
        repeatCount: 0,
        onRepeatCountChanged: (count) => selectedCount = count,
      ));

      await tester.tap(find.text('Open A-B Repeat'));
      await tester.pumpAndSettle();

      expect(find.text('Continuous'), findsOneWidget);
      expect(find.text('2×'), findsOneWidget);
      expect(find.text('3×'), findsOneWidget);
      expect(find.text('5×'), findsOneWidget);

      // Select 3×
      await tester.tap(find.text('3×'));
      await tester.pumpAndSettle();
      expect(selectedCount, equals(3));

      // Select 5×
      await tester.tap(find.text('5×'));
      await tester.pumpAndSettle();
      expect(selectedCount, equals(5));

      // Select Continuous
      await tester.tap(find.text('Continuous'));
      await tester.pumpAndSettle();
      expect(selectedCount, equals(0));
    });

    testWidgets('Timeline handles dragging Marker A and Marker B with clamping', (tester) async {
      setViewport(tester);
      Duration? latestA;
      Duration? latestB;

      await tester.pumpWidget(buildTestSheet(
        initialA: const Duration(minutes: 20),
        initialB: const Duration(minutes: 50),
        initialEnabled: true,
        totalDuration: const Duration(hours: 1, minutes: 40),
        onPointsChanged: (a, b, _) {
          latestA = a;
          latestB = b;
        },
      ));

      await tester.tap(find.text('Open A-B Repeat'));
      await tester.pumpAndSettle();

      // Find Marker A semantics
      final markerAFinder = find.bySemanticsLabel(RegExp(r'A marker at'));
      expect(markerAFinder, findsOneWidget);

      // Drag Marker A forward
      await tester.drag(markerAFinder, const Offset(60, 0));
      await tester.pumpAndSettle();

      expect(latestA, isNotNull);
      expect(latestA!.inMinutes, greaterThan(20));
      expect(latestA!, lessThan(const Duration(minutes: 50)));

      // Find Marker B semantics
      final markerBFinder = find.bySemanticsLabel(RegExp(r'B marker at'));
      expect(markerBFinder, findsOneWidget);

      // Drag Marker B backward
      await tester.drag(markerBFinder, const Offset(-40, 0));
      await tester.pumpAndSettle();

      expect(latestB, isNotNull);
      expect(latestB!, greaterThan(latestA!));
    });

    testWidgets('PlayerTopBar renders A ↔ B badge when repeat is active and opens sheet on tap', (tester) async {
      setViewport(tester);
      bool sheetOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerTopBar(
              video: sampleVideo,
              onBack: () {},
              onLock: () {},
              onToggleStats: () {},
              isStatsEnabled: false,
              onToggleOrientation: () {},
              onOverflow: () {},
              abRepeatBadge: 'A ↔ B',
              onAbRepeatTap: () {
                sheetOpened = true;
              },
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('player_ab_repeat_badge')), findsOneWidget);
      expect(find.text('A ↔ B'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('player_ab_repeat_badge')));
      await tester.pump();

      expect(sheetOpened, isTrue);
    });
  });
}
