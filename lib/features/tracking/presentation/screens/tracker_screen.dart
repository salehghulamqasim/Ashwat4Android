import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:vibration/vibration.dart';
import '../../cubit/tracking_cubit.dart';
import '../../cubit/tracking_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/status_card.dart';
import '../widgets/lap_counter.dart';
import '../widgets/main_button.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});
  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Theme colors
  static const _gold = Color(0xFFD4AF37);
  static const _gold2 = Color(0xFFB8860B);
  static const _beige = Color(0xFFF5E6D3);
  static const _brown = Color(0xFF2C1810);
  static const _lottieBgPath = 'asset/wavy.json';

  // Animations
  late final AnimationController _pulseCtl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);
  late final AnimationController _glowCtl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);
  late final AnimationController _breatheCtl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);
  late final Animation<double> _pulse = Tween(
    begin: 0.95,
    end: 1.05,
  ).animate(CurvedAnimation(parent: _pulseCtl, curve: Curves.easeInOut));
  late final Animation<double> _glow = Tween(
    begin: 0.7,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _glowCtl, curve: Curves.easeInOutSine));
  late final Animation<double> _breathe = Tween(
    begin: 0.8,
    end: 1.2,
  ).animate(CurvedAnimation(parent: _breatheCtl, curve: Curves.easeInOut));

  bool _isTestMode = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    _pulseCtl.dispose();
    _glowCtl.dispose();
    _breatheCtl.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _isTestMode = _prefs?.getBool('isTestMode') ?? false;
    await _requestLocationPermission();
    if (mounted) setState(() {});
  }

  Future<void> _requestLocationPermission() async {
    final whenInUse = await Permission.locationWhenInUse.request();
    if (!mounted) return;

    if (whenInUse.isGranted) {
      await Permission.locationAlways.request();
    } else if (whenInUse.isPermanentlyDenied) {
      _showPermissionDialog();
    } else {
      _vibe(25);
      _snack('Location permission is required for tracking');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            backgroundColor: _brown,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Location Permission Required',
              style: TextStyle(color: _gold, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'This app needs precise location access to track your Tawaf and Saee. Please enable location permissions in Settings.',
              style: TextStyle(color: _beige),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _vibe(35);
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: _beige.withOpacity(0.7)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _vibe(35);
                  Navigator.pop(context);
                  openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: const Color(0xFF8B4513)),
  );

  Future<void> _vibe(int ms) async {
    try {
      await Vibration.vibrate(duration: ms);
    } catch (_) {}
  }

  void _onModeChanged(bool isTest) {
    setState(() => _isTestMode = isTest);
    _prefs?.setBool('isTestMode', isTest);
    final c = context.read<TrackingCubit>();
    if (c.state.isTracking) {
      c.stop();
      c.startTracking(); // restart stream with same logic; UI gating uses _isTestMode
    }
  }

  void _onLapCompleted() {
    _pulseCtl.forward().then((_) => _pulseCtl.reverse());
    HapticFeedback.lightImpact();
    _vibe(40);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Tawaf & Saee Tracker'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              decoration: BoxDecoration(
                color: _brown.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _gold.withOpacity(0.3)),
              ),
              child: CupertinoSegmentedControl<bool>(
                padding: const EdgeInsets.all(2),
                groupValue: _isTestMode,
                selectedColor: _gold,
                unselectedColor: Colors.transparent,
                borderColor: _gold.withOpacity(0.3),
                children: {
                  false: _seg('Live', selected: !_isTestMode),
                  true: _seg('Indoor/Test', selected: _isTestMode),
                },
                onValueChanged: _onModeChanged,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: _gold),
            color: _brown,
            onSelected: (v) {
              if (v == 'reset') {
                context.read<TrackingCubit>().reset();
                _vibe(30);
                HapticFeedback.mediumImpact();
              }
            },
            itemBuilder:
                (_) => [
                  PopupMenuItem<String>(
                    value: 'reset',
                    child: Text(
                      'Reset',
                      style: TextStyle(color: _beige.withOpacity(0.95)),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Stack(
        children: [
          _bgLottie(),
          SafeArea(
            child: BlocConsumer<TrackingCubit, TrackingState>(
              listener: (_, s) {
                if (s.status.startsWith('Lap ') &&
                    s.status.contains('completed')) {
                  _onLapCompleted();
                }
              },
              builder: (_, s) {
                final canStart =
                    _isTestMode ||
                    (s.accuracyMeters != null && s.accuracyMeters! <= 25.0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: StatusBadge(
                        isTestMode: _isTestMode,
                        accuracyMeters: s.accuracyMeters,
                        breatheAnimation: _breathe,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: StatusCard(status: s.status),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.center,
                      child: LapCounter(
                        lapCount: s.lapCount,
                        pulseAnimation: _pulse,
                      ),
                    ),
                    const Spacer(flex: 2),
                    Align(
                      alignment: Alignment.center,
                      child: MainButton(
                        isTracking: s.isTracking,
                        canStart: canStart,
                        pulseAnimation: _pulse,
                        glowAnimation: _glow,
                        isTestMode: _isTestMode,
                        onTap: () {
                          if (!s.isTracking && !_isTestMode && !canStart) {
                            _vibe(20);
                            _snack('Please wait for GPS or use Test mode');
                            return;
                          }

                          final c = context.read<TrackingCubit>();
                          if (s.isTracking) {
                            c.stop();
                            _vibe(30);
                            HapticFeedback.selectionClick();
                          } else {
                            c.startTracking();
                            _vibe(45);
                            HapticFeedback.selectionClick();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _seg(String t, {required bool selected}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Text(
      t,
      style: TextStyle(
        color: selected ? Colors.black : _beige,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _bgLottie() {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.accessibleNavigation ?? false;
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: Opacity(
              opacity: 0.6,
              child: Lottie.asset(
                _lottieBgPath,
                fit: BoxFit.cover,
                repeat: true,
                animate: !reduceMotion,
                frameRate: FrameRate.max,
                errorBuilder:
                    (_, __, ___) => const ColoredBox(color: Colors.black),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x77000000),
                  Color(0x44000000),
                  Color(0x88000000),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
