import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Available library filter categories
enum LibraryFilter {
  all('All Videos'),
  recent('Recently Added'),
  favorites('Favorites'),
  fourK('4K'),
  hdr('HDR'),
  unwatched('Unwatched');

  final String label;
  const LibraryFilter(this.label);
}

/// Compact, horizontally scrollable filter chip row for the Library screen.
class LibraryFilterRow extends StatelessWidget {
  final LibraryFilter selectedFilter;
  final ValueChanged<LibraryFilter> onFilterSelected;

  const LibraryFilterRow({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppDimensions.homeHorizontalPadding,
        itemCount: LibraryFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = LibraryFilter.values[index];
          final isSelected = filter == selectedFilter;

          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.electricBlue
                    : AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected
                      ? AppColors.electricBlue
                      : AppColors.glassBorderSubtle,
                  width: 0.8,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.electricBlue.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  filter.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
