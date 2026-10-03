import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_typography.dart';

/// Tasteful dark cinematic empty state when no local videos are found
class EmptyLibraryView extends StatelessWidget {
  final VoidCallback onScanStorage;
  final VoidCallback onChooseFolder;

  const EmptyLibraryView({
    super.key,
    required this.onScanStorage,
    required this.onChooseFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Tasteful Abstract Media Illustration
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceGlass,
                border: Border.all(
                  color: AppColors.glassBorderSubtle,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.18),
                    blurRadius: 36,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.video_library_outlined,
                  size: 44,
                  color: AppColors.electricBlueBright,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // 2. Title: "No videos yet"
            const Text(
              'No videos yet',
              style: AppTypography.heroTitle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // 3. Supporting Text: "PIchiPlayer couldn't find any local videos on your device."
            const Text(
              'PIchiPlayer couldn\'t find any local videos on your device.',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // 4. Primary Button: "Scan Storage"
            GestureDetector(
              onTap: onScanStorage,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 26),
                decoration: BoxDecoration(
                  gradient: AppGradients.logoSymbol,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Scan Storage',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 5. Secondary Action: "Choose Folder"
            GestureDetector(
              onTap: onChooseFolder,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGlass,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.glassBorderSubtle,
                    width: 0.8,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_open_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Choose Folder',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
