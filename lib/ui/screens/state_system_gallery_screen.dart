import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/scan_state.dart';
import '../widgets/ambient_background.dart';
import '../widgets/states/states.dart';

/// Interactive gallery and reference catalog for all 18 PIchiPlayer
/// UI states and severity tiers.
class StateSystemGalleryScreen extends StatefulWidget {
  final int initialIndex;

  const StateSystemGalleryScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<StateSystemGalleryScreen> createState() =>
      _StateSystemGalleryScreenState();
}

class _StateSystemGalleryScreenState extends State<StateSystemGalleryScreen> {
  late int _selectedIndex;
  bool _decoderRecovered = false;
  int _discoveredCount = 3;

  static const List<String> _stateTitles = [
    '01. Library Scanning',
    '02. Home No Videos',
    '03. Empty Folder',
    '04. Empty Favorites',
    '05. Empty Continue',
    '06. Search No Results',
    '07. Missing Video',
    '08. Folder Access',
    '09. Unsupported Video',
    '10. Decoder Recovery',
    '11. Thumbnail Skeleton',
    '12. Fallback Thumbnail',
    '13. Library Refresh',
    '14. Storage Explanation',
    '15. Corrupt Media',
    '16. Subtitle Error',
    '17. Audio Track Error',
    '18. No Storage Access',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.electricBlueBright, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UI States System',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'PIchiPlayer Offline States Catalog',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.code_rounded,
                color: AppColors.electricBlueBright),
            tooltip: 'View Sample Technical Details',
            onPressed: () {
              TechnicalDetailsSheet.show(
                context,
                details: TechnicalMediaDetails.unsupportedAv1Sample(),
              );
            },
          ),
        ],
      ),
      body: AmbientBackground(
        enableAnimation: false,
        child: Column(
          children: [
            // Horizontal State Selector Bar
            Container(
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.surfaceGlass,
                border: Border(
                  bottom: BorderSide(color: AppColors.glassBorderSubtle),
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _stateTitles.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: ChoiceChip(
                        label: Text(_stateTitles[index]),
                        selected: isSelected,
                        selectedColor: AppColors.electricBlue,
                        backgroundColor: AppColors.surfaceSubtle,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedIndex = index;
                            _decoderRecovered = false;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Active State Presentation Area
            Expanded(
              child: Center(
                child: _buildSelectedState(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedState() {
    switch (_selectedIndex) {
      case 0:
        return const LibraryScanningStateView(
          scanState: ScanState(
            progress: 0.68,
            videosFound: 1248,
            currentFolder: 'Movies/',
          ),
          foldersCheckedCount: 342,
        );

      case 1:
        return HomeNoVideosStateView(
          onScanStorage: () => _showFeedback('Triggered Scan Storage'),
          onChooseFolder: () => _showFeedback('Triggered Choose Folder'),
        );

      case 2:
        return FolderEmptyStateView(
          onRescanFolder: () => _showFeedback('Triggered Rescan Folder'),
          onChooseAnotherFolder: () =>
              _showFeedback('Triggered Choose Another Folder'),
        );

      case 3:
        return EmptyFavoritesStateView(
          onBrowseLibrary: () => _showFeedback('Triggered Browse Library'),
        );

      case 4:
        return const EmptyContinueWatchingStateView();

      case 5:
        return SearchNoResultsStateView(
          query: 'interstelar',
          onClearSearch: () => _showFeedback('Cleared search query'),
          suggestion: 'Interstellar',
          onSelectSuggestion: (s) =>
              _showFeedback('Selected search suggestion: $s'),
        );

      case 6:
        return MissingVideoStateView(
          videoTitle: 'Interstellar.2014.2160p.mkv',
          onLocateFile: () => _showFeedback('Triggered Locate File'),
          onRemoveFromLibrary: () =>
              _showFeedback('Triggered Remove from Library'),
        );

      case 7:
        return FolderAccessRequiredStateView(
          folderName: 'External SD/Movies',
          onGrantAccess: () => _showFeedback('Requested folder access'),
          onRemoveFolder: () => _showFeedback('Removed folder from library'),
        );

      case 8:
        return UnsupportedVideoStateView(
          codec: 'AV1',
          resolution: '3840 × 2160',
          onTryAnotherDecoder: () =>
              _showFeedback('Switching to software decoder pipeline...'),
          technicalDetails: TechnicalMediaDetails.unsupportedAv1Sample(),
        );

      case 9:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoderRecoveryView(
              isRecovered: _decoderRecovered,
              onDismiss: () => _showFeedback('Returned to video playback'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceSubtle,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  _decoderRecovered = !_decoderRecovered;
                });
              },
              child: Text(
                _decoderRecovered
                    ? 'Reset to In-Progress'
                    : 'Simulate Recovery Success',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        );

      case 10:
        return const SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Video Thumbnail Skeletons',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  PichiThumbnailSkeleton(width: 160, height: 90),
                  PichiThumbnailSkeleton(width: 160, height: 90),
                  PichiThumbnailSkeleton(width: 160, height: 90),
                  PichiThumbnailSkeleton(width: 160, height: 90),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Without Text (Compact Grid)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PichiThumbnailSkeleton(
                      width: 120, height: 75, showTextSkeletons: false),
                  SizedBox(width: 14),
                  PichiThumbnailSkeleton(
                      width: 120, height: 75, showTextSkeletons: false),
                ],
              ),
            ],
          ),
        );

      case 11:
        return const SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Fallback Thumbnail Generation',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Shown cleanly when local media metadata extraction fails',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 90,
                    child: PichiFallbackThumbnail(
                        label: 'Dune.Part.Two.2024.mkv'),
                  ),
                  SizedBox(
                    width: 160,
                    height: 90,
                    child: PichiFallbackThumbnail(
                        label: 'Oppenheimer.2023.mp4'),
                  ),
                  SizedBox(
                    width: 160,
                    height: 90,
                    child: PichiFallbackThumbnail(label: 'Home_Video_01.mov'),
                  ),
                ],
              ),
            ],
          ),
        );

      case 12:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LibraryRefreshBanner(
              newlyDiscoveredCount: _discoveredCount,
              onDismiss: () => _showFeedback('Dismissed banner'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceSubtle,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  _discoveredCount += 2;
                });
              },
              child: const Text('Increment Discovered Videos',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ],
        );

      case 13:
        return Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            icon: const Icon(Icons.folder_shared_outlined,
                color: Colors.white, size: 20),
            label: const Text('Show Storage Access Explanation Sheet',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            onPressed: () {
              StorageAccessExplanationSheet.show(
                context,
                onContinue: () =>
                    _showFeedback('Continue: Opening Android folder picker'),
                onNotNow: () => _showFeedback('Not now: Cancelled access request'),
              );
            },
          ),
        );

      case 14:
        return CorruptMediaStateView(
          onTryAgain: () => _showFeedback('Retrying media extraction...'),
          technicalDetails: const TechnicalMediaDetails(
            filePath: '/storage/emulated/0/Download/Broken_Video.mp4',
            container: 'MP4 / QuickTime',
            parserStatus: 'Corrupt '
                'moov'
                ' atom: header table truncated at byte 4096.',
          ),
        );

      case 15:
        return SubtitleErrorStateView(
          subtitleFileName: 'Movie.Bengali.srt',
          onChooseAnotherFile: () =>
              _showFeedback('Opening subtitle file picker...'),
        );

      case 16:
        return AudioTrackErrorStateView(
          trackName: 'DTS-HD MA 7.1',
          onChooseAnotherTrack: () =>
              _showFeedback('Opening Audio Selection sheet...'),
        );

      case 17:
        return NoStorageAccessStateView(
          onGrantAccess: () =>
              _showFeedback('Triggered Storage Access Permission Request'),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
