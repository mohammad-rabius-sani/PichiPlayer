import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/local_video.dart';

enum _ActiveMarker { none, a, b }

/// Dedicated focused bottom sheet for configuring A-B Repeat loop points.
///
/// Principles:
/// A = Start
/// B = End
/// A ↔ B = Repeat
///
/// Designed as a simplified visual timeline editor for playback with live updates,
/// natural clamping, cinematic video preview, and seamless loop activation.
class ABRepeatSheet extends StatefulWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final Duration? initialA;
  final Duration? initialB;
  final bool initialEnabled;
  final void Function(Duration? a, Duration? b, bool enabled) onPointsChanged;
  final LocalVideo? video;
  final void Function(Duration position)? onSeek;
  final int repeatCount;
  final void Function(int count)? onRepeatCountChanged;

  const ABRepeatSheet({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    this.initialA,
    this.initialB,
    this.initialEnabled = false,
    required this.onPointsChanged,
    this.video,
    this.onSeek,
    this.repeatCount = 0,
    this.onRepeatCountChanged,
  });

  static void show(
    BuildContext context, {
    required Duration currentPosition,
    required Duration totalDuration,
    Duration? initialA,
    Duration? initialB,
    bool initialEnabled = false,
    required void Function(Duration? a, Duration? b, bool enabled) onPointsChanged,
    LocalVideo? video,
    void Function(Duration position)? onSeek,
    int repeatCount = 0,
    void Function(int count)? onRepeatCountChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ABRepeatSheet(
        currentPosition: currentPosition,
        totalDuration: totalDuration,
        initialA: initialA,
        initialB: initialB,
        initialEnabled: initialEnabled,
        onPointsChanged: onPointsChanged,
        video: video,
        onSeek: onSeek,
        repeatCount: repeatCount,
        onRepeatCountChanged: onRepeatCountChanged,
      ),
    );
  }

  @override
  State<ABRepeatSheet> createState() => _ABRepeatSheetState();
}

class _ABRepeatSheetState extends State<ABRepeatSheet> {
  static const Duration _minRepeatGap = Duration(seconds: 1);

  late Duration? _pointA;
  late Duration? _pointB;
  late bool _isEnabled;
  late Duration _previewPosition;
  late int _repeatCount;
  String? _feedbackMessage;
  _ActiveMarker _activeMarker = _ActiveMarker.none;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _pointA = widget.initialA;
    _pointB = widget.initialB;
    _isEnabled = widget.initialEnabled;
    _repeatCount = widget.repeatCount;
    _previewPosition = _pointA ?? widget.currentPosition;
    if (_pointA != null && _pointB != null) {
      _activeMarker = _ActiveMarker.none;
    } else if (_pointA != null) {
      _activeMarker = _ActiveMarker.a;
    }
  }

  Duration get _safeTotalDuration {
    if (widget.totalDuration <= Duration.zero) {
      return const Duration(minutes: 10);
    }
    return widget.totalDuration;
  }

  String _formatDuration(Duration? d) {
    if (d == null) return 'Not set';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  String _formatAccessibleDuration(Duration? d) {
    if (d == null) return 'Not set';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours hours $minutes minutes $seconds seconds';
    }
    return '$minutes minutes $seconds seconds';
  }

  void _setPointA() {
    final pos = widget.currentPosition;
    setState(() {
      _pointA = pos;
      _previewPosition = pos;
      _activeMarker = _ActiveMarker.a;

      // Intelligent clamping: if B was already set and is now <= A, reset B
      if (_pointB != null && _pointB! <= _pointA! + _minRepeatGap) {
        _pointB = null;
        _isEnabled = false;
      }
      _feedbackMessage = 'A point set';
    });
    HapticFeedback.lightImpact();
    _notify();
  }

  void _setPointB() {
    if (_pointA == null) return;

    Duration targetB = widget.currentPosition;
    // Intelligent clamping: B must always be after A by at least 1s
    if (targetB <= _pointA! + _minRepeatGap) {
      final candidate = _pointA! + const Duration(seconds: 10);
      if (candidate <= _safeTotalDuration) {
        targetB = candidate;
      } else {
        targetB = _safeTotalDuration;
      }
    }

    setState(() {
      _pointB = targetB;
      _previewPosition = targetB;
      _activeMarker = _ActiveMarker.b;
      _isEnabled = true;
      _feedbackMessage = 'B point set';
    });
    HapticFeedback.lightImpact();
    _notify();
  }

  void _disableOrEnableRepeat() {
    if (_pointA == null || _pointB == null) return;
    setState(() {
      _isEnabled = !_isEnabled;
      _feedbackMessage = _isEnabled ? 'Repeat section: ON' : 'Repeat section: OFF';
    });
    HapticFeedback.selectionClick();
    _notify();
  }

  void _clearPoints() {
    setState(() {
      _pointA = null;
      _pointB = null;
      _isEnabled = false;
      _activeMarker = _ActiveMarker.none;
      _previewPosition = widget.currentPosition;
      _feedbackMessage = 'Points cleared';
    });
    HapticFeedback.selectionClick();
    _notify();
  }

  void _onMarkerADragUpdate(double localDx, double trackWidth) {
    if (trackWidth <= 0) return;
    final totalMs = _safeTotalDuration.inMilliseconds;
    final ratio = (localDx / trackWidth).clamp(0.0, 1.0);
    final targetMs = (ratio * totalMs).round();

    final maxMs = _pointB != null
        ? (_pointB!.inMilliseconds - _minRepeatGap.inMilliseconds).clamp(0, totalMs)
        : (totalMs - _minRepeatGap.inMilliseconds).clamp(0, totalMs);

    final clampedMs = targetMs.clamp(0, maxMs);
    final newPos = Duration(milliseconds: clampedMs);

    setState(() {
      _pointA = newPos;
      _previewPosition = newPos;
      _activeMarker = _ActiveMarker.a;
      _isDragging = true;
    });
    widget.onSeek?.call(newPos);
    _notify();
  }

  void _onMarkerBDragUpdate(double localDx, double trackWidth) {
    if (trackWidth <= 0) return;
    final totalMs = _safeTotalDuration.inMilliseconds;
    final ratio = (localDx / trackWidth).clamp(0.0, 1.0);
    final targetMs = (ratio * totalMs).round();

    final minMs = _pointA != null
        ? (_pointA!.inMilliseconds + _minRepeatGap.inMilliseconds).clamp(0, totalMs)
        : _minRepeatGap.inMilliseconds.clamp(0, totalMs);

    final clampedMs = targetMs.clamp(minMs, totalMs);
    final newPos = Duration(milliseconds: clampedMs);

    setState(() {
      _pointB = newPos;
      _previewPosition = newPos;
      _activeMarker = _ActiveMarker.b;
      _isDragging = true;
    });
    widget.onSeek?.call(newPos);
    _notify();
  }

  void _onDragEnd() {
    setState(() {
      _isDragging = false;
    });
    HapticFeedback.selectionClick();
  }

  void _notify() {
    widget.onPointsChanged(_pointA, _pointB, _isEnabled);
  }

  void _setRepeatCount(int count) {
    setState(() {
      _repeatCount = count;
    });
    widget.onRepeatCountChanged?.call(count);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final bool bothSet = _pointA != null && _pointB != null;
    final bool aSetOnly = _pointA != null && _pointB == null;
    final Duration? repeatSpan = bothSet ? _pointB! - _pointA! : null;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(
            top: BorderSide(color: AppColors.glassBorderSubtle, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.65),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Header: Title, Description, Close Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.electricBlueBright.withOpacity(0.30),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.repeat_rounded,
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
                              'A-B Repeat',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Repeat a section of video',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Top-right Close Button
                      IconButton(
                        key: const ValueKey('ab_repeat_close_btn'),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                          size: 22,
                        ),
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                const Divider(color: AppColors.glassBorderSubtle, height: 1),
                const SizedBox(height: 14),

                // 3. Compact Cinematic Video Preview Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _CinematicPreviewBanner(
                    video: widget.video,
                    previewPosition: _previewPosition,
                    activeMarker: _activeMarker,
                    pointA: _pointA,
                    pointB: _pointB,
                    isEnabled: _isEnabled,
                    formatDuration: _formatDuration,
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Large Interactive Visual Timeline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      // Timestamp labels: Start & Total Duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(Duration.zero),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontFeatures: [FontFeature.tabularFigures()],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (bothSet && repeatSpan != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _isEnabled
                                    ? AppColors.electricBlue.withOpacity(0.18)
                                    : Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Loop Span: ${_formatDuration(repeatSpan)}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: _isEnabled
                                      ? AppColors.electricBlueBright
                                      : AppColors.textMuted,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                          Text(
                            _formatDuration(_safeTotalDuration),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontFeatures: [FontFeature.tabularFigures()],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Interactive Draggable Timeline Bar
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final trackWidth = constraints.maxWidth;
                          final totalMs = _safeTotalDuration.inMilliseconds > 0
                              ? _safeTotalDuration.inMilliseconds
                              : 1;

                          final double posA = _pointA != null
                              ? ((_pointA!.inMilliseconds / totalMs).clamp(0.0, 1.0) * trackWidth)
                              : 0.0;
                          final double posB = _pointB != null
                              ? ((_pointB!.inMilliseconds / totalMs).clamp(0.0, 1.0) * trackWidth)
                              : trackWidth;
                          final double posCurrent = ((widget.currentPosition.inMilliseconds / totalMs)
                                  .clamp(0.0, 1.0) *
                              trackWidth);

                          return SizedBox(
                            height: 52,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.centerLeft,
                              children: [
                                // Background base track
                                Container(
                                  height: 6,
                                  width: trackWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),

                                // Highlighted active region between A and B
                                if (bothSet)
                                  Positioned(
                                    left: posA,
                                    width: (posB - posA).clamp(0.0, trackWidth),
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _isEnabled
                                              ? [
                                                  AppColors.electricBlue,
                                                  AppColors.violetAccent,
                                                ]
                                              : [
                                                  Colors.white38,
                                                  Colors.white24,
                                                ],
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                        boxShadow: _isEnabled
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.electricBlue.withOpacity(0.50),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  )
                                else if (aSetOnly)
                                  // Subtle shaded range from A to playhead if forward
                                  Positioned(
                                    left: posA < posCurrent ? posA : posCurrent,
                                    width: (posA < posCurrent ? posCurrent - posA : posA - posCurrent)
                                        .clamp(0.0, trackWidth),
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.electricBlue.withOpacity(0.30),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),

                                // Current playback position needle
                                Positioned(
                                  left: (posCurrent - 1.5).clamp(0.0, trackWidth - 3),
                                  child: Container(
                                    width: 3,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.80),
                                      borderRadius: BorderRadius.circular(1.5),
                                    ),
                                  ),
                                ),

                                // Marker A Handle (Draggable)
                                if (_pointA != null)
                                  Positioned(
                                    left: (posA - 20).clamp(-4.0, trackWidth - 36),
                                    child: Semantics(
                                      label: 'A marker at ${_formatAccessibleDuration(_pointA)}',
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onHorizontalDragUpdate: (details) {
                                          final box = context.findRenderObject() as RenderBox?;
                                          if (box != null) {
                                            final localPos = box.globalToLocal(details.globalPosition);
                                            _onMarkerADragUpdate(localPos.dx, trackWidth);
                                          }
                                        },
                                        onHorizontalDragEnd: (_) => _onDragEnd(),
                                        child: SizedBox(
                                          width: 40,
                                          height: 48,
                                          child: Center(
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: AppColors.electricBlue,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2.2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.electricBlueBright.withOpacity(0.70),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'A',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Marker B Handle (Draggable)
                                if (_pointB != null)
                                  Positioned(
                                    left: (posB - 20).clamp(-4.0, trackWidth - 36),
                                    child: Semantics(
                                      label: 'B marker at ${_formatAccessibleDuration(_pointB)}',
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onHorizontalDragUpdate: (details) {
                                          final box = context.findRenderObject() as RenderBox?;
                                          if (box != null) {
                                            final localPos = box.globalToLocal(details.globalPosition);
                                            _onMarkerBDragUpdate(localPos.dx, trackWidth);
                                          }
                                        },
                                        onHorizontalDragEnd: (_) => _onDragEnd(),
                                        child: SizedBox(
                                          width: 40,
                                          height: 48,
                                          child: Center(
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: AppColors.violetAccent,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2.2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.violetAccent.withOpacity(0.70),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'B',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 5. Points A & B Status Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGlass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: bothSet && _isEnabled
                            ? AppColors.electricBlueBright.withOpacity(0.35)
                            : AppColors.glassBorderSubtle,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _PointBadge(
                                letter: 'A',
                                label: 'Point A',
                                value: _formatDuration(_pointA),
                                isSet: _pointA != null,
                                accentColor: AppColors.electricBlueBright,
                                isActiveDrag: _activeMarker == _ActiveMarker.a && _isDragging,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Icon(
                                bothSet ? Icons.repeat_rounded : Icons.arrow_forward_rounded,
                                size: 20,
                                color: bothSet
                                    ? (_isEnabled ? AppColors.electricBlueBright : AppColors.textMuted)
                                    : AppColors.textMuted,
                              ),
                            ),
                            Expanded(
                              child: _PointBadge(
                                letter: 'B',
                                label: 'Point B',
                                value: _formatDuration(_pointB),
                                isSet: _pointB != null,
                                accentColor: AppColors.violetAccent,
                                isActiveDrag: _activeMarker == _ActiveMarker.b && _isDragging,
                              ),
                            ),
                          ],
                        ),

                        // Active Repeat Section Display
                        if (bothSet) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isEnabled
                                  ? AppColors.electricBlue.withOpacity(0.12)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isEnabled
                                    ? AppColors.electricBlueBright.withOpacity(0.30)
                                    : Colors.white10,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isEnabled ? Icons.all_inclusive_rounded : Icons.pause_circle_filled_rounded,
                                  size: 16,
                                  color: _isEnabled ? AppColors.electricBlueBright : AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Repeat section',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        '${_formatDuration(_pointA)} → ${_formatDuration(_pointB)}',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: _isEnabled ? Colors.white : AppColors.textMuted,
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _isEnabled
                                        ? AppColors.electricBlue.withOpacity(0.25)
                                        : Colors.white12,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _isEnabled ? 'ON' : 'OFF',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: _isEnabled ? AppColors.electricBlueBright : AppColors.textMuted,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Feedback message
                        if (_feedbackMessage != null) ...[
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _feedbackMessage!,
                              key: ValueKey(_feedbackMessage),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.electricBlueBright,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 6. Primary Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      if (_pointA == null)
                        // Initial State: Set A
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.flag_rounded, size: 18),
                            label: Text(
                              'Set A (${_formatDuration(widget.currentPosition)})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.electricBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _setPointA,
                          ),
                        )
                      else if (_pointB == null)
                        // State 2: Set B
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.outlined_flag_rounded, size: 18),
                            label: Text(
                              'Set B (${_formatDuration(widget.currentPosition)})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.violetAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _setPointB,
                          ),
                        )
                      else
                        // Active State: Disable Repeat vs Clear Points
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton.icon(
                                  icon: Icon(
                                    _isEnabled
                                        ? Icons.pause_circle_outline_rounded
                                        : Icons.play_circle_outline_rounded,
                                    size: 18,
                                    color: _isEnabled
                                        ? AppColors.electricBlueBright
                                        : Colors.white70,
                                  ),
                                  label: Text(
                                    _isEnabled ? 'Disable Repeat' : 'Enable Repeat',
                                    style: TextStyle(
                                      color: _isEnabled
                                          ? AppColors.electricBlueBright
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: _isEnabled
                                        ? AppColors.electricBlue.withOpacity(0.12)
                                        : Colors.white.withOpacity(0.06),
                                    side: BorderSide(
                                      color: _isEnabled
                                          ? AppColors.electricBlueBright.withOpacity(0.60)
                                          : Colors.white24,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _disableOrEnableRepeat,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.restart_alt_rounded,
                                    size: 17,
                                    color: Colors.white70,
                                  ),
                                  label: const Text(
                                    'Clear Points',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _clearPoints,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 14),

                      // 7. Repeat Count Setting (Advanced, discrete)
                      _RepeatCountSelector(
                        selectedCount: _repeatCount,
                        onChanged: _setRepeatCount,
                      ),

                      const SizedBox(height: 8),

                      // Subtle 'Done' button for compatibility and fast close
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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

/// Compact cinematic video preview banner at the top of the sheet
class _CinematicPreviewBanner extends StatelessWidget {
  final LocalVideo? video;
  final Duration previewPosition;
  final _ActiveMarker activeMarker;
  final Duration? pointA;
  final Duration? pointB;
  final bool isEnabled;
  final String Function(Duration?) formatDuration;

  const _CinematicPreviewBanner({
    required this.video,
    required this.previewPosition,
    required this.activeMarker,
    required this.pointA,
    required this.pointB,
    required this.isEnabled,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final Color gradStart = video?.gradientStart ?? const Color(0xFF14203A);
    final Color gradEnd = video?.gradientEnd ?? const Color(0xFF090D17);
    final IconData icon = video?.visualIcon ?? Icons.movie_filter_rounded;
    final String? res = video?.resolution;

    String markerBadgeText;
    Color markerBadgeColor;
    if (activeMarker == _ActiveMarker.a) {
      markerBadgeText = 'A';
      markerBadgeColor = AppColors.electricBlueBright;
    } else if (activeMarker == _ActiveMarker.b) {
      markerBadgeText = 'B';
      markerBadgeColor = AppColors.violetAccent;
    } else if (pointA != null && pointB != null) {
      markerBadgeText = 'A ↔ B';
      markerBadgeColor = isEnabled ? AppColors.electricBlueBright : Colors.white60;
    } else {
      markerBadgeText = 'A';
      markerBadgeColor = Colors.white54;
    }

    return Container(
      height: 98,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorderSubtle,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Cinematic Gradient & Visual Icon
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [gradStart, gradEnd],
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 38,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),

            // Fine resolution watermark in preview
            if (res != null)
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    res,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            // Cinematic Gradient Vignette
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.20),
                    Colors.black.withOpacity(0.80),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),

            // Top-left Marker Badge
            Positioned(
              top: 10,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: markerBadgeColor.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: markerBadgeColor.withOpacity(0.60),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      markerBadgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: markerBadgeColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activeMarker == _ActiveMarker.a
                          ? 'Start'
                          : (activeMarker == _ActiveMarker.b ? 'End' : 'Active Range'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Center large live timecode
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatDuration(previewPosition),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      fontFeatures: [FontFeature.tabularFigures()],
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeMarker == _ActiveMarker.a
                        ? 'Position of Marker A'
                        : (activeMarker == _ActiveMarker.b
                            ? 'Position of Marker B'
                            : 'Playback Position'),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.white.withOpacity(0.65),
                      fontWeight: FontWeight.w400,
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

/// Point readout badge (Point A or Point B)
class _PointBadge extends StatelessWidget {
  final String letter;
  final String label;
  final String value;
  final bool isSet;
  final Color accentColor;
  final bool isActiveDrag;

  const _PointBadge({
    required this.letter,
    required this.label,
    required this.value,
    required this.isSet,
    required this.accentColor,
    this.isActiveDrag = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSet ? accentColor.withOpacity(0.12) : Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActiveDrag
              ? accentColor
              : (isSet ? accentColor.withOpacity(0.40) : AppColors.glassBorderSubtle),
          width: isActiveDrag ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isSet ? accentColor : Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isSet ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isSet ? accentColor : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSet ? Colors.white : AppColors.textMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector for repeat loop count (Continuous, 2×, 3×, 5×)
class _RepeatCountSelector extends StatelessWidget {
  final int selectedCount;
  final ValueChanged<int> onChanged;

  const _RepeatCountSelector({
    required this.selectedCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      (count: 0, label: 'Continuous'),
      (count: 2, label: '2×'),
      (count: 3, label: '3×'),
      (count: 5, label: '5×'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Row(
        children: [
          const Text(
            'Repeat Count',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final isSelected = selectedCount == opt.count;
              return Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: GestureDetector(
                  onTap: () => onChanged(opt.count),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.electricBlue.withOpacity(0.25)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.electricBlueBright.withOpacity(0.60)
                            : Colors.transparent,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      opt.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.electricBlueBright : Colors.white70,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
