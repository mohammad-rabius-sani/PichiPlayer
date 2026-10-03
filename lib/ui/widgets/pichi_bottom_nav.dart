import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Navigation destination enum for PIchiPlayer
enum NavDestination { home, library, folders, settings }

/// Fixed, compact bottom navigation bar with active-state pill highlights.
class PichiBottomNav extends StatelessWidget {
  final NavDestination currentDestination;
  final ValueChanged<NavDestination> onDestinationSelected;

  const PichiBottomNav({
    super.key,
    required this.currentDestination,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.90),
            border: const Border(
              top: BorderSide(
                color: AppColors.glassBorderSubtle,
                width: 0.8,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentDestination == NavDestination.home,
                onTap: () => onDestinationSelected(NavDestination.home),
              ),
              _NavItem(
                icon: Icons.video_library_outlined,
                activeIcon: Icons.video_library_rounded,
                label: 'Library',
                isSelected: currentDestination == NavDestination.library,
                onTap: () => onDestinationSelected(NavDestination.library),
              ),
              _NavItem(
                icon: Icons.folder_outlined,
                activeIcon: Icons.folder_rounded,
                label: 'Folders',
                isSelected: currentDestination == NavDestination.folders,
                onTap: () => onDestinationSelected(NavDestination.folders),
              ),
              _NavItem(
                icon: Icons.tune_rounded,
                activeIcon: Icons.tune_rounded,
                label: 'Settings',
                isSelected: currentDestination == NavDestination.settings,
                onTap: () => onDestinationSelected(NavDestination.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.electricBlue.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? AppColors.electricBlue.withOpacity(0.35)
                : Colors.transparent,
            width: 0.8,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? AppColors.electricBlueBright : AppColors.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.navLabel.copyWith(
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
