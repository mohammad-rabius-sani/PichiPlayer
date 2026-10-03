import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import 'pichi_state_severity.dart';

/// Diagnostics and media container metadata for advanced debugging
/// and technical inquiries.
class TechnicalMediaDetails {
  final String? filePath;
  final String? container;
  final String? videoCodec;
  final String? resolution;
  final String? frameRate;
  final String? bitrate;
  final String? audioCodec;
  final String? colorSpace;
  final String? decoderError;
  final String? parserStatus;
  final String? extraDiagnostics;

  const TechnicalMediaDetails({
    this.filePath,
    this.container,
    this.videoCodec,
    this.resolution,
    this.frameRate,
    this.bitrate,
    this.audioCodec,
    this.colorSpace,
    this.decoderError,
    this.parserStatus,
    this.extraDiagnostics,
  });

  /// Factory for sample unsupported AV1 video on non-hardware AV1 SoC
  factory TechnicalMediaDetails.unsupportedAv1Sample({
    String filePath = '/storage/emulated/0/Movies/Interstellar.2014.2160p.AV1.mkv',
  }) {
    return TechnicalMediaDetails(
      filePath: filePath,
      container: 'MKV (Matroska)',
      videoCodec: 'AV1 (libdav1d / Main Profile 10-bit)',
      resolution: '3840 × 2160 (16:9)',
      frameRate: '23.976 fps',
      bitrate: '28.4 Mbps',
      audioCodec: 'DTS-HD MA 7.1 / 48 kHz / 24-bit',
      colorSpace: 'BT.2020 10-bit HDR10',
      decoderError:
          'MediaCodecVideoRenderer exception: OMX.qcom.video.decoder.av1 not present on chipset.',
      parserStatus: 'Container demuxing successful; video packet stream unhandled.',
    );
  }

  /// Formatted plain-text export for copying to clipboard
  String toPlainText() {
    final buffer = StringBuffer();
    buffer.writeln('=== PIchiPlayer Technical Diagnostics ===');
    if (filePath != null) buffer.writeln('File Path: $filePath');
    if (container != null) buffer.writeln('Container: $container');
    if (videoCodec != null) buffer.writeln('Video Codec: $videoCodec');
    if (resolution != null) buffer.writeln('Resolution: $resolution');
    if (frameRate != null) buffer.writeln('Frame Rate: $frameRate');
    if (bitrate != null) buffer.writeln('Bitrate: $bitrate');
    if (audioCodec != null) buffer.writeln('Audio Codec: $audioCodec');
    if (colorSpace != null) buffer.writeln('Color Space: $colorSpace');
    if (decoderError != null) buffer.writeln('Decoder Diagnostics: $decoderError');
    if (parserStatus != null) buffer.writeln('Parser Status: $parserStatus');
    if (extraDiagnostics != null) buffer.writeln('Extra: $extraDiagnostics');
    buffer.writeln('==========================================');
    return buffer.toString();
  }
}

/// Bottom sheet displaying technical media diagnostics without confusing
/// ordinary users on standard playback errors.
class TechnicalDetailsSheet extends StatelessWidget {
  final TechnicalMediaDetails details;

  const TechnicalDetailsSheet({
    super.key,
    required this.details,
  });

  static Future<void> show(
    BuildContext context, {
    required TechnicalMediaDetails details,
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => TechnicalDetailsSheet(details: details),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.glassBorderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 32,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PichiSeverity.info.subtleBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: PichiSeverity.info.borderColor),
                    ),
                    child: const Icon(
                      Icons.code_rounded,
                      color: AppColors.electricBlueBright,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Technical Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Local media & decoder diagnostics',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.glassBorderSubtle, height: 1),

            // Content List
            Flexible(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (details.filePath != null)
                      _buildDetailRow(
                        label: 'File Path',
                        value: details.filePath!,
                        isMonospace: true,
                      ),
                    if (details.container != null)
                      _buildDetailRow(
                        label: 'Container',
                        value: details.container!,
                      ),
                    if (details.videoCodec != null)
                      _buildDetailRow(
                        label: 'Video Codec',
                        value: details.videoCodec!,
                      ),
                    if (details.resolution != null)
                      _buildDetailRow(
                        label: 'Resolution',
                        value: details.resolution!,
                      ),
                    if (details.frameRate != null)
                      _buildDetailRow(
                        label: 'Frame Rate',
                        value: details.frameRate!,
                      ),
                    if (details.bitrate != null)
                      _buildDetailRow(
                        label: 'Bitrate',
                        value: details.bitrate!,
                      ),
                    if (details.audioCodec != null)
                      _buildDetailRow(
                        label: 'Audio Stream',
                        value: details.audioCodec!,
                      ),
                    if (details.colorSpace != null)
                      _buildDetailRow(
                        label: 'Color Space',
                        value: details.colorSpace!,
                      ),
                    if (details.parserStatus != null)
                      _buildDetailRow(
                        label: 'Parser Status',
                        value: details.parserStatus!,
                      ),
                    if (details.decoderError != null)
                      _buildDetailRow(
                        label: 'Decoder Diagnostics',
                        value: details.decoderError!,
                        isError: true,
                        isMonospace: true,
                      ),
                    if (details.extraDiagnostics != null)
                      _buildDetailRow(
                        label: 'Extra Info',
                        value: details.extraDiagnostics!,
                        isMonospace: true,
                      ),
                  ],
                ),
              ),
            ),

            const Divider(color: AppColors.glassBorderSubtle, height: 1),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.glassBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.copy_rounded,
                          color: AppColors.electricBlueBright, size: 16),
                      label: const Text(
                        'Copy Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(
                            ClipboardData(text: details.toPlainText()));
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.surface,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: AppColors.electricBlueBright,
                                    size: 18),
                                SizedBox(width: 10),
                                Text(
                                  'Technical details copied to clipboard',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceSubtle,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isError = false,
    bool isMonospace = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isError
                  ? PichiSeverity.critical.subtleBackground
                  : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isError
                    ? PichiSeverity.critical.borderColor
                    : AppColors.glassBorderSubtle,
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: isError ? AppColors.errorBright : Colors.white,
                fontSize: 12.5,
                height: 1.35,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
