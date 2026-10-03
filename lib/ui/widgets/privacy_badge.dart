import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Understated, elegant privacy & offline badge near screen bottom
class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass.withOpacity(0.4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.glassBorderSubtle,
          width: 0.8,
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security_rounded,
                size: 13,
                color: AppColors.electricBlueBright,
              ),
              SizedBox(width: 6),
              Text(
                '100% Offline',
                style: AppTypography.privacyBadgeTitle,
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            'Your videos stay on your device.',
            style: AppTypography.privacyStatement,
          ),
        ],
      ),
    );
  }
}
