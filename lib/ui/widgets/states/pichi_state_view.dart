import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import 'pichi_state_severity.dart';
import 'technical_details_sheet.dart';

/// Reusable Global State widget implementing the PIchiPlayer unified state anatomy:
/// 1. Small visual icon/illustration badge with severity glow
/// 2. Short, crisp title
/// 3. One- or two-line calm explanation
/// 4. Optional metadata / chip content
/// 5. Primary actionable button
/// 6. Optional secondary action button
/// 7. Optional Technical Details action
class PichiStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final PichiSeverity severity;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final TechnicalMediaDetails? technicalDetails;
  final VoidCallback? onTechnicalDetails;
  final Widget? customContent;
  final bool isCompact;
  final EdgeInsetsGeometry padding;

  const PichiStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.severity = PichiSeverity.info,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.technicalDetails,
    this.onTechnicalDetails,
    this.customContent,
    this.isCompact = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isCompact ? 28.0 : 36.0;
    final badgeSize = isCompact ? 56.0 : 76.0;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Icon / Illustration Badge
            Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: severity.subtleBackground,
                border: Border.all(
                  color: severity.borderColor,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: severity.glowColor,
                    blurRadius: isCompact ? 16 : 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: severity.brightColor,
                ),
              ),
            ),

            SizedBox(height: isCompact ? 14 : 20),

            // 2. Short Title
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCompact ? 16 : 18.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // 3. One- or two-line calm explanation
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // 4. Optional Custom Content (Badges, Progress, Chips)
            if (customContent != null) ...[
              const SizedBox(height: 14),
              customContent!,
            ],

            SizedBox(height: isCompact ? 18 : 24),

            // 5 & 6. Actions Area
            if (primaryActionLabel != null ||
                secondaryActionLabel != null ||
                technicalDetails != null ||
                onTechnicalDetails != null)
              _buildActionsArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsArea(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary Action
          if (primaryActionLabel != null && onPrimaryAction != null)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: severity == PichiSeverity.critical
                      ? AppColors.error
                      : AppColors.electricBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onPrimaryAction!();
                },
                child: Text(
                  primaryActionLabel!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),

          // Secondary Action
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: AppColors.glassBorderSubtle,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onSecondaryAction!();
                },
                child: Text(
                  secondaryActionLabel!,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],

          // Technical Details Link
          if (technicalDetails != null || onTechnicalDetails != null) ...[
            const SizedBox(height: 6),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.code_rounded,
                  size: 15, color: AppColors.textSecondary),
              label: const Text(
                'Technical Details',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                if (onTechnicalDetails != null) {
                  onTechnicalDetails!();
                } else if (technicalDetails != null) {
                  TechnicalDetailsSheet.show(context,
                      details: technicalDetails!);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
