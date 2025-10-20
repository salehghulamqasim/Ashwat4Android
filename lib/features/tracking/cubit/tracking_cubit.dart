import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tracking_state.dart';

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
