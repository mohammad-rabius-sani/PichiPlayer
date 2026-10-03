import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/scan_state.dart';
import 'pichi_state_severity.dart';
import 'pichi_state_view.dart';
import 'technical_details_sheet.dart';

// ============================================================================
// STATE 01 — Library scanning
// ============================================================================

/// Dynamic scanning state appearing during initial indexing or manual rescans.
class LibraryScanningStateView extends StatelessWidget {
  final ScanState scanState;
  final int? foldersCheckedCount;
  final VoidCallback? onCancel;

  const LibraryScanningStateView({
    super.key,
    required this.scanState,
    this.foldersCheckedCount,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Luminous radar/scan icon badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.infoSubtle,
                border: Border.all(color: AppColors.infoBorder, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.electricBlueGlow,
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.sync_rounded,
                  size: 38,
                  color: AppColors.electricBlueBright,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Title
            const Text(
              'Updating your library',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle status: "Scanning Movies/"
            Text(
              scanState.currentFolder.startsWith('Scanning')
                  ? scanState.currentFolder
                  : 'Scanning ${scanState.currentFolder}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 22),

            // Percentage & Video Counts Row
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    scanState.percentageText,
                    style: const TextStyle(
                      color: AppColors.electricBlueBright,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    scanState.videosFoundText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Elegant Luminous Progress Line
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 6,
                  color: AppColors.progressTrack,
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: scanState.progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.electricBlue,
                                AppColors.electricBlueBright,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.electricBlueGlow,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Optional "342 folders checked" supporting text
            if (foldersCheckedCount != null) ...[
              const SizedBox(height: 12),
              Text(
                '$foldersCheckedCount folders checked',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],

            if (onCancel != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.glassBorderSubtle),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onCancel,
                child: const Text('Cancel Scan',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STATE 02 — Home with no videos
// ============================================================================

class HomeNoVideosStateView extends StatelessWidget {
  final VoidCallback onScanStorage;
  final VoidCallback onChooseFolder;

  const HomeNoVideosStateView({
    super.key,
    required this.onScanStorage,
    required this.onChooseFolder,
  });

  @override
  Widget build(BuildContext context) {
    return PichiStateView(
      icon: Icons.video_library_outlined,
      title: 'No videos yet',
      description: "PIchiPlayer couldn't find any local videos on your device.",
      severity: PichiSeverity.info,
      primaryActionLabel: 'Scan Storage',
      onPrimaryAction: onScanStorage,
      secondaryActionLabel: 'Choose Folder',
      onSecondaryAction: onChooseFolder,
    );
  }
}

// ============================================================================
// STATE 03 — Empty folder
// ============================================================================

class FolderEmptyStateView extends StatelessWidget {
  final VoidCallback onRescanFolder;
  final VoidCallback onChooseAnotherFolder;

  const FolderEmptyStateView({
    super.key,
    required this.onRescanFolder,
    required this.onChooseAnotherFolder,
  });

  @override
  Widget build(BuildContext context) {
    return PichiStateView(
      icon: Icons.folder_open_outlined,
      title: 'No videos here',
      description: "There aren't any playable local videos in this folder.",
      severity: PichiSeverity.info,
      primaryActionLabel: 'Rescan Folder',
      onPrimaryAction: onRescanFolder,
      secondaryActionLabel: 'Choose Another Folder',
      onSecondaryAction: onChooseAnotherFolder,
    );
  }
}

// ============================================================================
// STATE 04 — Empty Favorites
// ============================================================================

class EmptyFavoritesStateView extends StatelessWidget {
  final VoidCallback? onBrowseLibrary;

  const EmptyFavoritesStateView({
    super.key,
    this.onBrowseLibrary,
  });

  @override
  Widget build(BuildContext context) {
    return PichiStateView(
      icon: Icons.favorite_border_rounded,
      title: 'No favorites yet',
      description: 'Videos you favorite will appear here.',
      severity: PichiSeverity.info,
      primaryActionLabel: onBrowseLibrary != null ? 'Browse Library' : null,
      onPrimaryAction: onBrowseLibrary,
    );
  }
}

// ============================================================================
// STATE 05 — Empty Continue Watching
// ============================================================================

class EmptyContinueWatchingStateView extends StatelessWidget {
  final bool isCompact;

  const EmptyContinueWatchingStateView({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return PichiStateView(
      icon: Icons.play_circle_outline_rounded,
      title: 'Nothing to continue',
      description: 'Partially watched videos will appear here.',
      severity: PichiSeverity.info,
      isCompact: isCompact,
    );
  }
}

// ============================================================================
// STATE 06 — Search with no results
// ============================================================================

class SearchNoResultsStateView extends StatelessWidget {
  final String query;
  final VoidCallback onClearSearch;
  final String? suggestion;
  final ValueChanged<String>? onSelectSuggestion;

  const SearchNoResultsStateView({
    super.key,
    required this.query,
    required this.onClearSearch,
    this.suggestion,
    this.onSelectSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    return PichiStateView(
      icon: Icons.search_off_rounded,
      title: 'No videos found',
      description: 'Nothing in your local library matches "$query".',
      severity: PichiSeverity.info,
      primaryActionLabel: 'Clear Search',
      onPrimaryAction: onClearSearch,
      customContent: (suggestion != null && onSelectSuggestion != null)
          ? GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelectSuggestion!(suggestion!);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.infoBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_fix_high_rounded,
                        size: 14, color: AppColors.electricBlueBright),
                    const SizedBox(width: 6),
                    Text(
                      'Did you mean "$suggestion"?',
                      style: const TextStyle(
                        color: AppColors.electricBlueBright,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

// ============================================================================
// STATE 07 — Missing video file
// ============================================================================

class MissingVideoStateView extends StatelessWidget {
  final VoidCallback onLocateFile;
  final VoidCallback onRemoveFromLibrary;
  final String? videoTitle;

  const MissingVideoStateView({
    super.key,
    required this.onLocateFile,
    required this.onRemoveFromLibrary,
    this.videoTitle,
  });

  @override
  Widget build(BuildContext context) {
    return PichiStateView(
      icon: Icons.file_present_outlined,
      title: 'Video unavailable',
      description: 'This video is no longer available at its saved location.',
      severity: PichiSeverity.warning,
      primaryActionLabel: 'Locate File',
      onPrimaryAction: onLocateFile,
      secondaryActionLabel: 'Remove from Library',
      onSecondaryAction: onRemoveFromLibrary,
      customContent: videoTitle != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.glassBorderSubtle),
              ),
              child: Text(
                videoTitle!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : null,
    );
  }
}

// ============================================================================
// STATE 08 — Missing folder access
// ============================================================================

class FolderAccessRequiredStateView extends StatelessWidget {
  final VoidCallback onGrantAccess;
  final VoidCallback onRemoveFolder;
  final String? folderName;

  const FolderAccessRequiredStateView({
    super.key,
    required this.onGrantAccess,
    required this.onRemoveFolder,
    this.folderName,
  });

  @override
  Widget build(BuildContext context) {
    return PichiStateView(
      icon: Icons.folder_special_outlined,
      title: 'Folder access required',
      description: folderName != null
          ? 'PIchiPlayer no longer has access to "$folderName".'
          : 'PIchiPlayer no longer has access to this folder.',
      severity: PichiSeverity.warning,
      primaryActionLabel: 'Grant Access',
      onPrimaryAction: onGrantAccess,
      secondaryActionLabel: 'Remove Folder',
      onSecondaryAction: onRemoveFolder,
    );
  }
}

// ============================================================================
// STATE 09 — Unsupported video
// ============================================================================

class UnsupportedVideoStateView extends StatelessWidget {
  final String? codec;
  final String? resolution;
  final VoidCallback onTryAnotherDecoder;
  final TechnicalMediaDetails? technicalDetails;

  const UnsupportedVideoStateView({
    super.key,
    this.codec = 'AV1',
    this.resolution = '3840 × 2160',
    required this.onTryAnotherDecoder,
    this.technicalDetails,
  });

  @override
  Widget build(BuildContext context) {
    return PichiStateView(
      icon: Icons.movie_filter_outlined,
      title: "Can't play this video",
      description: 'This device may not support the required decoder.',
      severity: PichiSeverity.warning,
      primaryActionLabel: 'Try Another Decoder',
      onPrimaryAction: onTryAnotherDecoder,
      technicalDetails: technicalDetails ??
          TechnicalMediaDetails(
            videoCodec: codec,
            resolution: resolution,
            decoderError:
                'MediaCodecVideoRenderer: Hardware decoder not supported on this chipset.',
          ),
      customContent: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (codec != null)
            _buildBadge('Codec', codec!, AppColors.electricBlueBright),
          if (codec != null && resolution != null) const SizedBox(width: 8),
          if (resolution != null)
            _buildBadge('Resolution', resolution!, AppColors.warningBright),
        ],
      ),
    );
  }

  static Widget _buildBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================================
// STATE 10 — Decoder recovery
// ============================================================================

class DecoderRecoveryView extends StatefulWidget {
  final bool isRecovered;
  final VoidCallback? onDismiss;

  const DecoderRecoveryView({
    super.key,
    this.isRecovered = false,
    this.onDismiss,
  });

  @override
  State<DecoderRecoveryView> createState() => _DecoderRecoveryViewState();
}

class _DecoderRecoveryViewState extends State<DecoderRecoveryView> {
  @override
  void initState() {
    super.initState();
    if (widget.isRecovered && widget.onDismiss != null) {
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) widget.onDismiss!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recovered = widget.isRecovered;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: recovered
                ? AppColors.success.withOpacity(0.4)
                : AppColors.warningBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: recovered
                    ? AppColors.success.withOpacity(0.15)
                    : AppColors.warningSubtle,
                border: Border.all(
                  color: recovered
                      ? AppColors.success.withOpacity(0.5)
                      : AppColors.warningBorder,
                ),
              ),
              child: Center(
                child: recovered
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.success, size: 26)
                    : const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.warningBright),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              recovered ? 'Playback recovered' : 'Hardware decoder issue',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              recovered
                  ? 'Continuing with software rendering.'
                  : 'Trying software decoder...',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STATE 11 — Thumbnail loading skeleton
// ============================================================================

class PichiThumbnailSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool showTextSkeletons;

  const PichiThumbnailSkeleton({
    super.key,
    this.width = 180,
    this.height = 101, // 16:9 for 180
    this.borderRadius = 16,
    this.showTextSkeletons = true,
  });

  @override
  State<PichiThumbnailSkeleton> createState() => _PichiThumbnailSkeletonState();
}

class _PichiThumbnailSkeletonState extends State<PichiThumbnailSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.25, end: 0.60).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final shimmerColor =
            AppColors.surfaceSubtle.withOpacity(_animation.value);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail box
            Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: AppColors.glassBorderSubtle,
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 24,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            if (widget.showTextSkeletons) ...[
              const SizedBox(height: 8),
              Container(
                width: widget.width * 0.75,
                height: 12,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: widget.width * 0.45,
                height: 10,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ============================================================================
// STATE 12 — Thumbnail failure fallback
// ============================================================================

class PichiFallbackThumbnail extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final String? label;

  const PichiFallbackThumbnail({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF141C30),
              Color(0xFF0D121F),
              AppColors.backgroundNavy,
            ],
          ),
          border: Border.all(
            color: AppColors.glassBorderSubtle,
            width: 0.8,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Abstract subtle backdrop icon
            Icon(
              Icons.movie_outlined,
              size: 42,
              color: Colors.white.withOpacity(0.06),
            ),

            // Subtle play symbol
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.8,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 18,
                  color: Colors.white70,
                ),
              ),
            ),

            // Optional filename label at bottom
            if (label != null)
              Positioned(
                bottom: 6,
                left: 8,
                right: 8,
                child: Text(
                  label!,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STATE 13 — Library refresh (non-blocking)
// ============================================================================

class LibraryRefreshBanner extends StatelessWidget {
  final int? newlyDiscoveredCount;
  final VoidCallback? onDismiss;

  const LibraryRefreshBanner({
    super.key,
    this.newlyDiscoveredCount,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.infoBorder, width: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.electricBlueBright),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              newlyDiscoveredCount != null && newlyDiscoveredCount! > 0
                  ? 'Updating library... $newlyDiscoveredCount new videos found'
                  : 'Updating library...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close_rounded,
                  color: AppColors.textMuted, size: 16),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATE 14 — Storage access explanation sheet
// ============================================================================

class StorageAccessExplanationSheet extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onNotNow;

  const StorageAccessExplanationSheet({
    super.key,
    required this.onContinue,
    required this.onNotNow,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onContinue,
    required VoidCallback onNotNow,
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StorageAccessExplanationSheet(
        onContinue: () {
          Navigator.pop(ctx);
          onContinue();
        },
        onNotNow: () {
          Navigator.pop(ctx);
          onNotNow();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),

            // Icon badge
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.infoSubtle,
                border: Border.all(color: AppColors.infoBorder),
              ),
              child: const Center(
                child: Icon(Icons.folder_shared_outlined,
                    color: AppColors.electricBlueBright, size: 30),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Access your videos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            const Text(
              'PIchiPlayer needs access to this folder to discover and play your local videos.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Actions
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onContinue,
                child: const Text('Continue',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: onNotNow,
                child: const Text('Not now',
                    style: TextStyle(
                        fontSize: 13.5, color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STATE 15 — Corrupt / unreadable media
// ============================================================================

class CorruptMediaStateView extends StatelessWidget {
  final VoidCallback onTryAgain;
  final TechnicalMediaDetails? technicalDetails;

  const CorruptMediaStateView({
    super.key,
    required this.onTryAgain,
    this.technicalDetails,
  });

  @override
  Widget build(BuildContext context) {
    return PichiStateView(
      icon: Icons.broken_image_outlined,
      title: "File couldn't be read",
      description:
          "PIchiPlayer couldn't read the video information from this file.\nThe file may be damaged or incomplete.",
      severity: PichiSeverity.critical,
      primaryActionLabel: 'Try Again',
      onPrimaryAction: onTryAgain,
      technicalDetails: technicalDetails ??
          const TechnicalMediaDetails(
            parserStatus:
                'Demuxer failed: Unexpected EOF or corrupted container headers.',
          ),
    );
  }
}

// ============================================================================
// STATE 16 — Subtitle error
// ============================================================================

class SubtitleErrorStateView extends StatelessWidget {
  final String subtitleFileName;
  final VoidCallback onChooseAnotherFile;

  const SubtitleErrorStateView({
    super.key,
    this.subtitleFileName = 'Movie.Bengali.srt',
    required this.onChooseAnotherFile,
  });

  @override
  Widget build(BuildContext context) {
    return PichiStateView(
      icon: Icons.subtitles_off_outlined,
      title: 'Subtitle unavailable',
      description: "PIchiPlayer couldn't read $subtitleFileName.",
      severity: PichiSeverity.warning,
      primaryActionLabel: 'Choose Another File',
      onPrimaryAction: onChooseAnotherFile,
    );
  }
}

// ============================================================================
// STATE 17 — Audio track error
// ============================================================================

class AudioTrackErrorStateView extends StatelessWidget {
  final String trackName;
  final VoidCallback onChooseAnotherTrack;

  const AudioTrackErrorStateView({
    super.key,
    this.trackName = 'DTS-HD MA',
    required this.onChooseAnotherTrack,
  });

  @override
  Widget build(BuildContext context) {
    return PichiStateView(
      icon: Icons.volume_off_outlined,
      title: 'Audio track unavailable',
      description:
          'This audio track cannot be decoded with the current playback configuration.',
      severity: PichiSeverity.warning,
      primaryActionLabel: 'Choose Another Track',
      onPrimaryAction: onChooseAnotherTrack,
      customContent: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.warningSubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warningBorder),
        ),
        child: Text(
          trackName,
          style: const TextStyle(
            color: AppColors.warningBright,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// STATE 18 — No storage access
// ============================================================================

class NoStorageAccessStateView extends StatelessWidget {
  final VoidCallback onGrantAccess;

  const NoStorageAccessStateView({
    super.key,
    required this.onGrantAccess,
  });

  @override
  Widget build(BuildContext context) {
    return PichiStateView(
      icon: Icons.sd_storage_outlined,
      title: 'Storage access needed',
      description:
          'Grant PIchiPlayer access to your local video folders to build your library.',
      severity: PichiSeverity.warning,
      primaryActionLabel: 'Grant Access',
      onPrimaryAction: onGrantAccess,
    );
  }
}
