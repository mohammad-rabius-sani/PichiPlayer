import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/models/local_folder.dart';
import 'package:pichi_player/ui/screens/folder_detail_screen.dart';
import 'package:pichi_player/ui/screens/folders_screen.dart';
import 'package:pichi_player/ui/widgets/folder_list_row.dart';
import 'package:pichi_player/ui/widgets/library_grid_card.dart';
import 'package:pichi_player/ui/widgets/library_list_tile.dart';
import 'package:pichi_player/ui/widgets/storage_source_card.dart';

void setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  group('FoldersScreen Tests', () {
    testWidgets('renders header, storage cards, and video folder rows', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const FoldersScreen(
            initialLoading: false,
            enableBackgroundAnimation: false,
          ),
        ),
      );

      // Verify Header
      expect(find.text('Folders'), findsNWidgets(2)); // Top header + bottom nav
      expect(find.text('Browse your local video folders'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);

      // Verify Storage Section
      expect(find.text('STORAGE'), findsOneWidget);
      expect(find.byType(StorageSourceCard), findsNWidgets(2)); // Internal + SD Card
      expect(find.text('Internal Storage'), findsOneWidget);
      expect(find.text('1,024 videos'), findsOneWidget);
      expect(find.text('42 GB used by videos'), findsOneWidget);
      expect(find.text('SD Card'), findsOneWidget);
      expect(find.text('384 videos'), findsOneWidget);

      // Verify Video Folders Section
      expect(find.text('VIDEO FOLDERS'), findsOneWidget);
      expect(find.byType(FolderListRow), findsWidgets);
      expect(find.text('Movies'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Screen Recordings'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);

      // Verify Add Folder action button
      expect(find.text('Add Folder'), findsOneWidget);
    });

    testWidgets('displays attention/permission-loss state and grants access on tap', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const FoldersScreen(
            initialLoading: false,
            enableBackgroundAnimation: false,
          ),
        ),
      );

      // WhatsApp initially lacks permission
      expect(find.text('Folder access required • Permission is no longer available.'), findsOneWidget);
      expect(find.text('Grant Access'), findsOneWidget);

      // Tap 'Grant Access'
      await tester.tap(find.text('Grant Access'));
      await tester.pump();

      // Permission should now be granted and warning gone
      expect(find.text('Folder access required • Permission is no longer available.'), findsNothing);
      expect(find.text('Access granted to WhatsApp. Media indexed.'), findsOneWidget);
    });

    testWidgets('opens Add Folder dialog on button tap', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const FoldersScreen(
            initialLoading: false,
            enableBackgroundAnimation: false,
          ),
        ),
      );

      await tester.tap(find.text('Add Folder'));
      await tester.pumpAndSettle();

      expect(find.text('Add Video Folder'), findsOneWidget);
      expect(find.text('Add & Scan'), findsOneWidget);

      // Tap 'Add & Scan'
      await tester.tap(find.text('Add & Scan'));
      await tester.pumpAndSettle();

      expect(find.text('Anime'), findsOneWidget);
    });

    testWidgets('opens folder overflow menu and toggles hidden folders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const FoldersScreen(
            initialLoading: false,
            enableBackgroundAnimation: false,
          ),
        ),
      );

      // Hidden vault initially hidden
      expect(find.text('.hidden_vault'), findsNothing);

      // Tap overflow menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Folder Management'), findsOneWidget);
      expect(find.text('Scan for new videos'), findsOneWidget);
      expect(find.text('Rescan all folders'), findsOneWidget);
      expect(find.text('Show hidden folders'), findsOneWidget);

      // Toggle 'Show hidden folders'
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Close bottom sheet
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      // Hidden folder should now be visible
      expect(find.text('.hidden_vault'), findsOneWidget);
      expect(find.text('Hidden'), findsOneWidget);
    });

    testWidgets('navigates to FolderDetailScreen and toggles view modes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const FoldersScreen(
            initialLoading: false,
            enableBackgroundAnimation: false,
          ),
        ),
      );

      // Tap 'Movies' folder row
      await tester.tap(find.text('Movies'));
      await tester.pumpAndSettle();

      // In FolderDetailScreen
      expect(find.byType(FolderDetailScreen), findsOneWidget);
      expect(find.text('Movies'), findsOneWidget);
      expect(find.byType(LibraryGridCard), findsWidgets);

      // Toggle to List mode
      await tester.tap(find.byIcon(Icons.view_list_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(LibraryListTile), findsWidgets);
      expect(find.byType(LibraryGridCard), findsNothing);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(FoldersScreen), findsOneWidget);
    });

    testWidgets('FolderDetailScreen displays empty view when folder has no videos', (tester) async {
      const emptyFolder = LocalFolder(
        id: 'empty_folder',
        name: 'EmptyFolder',
        path: '/storage/emulated/0/EmptyFolder',
        videoCount: 0,
        totalSizeBytes: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const FolderDetailScreen(
            folder: emptyFolder,
            enableBackgroundAnimation: false,
          ),
        ),
      );

      expect(find.text('No videos in this folder'), findsOneWidget);
      expect(
        find.text('PIchiPlayer didn\'t find any playable local videos here.'),
        findsOneWidget,
      );
      expect(find.text('Rescan Folder'), findsOneWidget);
      expect(find.text('Choose Another Folder'), findsOneWidget);
    });
  });
}
