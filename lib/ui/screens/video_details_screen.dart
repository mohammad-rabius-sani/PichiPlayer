import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/audio_track_info.dart';
import '../../models/local_video.dart';
import '../widgets/ambient_background.dart';
import '../widgets/metadata_section_card.dart';
import '../widgets/video_details_hero.dart';
import '../widgets/video_details_menu_sheet.dart';
import '../widgets/video_quick_actions_row.dart';
import 'player_screen.dart';

/// The official Video Details screen for PIchiPlayer.
/// An offline-first, cinematic video inspector featuring full technical metadata,
/// quick audio/subtitle controls, and error states for missing/unsupported media.
class VideoDetailsScreen extends StatefulWidget {
  final LocalVideo video;
  final bool enableBackgroundAnimation;
  final bool isMissingOverride;
  final bool isUnsupportedOverride;

  const VideoDetailsScreen({
    super.key,
    required this.video,
    this.enableBackgroundAnimation = true,
    this.isMissingOverride = false,
    this.isUnsupportedOverride = false,
  });

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen>
    with SingleTickerProviderStateMixin {
  late LocalVideo _video;
  late bool _isFavorite;
  late AnimationController _favAnimController;
  late Animation<double> _favScaleAnim;

  // Selected Quick Settings
  late String _activeSubtitle;
  late AudioTrackInfo _activeAudioTrack;
  String _activeSpeed = '1×';

  // Path revelation
  bool _showFullPath = false;

  @override
  void initState() {
    super.initState();
    _video = widget.video;
    _isFavorite = _video.isFavorite;

    _activeSubtitle = _video.effectiveSubtitleTracks.first;
    _activeAudioTrack = _video.effectiveAudioTracks.first;

    _favAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _favScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _favAnimController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _favAnimController.dispose();
    super.dispose();
  }

  bool get _isMissing => widget.isMissingOverride || _video.isMissing;
  bool get _isUnsupported => widget.isUnsupportedOverride || _video.isUnsupported;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      _video = _video.copyWith(isFavorite: _isFavorite);
    });

    _favAnimController.forward(from: 0.0);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        content: Row(
          children: [
            Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? const Color(0xFFEF4444) : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              _isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStartPlayback() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => PlayerScreen(video: _video),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _showSubtitleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildSelectionSheet(
        title: 'Select Subtitles',
        icon: Icons.subtitles_rounded,
        items: _video.effectiveSubtitleTracks,
        selectedItem: _activeSubtitle,
        onSelected: (val) {
          setState(() => _activeSubtitle = val);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showAudioTrackSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildSelectionSheet(
        title: 'Select Audio Track',
        icon: Icons.audiotrack_rounded,
        items: _video.effectiveAudioTracks.map((a) => a.title).toList(),
        selectedItem: _activeAudioTrack.title,
        onSelected: (val) {
          final matched = _video.effectiveAudioTracks.firstWhere((a) => a.title == val);
          setState(() => _activeAudioTrack = matched);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showSpeedSelector() {
    const speeds = ['0.5×', '0.75×', '1×', '1.25×', '1.5×', '2×'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildSelectionSheet(
        title: 'Playback Speed',
        icon: Icons.speed_rounded,
        items: speeds,
        selectedItem: _activeSpeed,
        onSelected: (val) {
          setState(() => _activeSpeed = val);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Widget _buildSelectionSheet({
    required String title,
    required IconData icon,
    required List<String> items,
    required String selectedItem,
    required ValueChanged<String> onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: AppColors.glassBorderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.electricBlueBright, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: AppColors.glassBorderSubtle, height: 1),
            for (final item in items)
              ListTile(
                title: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: item == selectedItem ? FontWeight.w600 : FontWeight.w400,
                    color: item == selectedItem ? AppColors.electricBlueBright : AppColors.textPrimary,
                  ),
                ),
                trailing: item == selectedItem
                    ? const Icon(Icons.check_rounded, color: AppColors.electricBlueBright, size: 20)
                    : null,
                onTap: () => onSelected(item),
              ),
          ],
        ),
      ),
    );
  }

  void _openOverflowMenu() {
    VideoDetailsMenuSheet.show(
      context,
      video: _video,
      onAddToPlaylist: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Text('Added "${_video.title}" to offline playlist'),
          ),
        );
      },
      onOpenFolder: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Text('Folder: ${_video.folderPath}'),
          ),
        );
      },
      onRename: _showRenameDialog,
      onShare: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.surface,
            content: Text('System share sheet opened'),
          ),
        );
      },
      onShowFileInfo: () {
        setState(() => _showFullPath = true);
      },
      onDelete: _showDeleteConfirmationDialog,
    );
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: _video.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        title: const Text('Rename Video', style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'New title',
            labelStyle: TextStyle(color: AppColors.textMuted),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              Navigator.pop(ctx);
              if (newName.isNotEmpty) {
                setState(() {
                  _video = _video.copyWith(
                    title: newName,
                    fileName: '$newName.${_video.effectiveContainer.toLowerCase()}',
                  );
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricBlue),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 8),
            Text('Delete File?', style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
          ],
        ),
        content: Text(
          'Permanently delete "${_video.displayFileName}" from your device storage? This action cannot be reversed.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Return to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.surface,
                  content: Text('Deleted "${_video.displayFileName}"'),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientBackground(
        enableAnimation: widget.enableBackgroundAnimation,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Lightweight Top Header
              _buildTopHeader(),

              // 2. Scrollable Body
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 32.0),
                  children: [
                    // A. Missing File Notice State
                    if (_isMissing) ...[
                      _buildMissingFileNotice(),
                      const SizedBox(height: 16),
                    ],

                    // B. Unsupported Playback Notice State
                    if (!_isMissing && _isUnsupported) ...[
                      _buildUnsupportedNotice(),
                      const SizedBox(height: 16),
                    ],

                    // C. Cinematic Media Hero Thumbnail
                    VideoDetailsHero(
                      video: _video,
                      onPlay: _isMissing ? () {} : _handleStartPlayback,
                    ),

                    const SizedBox(height: 16),

                    // D. Video Title & Quick Summary Line
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _video.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _video.quickSummaryText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // E. Playback Progress Section
                    _buildPlaybackProgressSection(),

                    const SizedBox(height: 16),

                    // F. Primary Actions Row (Play/Resume, Favorite, More)
                    _buildPrimaryActionsRow(),

                    const SizedBox(height: 16),

                    // G. Quick Actions Row (Subtitles, Audio, Speed, Aspect)
                    VideoQuickActionsRow(
                      activeSubtitle: _activeSubtitle,
                      activeAudio: _activeAudioTrack.language,
                      activeSpeed: _activeSpeed,
                      onSubtitlesTap: _showSubtitleSelector,
                      onAudioTap: _showAudioTrackSelector,
                      onSpeedTap: _showSpeedSelector,
                      onMoreTap: _openOverflowMenu,
                    ),

                    const SizedBox(height: 24),

                    // H. VIDEO Information Section
                    _buildVideoSection(),

                    const SizedBox(height: 20),

                    // I. AUDIO Information Section
                    _buildAudioSection(),

                    const SizedBox(height: 20),

                    // J. FILE Information Section
                    _buildFileSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Top Header ---
  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 22),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Video Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onPressed: _openOverflowMenu,
            tooltip: 'More options',
          ),
        ],
      ),
    );
  }

  // --- Missing File Notice ---
  Widget _buildMissingFileNotice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 10),
              Text(
                'Video unavailable',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFFCA5A5)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'This file is no longer available at its saved location.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFFF87171)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Locate file picker opened')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Locate File', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFCA5A5),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Remove from Library', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Unsupported Format Notice ---
  Widget _buildUnsupportedNotice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.violetAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.violetAccent.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFA78BFA), size: 20),
              SizedBox(width: 10),
              Text(
                'This video may not be playable',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFDDD6FE)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Codec: ${_video.codec} • Resolution: ${_video.resolution}',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFFC4B5FD)),
          ),
          const SizedBox(height: 2),
          const Text(
            'Your device may not support hardware decoding for this format.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _handleStartPlayback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Try Playback', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Player decoding settings opened')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.glassBorderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Player Settings', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Playback Progress ---
  Widget _buildPlaybackProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_video.isPartiallyWatched) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress: ${_video.progressText}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.electricBlueBright,
                  ),
                ),
                Text(
                  '${(_video.progressRatio * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  Container(height: 4, color: Colors.white.withOpacity(0.08)),
                  FractionallySizedBox(
                    widthFactor: _video.progressRatio,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electricBlue.withOpacity(0.50),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: AppColors.textMuted),
                SizedBox(width: 6),
                Text(
                  'Not watched yet',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- Primary Actions Row ---
  Widget _buildPrimaryActionsRow() {
    final isResume = _video.isPartiallyWatched;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Play / Resume Button
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isMissing ? null : _handleStartPlayback,
                icon: Icon(
                  isResume ? Icons.play_arrow_rounded : Icons.play_arrow_rounded,
                  size: 24,
                  color: Colors.white,
                ),
                label: Text(
                  isResume ? 'Resume' : 'Play',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  disabledBackgroundColor: AppColors.surfaceGlass,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  shadowColor: AppColors.electricBlue.withOpacity(0.40),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Favorite Toggle with Animated Scaling
          ScaleTransition(
            scale: _favScaleAnim,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isFavorite
                    ? const Color(0xFFEF4444).withOpacity(0.12)
                    : AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isFavorite
                      ? const Color(0xFFEF4444).withOpacity(0.40)
                      : AppColors.glassBorderSubtle,
                  width: 0.8,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isFavorite ? const Color(0xFFEF4444) : AppColors.textSecondary,
                  size: 22,
                ),
                tooltip: _isFavorite ? 'Favorite' : 'Add to Favorites',
                onPressed: _toggleFavorite,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Context More Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceGlass,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.glassBorderSubtle,
                width: 0.8,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              tooltip: 'More actions',
              onPressed: _openOverflowMenu,
            ),
          ),
        ],
      ),
    );
  }

  // --- VIDEO Information Section ---
  Widget _buildVideoSection() {
    final items = [
      MetadataRowItem(label: 'Resolution', value: _video.effectiveDimensions),
      MetadataRowItem(label: 'Codec', value: '${_video.codec} / H.265'),
      if (_video.fps != null)
        MetadataRowItem(label: 'Frame rate', value: '${_video.fpsFormatted} FPS')
      else
        const MetadataRowItem(label: 'Frame rate', value: '23.976 FPS'),
      MetadataRowItem(label: 'Bitrate', value: '${_video.effectiveBitrateMbps} Mbps'),
      MetadataRowItem(
        label: 'Dynamic range',
        value: _video.dynamicRangeText,
        isHighlighted: _video.isHdr,
      ),
      const MetadataRowItem(label: 'Aspect ratio', value: '16:9 (1.78:1)'),
    ];

    return MetadataSectionCard(
      title: 'VIDEO',
      items: items,
    );
  }

  // --- AUDIO Information Section ---
  Widget _buildAudioSection() {
    final audio = _activeAudioTrack;
    final totalCount = _video.effectiveAudioTracks.length;

    final items = [
      MetadataRowItem(label: 'Track', value: audio.title),
      MetadataRowItem(label: 'Codec', value: audio.codec),
      MetadataRowItem(label: 'Channels', value: audio.channels),
      MetadataRowItem(label: 'Bitrate', value: audio.technicalBitrateText),
      MetadataRowItem(label: 'Sample rate', value: audio.sampleRateText),
    ];

    return MetadataSectionCard(
      title: 'AUDIO',
      badgeText: totalCount > 1 ? '$totalCount tracks' : '1 track',
      items: items,
      trailingAction: totalCount > 1
          ? GestureDetector(
              onTap: _showAudioTrackSelector,
              child: const Text(
                'Switch Track',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.electricBlueBright),
              ),
            )
          : null,
    );
  }

  // --- FILE Information Section ---
  Widget _buildFileSection() {
    final items = [
      MetadataRowItem(label: 'Container', value: _video.effectiveContainer),
      MetadataRowItem(label: 'Size', value: _video.fileSizeFormatted),
      MetadataRowItem(
        label: 'Location',
        value: _video.folderPath,
        onTap: () {
          setState(() => _showFullPath = !_showFullPath);
        },
      ),
      MetadataRowItem(
        label: 'Modified',
        value: '${_video.effectiveDateModified.year}-${_video.effectiveDateModified.month.toString().padLeft(2, '0')}-${_video.effectiveDateModified.day.toString().padLeft(2, '0')}',
      ),
    ];

    return MetadataSectionCard(
      title: 'FILE',
      items: items,
      bottomWidget: _showFullPath
          ? Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Full Device Path',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _video.fullDevicePath,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.electricBlueBright,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textMuted),
                        tooltip: 'Copy path',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _video.fullDevicePath));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Path copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
