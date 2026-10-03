import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Empty state displayed when an opened local folder contains 0 videos
class FolderEmptyView extends StatelessWidget {
  final VoidCallback onRescanFolder;
  final VoidCallback onChooseAnotherFolder;

  const FolderEmptyView({
    super.key,
    required this.onRescanFolder,
    required this.onChooseAnotherFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Folder with movie reel decorative icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceGlass,
                border: Border.all(
                  color: AppColors.glassBorderSubtle,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.08),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.folder_off_rounded,
                  size: 36,
                  color: AppColors.electricBlueBright,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'No videos in this folder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Supporting text
            const Text(
              'PIchiPlayer didn\'t find any playable local videos here.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Primary: Rescan Folder
                ElevatedButton.icon(
                  onPressed: onRescanFolder,
                  icon: const Icon(Icons.sync_rounded, size: 16),
                  label: const Text('Rescan Folder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Secondary: Choose Another Folder
                OutlinedButton(
                  onPressed: onChooseAnotherFolder,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.glassBorderSubtle),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Choose Another Folder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
