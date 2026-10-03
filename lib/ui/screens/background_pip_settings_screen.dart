import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/local_video.dart';
import '../../models/player_types.dart';

/// Premium Android settings screen for Background Playback & Picture-in-Picture (PiP)
/// in PIchiPlayer.
///
/// Fully offline, local playback session controls adhering to the dark cinematic
/// PIchiPlayer visual system.
class BackgroundPipSettingsScreen extends StatefulWidget {
  final BackgroundPipConfig? initialConfig;
  final ValueChanged<BackgroundPipConfig>? onConfigChanged;
  final bool isPipSupported;
  final LocalVideo? activeVideo;
  final Duration? activePosition;
  final VoidCallback? onReturnToPlayer;

  const BackgroundPipSettingsScreen({
    super.key,
    this.initialConfig,
    this.onConfigChanged,
    this.isPipSupported = true,
    this.activeVideo,
    this.activePosition,
    this.onReturnToPlayer,
  });

  @override
  State<BackgroundPipSettingsScreen> createState() =>
      _BackgroundPipSettingsScreenState();
}

class _BackgroundPipSettingsScreenState
    extends State<BackgroundPipSettingsScreen> {
  late BackgroundPipConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig ?? const BackgroundPipConfig();
  }

  void _updateConfig(BackgroundPipConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
    widget.onConfigChanged?.call(newConfig);
  }

  void _toggleBackgroundPlayback(bool value) {
    HapticFeedback.lightImpact();
    _updateConfig(_config.copyWith(backgroundPlaybackEnabled: value));
  }

  void _togglePip(bool value) {
    HapticFeedback.lightImpact();
    _updateConfig(_config.copyWith(pipEnabled: value));
  }

  void _toggleAutoEnterPip(bool value) {
    HapticFeedback.lightImpact();
    _updateConfig(_config.copyWith(autoEnterPip: value));
  }

  void _selectLeavingBehavior(LeavingAppBehavior behavior) {
    HapticFeedback.selectionClick();
    _updateConfig(_config.copyWith(leavingAppBehavior: behavior));
  }

  void _toggleLockScreenControls(bool value) {
    HapticFeedback.lightImpact();
    _updateConfig(_config.copyWith(showLockScreenControls: value));
  }

  void _toggleMediaNotification(bool value) {
    HapticFeedback.lightImpact();
    _updateConfig(_config.copyWith(showMediaNotification: value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),

            // Main Settings Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
                children: [
                  // 1. Re-entry state (Now Playing banner when session active)
                  if (widget.activeVideo != null) ...[
                    _buildNowPlayingBanner(),
                    const SizedBox(height: 18),
                  ],

                  // 2. Background Playback Section
                  _buildSectionHeader(
                    icon: Icons.headphones_rounded,
                    title: 'BACKGROUND PLAYBACK',
                  ),
                  const SizedBox(height: 8),
                  _buildBackgroundPlaybackCard(),
                  const SizedBox(height: 24),

                  // 3. Picture-in-Picture Section
                  _buildSectionHeader(
                    icon: Icons.picture_in_picture_alt_rounded,
                    title: 'PICTURE-IN-PICTURE',
                  ),
                  const SizedBox(height: 8),
                  if (!widget.isPipSupported)
                    _buildPipUnsupportedCard()
                  else ...[
                    _buildPipCard(),
                    const SizedBox(height: 14),
                    _buildPipVisualPreview(),
                    const SizedBox(height: 14),
                    _buildLeavingAppBehaviorSection(),
                    const SizedBox(height: 14),
                    _buildAutoEnterPipCard(),
                  ],
                  const SizedBox(height: 24),

                  // 4. Lock Screen & Notification Section
                  _buildSectionHeader(
                    icon: Icons.lock_outline_rounded,
                    title: 'LOCK SCREEN',
                  ),
                  const SizedBox(height: 8),
                  _buildLockScreenCard(),
                  const SizedBox(height: 14),
                  _buildMediaSessionMetadataCard(),
                  const SizedBox(height: 24),

                  // 5. Single Playback Session Architecture
                  _buildSessionArchitectureCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Background & PiP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Keep watching when you leave PIchiPlayer',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Section Header ---
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.electricBlueBright, size: 14),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.electricBlueBright,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // --- Re-entry Now Playing Banner ---
  Widget _buildNowPlayingBanner() {
    final video = widget.activeVideo!;
    final pos = widget.activePosition ?? const Duration(hours: 1, minutes: 12, seconds: 16);

    String formatTime(Duration d) {
      final hours = d.inHours;
      final minutes = d.inMinutes.remainder(60);
      final seconds = d.inSeconds.remainder(60);
      if (hours > 0) {
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.electricBlueBright.withOpacity(0.40),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricBlue.withOpacity(0.18),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.electricBlueBright,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Now playing',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  video.displayFileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formatTime(pos),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            key: const ValueKey('return_to_player_button'),
            onPressed: () {
              HapticFeedback.lightImpact();
              if (widget.onReturnToPlayer != null) {
                widget.onReturnToPlayer!();
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.fullscreen_rounded, size: 16),
            label: const Text('Return to Player'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Background Playback Card ---
  Widget _buildBackgroundPlaybackCard() {
    final isEnabled = _config.backgroundPlaybackEnabled;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Background playback',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Continue playback when PIchiPlayer is not in the foreground.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  label:
                      'Background playback, ${isEnabled ? "On" : "Off"}',
                  toggled: isEnabled,
                  child: Switch.adaptive(
                    key: const ValueKey('background_playback_switch'),
                    value: isEnabled,
                    activeColor: AppColors.electricBlueBright,
                    activeTrackColor: AppColors.electricBlue.withOpacity(0.40),
                    inactiveThumbColor: AppColors.textMuted,
                    inactiveTrackColor: AppColors.surfaceSubtle,
                    onChanged: _toggleBackgroundPlayback,
                  ),
                ),
              ],
            ),
          ),
          if (!isEnabled) ...[
            const Divider(color: AppColors.glassBorderSubtle, height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Playback stops when PIchiPlayer leaves the foreground.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Subtle battery guidance
          const Divider(color: AppColors.glassBorderSubtle, height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: const Row(
              children: [
                Icon(
                  Icons.battery_saver_rounded,
                  color: AppColors.textMuted,
                  size: 15,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Background playback may use additional battery.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- PiP Unsupported Capability Card ---
  Widget _buildPipUnsupportedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.35)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Picture-in-Picture unavailable',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "This device or Android configuration doesn't currently support the required PiP behavior.",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Picture-in-Picture Card ---
  Widget _buildPipCard() {
    final isEnabled = _config.pipEnabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Picture-in-Picture',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep the video visible in a floating window while using other apps.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: 'Picture-in-Picture, ${isEnabled ? "On" : "Off"}',
            toggled: isEnabled,
            child: Switch.adaptive(
              key: const ValueKey('pip_switch'),
              value: isEnabled,
              activeColor: AppColors.electricBlueBright,
              activeTrackColor: AppColors.electricBlue.withOpacity(0.40),
              inactiveThumbColor: AppColors.textMuted,
              inactiveTrackColor: AppColors.surfaceSubtle,
              onChanged: _togglePip,
            ),
          ),
        ],
      ),
    );
  }

  // --- Tasteful PiP Visual Preview ---
  Widget _buildPipVisualPreview() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF0C101A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background "Other app" stylized mock surface (Notes / Documents app)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mock header bar of other app
                    Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.article_outlined,
                            size: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 80,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Mock paragraphs/cards
                    Container(
                      width: 140,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 110,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 160,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: 90,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating PIchiPlayer PiP Window in top-right
            Positioned(
              right: 14,
              top: 14,
              child: Container(
                width: 148,
                height: 86,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E3A8A),
                      Color(0xFF0369A1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.electricBlueBright.withOpacity(0.75),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.40),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Subtle video play indicator & PiP badge
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.picture_in_picture_alt_rounded,
                              size: 10,
                              color: AppColors.electricBlueBright,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'PiP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white70,
                        size: 26,
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '01:12:16',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom informational pill
            const Positioned(
              bottom: 8,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Preview: Video floats over other apps when leaving PIchiPlayer',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- When Leaving PIchiPlayer (Leaving-App Behavior) ---
  Widget _buildLeavingAppBehaviorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHEN LEAVING PICHIPLAYER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose default behavior when switching to other apps:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 12),
          for (final option in LeavingAppBehavior.values)
            _buildLeavingOptionCard(option),
        ],
      ),
    );
  }

  Widget _buildLeavingOptionCard(LeavingAppBehavior option) {
    final isSelected = _config.leavingAppBehavior == option;
    final isRecommended = option == LeavingAppBehavior.openPip;

    IconData getIcon() {
      switch (option) {
        case LeavingAppBehavior.continuePlaying:
          return Icons.play_circle_outline_rounded;
        case LeavingAppBehavior.openPip:
          return Icons.picture_in_picture_alt_rounded;
        case LeavingAppBehavior.audioOnly:
          return Icons.headphones_rounded;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        key: ValueKey('leaving_behavior_${option.name}'),
        onTap: () => _selectLeavingBehavior(option),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.electricBlue.withOpacity(0.12)
                : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.electricBlueBright
                  : AppColors.glassBorderSubtle,
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected
                    ? AppColors.electricBlueBright
                    : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Icon(
                getIcon(),
                color: isSelected
                    ? AppColors.electricBlueBright
                    : AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          option.label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.electricBlue.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.electricBlueBright.withOpacity(0.40),
                                width: 0.8,
                              ),
                            ),
                            child: const Text(
                              'RECOMMENDED',
                              style: TextStyle(
                                color: AppColors.electricBlueBright,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Auto-Enter PiP Card ---
  Widget _buildAutoEnterPipCard() {
    final isEnabled = _config.autoEnterPip;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automatically enter Picture-in-Picture',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Enter PiP automatically when you leave the player.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label:
                'Automatically enter Picture-in-Picture, ${isEnabled ? "On" : "Off"}',
            toggled: isEnabled,
            child: Switch.adaptive(
              key: const ValueKey('auto_enter_pip_switch'),
              value: isEnabled,
              activeColor: AppColors.electricBlueBright,
              activeTrackColor: AppColors.electricBlue.withOpacity(0.40),
              inactiveThumbColor: AppColors.textMuted,
              inactiveTrackColor: AppColors.surfaceSubtle,
              onChanged: _toggleAutoEnterPip,
            ),
          ),
        ],
      ),
    );
  }

  // --- Lock Screen Card ---
  Widget _buildLockScreenCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          // Show media controls toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Show media controls',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Control playback from the lock screen and notification panel.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Exposed actions badges
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildMiniBadge('Play / Pause'),
                          _buildMiniBadge('Seek ±10s'),
                          _buildMiniBadge('Previous / Next'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  label:
                      'Show media controls, ${_config.showLockScreenControls ? "On" : "Off"}',
                  toggled: _config.showLockScreenControls,
                  child: Switch.adaptive(
                    key: const ValueKey('lock_screen_controls_switch'),
                    value: _config.showLockScreenControls,
                    activeColor: AppColors.electricBlueBright,
                    activeTrackColor: AppColors.electricBlue.withOpacity(0.40),
                    inactiveThumbColor: AppColors.textMuted,
                    inactiveTrackColor: AppColors.surfaceSubtle,
                    onChanged: _toggleLockScreenControls,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.glassBorderSubtle, height: 1),
          // Media notification toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media notification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Show playback controls in the notification panel while playing.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  label:
                      'Media notification, ${_config.showMediaNotification ? "On" : "Off"}',
                  toggled: _config.showMediaNotification,
                  child: Switch.adaptive(
                    key: const ValueKey('media_notification_switch'),
                    value: _config.showMediaNotification,
                    activeColor: AppColors.electricBlueBright,
                    activeTrackColor: AppColors.electricBlue.withOpacity(0.40),
                    inactiveThumbColor: AppColors.textMuted,
                    inactiveTrackColor: AppColors.surfaceSubtle,
                    onChanged: _toggleMediaNotification,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // --- Active Media Session Metadata Card ---
  Widget _buildMediaSessionMetadataCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1524),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.music_note_rounded,
                color: AppColors.electricBlueBright,
                size: 15,
              ),
              const SizedBox(width: 6),
              const Text(
                'MEDIA SESSION METADATA',
                style: TextStyle(
                  color: AppColors.electricBlueBright,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Android MediaSession',
                  style: TextStyle(
                    color: AppColors.electricBlueBright,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Clean title and metadata representation
          const Text(
            'Interstellar.2014.2160p.mkv',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          const Text(
            'PIchiPlayer',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          // Timecode
          const Text(
            '01:12:16 / 02:49:22',
            style: TextStyle(
              color: AppColors.electricBlueBright,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          // Mini progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.426,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.electricBlueBright,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Simulated media session buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimulatedMediaAction(Icons.replay_10_rounded, 'Replay 10s'),
              _buildSimulatedMediaAction(Icons.skip_previous_rounded, 'Previous'),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.electricBlueBright.withOpacity(0.60),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              _buildSimulatedMediaAction(Icons.skip_next_rounded, 'Next'),
              _buildSimulatedMediaAction(Icons.forward_10_rounded, 'Forward 10s'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedMediaAction(IconData icon, String tooltip) {
    return Icon(
      icon,
      color: Colors.white70,
      size: 20,
    );
  }

  // --- Session Architecture Information Card ---
  Widget _buildSessionArchitectureCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.sync_rounded,
            color: AppColors.electricBlueBright,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Single Playback Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Fullscreen, Picture-in-Picture, Background playback, and Lock screen controls all share one unified local playback session. No reloading, position loss, or duplicate audio.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
