import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/audio_track_info.dart';

/// The official Audio Track Selection & Audio Controls bottom sheet for PIchiPlayer.
/// An offline-first local audio selector featuring instant track switching,
/// metadata and special track badges (Main, Commentary, Dub), live volume slider with mute toggle,
/// audio delay controls (-500ms to +500ms), advanced audio processing (volume boost,
/// normalization, downmix), audio output route indication, and robust error/empty states.
class AudioSelectionSheet extends StatefulWidget {
  final List<AudioTrackInfo> audioTracks;
  final AudioTrackInfo selectedTrack;
  final ValueChanged<AudioTrackInfo> onSelected;
  final String? videoTitle;

  // Volume controls
  final double volume;
  final bool isMuted;
  final ValueChanged<double>? onVolumeChanged;
  final VoidCallback? onToggleMute;

  // Audio delay controls
  final int audioDelayMs;
  final ValueChanged<int>? onAudioDelayChanged;

  // Advanced audio processing
  final String volumeBoost;
  final ValueChanged<String>? onVolumeBoostChanged;
  final bool normalizeVolume;
  final ValueChanged<bool>? onNormalizeVolumeChanged;
  final String downmixOption;
  final ValueChanged<String>? onDownmixChanged;
  final String audioOutputDevice;

  const AudioSelectionSheet({
    super.key,
    required this.audioTracks,
    required this.selectedTrack,
    required this.onSelected,
    this.videoTitle,
    this.volume = 0.75,
    this.isMuted = false,
    this.onVolumeChanged,
    this.onToggleMute,
    this.audioDelayMs = 0,
    this.onAudioDelayChanged,
    this.volumeBoost = 'Off',
    this.onVolumeBoostChanged,
    this.normalizeVolume = false,
    this.onNormalizeVolumeChanged,
    this.downmixOption = 'Auto',
    this.onDownmixChanged,
    this.audioOutputDevice = 'Phone speaker',
  });

  /// Static helper to display the sheet over fullscreen player
  static void show(
    BuildContext context, {
    required List<AudioTrackInfo> audioTracks,
    required AudioTrackInfo selectedTrack,
    required ValueChanged<AudioTrackInfo> onSelected,
    String? videoTitle,
    double volume = 0.75,
    bool isMuted = false,
    ValueChanged<double>? onVolumeChanged,
    VoidCallback? onToggleMute,
    int audioDelayMs = 0,
    ValueChanged<int>? onAudioDelayChanged,
    String volumeBoost = 'Off',
    ValueChanged<String>? onVolumeBoostChanged,
    bool normalizeVolume = false,
    ValueChanged<bool>? onNormalizeVolumeChanged,
    String downmixOption = 'Auto',
    ValueChanged<String>? onDownmixChanged,
    String audioOutputDevice = 'Phone speaker',
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => AudioSelectionSheet(
        audioTracks: audioTracks,
        selectedTrack: selectedTrack,
        onSelected: onSelected,
        videoTitle: videoTitle,
        volume: volume,
        isMuted: isMuted,
        onVolumeChanged: onVolumeChanged,
        onToggleMute: onToggleMute,
        audioDelayMs: audioDelayMs,
        onAudioDelayChanged: onAudioDelayChanged,
        volumeBoost: volumeBoost,
        onVolumeBoostChanged: onVolumeBoostChanged,
        normalizeVolume: normalizeVolume,
        onNormalizeVolumeChanged: onNormalizeVolumeChanged,
        downmixOption: downmixOption,
        onDownmixChanged: onDownmixChanged,
        audioOutputDevice: audioOutputDevice,
      ),
    );
  }

  @override
  State<AudioSelectionSheet> createState() => _AudioSelectionSheetState();
}

class _AudioSelectionSheetState extends State<AudioSelectionSheet> {
  late AudioTrackInfo _currentTrack;
  late double _volume;
  late bool _isMuted;
  late int _audioDelayMs;
  late String _volumeBoost;
  late bool _normalizeVolume;
  late String _downmixOption;

  // Transient states
  bool _isSwitching = false;
  String? _switchingLabel;
  String? _unsupportedNotice;
  String? _transientFeedback;
  Timer? _switchingTimer;
  Timer? _feedbackTimer;

  // Expandable sections
  bool _isDelayExpanded = false;
  bool _isAdvancedExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentTrack = widget.selectedTrack;
    _volume = widget.volume;
    _isMuted = widget.isMuted;
    _audioDelayMs = widget.audioDelayMs;
    _volumeBoost = widget.volumeBoost;
    _normalizeVolume = widget.normalizeVolume;
    _downmixOption = widget.downmixOption;
  }

  @override
  void dispose() {
    _switchingTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _handleTrackSelected(AudioTrackInfo track) {
    if (!track.isSupported) {
      HapticFeedback.mediumImpact();
      setState(() {
        _unsupportedNotice =
            '${track.codec} is not supported on this device/player configuration. Try another track.';
      });
      return;
    }

    if (track.id == _currentTrack.id) return;

    HapticFeedback.selectionClick();

    setState(() {
      _isSwitching = true;
      _switchingLabel = track.language;
      _unsupportedNotice = null;
    });

    widget.onSelected(track);

    _switchingTimer?.cancel();
    _switchingTimer = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      setState(() {
        _isSwitching = false;
        _switchingLabel = null;
        _currentTrack = track;
        _transientFeedback = 'Audio: ${track.language} ${track.channels}';
      });

      _feedbackTimer?.cancel();
      _feedbackTimer = Timer(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        setState(() => _transientFeedback = null);
      });
    });
  }

  void _handleVolumeChanged(double val) {
    setState(() {
      _volume = val;
      if (_isMuted && val > 0) {
        _isMuted = false;
      }
    });
    widget.onVolumeChanged?.call(val);
  }

  void _handleToggleMute() {
    HapticFeedback.lightImpact();
    setState(() => _isMuted = !_isMuted);
    widget.onToggleMute?.call();
  }

  void _handleAudioDelayChanged(int ms) {
    HapticFeedback.selectionClick();
    setState(() => _audioDelayMs = ms.clamp(-500, 500));
    widget.onAudioDelayChanged?.call(_audioDelayMs);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final maxSheetHeight = isLandscape
        ? mediaQuery.size.height * 0.88
        : mediaQuery.size.height * 0.70;

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

                // 2. Header
                _buildHeader(),

                // 3. Transient Feedback Bar (when track switches)
                if (_transientFeedback != null)
                  _buildTransientFeedbackBar(),

                // 4. Main Scrollable Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      // Loading indicator during track switch
                      if (_isSwitching)
                        _buildSwitchingIndicator(),

                      // Unsupported notice banner
                      if (_unsupportedNotice != null)
                        _buildUnsupportedNotice(),

                      // Empty state or Track List
                      if (widget.audioTracks.isEmpty)
                        _buildNoAudioTracksState()
                      else ...[
                        _buildSectionHeader('AVAILABLE TRACKS'),
                        const SizedBox(height: 8),
                        for (final track in widget.audioTracks)
                          _buildAudioTrackRow(track),
                      ],

                      const SizedBox(height: 16),
                      const Divider(color: AppColors.glassBorderSubtle, height: 1),
                      const SizedBox(height: 14),

                      // Volume Control
                      _buildSectionHeader('VOLUME'),
                      const SizedBox(height: 8),
                      _buildVolumeControl(),

                      const SizedBox(height: 16),
                      const Divider(color: AppColors.glassBorderSubtle, height: 1),
                      const SizedBox(height: 14),

                      // Audio Delay Tile & Slider
                      _buildAudioDelaySection(),

                      const SizedBox(height: 14),
                      const Divider(color: AppColors.glassBorderSubtle, height: 1),
                      const SizedBox(height: 14),

                      // Advanced Audio Section
                      _buildAdvancedAudioSection(),

                      const SizedBox(height: 10),
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

  // --- Header ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.audiotrack_rounded,
            color: AppColors.electricBlueBright,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Audio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                if (widget.videoTitle != null)
                  Text(
                    widget.videoTitle!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            key: const ValueKey('audio_sheet_close_btn'),
            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // --- Section Header ---
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  // --- Transient Feedback Bar ---
  Widget _buildTransientFeedbackBar() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.electricBlue.withOpacity(0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.electricBlueBright.withOpacity(0.40)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.electricBlueBright, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _transientFeedback!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Switching Indicator ---
  Widget _buildSwitchingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlueBright),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _switchingLabel != null
                ? 'Switching audio to $_switchingLabel...'
                : 'Switching audio...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- Unsupported Audio Notice ---
  Widget _buildUnsupportedNotice() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2B1414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audio track unavailable',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _unsupportedNotice!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => setState(() => _unsupportedNotice = null),
                  child: const Text(
                    'Try another track',
                    style: TextStyle(
                      color: AppColors.electricBlueBright,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _unsupportedNotice = null),
            child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 16),
          ),
        ],
      ),
    );
  }

  // --- No Audio Tracks Empty State ---
  Widget _buildNoAudioTracksState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.volume_off_rounded,
            color: AppColors.textMuted,
            size: 36,
          ),
          const SizedBox(height: 10),
          const Text(
            'No audio tracks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "This video doesn't contain a supported audio track.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            key: const ValueKey('try_playback_btn'),
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              elevation: 0,
            ),
            child: const Text('Try playback', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // --- Audio Track Selectable Row ---
  Widget _buildAudioTrackRow(AudioTrackInfo track) {
    final isSelected = track.id == _currentTrack.id;

    return Container(
      key: ValueKey('audio_track_${track.id}'),
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
          onTap: () => _handleTrackSelected(track),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // Track Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.electricBlue.withOpacity(0.20)
                        : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.audiotrack_rounded,
                    size: 16,
                    color: isSelected
                        ? AppColors.electricBlueBright
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),

                // Title, Special Badge & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              track.displayTitle,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (track.specialLabel != null && track.specialLabel!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _buildSpecialBadge(track.specialLabel!),
                          ] else if (track.isDefault) ...[
                            const SizedBox(width: 6),
                            _buildSpecialBadge('Default'),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Circular Selection Indicator with Checkmark
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

  // Helper special badge widget (e.g. Main, Dub, Commentary, Default)
  Widget _buildSpecialBadge(String label) {
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

  // --- Volume Control Row & Slider ---
  Widget _buildVolumeControl() {
    final effectiveVol = _isMuted ? 0.0 : _volume;
    final iconData = _isMuted || effectiveVol == 0.0
        ? Icons.volume_off_rounded
        : (effectiveVol < 0.5 ? Icons.volume_down_rounded : Icons.volume_up_rounded);

    final iconColor = _isMuted
        ? const Color(0xFFEF4444)
        : AppColors.electricBlueBright;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Row(
        children: [
          // Mute Toggle Icon Button
          IconButton(
            key: const ValueKey('mute_toggle_btn'),
            icon: Icon(iconData, color: iconColor, size: 22),
            tooltip: _isMuted ? 'Unmute' : 'Mute',
            onPressed: _handleToggleMute,
          ),
          const SizedBox(width: 4),

          // Smooth Volume Slider
          Expanded(
            child: Slider(
              value: effectiveVol.clamp(0.0, 1.0),
              min: 0.0,
              max: 1.0,
              activeColor: _isMuted ? AppColors.textMuted : AppColors.electricBlueBright,
              inactiveColor: Colors.white.withOpacity(0.12),
              onChanged: _handleVolumeChanged,
            ),
          ),

          // Percentage Text
          Container(
            width: 44,
            alignment: Alignment.centerRight,
            child: Text(
              '${(effectiveVol * 100).toInt()}%',
              style: TextStyle(
                color: _isMuted ? AppColors.textMuted : AppColors.electricBlueBright,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Audio Delay Section ---
  Widget _buildAudioDelaySection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          ListTile(
            key: const ValueKey('audio_delay_tile'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            leading: const Icon(Icons.timer_outlined, color: AppColors.electricBlueBright, size: 20),
            title: const Text(
              'Audio delay',
              style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_audioDelayMs >= 0 ? '+' : ''}$_audioDelayMs ms',
                  style: const TextStyle(
                    color: AppColors.electricBlueBright,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  _isDelayExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
            onTap: () => setState(() => _isDelayExpanded = !_isDelayExpanded),
          ),

          // Expandable Delay Slider & Nudge Buttons
          if (_isDelayExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                children: [
                  const Divider(color: AppColors.glassBorderSubtle, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('-500 ms', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      Text(
                        '${_audioDelayMs >= 0 ? '+' : ''}$_audioDelayMs ms',
                        style: const TextStyle(
                          color: AppColors.electricBlueBright,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text('+500 ms', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                  Slider(
                    value: _audioDelayMs.toDouble(),
                    min: -500,
                    max: 500,
                    divisions: 20,
                    activeColor: AppColors.electricBlueBright,
                    inactiveColor: Colors.white.withOpacity(0.12),
                    onChanged: (val) => _handleAudioDelayChanged(val.toInt()),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNudgeButton('-50 ms', () => _handleAudioDelayChanged(_audioDelayMs - 50)),
                      _buildNudgeButton('Reset (0 ms)', () => _handleAudioDelayChanged(0)),
                      _buildNudgeButton('+50 ms', () => _handleAudioDelayChanged(_audioDelayMs + 50)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNudgeButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // --- Advanced Audio Section ---
  Widget _buildAdvancedAudioSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          ListTile(
            key: const ValueKey('advanced_audio_tile'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            leading: const Icon(Icons.equalizer_rounded, color: AppColors.electricBlueBright, size: 20),
            title: const Text(
              'Advanced audio',
              style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Volume boost, normalization, downmix, output',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            trailing: Icon(
              _isAdvancedExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onTap: () => setState(() => _isAdvancedExpanded = !_isAdvancedExpanded),
          ),

          if (_isAdvancedExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.glassBorderSubtle, height: 1),
                  const SizedBox(height: 12),

                  // 1. Volume Boost
                  const Text('Volume boost', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Off', '+25%', '+50%', '+75%', '+100%'].map((opt) {
                      final isSelected = _volumeBoost == opt;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _buildChoiceChip(
                            label: opt,
                            isSelected: isSelected,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _volumeBoost = opt);
                              widget.onVolumeBoostChanged?.call(opt);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // 2. Normalize Volume Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Normalize volume', style: TextStyle(color: Colors.white, fontSize: 13)),
                            SizedBox(height: 1.5),
                            Text(
                              'Evens out sudden loud sounds and quiet dialogue',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        key: const ValueKey('normalize_volume_switch'),
                        value: _normalizeVolume,
                        activeColor: AppColors.electricBlueBright,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          setState(() => _normalizeVolume = val);
                          widget.onNormalizeVolumeChanged?.call(val);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 3. Downmix Surround
                  const Text('Downmix surround', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Auto', 'Stereo', 'Preserve surround'].map((opt) {
                      final isSelected = _downmixOption == opt;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _buildChoiceChip(
                            label: opt,
                            isSelected: isSelected,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _downmixOption = opt);
                              widget.onDownmixChanged?.call(opt);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // 4. Audio Output Route Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.glassBorderSubtle),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.speaker_rounded, color: AppColors.electricBlueBright, size: 18),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Audio output',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                            Text(
                              'System-level routing authoritative',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 9.5),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.electricBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.electricBlueBright.withOpacity(0.30)),
                          ),
                          child: Text(
                            widget.audioOutputDevice,
                            style: const TextStyle(
                              color: AppColors.electricBlueBright,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Choice chip widget for segmented selections
  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: ValueKey('chip_$label'),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.electricBlue.withOpacity(0.18)
              : AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.electricBlueBright
                : AppColors.glassBorderSubtle,
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.25),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
