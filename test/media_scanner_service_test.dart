import 'package:flutter_test/flutter_test.dart';
import 'package:pichi_player/models/scan_state.dart';

void main() {
  group('ScanState Model Tests', () {
    test('initial state has correct default values', () {
      final state = ScanState.initial();
      expect(state.progress, 0.0);
      expect(state.percentageText, '0%');
      expect(state.videosFound, 0);
      expect(state.videosFoundText, '0 videos found');
      expect(state.statusMessage, 'Scanning local videos...');
      expect(state.isCompleted, false);
    });

    test('formats percentage and comma-separated numbers correctly', () {
      const state = ScanState(
        progress: 0.68,
        videosFound: 1248,
        currentFolder: 'Movies/',
      );

      expect(state.percentageText, '68%');
      expect(state.videosFoundText, '1,248 videos found');
      expect(state.currentFolder, 'Movies/');
    });

    test('formats single video count correctly', () {
      const state = ScanState(
        progress: 0.01,
        videosFound: 1,
        currentFolder: 'DCIM/Camera/',
      );

      expect(state.videosFoundText, '1 video found');
    });
  });
}
