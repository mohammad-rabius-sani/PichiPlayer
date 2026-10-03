import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Premium bottom sheet for Folder management and scanning options
class FolderManagementSheet extends StatelessWidget {
  final bool showHiddenFolders;
  final ValueChanged<bool> onToggleHiddenFolders;
  final VoidCallback onScanNewVideos;
  final VoidCallback onRescanAll;
  final VoidCallback onManageFolders;
  final VoidCallback onStoragePermissions;

  const FolderManagementSheet({
    super.key,
    required this.showHiddenFolders,
    required this.onToggleHiddenFolders,
    required this.onScanNewVideos,
    required this.onRescanAll,
    required this.onManageFolders,
    required this.onStoragePermissions,
  });

  static Future<void> show(
    BuildContext context, {
    required bool showHiddenFolders,
    required ValueChanged<bool> onToggleHiddenFolders,
    required VoidCallback onScanNewVideos,
    required VoidCallback onRescanAll,
    required VoidCallback onManageFolders,
    required VoidCallback onStoragePermissions,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FolderManagementSheet(
        showHiddenFolders: showHiddenFolders,
        onToggleHiddenFolders: onToggleHiddenFolders,
        onScanNewVideos: onScanNewVideos,
        onRescanAll: onRescanAll,
        onManageFolders: onManageFolders,
        onStoragePermissions: onStoragePermissions,
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

              // 2. Sheet Title & Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.folder_special_rounded,
                        color: AppColors.electricBlueBright,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Folder Management',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Index & configure local video directories',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              const Divider(color: AppColors.glassBorderSubtle, height: 1),
              const SizedBox(height: 6),

              // 3. Action Items
              _ActionTile(
                icon: Icons.sync_rounded,
                title: 'Scan for new videos',
                subtitle: 'Quick scan for newly added local videos',
                onTap: () {
                  Navigator.pop(context);
                  onScanNewVideos();
                },
              ),

              _ActionTile(
                icon: Icons.refresh_rounded,
                title: 'Rescan all folders',
                subtitle: 'Deep re-index of all storage locations',
                onTap: () {
                  Navigator.pop(context);
                  onRescanAll();
                },
              ),

              _ActionTile(
                icon: Icons.folder_shared_rounded,
                title: 'Manage folders',
                subtitle: 'Add, remove, or customize indexed paths',
                onTap: () {
                  Navigator.pop(context);
                  onManageFolders();
                },
              ),

              // Show Hidden Folders Toggle Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGlass,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.glassBorderSubtle, width: 0.6),
                      ),
                      child: const Icon(
                        Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Show hidden folders',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Reveal dotfolders and private directories',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: showHiddenFolders,
                      activeColor: AppColors.electricBlue,
                      activeTrackColor: AppColors.electricBlue.withOpacity(0.40),
                      onChanged: (val) {
                        onToggleHiddenFolders(val);
                      },
                    ),
                  ],
                ),
              ),

              _ActionTile(
                icon: Icons.security_rounded,
                title: 'Storage permissions',
                subtitle: 'Manage Android media and directory access',
                onTap: () {
                  Navigator.pop(context);
                  onStoragePermissions();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.glassBorderSubtle, width: 0.6),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11.5,
          color: AppColors.textMuted,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
