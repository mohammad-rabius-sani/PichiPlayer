import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/subtitle_track_info.dart';
import '../../screens/subtitle_style_screen.dart';

/// The official Subtitle Selection Bottom Sheet for PIchiPlayer.
/// An offline-first, local subtitle selector supporting embedded tracks,
/// companion external files (.srt, .ass, .ssa, .vtt), loading states,
/// invalid file handling, and instant switching with haptic feedback.
class SubtitleSelectionSheet extends StatefulWidget {
  final List<SubtitleTrackInfo> tracks;
  final String selectedTrack;
  final ValueChanged<String> onSelected;
  final VoidCallback? onOpenCustomization;
  final String? videoTitle;

  const SubtitleSelectionSheet({
    super.key,
    required this.tracks,
    required this.selectedTrack,
    required this.onSelected,
    this.onOpenCustomization,
    this.videoTitle,
  });

  /// Static helper to display the sheet over fullscreen player
  static void show(
    BuildContext context, {
    required List<String> subtitleTracks,
    required String selectedTrack,
    required ValueChanged<String> onSelected,
    VoidCallback? onAddSubtitleFile,
    VoidCallback? onOpenCustomization,
    String? videoTitle,
  }) {
    // Convert raw track strings to rich SubtitleTrackInfo instances
    final List<SubtitleTrackInfo> richTracks = [];

    // Always ensure "Off" option is available
    richTracks.add(SubtitleTrackInfo.off());

    for (final track in subtitleTracks) {
      final info = SubtitleTrackInfo.fromString(track);
      if (!info.isOff) {
        richTracks.add(info);
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SubtitleSelectionSheet(
        tracks: richTracks,
        selectedTrack: selectedTrack,
        onSelected: onSelected,
        onOpenCustomization: onOpenCustomization,
        videoTitle: videoTitle,
      ),
    );
  }

  @override
  State<SubtitleSelectionSheet> createState() => _SubtitleSelectionSheetState();
}

class _SubtitleSelectionSheetState extends State<SubtitleSelectionSheet> {
  late List<SubtitleTrackInfo> _tracks;
  late String _selectedTrack;

  // Loading & error states for external file parsing
  bool _isLoadingFile = false;
  String? _loadingFileName;
  String? _errorMessage;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _tracks = List.from(widget.tracks);
    _selectedTrack = widget.selectedTrack;

    // Normalize selectedTrack for matching
    if (_selectedTrack.toLowerCase() == 'none (off)' ||
        _selectedTrack.toLowerCase() == 'none' ||
        _selectedTrack.toLowerCase() == 'disabled') {
      _selectedTrack = 'Off';
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  bool _isOptionSelected(SubtitleTrackInfo track) {
    if (track.isOff) {
      return _selectedTrack == 'Off' ||
          _selectedTrack == 'None (Off)' ||
          _selectedTrack == 'None' ||
          _selectedTrack == 'Subtitles Off';
    }
    return _selectedTrack.toLowerCase() == track.language.toLowerCase() ||
        _selectedTrack.toLowerCase() == track.id.toLowerCase();
  }

  void _handleTrackTapped(SubtitleTrackInfo track) {
    HapticFeedback.selectionClick();
    final newSelection = track.isOff ? 'None (Off)' : track.language;

    setState(() {
      _selectedTrack = track.isOff ? 'Off' : track.language;
    });

    widget.onSelected(newSelection);

    // Momentary pause (220ms) so user sees checkmark and active glow feedback, then auto-dismisses
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(milliseconds: 220), () {
      if (mounted) Navigator.pop(context);
    });
  }

  /// Simulate selecting and parsing an offline subtitle file from local storage
  Future<void> _handleAddSubtitleFile() async {
    setState(() {
      _errorMessage = null;
      _isLoadingFile = true;
      _loadingFileName = '${widget.videoTitle ?? "Video"}.Bengali.srt';
    });

    // Simulate fast offline disk read & parsing
    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    // Check if this track is already added
    final exists = _tracks.any((t) => t.language.toLowerCase() == 'bengali' && t.source == SubtitleSource.externalFile);

    if (exists) {
      // Toggle to invalid test simulation if already added to demonstrate error recovery
      setState(() {
        _isLoadingFile = false;
        _loadingFileName = null;
        _errorMessage = "This subtitle file couldn't be read by PIchiPlayer.";
      });
      return;
    }

    final newTrack = SubtitleTrackInfo(
      id: 'ext_sub_${DateTime.now().millisecondsSinceEpoch}',
      language: 'Bengali',
      source: SubtitleSource.externalFile,
      format: SubtitleFormat.srt,
      formatLabel: 'SRT',
      filePath: '/storage/emulated/0/Movies/Subtitles/Bengali.srt',
    );

    setState(() {
      _isLoadingFile = false;
      _loadingFileName = null;
      _tracks.add(newTrack);
      _selectedTrack = newTrack.language;
    });

    HapticFeedback.lightImpact();
    widget.onSelected(newTrack.language);
  }

  void _openCustomizationSheet() {
    Navigator.pop(context);
    if (widget.onOpenCustomization != null) {
      widget.onOpenCustomization!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubtitleStyleScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final maxSheetHeight = isLandscape
        ? mediaQuery.size.height * 0.88
        : mediaQuery.size.height * 0.65;

    final availableSubtitleTracks = _tracks.where((t) => !t.isOff).toList();
    final hasNoSubtitles = availableSubtitleTracks.isEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          decoration: BoxDecoration(
            color: AppColors.backgroundNavy.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.60),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 2. Sheet Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.subtitles_rounded,
                        color: AppColors.electricBlueBright,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Subtitles',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      // Close button
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: AppColors.glassBorderSubtle, height: 1),

                // 3. Scrollable Track Content
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    children: [
                      // Loading state banner while parsing external file
                      if (_isLoadingFile) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.electricBlueBright.withOpacity(0.40),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.electricBlueBright,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Adding subtitle...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (_loadingFileName != null)
                                      Text(
                                        _loadingFileName!,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Invalid subtitle error card
                      if (_errorMessage != null) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A1515),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Couldn't add subtitle",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => setState(() => _errorMessage = null),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: AppColors.textMuted,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _handleAddSubtitleFile,
                                child: const Text(
                                  'Choose another file',
                                  style: TextStyle(
                                    color: AppColors.electricBlueBright,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Empty state if no subtitle tracks exist
                      if (hasNoSubtitles) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.50),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorderSubtle),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.closed_caption_disabled_rounded,
                                size: 36,
                                color: AppColors.textMuted.withOpacity(0.8),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'No subtitles available',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "PIchiPlayer couldn't find embedded or local subtitle tracks.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Render Subtitle Track Rows
                        for (final track in _tracks)
                          _buildSubtitleRow(track),
                      ],

                      const SizedBox(height: 8),
                      const Divider(color: AppColors.glassBorderSubtle, height: 1),
                      const SizedBox(height: 10),

                      // 4. Action: + Add Subtitle File
                      _buildActionTile(
                        icon: Icons.add_rounded,
                        title: 'Add subtitle file',
                        subtitle: 'Select .srt, .ass, .ssa, or .vtt from storage',
                        isPrimary: true,
                        onTap: _handleAddSubtitleFile,
                      ),

                      const SizedBox(height: 6),

                      // 5. Action: Subtitle Settings (Opens dedicated styling customization)
                      _buildActionTile(
                        icon: Icons.tune_rounded,
                        title: 'Subtitle settings',
                        subtitle: 'Appearance, size, colors, and delay',
                        isPrimary: false,
                        onTap: _openCustomizationSheet,
                      ),

                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitleRow(SubtitleTrackInfo track) {
    final isSelected = _isOptionSelected(track);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.electricBlue.withOpacity(0.12)
            : AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.electricBlueBright.withOpacity(0.45)
              : AppColors.glassBorderSubtle,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTrackTapped(track),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // Track Icon
                Icon(
                  track.icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.electricBlueBright
                      : (track.isOff ? AppColors.textMuted : AppColors.textSecondary),
                ),
                const SizedBox(width: 12),

                // Language & Metadata column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              track.language,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (track.isForced) ...[
                            const SizedBox(width: 6),
                            _buildTagBadge('FORCED'),
                          ],
                          if (track.isSdh) ...[
                            const SizedBox(width: 6),
                            _buildTagBadge('SDH'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        track.metadataLine,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.electricBlueBright.withOpacity(0.9)
                              : AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Radio Selection Indicator with Checkmark
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.electricBlueBright : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.electricBlueBright
                          : Colors.white.withOpacity(0.24),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.electricBlue.withOpacity(0.50),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.black,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: AppColors.badgeBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.badgeBorder, width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.electricBlueBright,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.surface.withOpacity(0.70)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrimary
              ? AppColors.glassBorderSubtle
              : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? AppColors.electricBlue.withOpacity(0.18)
                        : Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isPrimary
                        ? AppColors.electricBlueBright
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1.5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
