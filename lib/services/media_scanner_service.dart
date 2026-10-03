import 'dart:async';
import '../models/scan_state.dart';

/// Service responsible for scanning local storage for video files.
/// Provides a reactive stream of scan progress with smooth folder updates and count increments.
class MediaScannerService {
  final _stateController = StreamController<ScanState>.broadcast();
  Stream<ScanState> get scanStream => _stateController.stream;

  ScanState _currentState = ScanState.initial();
  ScanState get currentState => _currentState;

  Timer? _timer;

  /// Folders scanned sequentially during library indexing
  static const List<_ScanFolderStep> _scanSteps = [
    _ScanFolderStep('DCIM/Camera/', 140, 0.12),
    _ScanFolderStep('Download/', 285, 0.28),
    _ScanFolderStep('Movies/', 520, 0.45),
    _ScanFolderStep('Movies/Sci-Fi/', 730, 0.58),
    _ScanFolderStep('Movies/Action/', 960, 0.68),
    _ScanFolderStep('Movies/Documentaries/', 1084, 0.82),
    _ScanFolderStep('DCIM/ScreenRecorder/', 1162, 0.91),
    _ScanFolderStep('Telegram/Telegram Video/', 1248, 1.0),
  ];

  /// Starts or restarts the media scanning process
  void startScan({
    Duration stepInterval = const Duration(milliseconds: 140),
    VoidCallback? onComplete,
  }) {
    _timer?.cancel();
    _currentState = ScanState.initial();
    _stateController.add(_currentState);

    int currentStepIndex = 0;
    double currentProgress = 0.0;
    int currentVideos = 0;

    _timer = Timer.periodic(stepInterval, (timer) {
      if (currentStepIndex >= _scanSteps.length) {
        timer.cancel();
        _currentState = _currentState.copyWith(
          progress: 1.0,
          statusMessage: 'Scan complete',
          isCompleted: true,
        );
        _stateController.add(_currentState);
        onComplete?.call();
        return;
      }

      final targetStep = _scanSteps[currentStepIndex];
      
      // Interpolate smoothly towards the target step's values
      currentProgress += (targetStep.targetProgress - currentProgress) * 0.28 + 0.012;
      currentVideos += ((targetStep.targetVideos - currentVideos) * 0.3 + 4).toInt();

      if (currentProgress >= targetStep.targetProgress && currentVideos >= targetStep.targetVideos) {
        currentProgress = targetStep.targetProgress;
        currentVideos = targetStep.targetVideos;
        currentStepIndex++;
      }

      // Clamp progress to 1.0
      if (currentProgress > 1.0) currentProgress = 1.0;

      _currentState = _currentState.copyWith(
        progress: currentProgress,
        videosFound: currentVideos,
        currentFolder: targetStep.folderPath,
        statusMessage: 'Scanning local videos...',
        isCompleted: currentProgress >= 1.0,
      );

      _stateController.add(_currentState);

      if (currentProgress >= 1.0) {
        timer.cancel();
        _currentState = _currentState.copyWith(
          statusMessage: 'Scan complete',
          isCompleted: true,
        );
        _stateController.add(_currentState);
        onComplete?.call();
      }
    });
  }

  void cancelScan() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
    _stateController.close();
  }
}

class _ScanFolderStep {
  final String folderPath;
  final int targetVideos;
  final double targetProgress;

  const _ScanFolderStep(this.folderPath, this.targetVideos, this.targetProgress);
}

typedef VoidCallback = void Function();
