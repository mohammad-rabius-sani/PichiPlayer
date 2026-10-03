import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/models/player_types.dart';
import 'package:pichi_player/ui/widgets/player/more_panel/sleep_timer_sheet.dart';

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
    SleepTimerOption currentOption = SleepTimerOption.off,
    ValueChanged<SleepTimerOption>? onOptionSelected,
    DateTime? targetEndTime,
    Duration? remainingTime,
    VoidCallback? onCancelTimer,
    ValueChanged<Duration>? onExtendTimer,
    ValueChanged<Duration>? onCustomDurationSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                SleepTimerSheet.show(
                  context,
                  currentOption: currentOption,
                  onOptionSelected: onOptionSelected ?? (_) {},
                  targetEndTime: targetEndTime,
                  remainingTime: remainingTime,
                  onCancelTimer: onCancelTimer,
                  onExtendTimer: onExtendTimer,
                  onCustomDurationSelected: onCustomDurationSelected,
                );
              },
              child: const Text('Open Sleep Timer'),
            ),
          ),
        ),
      ),
    );
  }

  group('SleepTimerSheet Comprehensive Tests', () {
    testWidgets('Renders header with title, subtitle, and close button', (tester) async {
      setViewport(tester);
      await tester.pumpWidget(buildTestSheet());

      await tester.tap(find.text('Open Sleep Timer'));
      await tester.pumpAndSettle();

      expect(find.text('Sleep Timer'), findsOneWidget);
      expect(find.text('Stop playback automatically'), findsOneWidget);
      expect(find.byKey(const ValueKey('sleep_timer_close_btn')), findsOneWidget);

      // Tap close button
      await tester.tap(find.byKey(const ValueKey('sleep_timer_close_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Sleep Timer'), findsNothing);
    });

    testWidgets('Renders quick presets and inactive hero state', (tester) async {
      setViewport(tester);
      await tester.pumpWidget(buildTestSheet(currentOption: SleepTimerOption.off));

      await tester.tap(find.text('Open Sleep Timer'));
      await tester.pumpAndSettle();

      expect(find.text('No timer set'), findsOneWidget);
      expect(find.text('QUICK PRESETS'), findsOneWidget);
      expect(find.byKey(const ValueKey('sleep_preset_fifteen')), findsOneWidget);
      expect(find.byKey(const ValueKey('sleep_preset_thirty')), findsOneWidget);
      expect(find.byKey(const ValueKey('sleep_preset_fortyFive')), findsOneWidget);
      expect(find.byKey(const ValueKey('sleep_preset_sixty')), findsOneWidget);
      expect(find.byKey(const ValueKey('sleep_preset_endOfVideo')), findsOneWidget);
      expect(find.text('Stop when this video finishes'), findsOneWidget);
    });

    testWidgets('Tapping preset immediately selects it and starts countdown', (tester) async {
      setViewport(tester);
      SleepTimerOption? selectedOption;

      await tester.pumpWidget(buildTestSheet(
        currentOption: SleepTimerOption.off,
        onOptionSelected: (opt) => selectedOption = opt,
      ));

      await tester.tap(find.text('Open Sleep Timer'));
      await tester.pumpAndSettle();

      // Tap 30 min preset
      await tester.tap(find.byKey(const ValueKey('sleep_preset_thirty')));
      await tester.pump();

      expect(selectedOption, equals(SleepTimerOption.thirty));
      expect(find.text('Sleep timer set: 30 minutes'), findsOneWidget);
      expect(find.text('Timer active'), findsOneWidget);
      expect(find.text('remaining'), findsOneWidget);
    });

    testWidgets('Active timer state displays large countdown, +10, +30, and Cancel Timer', (tester) async {
      setViewport(tester);
      Duration? extendedDuration;
      bool cancelCalled = false;

      await tester.pumpWidget(buildTestSheet(
        currentOption: SleepTimerOption.thirty,
        remainingTime: const Duration(minutes: 29, seconds: 42),
        onExtendTimer: (ext) => extendedDuration = ext,
        onCancelTimer: () => cancelCalled = true,
      ));

      await tester.tap(find.text('Open Sleep Timer'));
      await tester.pumpAndSettle();

      expect(find.text('Timer active'), findsOneWidget);
      expect(find.text('remaining'), findsOneWidget);
      expect(find.byKey(const ValueKey('sleep_timer_plus_10')), findsOneWidget);
      expect(find.byKey(const ValueKey('sleep_timer_plus_30')), findsOneWidget);
      expect(find.byKey(const ValueKey('sleep_timer_cancel_btn')), findsOneWidget);

      // Tap +10 min
      await tester.tap(find.byKey(const ValueKey('sleep_timer_plus_10')));
      await tester.pump();

      expect(extendedDuration, equals(const Duration(minutes: 10)));
      expect(find.text('Timer extended (+10 min)'), findsOneWidget);

      // Tap +30 min
      await tester.tap(find.byKey(const ValueKey('sleep_timer_plus_30')));
      await tester.pump();

      expect(extendedDuration, equals(const Duration(minutes: 30)));
      expect(find.text('Timer extended (+30 min)'), findsOneWidget);

      // Tap Cancel Timer
      await tester.tap(find.byKey(const ValueKey('sleep_timer_cancel_btn')));
      await tester.pump();

      expect(cancelCalled, isTrue);
      expect(find.text('Timer cancelled'), findsOneWidget);
    });

    testWidgets('End of video option displays clear non-fake countdown message', (tester) async {
      setViewport(tester);

      await tester.pumpWidget(buildTestSheet(
        currentOption: SleepTimerOption.endOfVideo,
      ));

      await tester.tap(find.text('Open Sleep Timer'));
      await tester.pumpAndSettle();

      expect(find.text('Timer active'), findsOneWidget);
      expect(find.text('Stops when this video ends'), findsOneWidget);
      expect(find.text('Playback will stop automatically. Auto-play next is paused.'), findsOneWidget);
      expect(find.byKey(const ValueKey('sleep_timer_cancel_btn')), findsOneWidget);
    });

    testWidgets('Custom duration slider and exact time picker operate accurately', (tester) async {
      setViewport(tester);
      Duration? customDuration;

      await tester.pumpWidget(buildTestSheet(
        currentOption: SleepTimerOption.off,
        onCustomDurationSelected: (dur) => customDuration = dur,
      ));

      await tester.tap(find.text('Open Sleep Timer'));
      await tester.pumpAndSettle();

      // Scroll to custom duration
      final customSection = find.text('CUSTOM DURATION');
      await tester.scrollUntilVisible(customSection, 100);
      expect(customSection, findsOneWidget);

      // Check slider
      final sliderFinder = find.byKey(const ValueKey('sleep_timer_slider'));
      expect(sliderFinder, findsOneWidget);

      // Toggle exact picker
      final exactBtn = find.byKey(const ValueKey('sleep_timer_exact_time_btn'));
      await tester.tap(exactBtn);
      await tester.pumpAndSettle();

      expect(find.text('EXACT TIME PICKER'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Minutes'), findsOneWidget);
      expect(find.byKey(const ValueKey('exact_time_done_btn')), findsOneWidget);

      // Tap Done
      await tester.tap(find.byKey(const ValueKey('exact_time_done_btn')));
      await tester.pump();

      expect(customDuration, isNotNull);
      expect(customDuration!.inMinutes, equals(30));
    });
  });
}
