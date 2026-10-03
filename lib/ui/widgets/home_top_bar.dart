import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Top app bar displaying PIchiPlayer wordmark, dynamic time-of-day greeting,
/// and compact Search & Settings icon actions.
class HomeTopBar extends StatelessWidget {
  final double scrollOffset;
  final VoidCallback onSearchTap;
  final VoidCallback onSettingsTap;

  const HomeTopBar({
    super.key,
    this.scrollOffset = 0.0,
    required this.onSearchTap,
    required this.onSettingsTap,
  });

  /// Computes dynamic greeting from system time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 22) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Subtle background tint that fades in as user scrolls down
    final scrollRatio = (scrollOffset / 80.0).clamp(0.0, 1.0);
    final bgColor = AppColors.background.withOpacity(scrollRatio * 0.92);

    return Container(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 16.0,
        top: 14.0,
        bottom: 12.0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: AppColors.glassBorderSubtle.withOpacity(scrollRatio * 0.6),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Branding & Dynamic Greeting
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PIchiPlayer',
                  style: AppTypography.topBarBrand,
                ),
                const SizedBox(height: 2),
                Text(
                  getGreeting(),
                  style: AppTypography.greetingSubtitle,
                ),
              ],
            ),
          ),

          // Search Icon Action
          _TopBarIconButton(
            icon: Icons.search_rounded,
            tooltip: 'Search Local Videos',
            onTap: onSearchTap,
          ),

          const SizedBox(width: 8),

          // Settings Icon Action
          _TopBarIconButton(
            icon: Icons.tune_rounded,
            tooltip: 'Settings',
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.electricBlue.withOpacity(0.2),
          highlightColor: AppColors.electricBlue.withOpacity(0.1),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceGlass.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.glassBorderSubtle,
                width: 0.8,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
