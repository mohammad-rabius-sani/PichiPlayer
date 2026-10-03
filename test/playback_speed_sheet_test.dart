import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/ui/widgets/player/playback_speed_sheet.dart';

void setViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  Widget buildTestSheet({
    String selectedSpeed = '1×',
    ValueChanged<String>? onSelected,
    ValueChanged<double>? onSpeedChanged,
    bool holdFor2xEnabled = true,
    ValueChanged<bool>? onHoldFor2xChanged,
    String? videoTitle = 'Interstellar.mkv',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                PlaybackSpeedSheet.show(
                  context,
                  selectedSpeed: selectedSpeed,
                  onSelected: onSelected ?? (_) {},
                  onSpeedChanged: onSpeedChanged,
                  holdFor2xEnabled: holdFor2xEnabled,
                  onHoldFor2xChanged: onHoldFor2xChanged,
                  videoTitle: videoTitle,
                );
              },
              child: const Text('Open Speed Sheet'),
            ),
          ),
        ),
      ),
    );
  }

  group('PlaybackSpeedSheet Tests', () {
    testWidgets('Renders header with title, filename, and close button', (tester) async {
      setViewport(tester);
      await tester.pumpWidget(buildTestSheet(videoTitle: 'Interstellar.mkv'));

      // Open sheet
      await tester.tap(find.text('Open Speed Sheet'));
      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Playback Speed'), findsOneWidget);
      expect(find.text('Interstellar.mkv'), findsOneWidget);
      expect(find.byKey(const ValueKey('speed_sheet_close_btn')), findsOneWidget);

      // Tap close button
      await tester.tap(find.byKey(const ValueKey('speed_sheet_close_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Interstellar.mkv'), findsNothing);
    });

    testWidgets('Renders current speed hero card with tabular readout and status label', (tester) async {
      setViewport(tester);
      await tester.pumpWidget(buildTestSheet(selectedSpeed: '1.25×'));

      await tester.tap(find.text('Open Speed Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('CURRENT RATE'), findsOneWidget);
      expect(find.text('1.25×'), findsAtLeastNWidgets(1));
      expect(find.text('25% faster'), findsOneWidget);
    });

    testWidgets('Renders all 10 quick presets with active indicator and zero Save/Apply buttons', (tester) async {
      setViewport(tester);
      await tester.pumpWidget(buildTestSheet(selectedSpeed: '1×'));

      await tester.tap(find.text('Open Speed Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('QUICK PRESETS'), findsOneWidget);

      // Verify no Save or Apply buttons
      expect(find.text('Save'), findsNothing);
      expect(find.text('Apply'), findsNothing);

      // Check all 10 presets are present
      for (final preset in PlaybackSpeedSheet.presetSpeeds) {
        expect(find.byKey(ValueKey('preset_$preset')), findsOneWidget);
      }
    });

    testWidgets('Tapping quick preset immediately updates speed and dismisses sheet', (tester) async {
      setViewport(tester);
      String? selectedSpeedStr;
      double? selectedSpeedDbl;

      await tester.pumpWidget(buildTestSheet(
        selectedSpeed: '1×',
        onSelected: (s) => selectedSpeedStr = s,
        onSpeedChanged: (d) => selectedSpeedDbl = d,
      ));

      await tester.tap(find.text('Open Speed Sheet'));
      await tester.pumpAndSettle();

      // Tap 1.5× preset
      await tester.tap(find.byKey(const ValueKey('preset_1.5×')));
      await tester.pump();

      // Callback invoked immediately
      expect(selectedSpeedStr, equals('1.5×'));
      expect(selectedSpeedDbl, equals(1.5));

      // Transient feedback is visible
      expect(find.text('Playback speed set to 1.50×'), findsOneWidget);

      // Sheet dismisses after brief preset delay
      await tester.pumpAndSettle();
      expect(find.text('QUICK PRESETS'), findsNothing);
    });

    testWidgets('Custom speed slider updates speed live across range', (tester) async {
      setViewport(tester);
      String? selectedSpeedStr;
      double? selectedSpeedDbl;

      await tester.pumpWidget(buildTestSheet(
        selectedSpeed: '1×',
        onSelected: (s) => selectedSpeedStr = s,
        onSpeedChanged: (d) => selectedSpeedDbl = d,
      ));

      await tester.tap(find.text('Open Speed Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('CUSTOM SPEED'), findsOneWidget);
      expect(find.text('0.25×'), findsNWidgets(2)); // Preset button and slider endpoint
      expect(find.text('4.00×'), findsOneWidget);

      // Drag custom slider to the right
      final sliderFinder = find.byKey(const ValueKey('custom_speed_slider'));
      expect(sliderFinder, findsOneWidget);
      await tester.drag(sliderFinder, const Offset(80, 0));
      await tester.pump();

      expect(selectedSpeedStr, isNotNull);
      expect(selectedSpeedDbl, isNotNull);
      expect(selectedSpeedDbl!, greaterThan(1.0));
    });

    testWidgets('Fine adjustment stepper and nudge chips adjust speed by ±0.05×', (tester) async {
      setViewport(tester);
      double? speedVal;

      await tester.pumpWidget(buildTestSheet(
        selectedSpeed: '1.25×',
        onSpeedChanged: (d) => speedVal = d,
      ));

      await tester.tap(find.text('Open Speed Sheet'));
      await tester.pumpAndSettle();

      final fineSectionFinder = find.text('FINE TUNING (±0.05×)');
      await tester.scrollUntilVisible(fineSectionFinder, 100);
      expect(fineSectionFinder, findsOneWidget);

      // Tap + button (+0.05×)
      final incBtn = find.byKey(const ValueKey('speed_increment_btn'));
      await tester.scrollUntilVisible(incBtn, 100);
      await tester.tap(incBtn);
      await tester.pump();

      expect(speedVal, equals(1.30));

      // Tap - button (-0.05×)
      final decBtn = find.byKey(const ValueKey('speed_decrement_btn'));
      await tester.tap(decBtn);
      await tester.pump();

      expect(speedVal, equals(1.25));

      // Tap nudge chip +0.10×
      final nudgePlus10 = find.text('+0.10×');
      await tester.scrollUntilVisible(nudgePlus10, 100);
      await tester.tap(nudgePlus10);
      await tester.pump();

      expect(speedVal, equals(1.35));
    });

    testWidgets('Hold for 2× preference toggles correctly', (tester) async {
      setViewport(tester);
      bool? holdEnabled;

      await tester.pumpWidget(buildTestSheet(
        holdFor2xEnabled: true,
        onHoldFor2xChanged: (val) => holdEnabled = val,
      ));

      await tester.tap(find.text('Open Speed Sheet'));
      await tester.pumpAndSettle();

      final holdTile = find.text('Hold for 2×');
      await tester.scrollUntilVisible(holdTile, 100);
      expect(holdTile, findsOneWidget);
      expect(find.text('Temporarily play at 2× while holding the video.'), findsOneWidget);

      // Toggle switch
      final switchFinder = find.byKey(const ValueKey('hold_for_2x_switch'));
      await tester.scrollUntilVisible(switchFinder, 100);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(holdEnabled, isFalse);
    });

    testWidgets('Reset button restores 1.00× immediately', (tester) async {
      setViewport(tester);
      double? finalSpeed;

      await tester.pumpWidget(buildTestSheet(
        selectedSpeed: '2×',
        onSpeedChanged: (d) => finalSpeed = d,
      ));

      await tester.tap(find.text('Open Speed Sheet'));
      await tester.pumpAndSettle();

      final resetBtn = find.byKey(const ValueKey('reset_speed_btn'));
      await tester.scrollUntilVisible(resetBtn, 100);
      expect(resetBtn, findsOneWidget);

      // Tap reset
      await tester.tap(resetBtn);
      await tester.pump();

      expect(finalSpeed, equals(1.0));
      expect(find.text('Normal speed'), findsOneWidget);
    });
  });
}
