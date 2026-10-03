import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/audio_track_info.dart';
import '../../../../models/local_video.dart';
import '../../../../models/player_types.dart';

/// Dedicated focused bottom sheet for detailed playback statistics
class FocusedStatsSheet extends StatelessWidget {
  final LocalVideo video;
  final DecoderMode decoderMode;
  final AudioTrackInfo activeAudioTrack;
  final bool isOverlayEnabled;
  final ValueChanged<bool> onOverlayToggle;

  const FocusedStatsSheet({
    super.key,
    required this.video,
    required this.decoderMode,
    required this.activeAudioTrack,
    required this.isOverlayEnabled,
    required this.onOverlayToggle,
  });

  static void show(
    BuildContext context, {
    required LocalVideo video,
    required DecoderMode decoderMode,
    required AudioTrackInfo activeAudioTrack,
    required bool isOverlayEnabled,
    required ValueChanged<bool> onOverlayToggle,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FocusedStatsSheet(
        video: video,
        decoderMode: decoderMode,
        activeAudioTrack: activeAudioTrack,
        isOverlayEnabled: isOverlayEnabled,
        onOverlayToggle: onOverlayToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.only(top: 14, bottom: 28),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(
            top: BorderSide(color: AppColors.glassBorderSubtle, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.60),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header with overlay toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: AppColors.electricBlueBright,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Playback Statistics',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Hardware & media pipeline metrics',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              const Divider(color: AppColors.glassBorderSubtle, height: 1),

              // Scrollable stats body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Section
                      const _SectionHeader(title: 'VIDEO'),
                      _MetricTile(label: 'Resolution', value: video.effectiveDimensions),
                      _MetricTile(label: 'Codec', value: '${video.codec} / H.265 Main 10'),
                      _MetricTile(label: 'Frame rate', value: '${video.fpsFormatted} FPS'),
                      _MetricTile(label: 'Bitrate', value: '${video.effectiveBitrateMbps} Mbps'),

                      const SizedBox(height: 14),

                      // Decoder Section
                      const _SectionHeader(title: 'DECODER'),
                      _MetricTile(
                        label: 'Active Decoder',
                        value: decoderMode == DecoderMode.hardware
                            ? 'Hardware'
                            : decoderMode == DecoderMode.auto
                                ? 'Auto (Hardware Preferred)'
                                : 'Software',
                        highlight: true,
                      ),
                      const _MetricTile(label: 'Decoder Type', value: 'MediaCodec (c2.qti.hevc.decoder)'),

                      const SizedBox(height: 14),

                      // Performance Section
                      const _SectionHeader(title: 'PERFORMANCE'),
                      const _MetricTile(label: 'Dropped frames', value: '0 / 48,290 (0.0%)'),
                      const _MetricTile(label: 'Render Time', value: '4.2 ms / frame'),
                      const _MetricTile(label: 'Storage I/O', value: 'Direct Local File I/O'),

                      const SizedBox(height: 14),

                      // Audio Section
                      const _SectionHeader(title: 'AUDIO'),
                      _MetricTile(label: 'Codec', value: activeAudioTrack.codec),
                      _MetricTile(label: 'Channels', value: '${activeAudioTrack.channels} Surround'),
                      _MetricTile(label: 'Bitrate', value: activeAudioTrack.technicalBitrateText),
                      const _MetricTile(label: 'Sample Rate', value: '48,000 Hz'),

                      const SizedBox(height: 16),

                      // Floating Overlay Toggle Switch Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGlass,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.glassBorderSubtle),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.picture_in_picture_rounded, size: 18, color: AppColors.electricBlueBright),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Floating Nerd Stats Overlay',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Show live stats box over video',
                                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: isOverlayEnabled,
                              activeColor: AppColors.electricBlueBright,
                              onChanged: onOverlayToggle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.electricBlueBright,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _MetricTile({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: highlight ? AppColors.electricBlueBright : Colors.white,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
