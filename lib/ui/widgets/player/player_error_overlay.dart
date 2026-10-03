import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/local_video.dart';

/// Custom error UI when local video playback cannot be started or decoded
class PlayerErrorOverlay extends StatelessWidget {
  final LocalVideo video;
  final VoidCallback onTryAgain;
  final VoidCallback onOpenSettings;
  final VoidCallback onShowTechnicalDetails;

  const PlayerErrorOverlay({
    super.key,
    required this.video,
    required this.onTryAgain,
    required this.onOpenSettings,
    required this.onShowTechnicalDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFEF4444).withOpacity(0.40),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.60),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Warning Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.50),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444),
                      size: 28,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Can't play this video",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const Text(
                  "PIchiPlayer couldn't start playback for this file.",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 22),

                // 2. Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: onTryAgain,
                        child: const Text('Try Again'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.glassBorderSubtle),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: onOpenSettings,
                        child: const Text('Settings'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: onShowTechnicalDetails,
                  child: const Text(
                    'Technical details',
                    style: TextStyle(
                      color: AppColors.electricBlueBright,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
