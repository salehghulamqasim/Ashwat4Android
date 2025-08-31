// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:vibration/vibration.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const HajjUmrahTrackerApp());

class HajjUmrahTrackerApp extends StatelessWidget {
  const HajjUmrahTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'SF Pro Display',
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'SF Pro Display',
        ),
        iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
      ),
      extensions: <ThemeExtension<dynamic>>[AppTheme.dark()],
    );

    return MaterialApp(
      title: 'Hajj/Umrah Tracker',
      theme: theme,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const TrackerRoot(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TrackerRoot extends StatelessWidget {
  const TrackerRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // No hard-coded points. Logic anchors to user's position on START.
      create:
          (_) => TrackingCubit(
            enterRadiusMeters: 8.0,
            exitRadiusMeters: 16.0,
            requiredAccToAnchor: 15.0, // need this accurate (±m) to lock anchor
            maxAccToProcess: 30.0, // ignore worse samples
            minTravelDistanceMeters: 20.0, // small guard while outside
            minTravelTime: const Duration(seconds: 10),
          ),
      child: const TrackerScreen(),
    );
  }
}

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
                    Align(alignment: Alignment.center, child: _statusBadge(s)),
                    const SizedBox(height: 20),
                    Align(alignment: Alignment.center, child: _statusCard(s)),
                    const Spacer(),
                    Align(alignment: Alignment.center, child: _lapCounter(s)),
                    const Spacer(flex: 2),
                    Align(
                      alignment: Alignment.center,
                      child: _mainButton(s, canStart),
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

  Widget _statusBadge(TrackingState s) {
    final ready = (s.accuracyMeters != null && s.accuracyMeters! <= 25.0);
    final color =
        _isTestMode ? _gold : (ready ? _gold : const Color(0xFFFFC107));
    final label = _isTestMode ? 'Test Mode' : (ready ? 'Ready' : 'Waiting...');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _brown.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: ready ? const AlwaysStoppedAnimation(1.0) : _breathe,
            child: Icon(
              ready ? Icons.check_circle : Icons.schedule,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: _beige,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(TrackingState s) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _brown.withOpacity(0.95),
                const Color(0xFF3E2723).withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _gold.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            s.status,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _beige,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _lapCounter(TrackingState s) {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _brown.withOpacity(0.9),
              const Color(0xFF3E2723).withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: _gold.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current Lap',
              style: TextStyle(color: _beige.withOpacity(0.8), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${s.lapCount + 1}/7',
              style: TextStyle(
                color: _gold,
                fontSize: 52,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: _gold.withOpacity(0.4), blurRadius: 15),
                ],
              ),
            ),
            if (s.lapCount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '${s.lapCount} completed',
                style: TextStyle(color: _beige.withOpacity(0.6), fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _mainButton(TrackingState s, bool canStart) {
    final on = s.isTracking;
    return GestureDetector(
      onTap: () {
        if (!on && !_isTestMode && !canStart) {
          _vibe(20);
          _snack('Please wait for GPS or use Test mode');
          return;
        }

        final c = context.read<TrackingCubit>();
        if (on) {
          c.stop();
          _vibe(30);
          HapticFeedback.selectionClick();
        } else {
          c.startTracking();
          _vibe(45);
          HapticFeedback.selectionClick();
        }
      },
      child: ScaleTransition(
        scale: _pulse,
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  s.isTracking
                      ? [const Color(0xFF8B4513), const Color(0xFF654321)]
                      : (canStart
                          ? [_gold, _gold2]
                          : [Colors.grey, Colors.grey]),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  s.isTracking
                      ? const Color(0xFF654321)
                      : (canStart ? _gold : Colors.grey.shade500),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (s.isTracking
                        ? const Color(0xFF8B4513)
                        : (canStart ? _gold : Colors.grey))
                    .withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: 6,
              ),
              BoxShadow(
                color: (s.isTracking
                        ? const Color(0xFF8B4513)
                        : (canStart ? _gold : Colors.grey))
                    .withOpacity(0.2),
                blurRadius: 45,
                spreadRadius: 12,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (s.isTracking)
                ScaleTransition(
                  scale: _glow,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8B4513).withOpacity(0.3),
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    s.isTracking ? Icons.stop : Icons.directions_walk,
                    size: 45,
                    color:
                        s.isTracking
                            ? _beige
                            : (canStart ? Colors.black : Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.isTracking ? 'STOP' : 'START',
                    style: TextStyle(
                      color:
                          s.isTracking
                              ? _beige
                              : (canStart ? Colors.black : Colors.white70),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ─────────────────────────────────────────────────────────
   SIMPLE STATE + CUBIT (single file, no overengineering)
   - Anchor at first good fix after START
   - Count lap on exit → re-enter
   - Small guards for jitter
───────────────────────────────────────────────────────── */

class TrackingState {
  final bool isTracking;
  final int lapCount;
  final String status;
  final Position? lastPosition;
  final double? accuracyMeters;
  final bool anchorSet;

  const TrackingState({
    required this.isTracking,
    required this.lapCount,
    required this.status,
    required this.lastPosition,
    required this.accuracyMeters,
    required this.anchorSet,
  });

  TrackingState copyWith({
    bool? isTracking,
    int? lapCount,
    String? status,
    Position? lastPosition,
    double? accuracyMeters,
    bool? anchorSet,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      lapCount: lapCount ?? this.lapCount,
      status: status ?? this.status,
      lastPosition: lastPosition ?? this.lastPosition,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      anchorSet: anchorSet ?? this.anchorSet,
    );
  }
}

class TrackingCubit extends Cubit<TrackingState> {
  // Config (hysteresis + light guards)
  final double enterRadiusMeters;
  final double exitRadiusMeters;
  final double requiredAccToAnchor;
  final double maxAccToProcess;
  final double minTravelDistanceMeters;
  final Duration minTravelTime;

  StreamSubscription<Position>? _positionSub;
  SharedPreferences? _prefs;

  // Anchor + outside/inside FSM
  Position? _anchor;
  bool _isOutside = false;
  double _maxDistanceWhileOutside = 0.0;
  DateTime? _leftAt;

  // Throttle duplicate updates
  DateTime? _lastUpdateAt;

  TrackingCubit({
    required this.enterRadiusMeters,
    required this.exitRadiusMeters,
    required this.requiredAccToAnchor,
    required this.maxAccToProcess,
    required this.minTravelDistanceMeters,
    required this.minTravelTime,
  }) : super(
         const TrackingState(
           isTracking: false,
           lapCount: 0,
           status: 'Ready to track',
           lastPosition: null,
           accuracyMeters: null,
           anchorSet: false,
         ),
       ) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs?.getInt('lapCount') ?? 0;
    emit(state.copyWith(lapCount: saved));
  }

  Future<void> startTracking() async {
    if (state.isTracking) return;

    // Permission / service checks (fail silently to UI status)
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      emit(state.copyWith(status: 'Please enable location services'));
      return;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm != LocationPermission.always &&
        perm != LocationPermission.whileInUse) {
      emit(state.copyWith(status: 'Location permissions are required'));
      return;
    }

    // Reset anchor on every START (anchor = first good fix)
    _clearAnchor();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1,
    );

    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      _onPosition,
      onError: (e) {
        emit(state.copyWith(status: 'Location error: $e'));
      },
    );

    emit(state.copyWith(isTracking: true, status: 'Tracking started'));
  }

  void _onPosition(Position p) {
    final now = DateTime.now();
    if (_lastUpdateAt != null &&
        now.difference(_lastUpdateAt!) < const Duration(milliseconds: 400)) {
      return; // throttle a bit
    }
    _lastUpdateAt = now;

    final acc = p.accuracy;
    final goodEnough = acc <= maxAccToProcess;

    // Always surface current pos/accuracy to UI
    emit(
      state.copyWith(
        lastPosition: p,
        accuracyMeters: acc,
        status:
            state.anchorSet
                ? (goodEnough ? 'Walking…' : 'Poor GPS signal')
                : 'Waiting for GPS lock…',
      ),
    );

    if (!goodEnough) return;

    // Lock anchor at first accurate sample
    if (_anchor == null && acc <= requiredAccToAnchor) {
      _anchor = p;
      emit(
        state.copyWith(
          anchorSet: true,
          status:
              'Anchor set (±${acc.toStringAsFixed(0)} m). Begin your circuit.',
        ),
      );
      return;
    }

    // If no anchor yet, keep waiting
    if (_anchor == null) return;

    // Distance from anchor
    final d = Geolocator.distanceBetween(
      p.latitude,
      p.longitude,
      _anchor!.latitude,
      _anchor!.longitude,
    );

    if (_isOutside) {
      // Track farthest excursion
      if (d > _maxDistanceWhileOutside) {
        _maxDistanceWhileOutside = d;
      }

      // Re-enter?
      if (d <= enterRadiusMeters) {
        final distanceOk = _maxDistanceWhileOutside >= minTravelDistanceMeters;
        final timeOk =
            _leftAt != null &&
            DateTime.now().difference(_leftAt!) >= minTravelTime;

        // Count lap only if basic guards pass
        if (distanceOk && timeOk) {
          final next = (state.lapCount + 1).clamp(0, 7);
          emit(state.copyWith(lapCount: next, status: 'Lap $next/7 completed'));
          _prefs?.setInt('lapCount', next);
        } else {
          emit(state.copyWith(status: 'Inside zone'));
        }

        // Reset outside state
        _isOutside = false;
        _maxDistanceWhileOutside = 0.0;
        _leftAt = null;
      }
    } else {
      // Leaving zone?
      if (d >= exitRadiusMeters) {
        _isOutside = true;
        _leftAt = DateTime.now();
        _maxDistanceWhileOutside = d;
        emit(state.copyWith(status: 'Outside zone…'));
      }
    }
  }

  void stop() {
    _positionSub?.cancel();
    _positionSub = null;
    emit(state.copyWith(isTracking: false, status: 'Tracking stopped'));
  }

  void reset() {
    _positionSub?.cancel();
    _positionSub = null;
    _prefs?.setInt('lapCount', 0);
    _clearAnchor();
    emit(
      const TrackingState(
        isTracking: false,
        lapCount: 0,
        status: 'Ready to track',
        lastPosition: null,
        accuracyMeters: null,
        anchorSet: false,
      ),
    );
  }

  void _clearAnchor() {
    _anchor = null;
    _isOutside = false;
    _maxDistanceWhileOutside = 0.0;
    _leftAt = null;
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    return super.close();
  }
}

/* ─────────────────────────────────────────────────────────
   Minimal AppTheme used by your existing UI (unchanged)
───────────────────────────────────────────────────────── */
@immutable
class AppTheme extends ThemeExtension<AppTheme> {
  final Gradient primaryGradient;
  final Color cardBg;
  final Color surfaceBorder;
  final Color glowColor;
  final Color safeBlue;

  // Text styles
  final TextStyle title;
  final TextStyle body;
  final TextStyle chip;
  final TextStyle percent;

  const AppTheme({
    required this.primaryGradient,
    required this.cardBg,
    required this.surfaceBorder,
    required this.glowColor,
    required this.safeBlue,
    required this.title,
    required this.body,
    required this.chip,
    required this.percent,
  });

  static AppTheme dark() {
    return AppTheme(
      primaryGradient: const LinearGradient(
        colors: [Color(0xFF0A84FF), Color(0xFF64D2FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      cardBg: const Color(0xFF2C2C2E),
      surfaceBorder: const Color(0xFF3A3A3C),
      glowColor: const Color(0xFF0A84FF),
      safeBlue: const Color(0xFF0A84FF),
      title: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
      body: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        fontFamily: 'SF Pro Display',
      ),
      chip: const TextStyle(
        color: Color(0xFF64D2FF),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
      percent: const TextStyle(
        color: Color(0xFF64D2FF),
        fontSize: 15,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
    );
  }

  @override
  AppTheme copyWith({
    Gradient? primaryGradient,
    Color? cardBg,
    Color? surfaceBorder,
    Color? glowColor,
    Color? safeBlue,
    TextStyle? title,
    TextStyle? body,
    TextStyle? chip,
    TextStyle? percent,
  }) {
    return AppTheme(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      cardBg: cardBg ?? this.cardBg,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      glowColor: glowColor ?? this.glowColor,
      safeBlue: safeBlue ?? this.safeBlue,
      title: title ?? this.title,
      body: body ?? this.body,
      chip: chip ?? this.chip,
      percent: percent ?? this.percent,
    );
  }

  @override
  AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this;
    return AppTheme(
      primaryGradient: LinearGradient(
        colors: [
          Color.lerp(
                (primaryGradient as LinearGradient).colors.first,
                (other.primaryGradient as LinearGradient).colors.first,
                t,
              ) ??
              Colors.transparent,
          Color.lerp(
                (primaryGradient as LinearGradient).colors.last,
                (other.primaryGradient as LinearGradient).colors.last,
                t,
              ) ??
              Colors.transparent,
        ],
      ),
      cardBg: Color.lerp(cardBg, other.cardBg, t) ?? cardBg,
      surfaceBorder:
          Color.lerp(surfaceBorder, other.surfaceBorder, t) ?? surfaceBorder,
      glowColor: Color.lerp(glowColor, other.glowColor, t) ?? glowColor,
      safeBlue: Color.lerp(safeBlue, other.safeBlue, t) ?? safeBlue,
      title: TextStyle.lerp(title, other.title, t) ?? title,
      body: TextStyle.lerp(body, other.body, t) ?? body,
      chip: TextStyle.lerp(chip, other.chip, t) ?? chip,
      percent: TextStyle.lerp(percent, other.percent, t) ?? percent,
    );
  }
}
