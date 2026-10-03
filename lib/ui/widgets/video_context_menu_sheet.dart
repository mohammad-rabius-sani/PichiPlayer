import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/local_video.dart';

/// Modal bottom sheet for video contextual actions (invoked on long press)
class VideoContextMenuSheet extends StatelessWidget {
  final LocalVideo video;
  final VoidCallback onPlay;
  final VoidCallback? onDetails;
  final VoidCallback? onDelete;

  const VideoContextMenuSheet({
    super.key,
    required this.video,
    required this.onPlay,
    this.onDetails,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required LocalVideo video,
    required VoidCallback onPlay,
    VoidCallback? onDetails,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => VideoContextMenuSheet(
        video: video,
        onPlay: onPlay,
        onDetails: onDetails,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.glassBorderSubtle,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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

            const SizedBox(height: 18),

            // Video Preview Header
            Row(
              children: [
                Container(
                  width: 52,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [video.gradientStart, video.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      size: 20,
                      color: AppColors.electricBlueBright,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: AppTypography.videoCardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${video.durationFormatted} • ${video.resolution} • ${video.fileSizeFormatted}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: AppColors.glassBorderSubtle, height: 1),
            const SizedBox(height: 8),

            // Action: Play
            _buildActionTile(
              icon: Icons.play_arrow_rounded,
              title: video.isPartiallyWatched ? 'Resume Video' : 'Play Video',
              subtitle: video.isPartiallyWatched ? 'From ${video.progressText}' : null,
              iconColor: AppColors.electricBlueBright,
              onTap: () {
                Navigator.pop(context);
                onPlay();
              },
            ),

            // Action: File Details
            _buildActionTile(
              icon: Icons.info_outline_rounded,
              title: 'Video Details',
              subtitle: video.folderPath,
              onTap: () {
                Navigator.pop(context);
                onDetails?.call();
              },
            ),

            // Action: Delete from Device
            _buildActionTile(
              icon: Icons.delete_outline_rounded,
              title: 'Delete from Device',
              titleColor: const Color(0xFFEF4444),
              iconColor: const Color(0xFFEF4444),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(icon, size: 20, color: iconColor ?? AppColors.textPrimary),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: onTap,
    );
  }
}
