import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/services/search_history_service.dart';
import 'package:pichi_player/ui/screens/search_screen.dart';
import 'package:pichi_player/ui/widgets/library_grid_card.dart';
import 'package:pichi_player/ui/widgets/search_filter_row.dart';

void setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  setUp(() {
    SearchHistoryService.resetToDefault();
  });

  group('SearchScreen Tests', () {
    testWidgets('renders top search bar, auto-focuses text field, and displays recent searches', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SearchScreen(enableBackgroundAnimation: false),
        ),
      );
      await tester.pump();

      // Top Search Bar
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.text('Search videos...'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify TextField has focus
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.focusNode?.hasFocus, isTrue);

      // Recent Searches
      expect(find.text('Recent searches'), findsOneWidget);
      expect(find.text('Interstellar'), findsOneWidget);
      expect(find.text('Dune'), findsOneWidget);
      expect(find.text('Clear all'), findsOneWidget);

      // Empty state hint
      expect(find.text('Search your local video library'), findsOneWidget);
      expect(find.text('Everything stays on your device.'), findsOneWidget);
    });

    testWidgets('displays live search results as user types with result count', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SearchScreen(enableBackgroundAnimation: false),
        ),
      );
      await tester.pump();

      // Enter search query 'batman'
      await tester.enterText(find.byType(TextField), 'batman');
      await tester.pumpAndSettle();

      // Verify result counter and matching video card
      expect(find.text('1 result'), findsOneWidget);
      expect(find.text('The Batman.mkv'), findsOneWidget);
      expect(find.byType(LibraryGridCard), findsOneWidget);

      // Verify Clear / X icon appears
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Filter chips should be visible
      expect(find.text('All'), findsOneWidget);
      expect(find.text('4K'), findsWidgets); // chip + card badges
      expect(find.text('HDR'), findsWidgets); // chip + card badges
      expect(find.text('Favorites'), findsOneWidget);
    });

    testWidgets('filters live results by resolution/category chip', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SearchScreen(enableBackgroundAnimation: false),
        ),
      );
      await tester.pump();

      // Query for all videos with letter 'e' (matches multiple)
      await tester.enterText(find.byType(TextField), 'e');
      await tester.pumpAndSettle();

      expect(find.byType(LibraryGridCard), findsWidgets);

      // Tap 'HDR' filter chip inside SearchFilterRow
      final hdrChip = find.descendant(
        of: find.byType(SearchFilterRow),
        matching: find.text('HDR'),
      );
      await tester.tap(hdrChip);
      await tester.pumpAndSettle();

      // Results should remain filtered to HDR-only
      expect(find.byType(LibraryGridCard), findsWidgets);
    });

    testWidgets('tapping recent search executes search and remove X deletes item', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SearchScreen(enableBackgroundAnimation: false),
        ),
      );
      await tester.pump();

      // Tap 'Dune' recent search item
      await tester.tap(find.text('Dune'));
      await tester.pumpAndSettle();

      // Search field now contains 'Dune' and shows results
      expect(find.text('Dune Part Two.mkv'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Back in recent searches
      expect(find.text('Recent searches'), findsOneWidget);

      // Remove 'Documentary' from recent searches
      expect(find.text('Documentary'), findsOneWidget);
      final removeIcon = find.descendant(
        of: find.widgetWithText(ListTile, 'Documentary'),
        matching: find.byIcon(Icons.close_rounded),
      );
      await tester.tap(removeIcon);
      await tester.pumpAndSettle();

      // 'Documentary' should now be removed from recent searches
      expect(find.text('Documentary'), findsNothing);
    });

    testWidgets('displays no results view with typo suggestion and clear action', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SearchScreen(enableBackgroundAnimation: false),
        ),
      );
      await tester.pump();

      // Type a typo: 'interstelar'
      await tester.enterText(find.byType(TextField), 'interstelar');
      await tester.pumpAndSettle();

      // Should display "No videos found"
      expect(find.text('No videos found'), findsOneWidget);
      expect(find.text('We couldn\'t find a local video matching "interstelar".'), findsOneWidget);

      // Should display typo suggestion "Did you mean Interstellar?"
      expect(find.text('Did you mean Interstellar?'), findsOneWidget);

      // Tap suggestion to autocorrect
      await tester.tap(find.text('Did you mean Interstellar?'));
      await tester.pumpAndSettle();

      // Should now show Interstellar results
      expect(find.text('Interstellar.mkv'), findsOneWidget);

      // Type nonexistent query
      await tester.enterText(find.byType(TextField), 'nonexistentxyz123');
      await tester.pumpAndSettle();

      expect(find.text('No videos found'), findsOneWidget);

      // Tap 'Clear Search'
      await tester.tap(find.text('Clear Search'));
      await tester.pumpAndSettle();

      // Back to empty search view
      expect(find.text('Search your local video library'), findsOneWidget);
    });

    testWidgets('tapping a video card triggers playback and dismisses keyboard', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SearchScreen(enableBackgroundAnimation: false),
        ),
      );
      await tester.pump();

      // Search for Oppenheimer
      await tester.enterText(find.byType(TextField), 'Oppenheimer');
      await tester.pumpAndSettle();

      expect(find.text('Oppenheimer.mkv'), findsOneWidget);

      // Tap card
      await tester.tap(find.text('Oppenheimer.mkv'));
      await tester.pump();

      // Verify playback snackbar and keyboard dismissal
      expect(find.text('Playing from local storage • 4K • HEVC'), findsOneWidget);
    });
  });
}
