import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/player_types.dart';

/// Dedicated focused bottom sheet for configuring sleep timer in PIchiPlayer.
///
/// Supports quick presets, live custom duration slider, exact time picker,
/// active countdown display with +10/+30 extension and instant cancellation.
class SleepTimerSheet extends StatefulWidget {
  final SleepTimerOption currentOption;
  final ValueChanged<SleepTimerOption> onOptionSelected;
  final DateTime? targetEndTime;
  final Duration? remainingTime;
  final VoidCallback? onCancelTimer;
  final ValueChanged<Duration>? onExtendTimer;
  final ValueChanged<Duration>? onCustomDurationSelected;

  const SleepTimerSheet({
    super.key,
    required this.currentOption,
    required this.onOptionSelected,
    this.targetEndTime,
    this.remainingTime,
    this.onCancelTimer,
    this.onExtendTimer,
    this.onCustomDurationSelected,
  });

  static void show(
    BuildContext context, {
    required SleepTimerOption currentOption,
    required ValueChanged<SleepTimerOption> onOptionSelected,
    DateTime? targetEndTime,
    Duration? remainingTime,
    VoidCallback? onCancelTimer,
    ValueChanged<Duration>? onExtendTimer,
    ValueChanged<Duration>? onCustomDurationSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SleepTimerSheet(
        currentOption: currentOption,
        onOptionSelected: onOptionSelected,
        targetEndTime: targetEndTime,
        remainingTime: remainingTime,
        onCancelTimer: onCancelTimer,
        onExtendTimer: onExtendTimer,
        onCustomDurationSelected: onCustomDurationSelected,
      ),
    );
  }

  @override
  State<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends State<SleepTimerSheet> {
  late SleepTimerOption _selectedOption;
  DateTime? _targetEndTime;
  Duration _remainingDuration = Duration.zero;
  Timer? _countdownTicker;

  // Custom Duration Slider
  double _sliderMinutes = 30.0;
  bool _showExactPicker = false;
  int _exactHours = 0;
  int _exactMinutes = 30;

  // Transient feedback banner
  String? _feedbackMessage;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.currentOption;

    if (widget.targetEndTime != null) {
      _targetEndTime = widget.targetEndTime;
      _updateRemaining();
    } else if (widget.remainingTime != null && widget.remainingTime! > Duration.zero) {
      _targetEndTime = DateTime.now().add(widget.remainingTime!);
      _updateRemaining();
    } else if (widget.currentOption.duration != null) {
      _targetEndTime = DateTime.now().add(widget.currentOption.duration!);
      _updateRemaining();
    }

    // Start 1-second countdown ticker
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateRemaining();
        });
      }
    });
  }

  void _updateRemaining() {
    if (_targetEndTime != null) {
      final diff = _targetEndTime!.difference(DateTime.now());
      if (diff <= Duration.zero) {
        _remainingDuration = Duration.zero;
        _selectedOption = SleepTimerOption.off;
        _targetEndTime = null;
      } else {
        _remainingDuration = diff;
      }
    }
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _showFeedback(String message) {
    _feedbackTimer?.cancel();
    setState(() => _feedbackMessage = message);
    _feedbackTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _feedbackMessage = null);
    });
  }

  // --- Handlers ---

  void _handlePresetSelected(SleepTimerOption option) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedOption = option;
      if (option == SleepTimerOption.off) {
        _targetEndTime = null;
        _remainingDuration = Duration.zero;
        _showFeedback('Sleep timer off');
      } else if (option == SleepTimerOption.endOfVideo) {
        _targetEndTime = null;
        _remainingDuration = Duration.zero;
        _showFeedback('Stops when this video ends');
      } else if (option.duration != null) {
        _targetEndTime = DateTime.now().add(option.duration!);
        _remainingDuration = option.duration!;
        _showFeedback('Sleep timer set: ${option.label}');
      }
    });

    widget.onOptionSelected(option);
  }

  void _handleCustomDurationChanged(double minutes) {
    setState(() {
      _sliderMinutes = minutes;
    });
  }

  void _handleCustomDurationEnd(double minutes) {
    HapticFeedback.selectionClick();
    final dur = Duration(minutes: minutes.round());
    setState(() {
      _selectedOption = SleepTimerOption.custom;
      _targetEndTime = DateTime.now().add(dur);
      _remainingDuration = dur;
      _showFeedback('Sleep timer set: ${dur.inMinutes} minutes');
    });

    widget.onOptionSelected(SleepTimerOption.custom);
    widget.onCustomDurationSelected?.call(dur);
  }

  void _handleExtend(Duration extension) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_targetEndTime != null) {
        _targetEndTime = _targetEndTime!.add(extension);
      } else {
        _targetEndTime = DateTime.now().add(extension);
      }
      _remainingDuration += extension;
      _showFeedback('Timer extended (+${extension.inMinutes} min)');
    });

    widget.onExtendTimer?.call(extension);
  }

  void _handleCancelTimer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedOption = SleepTimerOption.off;
      _targetEndTime = null;
      _remainingDuration = Duration.zero;
      _showFeedback('Timer cancelled');
    });

    widget.onOptionSelected(SleepTimerOption.off);
    widget.onCancelTimer?.call();
  }

  void _applyExactTime() {
    final totalMinutes = (_exactHours * 60) + _exactMinutes;
    if (totalMinutes <= 0) return;

    final dur = Duration(minutes: totalMinutes);
    HapticFeedback.selectionClick();
    setState(() {
      _selectedOption = SleepTimerOption.custom;
      _targetEndTime = DateTime.now().add(dur);
      _remainingDuration = dur;
      _showExactPicker = false;
      _showFeedback('Sleep timer set: $totalMinutes minutes');
    });

    widget.onOptionSelected(SleepTimerOption.custom);
    widget.onCustomDurationSelected?.call(dur);
  }

  String _formatCountdown(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get _isActiveTimer =>
      _selectedOption != SleepTimerOption.off &&
      (_selectedOption == SleepTimerOption.endOfVideo || _remainingDuration > Duration.zero);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundNavy.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(
            top: BorderSide(color: AppColors.glassBorderSubtle, width: 1.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.70),
              blurRadius: 36,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: mediaQuery.size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 2. Header
                _buildHeader(),

                // 3. Transient Feedback Bar
                if (_feedbackMessage != null) _buildTransientFeedbackBar(),

                // 4. Scrollable Sheet Content
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 4,
                      bottom: bottomInset > 0 ? bottomInset + 12 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // A. Active Timer Countdown Card (Transforms when active)
                        if (_isActiveTimer) ...[
                          _buildActiveTimerCard(),
                          const SizedBox(height: 18),
                          const Divider(color: AppColors.glassBorderSubtle, height: 1),
                          const SizedBox(height: 14),
                        ] else ...[
                          // Inactive State Hero Display
                          _buildHeroInactiveDisplay(),
                          const SizedBox(height: 16),
                        ],

                        // B. Quick Presets Section
                        _buildSectionHeader('QUICK PRESETS'),
                        const SizedBox(height: 8),
                        _buildQuickPresetsGrid(),

                        const SizedBox(height: 18),
                        const Divider(color: AppColors.glassBorderSubtle, height: 1),
                        const SizedBox(height: 14),

                        // C. Custom Duration Slider
                        _buildSectionHeader('CUSTOM DURATION'),
                        const SizedBox(height: 8),
                        _buildCustomDurationSection(),

                        // D. Exact Duration Picker (Expandable)
                        if (_showExactPicker) ...[
                          const SizedBox(height: 14),
                          _buildExactDurationPickerCard(),
                        ],

                        const SizedBox(height: 8),
                      ],
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

  // --- Header ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.electricBlueBright.withOpacity(0.40),
                width: 1.0,
              ),
            ),
            child: const Icon(
              Icons.bedtime_outlined,
              color: AppColors.electricBlueBright,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sleep Timer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 1.5),
                Text(
                  'Stop playback automatically',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const ValueKey('sleep_timer_close_btn'),
            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTransientFeedbackBar() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.electricBlue.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.electricBlueBright.withOpacity(0.40)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.electricBlueBright, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _feedbackMessage!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --- A. Active Timer Countdown Card ---
  Widget _buildActiveTimerCard() {
    final isEndOfVideo = _selectedOption == SleepTimerOption.endOfVideo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.electricBlueBright.withOpacity(0.40),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricBlue.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Active Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.electricBlueBright,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlueBright,
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Timer active',
                    style: TextStyle(
                      color: AppColors.electricBlueBright,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Text(
                isEndOfVideo ? 'End of video' : _selectedOption.label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Large Hero Countdown Readout
          if (isEndOfVideo) ...[
            const Icon(
              Icons.stop_circle_outlined,
              size: 40,
              color: AppColors.electricBlueBright,
            ),
            const SizedBox(height: 8),
            const Text(
              'Stops when this video ends',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Playback will stop automatically. Auto-play next is paused.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Text(
              _formatCountdown(_remainingDuration),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'remaining',
              style: TextStyle(
                color: AppColors.electricBlueBright,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Playback will stop automatically.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
            ),
          ],

          const SizedBox(height: 16),

          // Action Buttons: [ Cancel Timer ]  [ +10 min ]  [ +30 min ]
          Row(
            children: [
              // Cancel Button
              Expanded(
                flex: 2,
                child: Semantics(
                  button: true,
                  label: 'Cancel timer',
                  child: GestureDetector(
                    key: const ValueKey('sleep_timer_cancel_btn'),
                    onTap: _handleCancelTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.14)),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_off_outlined, color: Colors.white70, size: 15),
                          SizedBox(width: 6),
                          Text(
                            'Cancel Timer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              if (!isEndOfVideo) ...[
                const SizedBox(width: 8),

                // +10 min extension
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Extend timer by 10 minutes',
                    child: GestureDetector(
                      key: const ValueKey('sleep_timer_plus_10'),
                      onTap: () => _handleExtend(const Duration(minutes: 10)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.electricBlueBright.withOpacity(0.50)),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '+10 min',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // +30 min extension
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Extend timer by 30 minutes',
                    child: GestureDetector(
                      key: const ValueKey('sleep_timer_plus_30'),
                      onTap: () => _handleExtend(const Duration(minutes: 30)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.glassBorderSubtle),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '+30 min',
                          style: TextStyle(
                            color: AppColors.electricBlueBright,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // --- Hero Inactive Display ---
  Widget _buildHeroInactiveDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.nightlight_round, color: AppColors.violetAccent, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No timer set',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Playback will stop automatically.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- B. Quick Presets Grid ---
  Widget _buildQuickPresetsGrid() {
    final presets = [
      {'opt': SleepTimerOption.fifteen, 'short': '15 min', 'sub': '15 minutes'},
      {'opt': SleepTimerOption.thirty, 'short': '30 min', 'sub': '30 minutes'},
      {'opt': SleepTimerOption.fortyFive, 'short': '45 min', 'sub': '45 minutes'},
      {'opt': SleepTimerOption.sixty, 'short': '60 min', 'sub': '60 minutes'},
      {'opt': SleepTimerOption.endOfVideo, 'short': 'End of video', 'sub': 'Stop when this video finishes'},
    ];

    return Column(
      children: [
        // Top 4 presets in 2x2 grid
        Row(
          children: [
            Expanded(child: _buildPresetCard(presets[0])),
            const SizedBox(width: 8),
            Expanded(child: _buildPresetCard(presets[1])),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildPresetCard(presets[2])),
            const SizedBox(width: 8),
            Expanded(child: _buildPresetCard(presets[3])),
          ],
        ),
        const SizedBox(height: 8),

        // End of Video Card
        _buildPresetCard(presets[4], fullWidth: true),
      ],
    );
  }

  Widget _buildPresetCard(Map<String, dynamic> item, {bool fullWidth = false}) {
    final option = item['opt'] as SleepTimerOption;
    final shortTitle = item['short'] as String;
    final subText = item['sub'] as String;
    final isSelected = _selectedOption == option;

    return Semantics(
      label: '$shortTitle sleep timer',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        key: ValueKey('sleep_preset_${option.name}'),
        onTap: () => _handlePresetSelected(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.electricBlue.withOpacity(0.20)
                : AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.electricBlueBright : AppColors.glassBorderSubtle,
              width: isSelected ? 1.4 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon or dot
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.electricBlueBright
                      : Colors.white.withOpacity(0.06),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.black, size: 14)
                    : Icon(
                        option == SleepTimerOption.endOfVideo
                            ? Icons.stop_rounded
                            : Icons.timer_outlined,
                        color: AppColors.textMuted,
                        size: 13,
                      ),
              ),
              const SizedBox(width: 10),

              // Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      shortTitle,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subText,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.electricBlueBright.withOpacity(0.9)
                            : AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: AppColors.electricBlueBright,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- C. Custom Duration Section ---
  Widget _buildCustomDurationSection() {
    final minutes = _sliderMinutes.round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Readout Row: [ 5 min ]   [ 45 min ]   [ 180 min ]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('5 min', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.electricBlueBright.withOpacity(0.40)),
                ),
                child: Text(
                  '$minutes min',
                  style: const TextStyle(
                    color: AppColors.electricBlueBright,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const Text('180 min', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),

          // Slider
          Semantics(
            label: 'Custom duration slider, currently $minutes minutes',
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.electricBlueBright,
                inactiveTrackColor: Colors.white.withOpacity(0.12),
                thumbColor: AppColors.electricBlueBright,
                overlayColor: AppColors.electricBlue.withOpacity(0.24),
                trackHeight: 3.5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
              ),
              child: Slider(
                key: const ValueKey('sleep_timer_slider'),
                value: _sliderMinutes.clamp(5.0, 180.0),
                min: 5.0,
                max: 180.0,
                divisions: 35,
                onChanged: _handleCustomDurationChanged,
                onChangeEnd: _handleCustomDurationEnd,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Secondary Action: Set Exact Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Slide to set custom duration',
                style: TextStyle(color: AppColors.textMuted.withOpacity(0.8), fontSize: 10.5),
              ),
              GestureDetector(
                key: const ValueKey('sleep_timer_exact_time_btn'),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showExactPicker = !_showExactPicker);
                },
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: AppColors.electricBlueBright, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _showExactPicker ? 'Hide exact picker' : 'Set exact time',
                      style: const TextStyle(
                        color: AppColors.electricBlueBright,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- D. Exact Duration Picker Card ---
  Widget _buildExactDurationPickerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.electricBlueBright.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'EXACT TIME PICKER',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          // Time Spinners Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hours
              _buildSpinnerColumn('Hours', _exactHours, 12, (newVal) {
                setState(() => _exactHours = newVal);
              }),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  ':',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Minutes
              _buildSpinnerColumn('Minutes', _exactMinutes, 59, (newVal) {
                setState(() => _exactMinutes = newVal);
              }),
            ],
          ),

          const SizedBox(height: 14),

          // Actions: [ Cancel ]  [ Done ]
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  key: const ValueKey('exact_time_cancel_btn'),
                  onTap: () => setState(() => _showExactPicker = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  key: const ValueKey('exact_time_done_btn'),
                  onTap: _applyExactTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.electricBlueBright),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Done',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpinnerColumn(String label, int value, int max, ValueChanged<int> onChanged) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white70, size: 20),
          onPressed: () {
            HapticFeedback.selectionClick();
            onChanged((value + 1) > max ? 0 : value + 1);
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.glassBorderSubtle),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 20),
          onPressed: () {
            HapticFeedback.selectionClick();
            onChanged((value - 1) < 0 ? max : value - 1);
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}
