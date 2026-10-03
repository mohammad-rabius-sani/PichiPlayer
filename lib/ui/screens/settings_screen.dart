import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/app_preferences.dart';
import '../../models/player_types.dart';
import 'background_pip_settings_screen.dart';
import 'folders_screen.dart';
import 'state_system_gallery_screen.dart';
import 'subtitle_style_screen.dart';

/// The central Settings Hub screen for PIchiPlayer.
///
/// An offline-first, premium settings experience organized into clear categories:
/// Playback, Appearance, Subtitles, Library, Background & PiP, Storage & Permissions, and About.
class SettingsScreen extends StatefulWidget {
  final AppPreferences? initialPreferences;
  final ValueChanged<AppPreferences>? onPreferencesChanged;

  const SettingsScreen({
    super.key,
    this.initialPreferences,
    this.onPreferencesChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = widget.initialPreferences ?? const AppPreferences();
  }

  void _updatePreferences(AppPreferences newPrefs) {
    setState(() {
      _preferences = newPrefs;
    });
    widget.onPreferencesChanged?.call(newPrefs);
  }

  // --- Quick Toggles ---
  void _toggleResumePlayback(bool val) {
    HapticFeedback.lightImpact();
    _updatePreferences(_preferences.copyWith(resumePlayback: val));
  }

  void _toggleAutoPlayNext(bool val) {
    HapticFeedback.lightImpact();
    _updatePreferences(_preferences.copyWith(autoPlayNext: val));
  }

  void _toggleExternalSubtitles(bool val) {
    HapticFeedback.lightImpact();
    _updatePreferences(_preferences.copyWith(externalSubtitlesEnabled: val));
  }

  void _toggleAutoScanLibrary(bool val) {
    HapticFeedback.lightImpact();
    _updatePreferences(_preferences.copyWith(autoScanLibrary: val));
  }

  void _toggleShowHiddenFolders(bool val) {
    HapticFeedback.lightImpact();
    _updatePreferences(_preferences.copyWith(showHiddenFolders: val));
  }

  // --- Sub-screen & Modal Navigations ---
  void _openPlaybackSettingsSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.glassBorderSubtle),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.play_circle_outline_rounded,
                        color: AppColors.electricBlueBright, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Playback Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Fine-tune player gestures, seeking, and hardware pipeline',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.history_rounded,
                      color: AppColors.electricBlueBright),
                  title: const Text('Resume Playback',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text(
                      'Automatically remember where you stopped watching',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  value: _preferences.resumePlayback,
                  activeColor: AppColors.electricBlueBright,
                  onChanged: (val) {
                    setModalState(() {});
                    _toggleResumePlayback(val);
                  },
                ),
                const Divider(color: AppColors.glassBorderSubtle, height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.queue_play_next_rounded,
                      color: AppColors.electricBlueBright),
                  title: const Text('Auto-play Next',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text(
                      'Play the next video in folder upon completion',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  value: _preferences.autoPlayNext,
                  activeColor: AppColors.electricBlueBright,
                  onChanged: (val) {
                    setModalState(() {});
                    _toggleAutoPlayNext(val);
                  },
                ),
                const Divider(color: AppColors.glassBorderSubtle, height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.memory_rounded,
                      color: AppColors.electricBlueBright),
                  title: const Text('Hardware Decoding (HW)',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text(
                      'Use GPU hardware acceleration for smooth 4K/HEVC playback',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  value: _preferences.hardwareDecoding,
                  activeColor: AppColors.electricBlueBright,
                  onChanged: (val) {
                    setModalState(() {});
                    _updatePreferences(
                        _preferences.copyWith(hardwareDecoding: val));
                  },
                ),
                const Divider(color: AppColors.glassBorderSubtle, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.touch_app_outlined,
                      color: AppColors.electricBlueBright),
                  title: const Text('Double Tap Seek Interval',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text(
                      '${_preferences.doubleTapSeekSeconds} seconds jump per double tap',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                  trailing: Text('${_preferences.doubleTapSeekSeconds}s',
                      style: const TextStyle(
                          color: AppColors.electricBlueBright,
                          fontWeight: FontWeight.w700)),
                  onTap: () {
                    final next = _preferences.doubleTapSeekSeconds == 10
                        ? 15
                        : (_preferences.doubleTapSeekSeconds == 15 ? 30 : 10);
                    setModalState(() {});
                    _updatePreferences(
                        _preferences.copyWith(doubleTapSeekSeconds: next));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDefaultSpeedSheet() {
    HapticFeedback.selectionClick();
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Default Playback Speed',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final sp in speeds)
                    ChoiceChip(
                      label: Text('${sp == 1.0 ? '1.0' : sp}×'),
                      selected: _preferences.defaultSpeed == sp,
                      selectedColor: AppColors.electricBlue,
                      backgroundColor: AppColors.surfaceSubtle,
                      labelStyle: TextStyle(
                        color: _preferences.defaultSpeed == sp
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        Navigator.pop(ctx);
                        _updatePreferences(
                            _preferences.copyWith(defaultSpeed: sp));
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openOrientationSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Player Screen Orientation',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              for (final mode in PlayerOrientationMode.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    mode == PlayerOrientationMode.auto
                        ? Icons.screen_rotation_rounded
                        : (mode == PlayerOrientationMode.portrait
                            ? Icons.stay_current_portrait_rounded
                            : Icons.stay_current_landscape_rounded),
                    color: _preferences.defaultOrientation == mode
                        ? AppColors.electricBlueBright
                        : AppColors.textSecondary,
                  ),
                  title: Text(mode.label,
                      style: TextStyle(
                        color: _preferences.defaultOrientation == mode
                            ? AppColors.electricBlueBright
                            : Colors.white,
                        fontWeight: _preferences.defaultOrientation == mode
                            ? FontWeight.w700
                            : FontWeight.w500,
                      )),
                  trailing: _preferences.defaultOrientation == mode
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.electricBlueBright)
                      : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(ctx);
                    _updatePreferences(
                        _preferences.copyWith(defaultOrientation: mode));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAppearanceSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.glassBorderSubtle),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.palette_outlined,
                        color: AppColors.electricBlueBright, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Appearance Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Theme, layout density, and luminous accent styling',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.dark_mode_outlined,
                      color: AppColors.electricBlueBright),
                  title: const Text('Theme Mode',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Pure OLED deep black & cinematic navy',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.glassBorderSubtle),
                    ),
                    child: Text(
                      _preferences.themeMode,
                      style: const TextStyle(
                        color: AppColors.electricBlueBright,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Divider(color: AppColors.glassBorderSubtle, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.electricBlueBright),
                  title: const Text('Accent Color',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Electric blue with subtle violet hue',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.electricBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.violetAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.glassBorderSubtle, height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.blur_on_rounded,
                      color: AppColors.electricBlueBright),
                  title: const Text('Ambient Glow Effects',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Soft luminous glows on active player controls',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  value: _preferences.enableGlowEffects,
                  activeColor: AppColors.electricBlueBright,
                  onChanged: (val) {
                    setSheetState(() {});
                    _updatePreferences(
                        _preferences.copyWith(enableGlowEffects: val));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSubtitleLanguageSheet() {
    HapticFeedback.selectionClick();
    const languages = ['Auto', 'English', 'Spanish', 'Japanese', 'French', 'German'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Preferred Subtitle Language',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              for (final lang in languages)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(lang,
                      style: TextStyle(
                        color: _preferences.preferredLanguage == lang
                            ? AppColors.electricBlueBright
                            : Colors.white,
                        fontWeight: _preferences.preferredLanguage == lang
                            ? FontWeight.w700
                            : FontWeight.w500,
                      )),
                  trailing: _preferences.preferredLanguage == lang
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.electricBlueBright)
                      : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(ctx);
                    _updatePreferences(
                        _preferences.copyWith(preferredLanguage: lang));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSubtitleStyleScreen() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubtitleStyleScreen(),
      ),
    );
  }

  void _navigateToBackgroundPipScreen() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BackgroundPipSettingsScreen(
          initialConfig: BackgroundPipConfig(
            backgroundPlaybackEnabled: _preferences.backgroundPlayback,
            pipEnabled: _preferences.pictureInPicture,
            autoEnterPip: _preferences.autoEnterPip,
            leavingAppBehavior: _preferences.leavingAppBehavior,
            showLockScreenControls: _preferences.showMediaControls,
            showMediaNotification: _preferences.showMediaNotification,
          ),
          onConfigChanged: (cfg) {
            _updatePreferences(_preferences.copyWith(
              backgroundPlayback: cfg.backgroundPlaybackEnabled,
              pictureInPicture: cfg.pipEnabled,
              autoEnterPip: cfg.autoEnterPip,
              leavingAppBehavior: cfg.leavingAppBehavior,
              showMediaControls: cfg.showLockScreenControls,
              showMediaNotification: cfg.showMediaNotification,
            ));
          },
        ),
      ),
    );
  }

  void _navigateToFoldersScreen() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FoldersScreen(),
      ),
    );
  }

  void _clearThumbnailCache() {
    HapticFeedback.mediumImpact();
    final formattedSize = _preferences.formattedThumbnailCacheSize;

    _updatePreferences(_preferences.copyWith(thumbnailCacheSizeBytes: 0));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.delete_sweep_rounded,
                color: AppColors.electricBlueBright, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cleared $formattedSize thumbnail cache',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearPlaybackHistory() {
    HapticFeedback.mediumImpact();
    _updatePreferences(_preferences.copyWith(playbackHistoryCount: 0));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.history_toggle_off_rounded,
                color: AppColors.electricBlueBright, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cleared playback history and resume positions',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetSettingsConfirmation() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.red.withOpacity(0.35)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.restart_alt_rounded,
                      color: Color(0xFFEF4444), size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Reset player settings?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'This will restore playback, appearance and interaction settings to their defaults.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              // Safety Reassurance
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.success, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your videos and library will not be deleted.',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('cancel_reset_button'),
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.glassBorder),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      key: const ValueKey('confirm_reset_button'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _performResetSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performResetSettings() {
    HapticFeedback.heavyImpact();
    _updatePreferences(AppPreferences.defaults());

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.restart_alt_rounded,
                color: AppColors.electricBlueBright, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Player settings restored to defaults',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOfflinePrivacyDialog() {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.security_rounded,
                color: AppColors.electricBlueBright, size: 20),
            SizedBox(width: 8),
            Text('100% Offline Privacy',
                style: TextStyle(color: Colors.white, fontSize: 17)),
          ],
        ),
        content: const Text(
          'PIchiPlayer runs entirely on your local device. We do not track, collect, or transmit any video metadata, viewing history, or telemetry to external servers. No account required.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood',
                style: TextStyle(color: AppColors.electricBlueBright)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.play_circle_fill_rounded,
                color: AppColors.electricBlueBright, size: 22),
            SizedBox(width: 8),
            Text('PIchiPlayer',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0 (Build 100)',
                style: TextStyle(
                    color: AppColors.electricBlueBright,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            SizedBox(height: 8),
            Text(
              'A local-first, cinematic Android video player engineered for high-fidelity offline playback without cloud services or accounts.',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(color: AppColors.electricBlueBright)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top App Bar
            _buildTopAppBar(),

            // 2. Settings Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
                children: [
                  // --- Category 1: PLAYBACK ---
                  _buildCategoryCard(
                    icon: Icons.play_circle_outline_rounded,
                    title: 'Playback',
                    description: 'Playback, gestures & player behavior',
                    onTap: _openPlaybackSettingsSheet,
                    children: [
                      _buildSwitchRow(
                        key: const ValueKey('resume_playback_row'),
                        title: 'Resume playback',
                        value: _preferences.resumePlayback,
                        onChanged: _toggleResumePlayback,
                      ),
                      _buildSwitchRow(
                        key: const ValueKey('autoplay_next_row'),
                        title: 'Auto-play next',
                        value: _preferences.autoPlayNext,
                        onChanged: _toggleAutoPlayNext,
                      ),
                      _buildNavigationRow(
                        key: const ValueKey('default_speed_row'),
                        title: 'Default speed',
                        value: _preferences.formattedSpeed,
                        onTap: _openDefaultSpeedSheet,
                      ),
                      _buildNavigationRow(
                        key: const ValueKey('orientation_row'),
                        title: 'Orientation',
                        value: _preferences.defaultOrientation.label,
                        onTap: _openOrientationSheet,
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Category 2: APPEARANCE ---
                  _buildCategoryCard(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    description: 'Theme, layout & visual style',
                    onTap: _openAppearanceSheet,
                    children: [
                      _buildNavigationRow(
                        key: const ValueKey('theme_mode_row'),
                        title: 'Theme',
                        value: _preferences.themeMode,
                        onTap: _openAppearanceSheet,
                      ),
                      _buildNavigationRow(
                        key: const ValueKey('accent_color_row'),
                        title: 'Accent',
                        value: _preferences.accentColorName,
                        onTap: _openAppearanceSheet,
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Category 3: SUBTITLES ---
                  _buildCategoryCard(
                    icon: Icons.subtitles_outlined,
                    title: 'Subtitles',
                    description: 'Language, style & subtitle behavior',
                    onTap: _navigateToSubtitleStyleScreen,
                    children: [
                      _buildNavigationRow(
                        key: const ValueKey('preferred_language_row'),
                        title: 'Preferred language',
                        value: _preferences.preferredLanguage,
                        onTap: _openSubtitleLanguageSheet,
                      ),
                      _buildNavigationRow(
                        key: const ValueKey('subtitle_style_row'),
                        title: 'Subtitle style',
                        value: _preferences.subtitleStyleName,
                        onTap: _navigateToSubtitleStyleScreen,
                      ),
                      _buildSwitchRow(
                        key: const ValueKey('external_subtitles_row'),
                        title: 'External subtitles',
                        value: _preferences.externalSubtitlesEnabled,
                        onChanged: _toggleExternalSubtitles,
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Category 4: LIBRARY ---
                  _buildCategoryCard(
                    icon: Icons.video_library_outlined,
                    title: 'Library',
                    description: 'Scanning, indexing & video discovery',
                    onTap: _navigateToFoldersScreen,
                    children: [
                      _buildSwitchRow(
                        key: const ValueKey('auto_scan_library_row'),
                        title: 'Automatic library updates',
                        value: _preferences.autoScanLibrary,
                        onChanged: _toggleAutoScanLibrary,
                      ),
                      _buildSwitchRow(
                        key: const ValueKey('hidden_folders_row'),
                        title: 'Hidden folders',
                        value: _preferences.showHiddenFolders,
                        onChanged: _toggleShowHiddenFolders,
                      ),
                      _buildNavigationRow(
                        key: const ValueKey('scan_folders_row'),
                        title: 'Scan folders',
                        value: '${_preferences.scannedFolderCount} locations',
                        onTap: _navigateToFoldersScreen,
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Category 5: BACKGROUND & PIP ---
                  _buildCategoryCard(
                    icon: Icons.picture_in_picture_alt_rounded,
                    title: 'Background & PiP',
                    description: 'Playback outside the main player',
                    onTap: _navigateToBackgroundPipScreen,
                    children: [
                      _buildNavigationRow(
                        key: const ValueKey('bg_playback_summary_row'),
                        title: 'Background playback',
                        value: _preferences.backgroundPlayback ? 'ON' : 'OFF',
                        onTap: _navigateToBackgroundPipScreen,
                      ),
                      _buildNavigationRow(
                        key: const ValueKey('pip_summary_row'),
                        title: 'Picture-in-Picture',
                        value: _preferences.pictureInPicture ? 'ON' : 'OFF',
                        onTap: _navigateToBackgroundPipScreen,
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Category 6: STORAGE & PERMISSIONS ---
                  _buildStoragePermissionsCard(),
                  const SizedBox(height: 16),

                  // --- Local Data & Privacy Reassurance Notice ---
                  _buildPrivacyNotice(),
                  const SizedBox(height: 20),

                  // --- Reset Player Settings ---
                  _buildResetSettingsButton(),
                  const SizedBox(height: 24),

                  // --- About Section ---
                  _buildAboutSection(),
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
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Customize your PIchiPlayer experience',
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

  // --- Category Card Builder ---
  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          // Header Row
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.electricBlueBright.withOpacity(0.25),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(icon,
                        color: AppColors.electricBlueBright, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: AppColors.glassBorderSubtle, height: 1),
          // Embedded Compact Summary Rows
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required Key key,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Semantics(
                label: '$title, ${value ? "On" : "Off"}',
                toggled: value,
                child: Switch.adaptive(
                  key: key,
                  value: value,
                  activeColor: AppColors.electricBlueBright,
                  activeTrackColor: AppColors.electricBlue.withOpacity(0.40),
                  inactiveThumbColor: AppColors.textMuted,
                  inactiveTrackColor: AppColors.surfaceSubtle,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            color: AppColors.glassBorderSubtle,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildNavigationRow({
    required Key key,
    required String title,
    required String value,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          key: key,
          onTap: onTap,
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(16))
              : BorderRadius.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.electricBlueBright,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            color: AppColors.glassBorderSubtle,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  // --- Storage & Permissions Card ---
  Widget _buildStoragePermissionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.electricBlueBright.withOpacity(0.25),
                      width: 1.0,
                    ),
                  ),
                  child: const Icon(Icons.folder_shared_outlined,
                      color: AppColors.electricBlueBright, size: 20),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Storage & Permissions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Manage local media access',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.glassBorderSubtle, height: 1),

          // Storage Status Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STORAGE ACCESS',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    if (_preferences.hasInternalStoragePermission)
                      _buildStorageStatusChip('Internal storage', true),
                    if (_preferences.sdCardDetected &&
                        _preferences.hasSdCardPermission)
                      _buildStorageStatusChip('SD card', true),
                    if (_preferences.foldersNeedingAccessCount > 0)
                      _buildStorageStatusChip(
                          '${_preferences.foldersNeedingAccessCount} folder needs access',
                          false),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.glassBorderSubtle, height: 1),

          // Cache & History Actions
          InkWell(
            key: const ValueKey('clear_thumbnail_cache_tile'),
            onTap: _clearThumbnailCache,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.cleaning_services_rounded,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clear thumbnail cache',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Removes cached previews; regenerates on demand',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _preferences.formattedThumbnailCacheSize,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            color: AppColors.glassBorderSubtle,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          InkWell(
            key: const ValueKey('clear_playback_history_tile'),
            onTap: _clearPlaybackHistory,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.history_toggle_off_rounded,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clear playback history',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Resets resume positions & recently played history',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_preferences.playbackHistoryCount} items',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageStatusChip(String label, bool isOk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOk
            ? AppColors.success.withOpacity(0.12)
            : Colors.amber.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOk
              ? AppColors.success.withOpacity(0.40)
              : Colors.amber.withOpacity(0.45),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOk ? Icons.check_rounded : Icons.warning_amber_rounded,
            color: isOk ? AppColors.success : Colors.amber,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isOk ? AppColors.success : Colors.amber,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- Local Data & Privacy Notice ---
  Widget _buildPrivacyNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppColors.electricBlueBright,
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your videos stay on your device.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Videos, playback history, preferences and thumbnail cache are stored locally. 100% offline, zero internet telemetry.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
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

  // --- Reset Player Settings Button ---
  Widget _buildResetSettingsButton() {
    return InkWell(
      key: const ValueKey('reset_player_settings_button'),
      onTap: _showResetSettingsConfirmation,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.withOpacity(0.28)),
        ),
        child: const Row(
          children: [
            Icon(Icons.restart_alt_rounded,
                color: Color(0xFFEF4444), size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset player settings',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Restore playback and appearance defaults without deleting media',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Color(0xFFEF4444), size: 18),
          ],
        ),
      ),
    );
  }

  // --- About Section ---
  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.play_circle_fill_rounded,
            color: AppColors.electricBlueBright,
            size: 36,
          ),
          const SizedBox(height: 8),
          const Text(
            'PIchiPlayer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Version 1.0.0 (Build 100)',
            style: TextStyle(
              color: AppColors.electricBlueBright,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'A local-first video player for Android.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.glassBorderSubtle, height: 1),
          const SizedBox(height: 8),
          // Links Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                key: const ValueKey('about_privacy_button'),
                onPressed: _showOfflinePrivacyDialog,
                child: const Text('Privacy',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ),
              Container(width: 1, height: 12, color: AppColors.glassBorder),
              TextButton(
                key: const ValueKey('about_licenses_button'),
                onPressed: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'PIchiPlayer',
                    applicationVersion: '1.0.0 (Build 100)',
                  );
                },
                child: const Text('Licenses',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ),
              Container(width: 1, height: 12, color: AppColors.glassBorder),
              TextButton(
                key: const ValueKey('about_info_button'),
                onPressed: _showAboutDialog,
                child: const Text('About',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            key: const ValueKey('about_ui_states_button'),
            icon: const Icon(Icons.widgets_outlined,
                size: 14, color: AppColors.electricBlueBright),
            label: const Text(
              'UI States System',
              style: TextStyle(
                color: AppColors.electricBlueBright,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const StateSystemGalleryScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
