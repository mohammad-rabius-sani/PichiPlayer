import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/local_video.dart';

/// List mode row item for the Library screen, optimized for large collections.
class LibraryListTile extends StatelessWidget {
  final LocalVideo video;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMoreTap;

  const LibraryListTile({
    super.key,
    required this.video,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      splashColor: AppColors.electricBlue.withOpacity(0.1),
      highlightColor: AppColors.electricBlue.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: isSelected ? AppColors.electricBlue.withOpacity(0.08) : Colors.transparent,
        child: Row(
          children: [
            // Selection Checkbox
            if (isSelectionMode) ...[
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.electricBlue : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.electricBlueBright : AppColors.glassBorder,
                    width: 1.2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : null,
              ),
            ],

            // 1. Thumbnail (108dp wide, 16:9 ratio, 10dp rounded corners)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 108,
                height: 108 * (9 / 16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient Base
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [video.gradientStart, video.gradientEnd],
                        ),
                      ),
                    ),

                    // Atmospheric Icon
                    Center(
                      child: Icon(
                        video.visualIcon,
                        size: 24,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),

                    // Duration Badge (Bottom-Right)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          video.durationFormatted,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // 4K Badge (Top-Left)
                    if (video.resolution == '4K')
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            '4K',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.electricBlueBright,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 14),

            // 2. Metadata Columns (Filename, Duration, Resolution, Codec, File size)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    video.displayFileName,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    video.listMetadataText,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    video.folderPath,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 3. Overflow Action Button
            if (!isSelectionMode)
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 19),
                onPressed: onMoreTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ),
    );
  }
}
