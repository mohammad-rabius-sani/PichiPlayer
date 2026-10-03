import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Single row item for technical metadata display
class MetadataRowItem {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const MetadataRowItem({
    required this.label,
    required this.value,
    this.onTap,
    this.isHighlighted = false,
  });
}

/// Clean two-column technical metadata card component for VIDEO, AUDIO, and FILE
class MetadataSectionCard extends StatelessWidget {
  final String title;
  final String? badgeText;
  final List<MetadataRowItem> items;
  final Widget? trailingAction;
  final Widget? bottomWidget;

  const MetadataSectionCard({
    super.key,
    required this.title,
    this.badgeText,
    required this.items,
    this.trailingAction,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Optional Badge
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1.1,
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.electricBlue.withOpacity(0.30),
                      width: 0.6,
                    ),
                  ),
                  child: Text(
                    badgeText!,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.electricBlueBright,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (trailingAction != null) trailingAction!,
            ],
          ),
          const SizedBox(height: 8),

          // Two-column Card Container
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceGlass,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.glassBorderSubtle,
                width: 0.8,
              ),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _buildMetadataRow(items[i]),
                  if (i < items.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                      child: Divider(
                        color: AppColors.glassBorderSubtle,
                        height: 1,
                        thickness: 0.8,
                      ),
                    ),
                ],
                if (bottomWidget != null) ...[
                  const Divider(
                    color: AppColors.glassBorderSubtle,
                    height: 1,
                    thickness: 0.8,
                  ),
                  bottomWidget!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(MetadataRowItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Column: Label
            SizedBox(
              width: 110,
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  letterSpacing: 0.1,
                ),
              ),
            ),

            // Right Column: Value
            Expanded(
              child: Text(
                item.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: item.isHighlighted
                      ? AppColors.electricBlueBright
                      : AppColors.textPrimary,
                  letterSpacing: 0.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (item.onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
