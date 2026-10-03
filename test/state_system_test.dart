import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_colors.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/models/scan_state.dart';
import 'package:pichi_player/ui/screens/state_system_gallery_screen.dart';
import 'package:pichi_player/ui/widgets/states/states.dart';

void main() {
  void setDeviceViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
  }

  group('PichiSeverity & Error Severity System Tests', () {
    test('PichiSeverity defines 3 distinct calm severity tiers', () {
      expect(PichiSeverity.info.accentColor, equals(AppColors.electricBlue));
      expect(PichiSeverity.warning.accentColor, equals(AppColors.warning));
      expect(PichiSeverity.critical.accentColor, equals(AppColors.error));

      expect(PichiSeverity.info.brightColor, equals(AppColors.electricBlueBright));
      expect(PichiSeverity.warning.brightColor, equals(AppColors.warningBright));
      expect(PichiSeverity.critical.brightColor, equals(AppColors.errorBright));

      expect(PichiSeverity.info.subtleBackground, isNotNull);
      expect(PichiSeverity.warning.subtleBackground, isNotNull);
      expect(PichiSeverity.critical.subtleBackground, isNotNull);

      expect(PichiSeverity.info.borderColor, isNotNull);
      expect(PichiSeverity.warning.borderColor, isNotNull);
      expect(PichiSeverity.critical.borderColor, isNotNull);

      expect(PichiSeverity.info.glowColor, isNotNull);
      expect(PichiSeverity.warning.glowColor, isNotNull);
      expect(PichiSeverity.critical.glowColor, isNotNull);
    });

    test('TechnicalMediaDetails formats clean diagnostics text for export', () {
      final details = TechnicalMediaDetails.unsupportedAv1Sample();
      final text = details.toPlainText();

      expect(text, contains('=== PIchiPlayer Technical Diagnostics ==='));
      expect(text, contains('AV1'));
      expect(text, contains('3840 × 2160'));
      expect(text, contains('DTS-HD MA 7.1'));
      expect(text, contains('MediaCodecVideoRenderer'));
    });
  });

  group('PIchiPlayer States 01 - 06 Tests', () {
    testWidgets('STATE 01: LibraryScanningStateView renders progress, percentage, video count, and folder count', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: LibraryScanningStateView(
              scanState: ScanState(
                progress: 0.68,
                videosFound: 1248,
                currentFolder: 'Movies/',
              ),
              foldersCheckedCount: 342,
            ),
          ),
        ),
      );

      expect(find.text('Updating your library'), findsOneWidget);
      expect(find.text('68%'), findsOneWidget);
      expect(find.text('1,248 videos found'), findsOneWidget);
      expect(find.text('Scanning Movies/'), findsOneWidget);
      expect(find.text('342 folders checked'), findsOneWidget);
    });

    testWidgets('STATE 02: HomeNoVideosStateView renders calm offline empty state with actions', (tester) async {
      setDeviceViewport(tester);
      bool scanClicked = false;
      bool chooseClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: HomeNoVideosStateView(
              onScanStorage: () => scanClicked = true,
              onChooseFolder: () => chooseClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('No videos yet'), findsOneWidget);
      expect(find.text("PIchiPlayer couldn't find any local videos on your device."), findsOneWidget);
      expect(find.text('Scan Storage'), findsOneWidget);
      expect(find.text('Choose Folder'), findsOneWidget);

      await tester.tap(find.text('Scan Storage'));
      await tester.pump();
      expect(scanClicked, isTrue);

      await tester.tap(find.text('Choose Folder'));
      await tester.pump();
      expect(chooseClicked, isTrue);
    });

    testWidgets('STATE 03: FolderEmptyStateView renders empty folder copy and rescan actions', (tester) async {
      setDeviceViewport(tester);
      bool rescanClicked = false;
      bool chooseAnotherClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: FolderEmptyStateView(
              onRescanFolder: () => rescanClicked = true,
              onChooseAnotherFolder: () => chooseAnotherClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('No videos here'), findsOneWidget);
      expect(find.text("There aren't any playable local videos in this folder."), findsOneWidget);
      expect(find.text('Rescan Folder'), findsOneWidget);
      expect(find.text('Choose Another Folder'), findsOneWidget);

      await tester.tap(find.text('Rescan Folder'));
      await tester.pump();
      expect(rescanClicked, isTrue);

      await tester.tap(find.text('Choose Another Folder'));
      await tester.pump();
      expect(chooseAnotherClicked, isTrue);
    });

    testWidgets('STATE 04: EmptyFavoritesStateView renders subtle favorite state with library link', (tester) async {
      setDeviceViewport(tester);
      bool browseClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyFavoritesStateView(
              onBrowseLibrary: () => browseClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('No favorites yet'), findsOneWidget);
      expect(find.text('Videos you favorite will appear here.'), findsOneWidget);
      expect(find.text('Browse Library'), findsOneWidget);

      await tester.tap(find.text('Browse Library'));
      await tester.pump();
      expect(browseClicked, isTrue);
    });

    testWidgets('STATE 05: EmptyContinueWatchingStateView renders calm progress icon without clutter', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: EmptyContinueWatchingStateView(),
          ),
        ),
      );

      expect(find.text('Nothing to continue'), findsOneWidget);
      expect(find.text('Partially watched videos will appear here.'), findsOneWidget);
    });

    testWidgets('STATE 06: SearchNoResultsStateView renders clear search action and local fuzzy suggestion', (tester) async {
      setDeviceViewport(tester);
      bool clearClicked = false;
      String? selectedSuggestion;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SearchNoResultsStateView(
              query: 'interstelar',
              onClearSearch: () => clearClicked = true,
              suggestion: 'Interstellar',
              onSelectSuggestion: (s) => selectedSuggestion = s,
            ),
          ),
        ),
      );

      expect(find.text('No videos found'), findsOneWidget);
      expect(find.text('Nothing in your local library matches "interstelar".'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);
      expect(find.text('Did you mean "Interstellar"?'), findsOneWidget);

      await tester.tap(find.text('Clear Search'));
      await tester.pump();
      expect(clearClicked, isTrue);

      await tester.tap(find.text('Did you mean "Interstellar"?'));
      await tester.pump();
      expect(selectedSuggestion, equals('Interstellar'));
    });
  });

  group('PIchiPlayer States 07 - 12 Tests', () {
    testWidgets('STATE 07: MissingVideoStateView renders Locate File and Remove from Library actions', (tester) async {
      setDeviceViewport(tester);
      bool locateClicked = false;
      bool removeClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: MissingVideoStateView(
              videoTitle: 'Inception.2010.1080p.mp4',
              onLocateFile: () => locateClicked = true,
              onRemoveFromLibrary: () => removeClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Video unavailable'), findsOneWidget);
      expect(find.text('This video is no longer available at its saved location.'), findsOneWidget);
      expect(find.text('Inception.2010.1080p.mp4'), findsOneWidget);
      expect(find.text('Locate File'), findsOneWidget);
      expect(find.text('Remove from Library'), findsOneWidget);

      await tester.tap(find.text('Locate File'));
      await tester.pump();
      expect(locateClicked, isTrue);

      await tester.tap(find.text('Remove from Library'));
      await tester.pump();
      expect(removeClicked, isTrue);
    });

    testWidgets('STATE 08: FolderAccessRequiredStateView renders Grant Access and Remove Folder actions', (tester) async {
      setDeviceViewport(tester);
      bool grantClicked = false;
      bool removeClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: FolderAccessRequiredStateView(
              folderName: 'Movies',
              onGrantAccess: () => grantClicked = true,
              onRemoveFolder: () => removeClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Folder access required'), findsOneWidget);
      expect(find.text('PIchiPlayer no longer has access to "Movies".'), findsOneWidget);
      expect(find.text('Grant Access'), findsOneWidget);
      expect(find.text('Remove Folder'), findsOneWidget);

      await tester.tap(find.text('Grant Access'));
      await tester.pump();
      expect(grantClicked, isTrue);

      await tester.tap(find.text('Remove Folder'));
      await tester.pump();
      expect(removeClicked, isTrue);
    });

    testWidgets('STATE 09: UnsupportedVideoStateView displays badges and opens Technical Details sheet', (tester) async {
      setDeviceViewport(tester);
      bool tryAnotherClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: UnsupportedVideoStateView(
              codec: 'AV1',
              resolution: '3840 × 2160',
              onTryAnotherDecoder: () => tryAnotherClicked = true,
              technicalDetails: TechnicalMediaDetails.unsupportedAv1Sample(),
            ),
          ),
        ),
      );

      expect(find.text("Can't play this video"), findsOneWidget);
      expect(find.text('This device may not support the required decoder.'), findsOneWidget);
      expect(find.text('Codec: AV1'), findsOneWidget);
      expect(find.text('Resolution: 3840 × 2160'), findsOneWidget);
      expect(find.text('Try Another Decoder'), findsOneWidget);
      expect(find.text('Technical Details'), findsOneWidget);

      await tester.tap(find.text('Try Another Decoder'));
      await tester.pump();
      expect(tryAnotherClicked, isTrue);

      // Open Technical Details sheet
      await tester.tap(find.text('Technical Details'));
      await tester.pumpAndSettle();

      expect(find.text('Local media & decoder diagnostics'), findsOneWidget);
      expect(find.text('Copy Details'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });

    testWidgets('STATE 10: DecoderRecoveryView displays in-progress and recovered states', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: DecoderRecoveryView(isRecovered: false),
          ),
        ),
      );

      expect(find.text('Hardware decoder issue'), findsOneWidget);
      expect(find.text('Trying software decoder...'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: DecoderRecoveryView(isRecovered: true),
          ),
        ),
      );

      expect(find.text('Playback recovered'), findsOneWidget);
      expect(find.text('Continuing with software rendering.'), findsOneWidget);
    });

    testWidgets('STATE 11: PichiThumbnailSkeleton renders dark placeholder shimmer with text lines', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Center(
              child: PichiThumbnailSkeleton(width: 180, height: 101),
            ),
          ),
        ),
      );

      expect(find.byType(PichiThumbnailSkeleton), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('STATE 12: PichiFallbackThumbnail renders clean media symbol without broken image icon', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 160,
                height: 90,
                child: PichiFallbackThumbnail(label: 'Matrix.1999.mkv'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PichiFallbackThumbnail), findsOneWidget);
      expect(find.text('Matrix.1999.mkv'), findsOneWidget);
      expect(find.byIcon(Icons.broken_image), findsNothing);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });
  });

  group('PIchiPlayer States 13 - 18 Tests', () {
    testWidgets('STATE 13: LibraryRefreshBanner renders non-blocking progressive update message', (tester) async {
      setDeviceViewport(tester);
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: LibraryRefreshBanner(
              newlyDiscoveredCount: 5,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.text('Updating library... 5 new videos found'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(dismissed, isTrue);
    });

    testWidgets('STATE 14: StorageAccessExplanationSheet renders explanation before system picker', (tester) async {
      setDeviceViewport(tester);
      bool continueClicked = false;
      bool notNowClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: StorageAccessExplanationSheet(
              onContinue: () => continueClicked = true,
              onNotNow: () => notNowClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Access your videos'), findsOneWidget);
      expect(find.text('PIchiPlayer needs access to this folder to discover and play your local videos.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(continueClicked, isTrue);

      await tester.tap(find.text('Not now'));
      await tester.pump();
      expect(notNowClicked, isTrue);
    });

    testWidgets('STATE 15: CorruptMediaStateView renders file unreadable message and Try Again action', (tester) async {
      setDeviceViewport(tester);
      bool tryAgainClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CorruptMediaStateView(
              onTryAgain: () => tryAgainClicked = true,
            ),
          ),
        ),
      );

      expect(find.text("File couldn't be read"), findsOneWidget);
      expect(find.textContaining("PIchiPlayer couldn't read the video information from this file."), findsOneWidget);
      expect(find.textContaining("The file may be damaged or incomplete."), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Technical Details'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pump();
      expect(tryAgainClicked, isTrue);
    });

    testWidgets('STATE 16: SubtitleErrorStateView renders subtitle file name and Choose Another File action', (tester) async {
      setDeviceViewport(tester);
      bool chooseAnotherClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SubtitleErrorStateView(
              subtitleFileName: 'Movie.Bengali.srt',
              onChooseAnotherFile: () => chooseAnotherClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Subtitle unavailable'), findsOneWidget);
      expect(find.text("PIchiPlayer couldn't read Movie.Bengali.srt."), findsOneWidget);
      expect(find.text('Choose Another File'), findsOneWidget);

      await tester.tap(find.text('Choose Another File'));
      await tester.pump();
      expect(chooseAnotherClicked, isTrue);
    });

    testWidgets('STATE 17: AudioTrackErrorStateView renders track name badge and Choose Another Track action', (tester) async {
      setDeviceViewport(tester);
      bool chooseAnotherClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AudioTrackErrorStateView(
              trackName: 'DTS-HD MA',
              onChooseAnotherTrack: () => chooseAnotherClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Audio track unavailable'), findsOneWidget);
      expect(find.text('DTS-HD MA'), findsOneWidget);
      expect(find.text('This audio track cannot be decoded with the current playback configuration.'), findsOneWidget);
      expect(find.text('Choose Another Track'), findsOneWidget);

      await tester.tap(find.text('Choose Another Track'));
      await tester.pump();
      expect(chooseAnotherClicked, isTrue);
    });

    testWidgets('STATE 18: NoStorageAccessStateView renders Storage access needed with Grant Access action', (tester) async {
      setDeviceViewport(tester);
      bool grantClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: NoStorageAccessStateView(
              onGrantAccess: () => grantClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Storage access needed'), findsOneWidget);
      expect(find.text('Grant PIchiPlayer access to your local video folders to build your library.'), findsOneWidget);
      expect(find.text('Grant Access'), findsOneWidget);

      await tester.tap(find.text('Grant Access'));
      await tester.pump();
      expect(grantClicked, isTrue);
    });
  });

  group('StateSystemGalleryScreen Integration Tests', () {
    testWidgets('StateSystemGalleryScreen renders tabs, switches states, and opens technical details', (tester) async {
      setDeviceViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const StateSystemGalleryScreen(),
        ),
      );

      expect(find.text('UI States System'), findsOneWidget);
      expect(find.text('01. Library Scanning'), findsOneWidget);
      expect(find.text('02. Home No Videos'), findsOneWidget);

      // Initial state is Library Scanning
      expect(find.text('Updating your library'), findsOneWidget);

      // Switch to 02. Home No Videos
      await tester.tap(find.text('02. Home No Videos'));
      await tester.pump();

      expect(find.text('No videos yet'), findsOneWidget);
      expect(find.text('Scan Storage'), findsOneWidget);

      // Tap top action for Technical Details
      await tester.tap(find.byTooltip('View Sample Technical Details'));
      await tester.pumpAndSettle();

      expect(find.text('Technical Details'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });
  });
}
