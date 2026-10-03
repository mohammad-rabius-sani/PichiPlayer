/// Model representing the live status of the local media scanner
class ScanState {
  final double progress; // 0.0 to 1.0
  final int videosFound;
  final String currentFolder;
  final String statusMessage;
  final bool isCompleted;

  const ScanState({
    required this.progress,
    required this.videosFound,
    required this.currentFolder,
    this.statusMessage = 'Scanning local videos...',
    this.isCompleted = false,
  });

  /// Formatted percentage string e.g. "68%"
  String get percentageText => '${(progress * 100).toInt()}%';

  /// Formatted video count string e.g. "1,248 videos found"
  String get videosFoundText {
    final count = videosFound;
    final formatted = _formatWithCommas(count);
    return '$formatted ${count == 1 ? "video" : "videos"} found';
  }

  /// Initial scan state
  factory ScanState.initial() {
    return const ScanState(
      progress: 0.0,
      videosFound: 0,
      currentFolder: 'Storage/',
      statusMessage: 'Scanning local videos...',
      isCompleted: false,
    );
  }

  ScanState copyWith({
    double? progress,
    int? videosFound,
    String? currentFolder,
    String? statusMessage,
    bool? isCompleted,
  }) {
    return ScanState(
      progress: progress ?? this.progress,
      videosFound: videosFound ?? this.videosFound,
      currentFolder: currentFolder ?? this.currentFolder,
      statusMessage: statusMessage ?? this.statusMessage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  static String _formatWithCommas(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
