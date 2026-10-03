import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/models/player_types.dart';
import 'package:pichi_player/ui/widgets/player/display_control_sheet.dart';

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
    PlayerScalingMode selectedMode = PlayerScalingMode.fit,
    ValueChanged<PlayerScalingMode>? onSelected,
    String selectedAspectRatio = 'Auto',
    ValueChanged<String>? onAspectRatioChanged,
    double userZoomScale = 1.0,
    ValueChanged<double>? onZoomChanged,
    Alignment cropAlignment = Alignment.center,
    ValueChanged<Alignment>? onCropAlignmentChanged,
    VoidCallback? onResetDisplay,
    String? videoTitle = 'Interstellar.mkv',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                DisplayControlSheet.show(
                  context,
                  selectedMode: selectedMode,
                  onSelected: onSelected ?? (_) {},
                  selectedAspectRatio: selectedAspectRatio,
                  onAspectRatioChanged: onAspectRatioChanged,
                  userZoomScale: userZoomScale,
                  onZoomChanged: onZoomChanged,
                  cropAlignment: cropAlignment,
                  onCropAlignmentChanged: onCropAlignmentChanged,
                  onResetDisplay: onResetDisplay,
                  videoTitle: videoTitle,
                );
              },
              child: const Text('Open Display Sheet'),
            ),
          ),
        ),
      ),
    );
  }

  group('DisplayControlSheet Tests', () {
    testWidgets('Renders header with title, subtitle, filename, and close button', (tester) async {
      setViewport(tester);
      await tester.pumpWidget(buildTestSheet(videoTitle: 'Interstellar.mkv'));

      // Open sheet
      await tester.tap(find.text('Open Display Sheet'));
      await tester.pumpAndSettle();

      // Check header items
      expect(find.text('Display'), findsOneWidget);
      expect(find.text('Aspect Ratio / Display'), findsOneWidget);
      expect(find.text('Interstellar.mkv'), findsOneWidget);
      expect(find.byKey(const ValueKey('display_sheet_close_btn')), findsOneWidget);

      // Tap close button
      await tester.tap(find.byKey(const ValueKey('display_sheet_close_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Interstellar.mkv'), findsNothing);
    });

    testWidgets('Renders 4 scaling modes with visual diagram previews and zero Save/Apply buttons', (tester) async {
      setViewport(tester);
      await tester.pumpWidget(buildTestSheet(selectedMode: PlayerScalingMode.fit));

      await tester.tap(find.text('Open Display Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('SCALING'), findsOneWidget);

      // Verify no Save or Apply buttons
      expect(find.text('Save'), findsNothing);
      expect(find.text('Apply'), findsNothing);

      // Check 4 scaling modes
      expect(find.byKey(const ValueKey('scaling_mode_fit')), findsOneWidget);
      expect(find.byKey(const ValueKey('scaling_mode_fill')), findsOneWidget);
      expect(find.byKey(const ValueKey('scaling_mode_crop')), findsOneWidget);
      expect(find.byKey(const ValueKey('scaling_mode_original')), findsOneWidget);

      expect(find.text('Fit'), findsOneWidget);
      expect(find.text('Fill'), findsOneWidget);
      expect(find.text('Crop / Zoom'), findsOneWidget);
      expect(find.text('Original (1:1)'), findsOneWidget);

      // Selected mode has checkmark
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('Tapping scaling mode immediately applies and shows transient feedback', (tester) async {
      setViewport(tester);
      PlayerScalingMode? selectedMode;

      await tester.pumpWidget(buildTestSheet(
        selectedMode: PlayerScalingMode.fit,
        onSelected: (mode) => selectedMode = mode,
      ));

      await tester.tap(find.text('Open Display Sheet'));
      await tester.pumpAndSettle();

      // Tap Fill mode
      await tester.tap(find.byKey(const ValueKey('scaling_mode_fill')));
      await tester.pump();

      expect(selectedMode, equals(PlayerScalingMode.fill));
      expect(find.text('Scaling: FILL'), findsOneWidget);

      // Tap Crop mode
      await tester.tap(find.byKey(const ValueKey('scaling_mode_crop')));
      await tester.pump();

      expect(selectedMode, equals(PlayerScalingMode.crop));
      expect(find.text('Scaling: CROP / ZOOM'), findsOneWidget);
    });

    testWidgets('Aspect ratio section displays all ratios and switches immediately', (tester) async {
      setViewport(tester);
      String? changedRatio;

      await tester.pumpWidget(buildTestSheet(
        selectedAspectRatio: 'Auto',
        onAspectRatioChanged: (r) => changedRatio = r,
      ));

      await tester.tap(find.text('Open Display Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('ASPECT RATIO'), findsOneWidget);
      expect(find.text('Auto (Native)'), findsOneWidget);
      expect(find.text('16:9'), findsOneWidget);
      expect(find.text('4:3'), findsOneWidget);
      expect(find.text('21:9'), findsOneWidget);
      expect(find.text('1:1'), findsOneWidget);
      expect(find.text('9:16'), findsOneWidget);

      // Tap 21:9
      await tester.tap(find.byKey(const ValueKey('ratio_21:9')));
      await tester.pump();

      expect(changedRatio, equals('21:9'));
      expect(find.text('Aspect Ratio: 21:9'), findsOneWidget);

      // Tap 16:9
      await tester.tap(find.byKey(const ValueKey('ratio_16:9')));
      await tester.pump();

      expect(changedRatio, equals('16:9'));
      expect(find.text('Aspect Ratio: 16:9'), findsOneWidget);
    });

    testWidgets('Zoom section stepper and slider operate smoothly with snapping', (tester) async {
      setViewport(tester);
      double? changedZoom;

      await tester.pumpWidget(buildTestSheet(
        userZoomScale: 1.00,
        onZoomChanged: (z) => changedZoom = z,
      ));

      await tester.tap(find.text('Open Display Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('ZOOM'), findsOneWidget);
      expect(find.text('1.00×'), findsAtLeastNWidgets(1));

      // Tap + button (+0.05×)
      final incBtn = find.byKey(const ValueKey('zoom_increment_btn'));
      await tester.tap(incBtn);
      await tester.pump();

      expect(changedZoom, isNotNull);
      expect(changedZoom!, greaterThanOrEqualTo(1.05));

      // Tap - button (-0.05×)
      final decBtn = find.byKey(const ValueKey('zoom_decrement_btn'));
      await tester.tap(decBtn);
      await tester.pump();

      expect(changedZoom!, closeTo(1.00, 0.02));

      // Quick zoom chip 2.00x
      await tester.tap(find.text('2.00×'));
      await tester.pump();

      expect(changedZoom, equals(2.00));
      expect(find.text('2.00× Zoom'), findsOneWidget);

      // Drag zoom slider
      final sliderFinder = find.byKey(const ValueKey('zoom_slider'));
      await tester.drag(sliderFinder, const Offset(-50, 0));
      await tester.pump();

      expect(changedZoom, isNotNull);
    });

    testWidgets('Crop positioning row allows selecting Top, Center, Bottom anchor', (tester) async {
      setViewport(tester);
      Alignment? selectedAlignment;

      await tester.pumpWidget(buildTestSheet(
        cropAlignment: Alignment.center,
        onCropAlignmentChanged: (a) => selectedAlignment = a,
      ));

      await tester.tap(find.text('Open Display Sheet'));
      await tester.pumpAndSettle();

      final cropSection = find.text('CROP POSITIONING');
      await tester.scrollUntilVisible(cropSection, 100);
      expect(cropSection, findsOneWidget);

      // Tap Top anchor
      final topBtn = find.byKey(const ValueKey('align_Top'));
      await tester.scrollUntilVisible(topBtn, 100);
      await tester.tap(topBtn);
      await tester.pump();

      expect(selectedAlignment, equals(Alignment.topCenter));

      // Tap Bottom anchor
      final bottomBtn = find.byKey(const ValueKey('align_Bottom'));
      await tester.tap(bottomBtn);
      await tester.pump();

      expect(selectedAlignment, equals(Alignment.bottomCenter));
    });

    testWidgets('Reset Display button restores Fit, Auto, 1.00x, and Center alignment', (tester) async {
      setViewport(tester);
      PlayerScalingMode? finalMode;
      String? finalRatio;
      double? finalZoom;
      Alignment? finalAlign;
      bool resetCalled = false;

      await tester.pumpWidget(buildTestSheet(
        selectedMode: PlayerScalingMode.crop,
        selectedAspectRatio: '21:9',
        userZoomScale: 1.50,
        cropAlignment: Alignment.topCenter,
        onSelected: (m) => finalMode = m,
        onAspectRatioChanged: (r) => finalRatio = r,
        onZoomChanged: (z) => finalZoom = z,
        onCropAlignmentChanged: (a) => finalAlign = a,
        onResetDisplay: () => resetCalled = true,
      ));

      await tester.tap(find.text('Open Display Sheet'));
      await tester.pumpAndSettle();

      final resetBtn = find.byKey(const ValueKey('reset_display_btn'));
      await tester.scrollUntilVisible(resetBtn, 100);
      expect(resetBtn, findsOneWidget);

      // Tap Reset Display
      await tester.tap(resetBtn);
      await tester.pump();

      expect(resetCalled, isTrue);
      expect(finalMode, equals(PlayerScalingMode.fit));
      expect(finalRatio, equals('Auto'));
      expect(finalZoom, equals(1.00));
      expect(finalAlign, equals(Alignment.center));
      expect(find.text('Display reset to Fit (1.00×)'), findsOneWidget);
    });
  });
}
