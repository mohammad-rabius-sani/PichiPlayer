import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Available sorting criteria for the Library
enum LibrarySort {
  recent('Recently Added'),
  name('Name'),
  duration('Duration'),
  size('File Size'),
  resolution('Resolution'),
  dateModified('Date Modified');

  final String label;
  const LibrarySort(this.label);
}

/// Polished bottom sheet for selecting sort criteria and ordering
class SortBottomSheet extends StatelessWidget {
  final LibrarySort currentSort;
  final bool isAscending;
  final ValueChanged<LibrarySort> onSortSelected;
  final VoidCallback onToggleOrder;

  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.isAscending,
    required this.onSortSelected,
    required this.onToggleOrder,
  });

  static Future<void> show(
    BuildContext context, {
    required LibrarySort currentSort,
    required bool isAscending,
    required ValueChanged<LibrarySort> onSortSelected,
    required VoidCallback onToggleOrder,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SortBottomSheet(
        currentSort: currentSort,
        isAscending: isAscending,
        onSortSelected: onSortSelected,
        onToggleOrder: onToggleOrder,
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

            // Header row with Order Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sort Videos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    onToggleOrder();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGlass,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.glassBorderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          size: 14,
                          color: AppColors.electricBlueBright,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAscending ? 'Ascending' : 'Descending',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: AppColors.glassBorderSubtle, height: 1),
            const SizedBox(height: 6),

            // Sort Options List
            ...LibrarySort.values.map((sort) {
              final isSelected = sort == currentSort;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                onTap: () {
                  onSortSelected(sort);
                  Navigator.pop(context);
                },
                leading: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.electricBlue.withOpacity(0.15)
                        : AppColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.electricBlue.withOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    _getSortIcon(sort),
                    size: 17,
                    color: isSelected ? AppColors.electricBlueBright : AppColors.textSecondary,
                  ),
                ),
                title: Text(
                  sort.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.electricBlueBright,
                        size: 18,
                      )
                    : null,
              );
            }),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(LibrarySort sort) {
    switch (sort) {
      case LibrarySort.recent:
        return Icons.access_time_rounded;
      case LibrarySort.name:
        return Icons.sort_by_alpha_rounded;
      case LibrarySort.duration:
        return Icons.timelapse_rounded;
      case LibrarySort.size:
        return Icons.data_usage_rounded;
      case LibrarySort.resolution:
        return Icons.high_quality_rounded;
      case LibrarySort.dateModified:
        return Icons.edit_calendar_rounded;
    }
  }
}
