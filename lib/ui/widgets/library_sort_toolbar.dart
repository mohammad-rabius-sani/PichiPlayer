import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'sort_bottom_sheet.dart';

/// Compact toolbar below the filter row displaying the active sort option
/// and filter/sort trigger button.
class LibrarySortToolbar extends StatelessWidget {
  final LibrarySort currentSort;
  final bool isAscending;
  final VoidCallback onOpenSortSheet;
  final int totalCount;

  const LibrarySortToolbar({
    super.key,
    required this.currentSort,
    required this.isAscending,
    required this.onOpenSortSheet,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18.0,
        vertical: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Current Sort Order Indicator
          GestureDetector(
            onTap: onOpenSortSheet,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 14,
                  color: AppColors.electricBlueBright,
                ),
                const SizedBox(width: 5),
                Text(
                  currentSort.label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),

          // Total Videos Count Indicator & Filter Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$totalCount ${totalCount == 1 ? "video" : "videos"}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onOpenSortSheet,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.glassBorderSubtle,
                      width: 0.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
