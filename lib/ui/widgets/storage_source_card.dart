import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/storage_source.dart';

/// Horizontal storage source card displaying video counts and indexed video footprint
class StorageSourceCard extends StatelessWidget {
  final StorageSource source;
  final VoidCallback? onTap;

  const StorageSourceCard({
    super.key,
    required this.source,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isInternal = source.type == StorageType.internal;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.glassBorderSubtle,
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Storage Device Icon with subtle glow container
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isInternal
                        ? AppColors.electricBlue.withOpacity(0.12)
                        : AppColors.violetAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isInternal
                          ? AppColors.electricBlue.withOpacity(0.30)
                          : AppColors.violetAccent.withOpacity(0.30),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    isInternal
                        ? Icons.phone_android_rounded
                        : Icons.sd_card_rounded,
                    size: 20,
                    color: isInternal
                        ? AppColors.electricBlueBright
                        : AppColors.violetAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        source.formattedVideoCount,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Usage footprint
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      source.formattedUsage,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isInternal
                            ? AppColors.electricBlueBright
                            : AppColors.violetAccent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Indexed footprint',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Subtle video media footprint bar
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  Container(
                    height: 5,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.06),
                  ),
                  FractionallySizedBox(
                    widthFactor: source.videoStorageRatio.clamp(0.05, 1.0),
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isInternal
                              ? [
                                  AppColors.electricBlue,
                                  AppColors.electricBlueBright,
                                ]
                              : [
                                  AppColors.violetAccent,
                                  const Color(0xFFA78BFA),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isInternal
                                ? AppColors.electricBlue.withOpacity(0.50)
                                : AppColors.violetAccent.withOpacity(0.50),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
