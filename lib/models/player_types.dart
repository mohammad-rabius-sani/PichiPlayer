/// Scaling and display modes for the video render surface
enum PlayerScalingMode {
  fit('Fit', 'Preserve ratio, no cropping'),
  fill('Fill', 'Stretch to fill screen'),
  crop('Crop / Zoom', 'Zoom to fill, cropping edges'),
  original('Original (1:1)', 'Native pixel dimensions'),
  sixteenNine('16:9', 'Standard widescreen display'),
  fourThree('4:3', 'Classic television format');

  final String label;
  final String description;

  const PlayerScalingMode(this.label, this.description);
}

/// Screen orientation preferences
enum PlayerOrientationMode {
  auto('Auto Rotate'),
  portrait('Portrait'),
  landscape('Landscape'),
  reverseLandscape('Reverse Landscape');

  final String label;

  const PlayerOrientationMode(this.label);
}

/// Decoder mode for local offline playback
enum DecoderMode {
  auto('Auto', 'Smart hardware preference based on codec'),
  hardware('Hardware (HW)', 'Low power, GPU accelerated'),
  software('Software (SW)', 'CPU fallback compatibility');

  final String label;
  final String description;

  const DecoderMode(this.label, this.description);
}

/// Double tap seek direction
enum SeekDirection {
  backward('↶'),
  forward('↷');

  final String symbol;

  const SeekDirection(this.symbol);
}

/// Sleep timer duration options
enum SleepTimerOption {
  off('Off', null),
  fifteen('15 minutes', Duration(minutes: 15)),
  thirty('30 minutes', Duration(minutes: 30)),
  fortyFive('45 minutes', Duration(minutes: 45)),
  sixty('60 minutes', Duration(hours: 1)),
  endOfVideo('End of video', null),
  custom('Custom duration', null);

  final String label;
  final Duration? duration;

  const SleepTimerOption(this.label, this.duration);
}

/// Volume boost options for safe audio pipeline amplification
enum VolumeBoostOption {
  off('Off', 1.0),
  boost25('+25%', 1.25),
  boost50('+50%', 1.50),
  boost75('+75%', 1.75),
  boost100('+100%', 2.00);

  final String label;
  final double multiplier;

  const VolumeBoostOption(this.label, this.multiplier);
}

/// Unlock interaction method for screen lock
enum UnlockMethod {
  longPress('Hold to unlock'),
  tap('Tap to unlock');

  final String label;
  const UnlockMethod(this.label);
}

/// Lock indicator visibility mode
enum LockIndicatorVisibility {
  visible('Always visible'),
  temporary('Auto-hide when idle');

  final String label;
  const LockIndicatorVisibility(this.label);
}

/// Architecture configuration model for screen lock behavior and preferences
class ScreenLockConfig {
  final UnlockMethod unlockMethod;
  final LockIndicatorVisibility indicatorVisibility;
  final bool hapticsEnabled;
  final Duration holdDuration;

  const ScreenLockConfig({
    this.unlockMethod = UnlockMethod.longPress,
    this.indicatorVisibility = LockIndicatorVisibility.visible,
    this.hapticsEnabled = true,
    this.holdDuration = const Duration(milliseconds: 800),
  });
}

/// Behavior when leaving the PIchiPlayer application
enum LeavingAppBehavior {
  continuePlaying('Continue playing', 'Playback continues in background'),
  openPip('Open Picture-in-Picture', 'Float video above other apps (Recommended)'),
  audioOnly('Audio only', 'Continue sound without video rendering');

  final String label;
  final String description;

  const LeavingAppBehavior(this.label, this.description);
}

/// Architecture configuration model for Background Playback and Picture-in-Picture
class BackgroundPipConfig {
  final bool backgroundPlaybackEnabled;
  final bool pipEnabled;
  final LeavingAppBehavior leavingAppBehavior;
  final bool autoEnterPip;
  final bool showLockScreenControls;
  final bool showMediaNotification;

  const BackgroundPipConfig({
    this.backgroundPlaybackEnabled = true,
    this.pipEnabled = true,
    this.leavingAppBehavior = LeavingAppBehavior.openPip,
    this.autoEnterPip = false,
    this.showLockScreenControls = true,
    this.showMediaNotification = true,
  });

  BackgroundPipConfig copyWith({
    bool? backgroundPlaybackEnabled,
    bool? pipEnabled,
    LeavingAppBehavior? leavingAppBehavior,
    bool? autoEnterPip,
    bool? showLockScreenControls,
    bool? showMediaNotification,
  }) {
    return BackgroundPipConfig(
      backgroundPlaybackEnabled:
          backgroundPlaybackEnabled ?? this.backgroundPlaybackEnabled,
      pipEnabled: pipEnabled ?? this.pipEnabled,
      leavingAppBehavior: leavingAppBehavior ?? this.leavingAppBehavior,
      autoEnterPip: autoEnterPip ?? this.autoEnterPip,
      showLockScreenControls:
          showLockScreenControls ?? this.showLockScreenControls,
      showMediaNotification:
          showMediaNotification ?? this.showMediaNotification,
    );
  }
}

