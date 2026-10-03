import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/models/subtitle_style_config.dart';
import 'package:pichi_player/ui/screens/subtitle_style_screen.dart';

void main() {
  Widget buildTestableScreen({
    SubtitleStyleConfig? initialConfig,
    ValueChanged<SubtitleStyleConfig>? onConfigChanged,
  }) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF06080D),
      ),
      home: SubtitleStyleScreen(
        initialConfig: initialConfig,
        onConfigChanged: onConfigChanged,
      ),
    );
  }

  void setPortraitViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  void setLandscapeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Finder findVerticalControlsList() =>
      find.byWidgetPredicate((w) => w is ListView && w.scrollDirection == Axis.vertical);

  Finder findHorizontalPresetsList() =>
      find.byWidgetPredicate((w) => w is ListView && w.scrollDirection == Axis.horizontal);

  group('SubtitleStyleScreen Core Visual Studio & Layout Tests', () {
    testWidgets('renders top app bar, reset button, and cinematic live preview', (tester) async {
      setPortraitViewport(tester);
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // Top app bar
      expect(find.text('Subtitle Style'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Live preview panel
      expect(find.text('LIVE PREVIEW'), findsOneWidget);
      expect(find.text('“The stars are beautiful.”'), findsOneWidget);

      // Section headers
      expect(find.text('PRESETS'), findsOneWidget);
      expect(find.text('TEXT SIZE'), findsOneWidget);
      expect(find.text('FONT'), findsOneWidget);
      expect(find.text('TEXT COLOR'), findsOneWidget);
    });

    testWidgets('presets carousel renders all presets and switches live', (tester) async {
      setPortraitViewport(tester);
      SubtitleStyleConfig? updatedConfig;

      await tester.pumpWidget(buildTestableScreen(
        onConfigChanged: (config) => updatedConfig = config,
      ));
      await tester.pumpAndSettle();

      // Verify preset labels in carousel
      expect(find.text('Classic'), findsOneWidget);
      expect(find.text('Modern'), findsOneWidget);
      expect(find.text('Cinema'), findsOneWidget);

      // Tap "Classic" preset (on screen)
      await tester.tap(find.byKey(const ValueKey('preset_Classic')));
      await tester.pumpAndSettle();

      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.presetName, equals('Classic'));
      expect(updatedConfig!.backgroundType, equals(SubtitleBackgroundType.none));

      // Scroll horizontal carousel to reveal High Contrast
      await tester.drag(findHorizontalPresetsList(), const Offset(-250, 0));
      await tester.pumpAndSettle();

      expect(find.text('High Contrast'), findsOneWidget);

      // Tap "High Contrast" preset
      await tester.tap(find.byKey(const ValueKey('preset_High Contrast')));
      await tester.pumpAndSettle();

      expect(updatedConfig!.presetName, equals('High Contrast'));
      expect(updatedConfig!.fontSizePercent, equals(125));
      expect(updatedConfig!.textColor, equals(const Color(0xFFFDE047)));
      expect(updatedConfig!.outlineStyle, equals(SubtitleOutlineStyle.thick));
    });

    testWidgets('text size slider updates percentage and fires onConfigChanged', (tester) async {
      setPortraitViewport(tester);
      SubtitleStyleConfig? updatedConfig;

      await tester.pumpWidget(buildTestableScreen(
        onConfigChanged: (config) => updatedConfig = config,
      ));
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);

      // Find the text size slider
      final sliderFinder = find.byType(Slider).first;
      expect(sliderFinder, findsOneWidget);

      // Drag slider forward
      await tester.drag(sliderFinder, const Offset(60, 0));
      await tester.pumpAndSettle();

      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.fontSizePercent, isNot(equals(100)));
      expect(updatedConfig!.presetName, equals('Custom'));
    });

    testWidgets('font selector row opens bottom sheet and selects Serif font', (tester) async {
      setPortraitViewport(tester);
      SubtitleStyleConfig? updatedConfig;

      await tester.pumpWidget(buildTestableScreen(
        onConfigChanged: (config) => updatedConfig = config,
      ));
      await tester.pumpAndSettle();

      // Tap Font row
      await tester.tap(find.text('System Default'));
      await tester.pumpAndSettle();

      // Sheet opens
      expect(find.text('Select Subtitle Font'), findsOneWidget);
      expect(find.text('Sans Serif'), findsOneWidget);
      expect(find.text('Serif'), findsOneWidget);
      expect(find.text('Monospace'), findsOneWidget);

      // Tap Serif
      await tester.tap(find.byKey(const ValueKey('font_Serif')));
      await tester.pumpAndSettle();

      // Sheet closes and config is updated
      expect(find.text('Select Subtitle Font'), findsNothing);
      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.fontFamily, equals('Serif'));
    });

    testWidgets('text color chips change color immediately and custom button opens picker', (tester) async {
      setPortraitViewport(tester);
      SubtitleStyleConfig? updatedConfig;

      await tester.pumpWidget(buildTestableScreen(
        onConfigChanged: (config) => updatedConfig = config,
      ));
      await tester.pumpAndSettle();

      // Tap Yellow chip
      await tester.tap(find.byKey(const ValueKey('color_Yellow')));
      await tester.pumpAndSettle();

      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.textColor, equals(const Color(0xFFFDE047)));

      // Tap custom color button
      await tester.tap(find.byKey(const ValueKey('color_custom_btn')));
      await tester.pumpAndSettle();

      // Custom color modal opens
      expect(find.text('Custom Text Color'), findsOneWidget);

      // Tap orange custom color (index 0)
      await tester.tap(find.byKey(const ValueKey('custom_color_0')));
      await tester.pumpAndSettle();

      expect(updatedConfig!.textColor, equals(const Color(0xFFF97316)));
    });

    testWidgets('outline, shadow, and background segmented selectors update styling live', (tester) async {
      setPortraitViewport(tester);
      SubtitleStyleConfig? updatedConfig;

      await tester.pumpWidget(buildTestableScreen(
        onConfigChanged: (config) => updatedConfig = config,
      ));
      await tester.pumpAndSettle();

      // Drag vertical controls to reveal outline and shadow
      await tester.drag(findVerticalControlsList(), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Tap Thick outline
      await tester.tap(find.byKey(const ValueKey('chip_Thick')));
      await tester.pumpAndSettle();

      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.outlineStyle, equals(SubtitleOutlineStyle.thick));

      // Tap Strong shadow
      await tester.tap(find.byKey(const ValueKey('chip_Strong')));
      await tester.pumpAndSettle();

      expect(updatedConfig!.shadowStyle, equals(SubtitleShadowStyle.strong));

      // Tap Solid background
      await tester.tap(find.byKey(const ValueKey('chip_Solid')));
      await tester.pumpAndSettle();

      expect(updatedConfig!.backgroundType, equals(SubtitleBackgroundType.solid));
    });

    testWidgets('position and alignment controls adjust subtitle placement', (tester) async {
      setPortraitViewport(tester);
      SubtitleStyleConfig? updatedConfig;

      await tester.pumpWidget(buildTestableScreen(
        onConfigChanged: (config) => updatedConfig = config,
      ));
      await tester.pumpAndSettle();

      // Drag down to position and alignment
      await tester.drag(findVerticalControlsList(), const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);

      // Tap Left alignment
      await tester.tap(find.byKey(const ValueKey('chip_Left')));
      await tester.pumpAndSettle();

      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.alignment, equals(TextAlign.left));

      // Tap Right alignment
      await tester.tap(find.byKey(const ValueKey('chip_Right')));
      await tester.pumpAndSettle();

      expect(updatedConfig!.alignment, equals(TextAlign.right));
    });

    testWidgets('advanced typography and positioning sections expand and collapse', (tester) async {
      setPortraitViewport(tester);
      SubtitleStyleConfig? updatedConfig;

      await tester.pumpWidget(buildTestableScreen(
        onConfigChanged: (config) => updatedConfig = config,
      ));
      await tester.pumpAndSettle();

      // Drag down to advanced typography
      await tester.drag(findVerticalControlsList(), const Offset(0, -450));
      await tester.pumpAndSettle();

      // Tap to expand
      await tester.tap(find.text('Advanced typography'));
      await tester.pumpAndSettle();

      expect(find.text('Font Weight'), findsOneWidget);
      expect(find.text('Regular'), findsOneWidget);
      expect(find.text('Bold'), findsOneWidget);
      expect(find.text('Italic'), findsOneWidget);
      expect(find.text('Letter spacing'), findsOneWidget);
      expect(find.text('Line spacing'), findsOneWidget);

      // Scroll a bit more to ensure Switch is comfortably in center of viewport
      await tester.drag(findVerticalControlsList(), const Offset(0, -150));
      await tester.pumpAndSettle();

      // Toggle Italic switch
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.isItalic, isTrue);

      // Scroll further down to advanced positioning
      await tester.drag(findVerticalControlsList(), const Offset(0, -250));
      await tester.pumpAndSettle();

      // Tap to expand
      await tester.tap(find.text('Advanced positioning'));
      await tester.pumpAndSettle();

      expect(find.text('Corner radius'), findsOneWidget);
      expect(find.text('Bottom margin'), findsOneWidget);
      expect(find.text('Horizontal margin'), findsOneWidget);
      expect(find.text('Respect safe area'), findsOneWidget);
    });

    testWidgets('subtitle appearance toggles between embedded and PIchiPlayer styling', (tester) async {
      setPortraitViewport(tester);
      SubtitleStyleConfig? updatedConfig;

      await tester.pumpWidget(buildTestableScreen(
        onConfigChanged: (config) => updatedConfig = config,
      ));
      await tester.pumpAndSettle();

      // Drag to bottom
      await tester.drag(findVerticalControlsList(), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.drag(findVerticalControlsList(), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Use embedded styling'), findsOneWidget);
      expect(find.text('Use PIchiPlayer styling'), findsOneWidget);

      // Tap "Use PIchiPlayer styling"
      await tester.tap(find.byKey(const ValueKey('chip_Use PIchiPlayer styling')));
      await tester.pumpAndSettle();

      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.useEmbeddedStyling, isFalse);
    });

    testWidgets('Reset button restores default style immediately and shows snackbar', (tester) async {
      setPortraitViewport(tester);
      SubtitleStyleConfig? updatedConfig;

      // Start with Cinema preset
      await tester.pumpWidget(buildTestableScreen(
        initialConfig: SubtitleStyleConfig.cinema(),
        onConfigChanged: (config) => updatedConfig = config,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Cinema'), findsOneWidget);

      // Tap Reset button in top bar
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(find.text('Reset to default subtitle style'), findsOneWidget);
      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.presetName, equals('Modern'));
      expect(updatedConfig!.fontSizePercent, equals(100));
    });

    testWidgets('renders cleanly in landscape layout without clipping', (tester) async {
      setLandscapeViewport(tester);
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // Both preview and controls exist side-by-side
      expect(find.text('LIVE PREVIEW'), findsOneWidget);
      expect(find.text('“The stars are beautiful.”'), findsOneWidget);
      expect(find.text('PRESETS'), findsOneWidget);
      expect(find.text('TEXT SIZE'), findsOneWidget);
    });
  });
}
