import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/models/subtitle_track_info.dart';
import 'package:pichi_player/ui/widgets/player/subtitle_selection_sheet.dart';

void main() {
  final sampleTracks = [
    SubtitleTrackInfo.off(),
    const SubtitleTrackInfo(
      id: 'sub_01',
      language: 'English',
      source: SubtitleSource.embedded,
      format: SubtitleFormat.utf8,
      formatLabel: 'UTF-8',
      isSdh: true,
    ),
    const SubtitleTrackInfo(
      id: 'sub_02',
      language: 'Bengali',
      source: SubtitleSource.embedded,
      format: SubtitleFormat.utf8,
      formatLabel: 'UTF-8',
    ),
    const SubtitleTrackInfo(
      id: 'sub_03',
      language: 'Japanese',
      source: SubtitleSource.embedded,
      format: SubtitleFormat.ass,
      formatLabel: 'ASS',
      isForced: true,
    ),
    const SubtitleTrackInfo(
      id: 'sub_04',
      language: 'Spanish',
      source: SubtitleSource.externalFile,
      format: SubtitleFormat.srt,
      formatLabel: 'SRT',
    ),
  ];

  group('SubtitleSelectionSheet Core & Visual Presentation', () {
    testWidgets('renders title, close button, track rows, and action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SubtitleSelectionSheet(
              tracks: sampleTracks,
              selectedTrack: 'English',
              onSelected: (_) {},
            ),
          ),
        ),
      );

      // Header
      expect(find.text('Subtitles'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Track items
      expect(find.text('Off'), findsOneWidget);
      expect(find.text('Disable subtitles'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Bengali'), findsOneWidget);
      expect(find.text('Japanese'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);

      // Metadata lines & badges
      expect(find.text('Embedded • UTF-8 • SDH'), findsOneWidget);
      expect(find.text('Embedded • UTF-8'), findsOneWidget);
      expect(find.text('Embedded • ASS • Forced'), findsOneWidget);
      expect(find.text('External • SRT'), findsOneWidget);
      expect(find.text('SDH'), findsOneWidget);
      expect(find.text('FORCED'), findsOneWidget);

      // Action buttons
      expect(find.text('Add subtitle file'), findsOneWidget);
      expect(find.text('Subtitle settings'), findsOneWidget);
    });

    testWidgets('displays checkmark icon on selected track and empty radio on unselected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SubtitleSelectionSheet(
              tracks: sampleTracks,
              selectedTrack: 'English',
              onSelected: (_) {},
            ),
          ),
        ),
      );

      // Checkmark icon appears on selected track
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('tapping a subtitle track triggers onSelected callback immediately', (tester) async {
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SubtitleSelectionSheet(
              tracks: sampleTracks,
              selectedTrack: 'English',
              onSelected: (track) => selected = track,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Bengali'));
      await tester.pump();

      expect(selected, 'Bengali');
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('tapping Off selects None (Off) and disables subtitles', (tester) async {
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SubtitleSelectionSheet(
              tracks: sampleTracks,
              selectedTrack: 'English',
              onSelected: (track) => selected = track,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Off'));
      await tester.pump();

      expect(selected, 'None (Off)');
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('Add subtitle file triggers parsing animation and appends external track', (tester) async {
      String? newlySelected;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SubtitleSelectionSheet(
              tracks: [
                SubtitleTrackInfo.off(),
                const SubtitleTrackInfo(
                  id: 'sub_en',
                  language: 'English',
                  formatLabel: 'UTF-8',
                ),
              ],
              selectedTrack: 'English',
              onSelected: (track) => newlySelected = track,
              videoTitle: 'Interstellar',
            ),
          ),
        ),
      );

      expect(find.text('Bengali'), findsNothing);

      // Tap Add subtitle file
      await tester.tap(find.text('Add subtitle file'));
      await tester.pump();

      // Loading state displays with filename
      expect(find.text('Adding subtitle...'), findsOneWidget);
      expect(find.text('Interstellar.Bengali.srt'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Finish simulated parsing delay
      await tester.pump(const Duration(milliseconds: 700));

      // New track is appended and selected
      expect(find.text('Bengali'), findsOneWidget);
      expect(find.text('External • SRT'), findsOneWidget);
      expect(newlySelected, 'Bengali');
    });

    testWidgets('displays invalid subtitle error state when file cannot be parsed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SubtitleSelectionSheet(
              tracks: [
                SubtitleTrackInfo.off(),
                // Pre-existing external Bengali to trigger conflict simulation
                const SubtitleTrackInfo(
                  id: 'ext_sub_existing',
                  language: 'Bengali',
                  source: SubtitleSource.externalFile,
                  formatLabel: 'SRT',
                ),
              ],
              selectedTrack: 'Bengali',
              onSelected: (_) {},
            ),
          ),
        ),
      );

      // Tap Add subtitle file to trigger invalid/conflict state
      await tester.tap(find.text('Add subtitle file'));
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text("Couldn't add subtitle"), findsOneWidget);
      expect(find.text("This subtitle file couldn't be read by PIchiPlayer."), findsOneWidget);
      expect(find.text('Choose another file'), findsOneWidget);
    });

    testWidgets('renders empty state when no embedded or local tracks are available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SubtitleSelectionSheet(
              tracks: [SubtitleTrackInfo.off()],
              selectedTrack: 'Off',
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('No subtitles available'), findsOneWidget);
      expect(find.text("PIchiPlayer couldn't find embedded or local subtitle tracks."), findsOneWidget);
      expect(find.byIcon(Icons.closed_caption_disabled_rounded), findsOneWidget);
      expect(find.text('Add subtitle file'), findsOneWidget);
      expect(find.text('Subtitle settings'), findsOneWidget);
    });

    testWidgets('tapping Subtitle settings invokes onOpenCustomization callback', (tester) async {
      bool customizationOpened = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SubtitleSelectionSheet(
              tracks: sampleTracks,
              selectedTrack: 'English',
              onSelected: (_) {},
              onOpenCustomization: () => customizationOpened = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Subtitle settings'));
      await tester.pump();

      expect(customizationOpened, isTrue);
    });
  });
}
