import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/core/theme/app_theme.dart';
import 'package:pichi_player/ui/screens/splash_scan_screen.dart';

void main() {
  testWidgets('SplashScanScreen renders branding and privacy elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const SplashScanScreen(
          enableBackgroundAnimation: false,
          autoStartScan: false,
        ),
      ),
    );

    // Advance intro animations completely
    await tester.pump(const Duration(milliseconds: 1500));

    // Verify wordmark & subtitle
    expect(find.text('PIchiPlayer'), findsOneWidget);
    expect(find.text('Your Local Video Companion'), findsOneWidget);

    // Verify scanning section header
    expect(find.text('Scanning local videos...'), findsOneWidget);

    // Verify offline privacy badge
    expect(find.text('100% Offline'), findsOneWidget);
    expect(find.text('Your videos stay on your device.'), findsOneWidget);
  });
}
