import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/models/app_preferences.dart';
import 'package:pichi_player/models/player_types.dart';
import 'package:pichi_player/ui/screens/background_pip_settings_screen.dart';
import 'package:pichi_player/ui/screens/folders_screen.dart';
import 'package:pichi_player/ui/screens/settings_screen.dart';
import 'package:pichi_player/ui/screens/subtitle_style_screen.dart';

void setDeviceViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  group('SettingsScreen Core Architecture & Category Tests', () {
    testWidgets('Renders header with Settings title, supporting text, and back button', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SettingsScreen(),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Customize your PIchiPlayer experience'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Verify no account/profile/social controls are present
      expect(find.text('Account'), findsNothing);
      expect(find.text('Profile'), findsNothing);
      expect(find.byIcon(Icons.person_rounded), findsNothing);
    });

    testWidgets('Renders all primary categories with correct titles and descriptions', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SettingsScreen(),
        ),
      );

      // Playback
      expect(find.text('Playback'), findsOneWidget);
      expect(find.text('Playback, gestures & player behavior'), findsOneWidget);

      // Appearance
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme, layout & visual style'), findsOneWidget);

      // Subtitles
      expect(find.text('Subtitles'), findsOneWidget);
      expect(find.text('Language, style & subtitle behavior'), findsOneWidget);

      // Library
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Scanning, indexing & video discovery'), findsOneWidget);

      // Background & PiP
      expect(find.text('Background & PiP'), findsOneWidget);
      expect(find.text('Playback outside the main player'), findsOneWidget);

      // Storage & Permissions
      expect(find.text('Storage & Permissions'), findsOneWidget);
      expect(find.text('Manage local media access'), findsOneWidget);

      // About
      expect(find.text('PIchiPlayer'), findsOneWidget);
      expect(find.text('Version 1.0.0 (Build 100)'), findsOneWidget);
      expect(find.text('A local-first video player for Android.'), findsOneWidget);
    });

    testWidgets('Playback category: toggling switches and opening speed/orientation sheets', (tester) async {
      setDeviceViewport(tester);
      AppPreferences? capturedPrefs;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SettingsScreen(
            onPreferencesChanged: (p) => capturedPrefs = p,
          ),
        ),
      );

      // Resume playback row
      expect(find.text('Resume playback'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('resume_playback_row')));
      await tester.pump();

      expect(capturedPrefs, isNotNull);
      expect(capturedPrefs!.resumePlayback, isFalse);

      // Auto-play next row
      expect(find.text('Auto-play next'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('autoplay_next_row')));
      await tester.pump();

      expect(capturedPrefs!.autoPlayNext, isFalse);

      // Default speed picker sheet
      expect(find.text('Default speed'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('default_speed_row')));
      await tester.pumpAndSettle();

      expect(find.text('Default Playback Speed'), findsOneWidget);
      expect(find.text('1.5×'), findsOneWidget);

      await tester.tap(find.text('1.5×'));
      await tester.pumpAndSettle();

      expect(capturedPrefs!.defaultSpeed, equals(1.5));
      expect(find.text('1.5×'), findsOneWidget);

      // Orientation picker sheet
      expect(find.text('Orientation'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('orientation_row')));
      await tester.pumpAndSettle();

      expect(find.text('Player Screen Orientation'), findsOneWidget);
      expect(find.text('Landscape'), findsOneWidget);

      await tester.tap(find.text('Landscape'));
      await tester.pumpAndSettle();

      expect(capturedPrefs!.defaultOrientation, equals(PlayerOrientationMode.landscape));
      expect(find.text('Landscape'), findsOneWidget);
    });

    testWidgets('Tapping Playback category card opens detailed playback settings bottom sheet', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SettingsScreen(),
        ),
      );

      await tester.tap(find.text('Playback, gestures & player behavior'));
      await tester.pumpAndSettle();

      expect(find.text('Playback Settings'), findsOneWidget);
      expect(find.text('Hardware Decoding (HW)'), findsOneWidget);
      expect(find.text('Double Tap Seek Interval'), findsOneWidget);
    });

    testWidgets('Appearance category opens appearance modal with theme and glow toggles', (tester) async {
      setDeviceViewport(tester);
      AppPreferences? capturedPrefs;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SettingsScreen(
            onPreferencesChanged: (p) => capturedPrefs = p,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('theme_mode_row')));
      await tester.pumpAndSettle();

      expect(find.text('Appearance Settings'), findsOneWidget);
      expect(find.text('Pure OLED deep black & cinematic navy'), findsOneWidget);
      expect(find.text('Ambient Glow Effects'), findsOneWidget);

      // Toggle glow switch inside sheet
      await tester.tap(find.byType(Switch).last);
      await tester.pump();

      expect(capturedPrefs, isNotNull);
      expect(capturedPrefs!.enableGlowEffects, isFalse);
    });

    testWidgets('Subtitles category: language selector and navigation to SubtitleStyleScreen', (tester) async {
      setDeviceViewport(tester);
      AppPreferences? capturedPrefs;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SettingsScreen(
            onPreferencesChanged: (p) => capturedPrefs = p,
          ),
        ),
      );

      // Preferred language picker
      expect(find.text('Preferred language'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('preferred_language_row')));
      await tester.pumpAndSettle();

      expect(find.text('Preferred Subtitle Language'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);

      await tester.tap(find.text('Spanish'));
      await tester.pumpAndSettle();

      expect(capturedPrefs, isNotNull);
      expect(capturedPrefs!.preferredLanguage, equals('Spanish'));

      // External subtitles toggle
      expect(find.text('External subtitles'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('external_subtitles_row')));
      await tester.pump();

      expect(capturedPrefs!.externalSubtitlesEnabled, isFalse);

      // Subtitle style row navigates to SubtitleStyleScreen
      expect(find.text('Subtitle style'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('subtitle_style_row')));
      await tester.pumpAndSettle();

      expect(find.byType(SubtitleStyleScreen), findsOneWidget);
    });

    testWidgets('Library category: toggle auto scan, hidden folders, and navigate to FoldersScreen', (tester) async {
      setDeviceViewport(tester);
      AppPreferences? capturedPrefs;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SettingsScreen(
            onPreferencesChanged: (p) => capturedPrefs = p,
          ),
        ),
      );

      // Automatic library updates toggle
      expect(find.text('Automatic library updates'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('auto_scan_library_row')));
      await tester.pump();

      expect(capturedPrefs, isNotNull);
      expect(capturedPrefs!.autoScanLibrary, isFalse);

      // Hidden folders toggle
      expect(find.text('Hidden folders'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('hidden_folders_row')));
      await tester.pump();

      expect(capturedPrefs!.showHiddenFolders, isTrue);

      // Scan folders row navigates to FoldersScreen
      expect(find.text('Scan folders'), findsOneWidget);
      expect(find.text('4 locations'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('scan_folders_row')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(FoldersScreen), findsOneWidget);
    });

    testWidgets('Background & PiP category navigates to BackgroundPipSettingsScreen', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SettingsScreen(),
        ),
      );

      expect(find.text('Background playback'), findsOneWidget);
      expect(find.text('Picture-in-Picture'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('bg_playback_summary_row')));
      await tester.pumpAndSettle();

      expect(find.byType(BackgroundPipSettingsScreen), findsOneWidget);
    });

    testWidgets('Storage & Permissions card: shows status, clears thumbnail cache and history separately', (tester) async {
      setDeviceViewport(tester);
      AppPreferences? capturedPrefs;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SettingsScreen(
            onPreferencesChanged: (p) => capturedPrefs = p,
          ),
        ),
      );

      expect(find.text('STORAGE ACCESS'), findsOneWidget);
      expect(find.text('Internal storage'), findsOneWidget);
      expect(find.text('SD card'), findsOneWidget);

      // Clear thumbnail cache
      expect(find.text('Clear thumbnail cache'), findsOneWidget);
      expect(find.text('48.0 MB'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('clear_thumbnail_cache_tile')));
      await tester.pump();

      expect(capturedPrefs, isNotNull);
      expect(capturedPrefs!.thumbnailCacheSizeBytes, equals(0));
      expect(find.text('0 MB'), findsOneWidget);
      expect(find.textContaining('Cleared 48.0 MB thumbnail cache'), findsOneWidget);

      // Clear playback history
      expect(find.text('Clear playback history'), findsOneWidget);
      expect(find.text('18 items'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('clear_playback_history_tile')));
      await tester.pump();

      expect(capturedPrefs!.playbackHistoryCount, equals(0));
      expect(find.text('0 items'), findsOneWidget);
      expect(find.textContaining('Cleared playback history and resume positions'), findsOneWidget);
    });

    testWidgets('Local data and privacy notice is rendered', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SettingsScreen(),
        ),
      );

      expect(find.text('Your videos stay on your device.'), findsOneWidget);
      expect(
        find.text('Videos, playback history, preferences and thumbnail cache are stored locally. 100% offline, zero internet telemetry.'),
        findsOneWidget,
      );
    });

    testWidgets('Reset player settings shows confirmation dialog, cancels safely, or resets to defaults', (tester) async {
      setDeviceViewport(tester);
      AppPreferences? capturedPrefs;

      // Start with non-default preferences
      const customPrefs = AppPreferences(
        resumePlayback: false,
        defaultSpeed: 1.75,
        defaultOrientation: PlayerOrientationMode.landscape,
        showHiddenFolders: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SettingsScreen(
            initialPreferences: customPrefs,
            onPreferencesChanged: (p) => capturedPrefs = p,
          ),
        ),
      );

      expect(find.text('1.75×'), findsOneWidget);

      // Tap Reset player settings button
      await tester.tap(find.byKey(const ValueKey('reset_player_settings_button')));
      await tester.pumpAndSettle();

      expect(find.text('Reset player settings?'), findsOneWidget);
      expect(
        find.text('This will restore playback, appearance and interaction settings to their defaults.'),
        findsOneWidget,
      );
      expect(find.text('Your videos and library will not be deleted.'), findsOneWidget);

      // Cancel button test
      await tester.tap(find.byKey(const ValueKey('cancel_reset_button')));
      await tester.pumpAndSettle();

      expect(find.text('Reset player settings?'), findsNothing);
      expect(capturedPrefs, isNull); // Was not reset

      // Re-open and confirm reset
      await tester.tap(find.byKey(const ValueKey('reset_player_settings_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('confirm_reset_button')));
      await tester.pumpAndSettle();

      expect(capturedPrefs, isNotNull);
      expect(capturedPrefs!.resumePlayback, isTrue); // Restored
      expect(capturedPrefs!.defaultSpeed, equals(1.0)); // Restored
      expect(capturedPrefs!.defaultOrientation, equals(PlayerOrientationMode.auto)); // Restored
      expect(capturedPrefs!.showHiddenFolders, isFalse); // Restored

      expect(find.text('Player settings restored to defaults'), findsOneWidget);
    });

    testWidgets('About section links open privacy dialog and about dialog', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SettingsScreen(),
        ),
      );

      // Privacy dialog
      await tester.tap(find.byKey(const ValueKey('about_privacy_button')));
      await tester.pumpAndSettle();

      expect(find.text('100% Offline Privacy'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);

      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();

      // About dialog
      await tester.tap(find.byKey(const ValueKey('about_info_button')));
      await tester.pumpAndSettle();

      expect(find.text('PIchiPlayer'), findsWidgets);
      expect(find.text('Version 1.0.0 (Build 100)'), findsWidgets);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('AppPreferences model supports copyWith and immutability', (tester) async {
      const prefs = AppPreferences();

      expect(prefs.resumePlayback, isTrue);
      expect(prefs.autoPlayNext, isTrue);
      expect(prefs.defaultSpeed, equals(1.0));
      expect(prefs.formattedSpeed, equals('1×'));
      expect(prefs.formattedThumbnailCacheSize, equals('48.0 MB'));

      final modified = prefs.copyWith(
        resumePlayback: false,
        defaultSpeed: 1.25,
        thumbnailCacheSizeBytes: 0,
      );

      expect(modified.resumePlayback, isFalse);
      expect(modified.defaultSpeed, equals(1.25));
      expect(modified.formattedSpeed, equals('1.25×'));
      expect(modified.formattedThumbnailCacheSize, equals('0 MB'));
    });
  });
}
