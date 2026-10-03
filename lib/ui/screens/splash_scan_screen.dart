import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../models/scan_state.dart';
import '../../services/media_scanner_service.dart';
import '../widgets/ambient_background.dart';
import '../widgets/pichi_logo.dart';
import '../widgets/privacy_badge.dart';
import '../widgets/scanning_progress_card.dart';
import 'home_screen.dart';

/// Primary Splash + Initial Local Media Scan Screen for PIchiPlayer.
/// Orchestrates cinematic launch animations, dynamic local media scanning,
/// and smooth transition to the Home Library.
class SplashScanScreen extends StatefulWidget {
  final bool enableBackgroundAnimation;
  final bool autoStartScan;

  const SplashScanScreen({
    super.key,
    this.enableBackgroundAnimation = true,
    this.autoStartScan = true,
  });

  @override
  State<SplashScanScreen> createState() => _SplashScanScreenState();
}

class _SplashScanScreenState extends State<SplashScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;

  // Staged intro animations
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _wordmarkFade;
  late final Animation<Offset> _wordmarkSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _scanCardFade;
  late final Animation<Offset> _scanCardSlide;
  late final Animation<double> _privacyFade;

  final MediaScannerService _scannerService = MediaScannerService();
  StreamSubscription<ScanState>? _scanSubscription;
  ScanState _currentScanState = ScanState.initial();

  Timer? _scanStartTimer;
  Timer? _autoTransitionTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startOrchestratedFlow();
  }

  void _initAnimations() {
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 1. Logo: Fades & smoothly scales into view
    _logoFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.05, 0.40, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.05, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Wordmark: Fades and slides upward
    _wordmarkFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
    );
    _wordmarkSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Subtitle: Softly dissolves in
    _subtitleFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.38, 0.65, curve: Curves.easeOut),
    );

    // 4. Scanning Card: Slides up and fades in
    _scanCardFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.50, 0.85, curve: Curves.easeOut),
    );
    _scanCardSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.50, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // 5. Privacy Badge: Understated fade at bottom
    _privacyFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.65, 1.00, curve: Curves.easeOut),
    );
  }

  void _startOrchestratedFlow() {
    // Listen to live scan state updates
    _scanSubscription = _scannerService.scanStream.listen((state) {
      if (mounted) {
        setState(() {
          _currentScanState = state;
        });

        // Once scanning hits 100%, prepare smooth auto-transition to Home Screen
        if (state.isCompleted && _autoTransitionTimer == null) {
          _autoTransitionTimer = Timer(const Duration(milliseconds: 1400), () {
            if (mounted) {
              _navigateToHome();
            }
          });
        }
      }
    });

    // Start intro choreograph
    _introController.forward();

    // Trigger media scanner once the scanning card begins its reveal
    if (widget.autoStartScan) {
      _scanStartTimer = Timer(const Duration(milliseconds: 750), () {
        if (mounted) {
          _scannerService.startScan();
        }
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, _, __) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeAnim = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
          final scaleAnim = Tween<double>(begin: 0.98, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: fadeAnim,
            child: ScaleTransition(scale: scaleAnim, child: child),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scanStartTimer?.cancel();
    _autoTransitionTimer?.cancel();
    _scanSubscription?.cancel();
    _scannerService.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientBackground(
        enableAnimation: widget.enableBackgroundAnimation,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: AppDimensions.screenPadding,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top Spacer for optical vertical centering
                          const SizedBox(height: AppDimensions.spacing16),

                          // Central Splash + Scanner Experience
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: AppDimensions.maxContentWidth,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 1. Logo with Scale & Fade
                                  FadeTransition(
                                    opacity: _logoFade,
                                    child: ScaleTransition(
                                      scale: _logoScale,
                                      child: const PichiLogo(
                                        size: AppDimensions.logoSize,
                                        enableGlow: true,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: AppDimensions.spacing24),

                                  // 2. Wordmark: PIchiPlayer
                                  SlideTransition(
                                    position: _wordmarkSlide,
                                    child: FadeTransition(
                                      opacity: _wordmarkFade,
                                      child: const Text(
                                        'PIchiPlayer',
                                        style: AppTypography.brandWordmark,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: AppDimensions.spacing8),

                                  // 3. Subtitle: Your Local Video Companion
                                  FadeTransition(
                                    opacity: _subtitleFade,
                                    child: const Text(
                                      'Your Local Video Companion',
                                      style: AppTypography.brandSubtitle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  const SizedBox(height: AppDimensions.spacing40),

                                  // 4. Scanning Status & Luminous Progress Indicator
                                  SlideTransition(
                                    position: _scanCardSlide,
                                    child: FadeTransition(
                                      opacity: _scanCardFade,
                                      child: ScanningProgressCard(
                                        scanState: _currentScanState,
                                        onCompletedAction: _currentScanState.isCompleted
                                            ? _navigateToHome
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Bottom Understated Privacy Badge
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.spacing16,
                              top: AppDimensions.spacing24,
                            ),
                            child: FadeTransition(
                              opacity: _privacyFade,
                              child: const PrivacyBadge(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
