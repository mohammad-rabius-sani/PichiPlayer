import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/ui/screens/library_screen.dart';
import 'package:pichi_player/ui/widgets/library_grid_card.dart';
import 'package:pichi_player/ui/widgets/library_list_tile.dart';

void main() {
  group('LibraryScreen Tests', () {
    testWidgets('renders top bar, filter row, sort toolbar, and video grid', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const LibraryScreen(
            initialLoading: false,
            isEmptyLibrary: false,
            enableBackgroundAnimation: false,
          ),
        ),
      );

      // Verify Header and Bottom Nav title
      expect(find.text('Library'), findsNWidgets(2));
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.view_list_rounded), findsOneWidget);

      // Verify Filter Chips
      expect(find.text('All Videos'), findsOneWidget);
      expect(find.text('Recently Added'), findsNWidgets(2)); // Filter chip + sort toolbar
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('4K'), findsWidgets); // Filter chip + video badges
      expect(find.text('HDR'), findsWidgets); // Filter chip + video badges
      expect(find.text('Unwatched'), findsOneWidget);

      // Verify Video Grid Items
      expect(find.byType(LibraryGridCard), findsWidgets);
      expect(find.text('Oppenheimer.mkv'), findsOneWidget);

      // Verify Bottom Navigation
      expect(find.text('Library'), findsWidgets);
    });

    testWidgets('toggles between Grid Mode and List Mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const LibraryScreen(
            initialLoading: false,
            isEmptyLibrary: false,
            enableBackgroundAnimation: false,
          ),
        ),
      );

      // Initially in Grid mode
      expect(find.byType(LibraryGridCard), findsWidgets);
      expect(find.byType(LibraryListTile), findsNothing);

      // Tap List View toggle button
      await tester.tap(find.byIcon(Icons.view_list_rounded));
      await tester.pumpAndSettle();

      // Now in List mode
      expect(find.byType(LibraryListTile), findsWidgets);
      expect(find.byType(LibraryGridCard), findsNothing);
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
    });

    testWidgets('filters videos when a filter chip is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const LibraryScreen(
            initialLoading: false,
            isEmptyLibrary: false,
            enableBackgroundAnimation: false,
          ),
        ),
      );

      // Tap 'Favorites' filter chip
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      // Favorite item like 'The Batman.mkv' should be present
      expect(find.text('The Batman.mkv'), findsOneWidget); // isFavorite: true
      // Non-favorite like 'Spider-Man Across the Spider-Verse.mkv' should be filtered out
      expect(find.text('Spider-Man Across the Spider-Verse.mkv'), findsNothing); // isFavorite: false
    });

    testWidgets('searches videos in-line locally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const LibraryScreen(
            initialLoading: false,
            isEmptyLibrary: false,
            enableBackgroundAnimation: false,
          ),
        ),
      );

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      // Verify search input field is open
      expect(find.byType(TextField), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Batman');
      await tester.pumpAndSettle();

      // Should find The Batman and filter out Interstellar
      expect(find.text('The Batman.mkv'), findsOneWidget);
      expect(find.text('Interstellar.mkv'), findsNothing);
    });

    testWidgets('renders empty state when library is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const LibraryScreen(
            initialLoading: false,
            isEmptyLibrary: true,
            enableBackgroundAnimation: false,
          ),
        ),
      );

      expect(find.text('No videos yet'), findsOneWidget);
      expect(
        find.text('PIchiPlayer couldn\'t find any local videos on your device.'),
        findsOneWidget,
      );
      expect(find.text('Scan Storage'), findsOneWidget);
      expect(find.text('Choose Folder'), findsOneWidget);
    });
  });
}
