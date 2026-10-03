import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/local_video.dart';

/// Polished bottom sheet for individual video overflow / context actions
class LibraryContextMenuSheet extends StatelessWidget {
  final LocalVideo video;
  final VoidCallback onPlay;
  final VoidCallback? onResume;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToPlaylist;
  final VoidCallback onVideoInfo;
  final VoidCallback onOpenFolder;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;

  const LibraryContextMenuSheet({
    super.key,
    required this.video,
    required this.onPlay,
    this.onResume,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
    required this.onVideoInfo,
    required this.onOpenFolder,
    required this.onRename,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required LocalVideo video,
    required VoidCallback onPlay,
    VoidCallback? onResume,
    required VoidCallback onToggleFavorite,
    required VoidCallback onAddToPlaylist,
    required VoidCallback onVideoInfo,
    required VoidCallback onOpenFolder,
    required ValueChanged<String> onRename,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LibraryContextMenuSheet(
        video: video,
        onPlay: onPlay,
        onResume: onResume,
        onToggleFavorite: onToggleFavorite,
        onAddToPlaylist: onAddToPlaylist,
        onVideoInfo: onVideoInfo,
        onOpenFolder: onOpenFolder,
        onRename: onRename,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
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

              // Header: Thumbnail + Title + Metadata
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [video.gradientStart, video.gradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        video.visualIcon,
                        size: 22,
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
                          video.displayFileName,
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

              const SizedBox(height: 14),
              const Divider(color: AppColors.glassBorderSubtle, height: 1),
              const SizedBox(height: 4),

              // Action: Resume (if partially watched)
              if (video.isPartiallyWatched)
                _buildActionTile(
                  icon: Icons.replay_rounded,
                  title: 'Resume Playback',
                  subtitle: 'Continue from ${video.progressText}',
                  iconColor: AppColors.electricBlueBright,
                  onTap: () {
                    Navigator.pop(context);
                    onResume?.call();
                  },
                ),

              // Action: Play from Start
              _buildActionTile(
                icon: Icons.play_arrow_rounded,
                title: video.isPartiallyWatched ? 'Play from Beginning' : 'Play',
                iconColor: AppColors.electricBlueBright,
                onTap: () {
                  Navigator.pop(context);
                  onPlay();
                },
              ),

              // Action: Add / Remove Favorite
              _buildActionTile(
                icon: video.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                title: video.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                iconColor: video.isFavorite ? const Color(0xFFF43F5E) : AppColors.textSecondary,
                onTap: () {
                  Navigator.pop(context);
                  onToggleFavorite();
                },
              ),

              // Action: Add to Playlist
              _buildActionTile(
                icon: Icons.playlist_add_rounded,
                title: 'Add to Playlist',
                onTap: () {
                  Navigator.pop(context);
                  onAddToPlaylist();
                },
              ),

              // Action: Video Information
              _buildActionTile(
                icon: Icons.info_outline_rounded,
                title: 'Video Information',
                onTap: () {
                  Navigator.pop(context);
                  onVideoInfo();
                },
              ),

              // Action: Open Folder
              _buildActionTile(
                icon: Icons.folder_open_rounded,
                title: 'Open Folder',
                subtitle: video.folderPath,
                onTap: () {
                  Navigator.pop(context);
                  onOpenFolder();
                },
              ),

              // Action: Rename
              _buildActionTile(
                icon: Icons.drive_file_rename_outline_rounded,
                title: 'Rename',
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(context);
                },
              ),

              // Action: Delete (with confirmation)
              _buildActionTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete',
                titleColor: const Color(0xFFEF4444),
                iconColor: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmDialog(context);
                },
              ),

              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: video.title);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        title: const Text(
          'Rename Video',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter new video name',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.electricBlue.withOpacity(0.5)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.electricBlueBright),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(ctx);
                onRename(newName);
              }
            },
            child: const Text('Rename', style: TextStyle(color: AppColors.electricBlueBright)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
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
            Text('Delete File?', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${video.displayFileName}" from your device storage? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ),
        ],
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
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Icon(icon, size: 19, color: iconColor ?? AppColors.textPrimary),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: onTap,
    );
  }
}
