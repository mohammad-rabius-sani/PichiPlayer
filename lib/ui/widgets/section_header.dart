import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

/// Clean, restrained section header for Home screen media carousels.
class SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText = 'View all',
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimensions.homeHorizontalPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section Title
          Text(
            title,
            style: AppTypography.sectionHeading,
          ),

          // Action Link ("View all" / "See all")
          if (onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Text(
                  actionText,
                  style: AppTypography.sectionAction,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
