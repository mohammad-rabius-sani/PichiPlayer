import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/local_video.dart';

/// Overflow options bottom sheet for the Video Details screen
class VideoDetailsMenuSheet extends StatelessWidget {
  final LocalVideo video;
  final VoidCallback onAddToPlaylist;
  final VoidCallback onOpenFolder;
  final VoidCallback onRename;
  final VoidCallback onShare;
  final VoidCallback onShowFileInfo;
  final VoidCallback onDelete;

  const VideoDetailsMenuSheet({
    super.key,
    required this.video,
    required this.onAddToPlaylist,
    required this.onOpenFolder,
    required this.onRename,
    required this.onShare,
    required this.onShowFileInfo,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required LocalVideo video,
    required VoidCallback onAddToPlaylist,
    required VoidCallback onOpenFolder,
    required VoidCallback onRename,
    required VoidCallback onShare,
    required VoidCallback onShowFileInfo,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => VideoDetailsMenuSheet(
        video: video,
        onAddToPlaylist: onAddToPlaylist,
        onOpenFolder: onOpenFolder,
        onRename: onRename,
        onShare: onShare,
        onShowFileInfo: onShowFileInfo,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.only(bottom: 24, top: 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(
            top: BorderSide(color: AppColors.glassBorderSubtle, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.40),
              blurRadius: 20,
              offset: const Offset(0, -4),
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
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Video Title Header in Sheet
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [video.gradientStart, video.gradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Icon(
                          video.visualIcon,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.displayFileName,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            video.listMetadataText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Divider(color: AppColors.glassBorderSubtle, height: 1),
              const SizedBox(height: 6),

              // 3. Menu Options
              _MenuActionTile(
                icon: Icons.playlist_add_rounded,
                title: 'Add to Playlist',
                onTap: () {
                  Navigator.pop(context);
                  onAddToPlaylist();
                },
              ),
              _MenuActionTile(
                icon: Icons.folder_open_rounded,
                title: 'Open Folder',
                onTap: () {
                  Navigator.pop(context);
                  onOpenFolder();
                },
              ),
              _MenuActionTile(
                icon: Icons.drive_file_rename_outline_rounded,
                title: 'Rename',
                onTap: () {
                  Navigator.pop(context);
                  onRename();
                },
              ),
              _MenuActionTile(
                icon: Icons.share_rounded,
                title: 'Share',
                onTap: () {
                  Navigator.pop(context);
                  onShare();
                },
              ),
              _MenuActionTile(
                icon: Icons.info_outline_rounded,
                title: 'Show File Information',
                onTap: () {
                  Navigator.pop(context);
                  onShowFileInfo();
                },
              ),

              const Divider(color: AppColors.glassBorderSubtle, height: 1),
              const SizedBox(height: 4),

              // Destructive Delete Action with confirmation requirement
              _MenuActionTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete',
                iconColor: const Color(0xFFEF4444),
                textColor: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _MenuActionTile({
    required this.icon,
    required this.title,
    this.iconColor,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
      dense: true,
      leading: Icon(
        icon,
        size: 20,
        color: iconColor ?? AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
