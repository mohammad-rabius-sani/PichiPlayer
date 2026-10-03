import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/ui/screens/home_screen.dart';

void main() {
  group('HomeScreen Tests', () {
    testWidgets('renders top bar, featured hero, sections, and bottom navigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const HomeScreen(
            initialLoading: false,
            isEmptyLibrary: false,
          ),
        ),
      );

      // Verify Top Bar
      expect(find.text('PIchiPlayer'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsWidgets); // top bar and bottom nav settings

      // Verify Hero content
      expect(find.text('Interstellar'), findsWidgets);
      expect(find.text('2h 49m • 4K • HEVC • 60fps'), findsOneWidget);

      // Verify Section Headers
      expect(find.text('Continue Watching'), findsOneWidget);
      expect(find.text('Recently Added'), findsOneWidget);
      expect(find.text('4K & High Quality'), findsOneWidget);

      // Verify Bottom Navigation items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Folders'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders Empty state when no videos are present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const HomeScreen(
            initialLoading: false,
            isEmptyLibrary: true,
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
