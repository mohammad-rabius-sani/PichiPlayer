import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/local_folder.dart';
import 'overlapping_thumbnails.dart';

/// Compact, elegant row displaying a local video directory in PIchiPlayer
class FolderListRow extends StatelessWidget {
  final LocalFolder folder;
  final VoidCallback onTap;
  final VoidCallback? onGrantAccess;

  const FolderListRow({
    super.key,
    required this.folder,
    required this.onTap,
    this.onGrantAccess,
  });

  @override
  Widget build(BuildContext context) {
    final hasPermission = folder.hasPermission;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasPermission ? onTap : (onGrantAccess ?? onTap),
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.electricBlue.withOpacity(0.08),
        highlightColor: AppColors.electricBlue.withOpacity(0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
          decoration: BoxDecoration(
            color: hasPermission
                ? Colors.transparent
                : const Color(0xFFEF4444).withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasPermission
                  ? Colors.transparent
                  : const Color(0xFFEF4444).withOpacity(0.25),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              // Folder / Category Icon with subtle background pill
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: hasPermission
                      ? AppColors.electricBlue.withOpacity(0.08)
                      : const Color(0xFFEF4444).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasPermission
                        ? AppColors.glassBorderSubtle
                        : const Color(0xFFEF4444).withOpacity(0.35),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  hasPermission
                      ? (folder.customIcon ?? Icons.folder_rounded)
                      : Icons.warning_amber_rounded,
                  size: 20,
                  color: hasPermission
                      ? AppColors.electricBlueBright
                      : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 14),

              // Title and metadata / permission-loss message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            folder.name,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: hasPermission
                                  ? AppColors.textPrimary
                                  : const Color(0xFFFCA5A5),
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (folder.isHidden) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.violetAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.violetAccent.withOpacity(0.35),
                                width: 0.6,
                              ),
                            ),
                            child: const Text(
                              'Hidden',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFC4B5FD),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2.5),
                    if (hasPermission)
                      Text(
                        folder.metadataSummary,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      const Text(
                        'Folder access required • Permission is no longer available.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFF87171),
                        ),
                      ),
                  ],
                ),
              ),

              // Trailing side: Overlapping miniature thumbnails or Grant Access button
              const SizedBox(width: 8),
              if (hasPermission) ...[
                if (folder.previewVideos.isNotEmpty) ...[
                  OverlappingThumbnails(previewVideos: folder.previewVideos),
                  const SizedBox(width: 10),
                ],
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ] else ...[
                GestureDetector(
                  onTap: onGrantAccess ?? onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withOpacity(0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Grant Access',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
