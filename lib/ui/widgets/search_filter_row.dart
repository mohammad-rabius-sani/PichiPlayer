import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Available search result filters
enum SearchFilter {
  all('All'),
  fourK('4K'),
  tenEightyP('1080p'),
  sevenTwentyP('720p'),
  hdr('HDR'),
  favorites('Favorites');

  final String label;
  const SearchFilter(this.label);
}

/// Compact horizontal filter row for Search results matching PIchiPlayer chip styling
class SearchFilterRow extends StatelessWidget {
  final SearchFilter selectedFilter;
  final ValueChanged<SearchFilter> onFilterSelected;

  const SearchFilterRow({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: SearchFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = SearchFilter.values[index];
          final isSelected = filter == selectedFilter;

          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    fontSize: 12,
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
