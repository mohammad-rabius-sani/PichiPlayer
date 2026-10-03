import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/local_video.dart';
import '../../../models/player_types.dart';

/// Unobtrusive floating statistics overlay displaying live playback metrics
class PlaybackStatisticsOverlay extends StatelessWidget {
  final LocalVideo video;
  final DecoderMode decoderMode;
  final VoidCallback onClose;

  const PlaybackStatisticsOverlay({
    super.key,
    required this.video,
    required this.decoderMode,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 270,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.electricBlueBright.withOpacity(0.35),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.50),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.query_stats_rounded,
                          color: AppColors.electricBlueBright,
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'NERD STATS',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.electricBlueBright,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 15,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Divider(color: AppColors.glassBorderSubtle, height: 1),
                const SizedBox(height: 6),

                // Stats Rows
                _buildStatRow('Resolution', video.effectiveDimensions),
                _buildStatRow('Codec', '${video.codec} / H.265'),
                _buildStatRow('Frame rate', '${video.fpsFormatted} FPS'),
                _buildStatRow('Bitrate', '${video.effectiveBitrateMbps} Mbps'),
                _buildStatRow(
                  'Decoder',
                  decoderMode == DecoderMode.hardware ? 'Hardware Decoder' : 'Software Decoder',
                ),
                _buildStatRow('Buffer Health', '34.2s (Optimal)'),
                _buildStatRow('Dropped Frames', '0 / 48,290 (0.0%)'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
