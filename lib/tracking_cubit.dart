// // ! THIS FILE ISNT BEING USED. ALL LOGIC AND UI EXIST IN MAIN.DART
// // lib/tracking_cubit.dart
// import 'dart:async';
// import 'dart:io' show Platform;
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'features/tracking/domain/loop_closure.dart';

// // ───────────────── STATE
// class TrackingState extends Equatable {
//   final bool isTracking;
//   final int lapCount;
//   final String status;
//   final Position? lastPosition;
//   final bool goingToB;
//   final bool demoMode;

//   // NEW: UI helpers
//   final bool gpsPoor; // true when accuracy is worse than we need
//   final double? accuracyMeters; // exposes current accuracy to UI
//   final bool anchorSet; // show if start point is locked

//   const TrackingState({
//     required this.isTracking,
//     required this.lapCount,
//     required this.status,
//     required this.lastPosition,
//     required this.goingToB,
//     required this.demoMode,
//     this.gpsPoor = false,
//     this.accuracyMeters,
//     this.anchorSet = false,
//   });

//   TrackingState copyWith({
//     bool? isTracking,
//     int? lapCount,
//     String? status,
//     Position? lastPosition,
//     bool? goingToB,
//     bool? demoMode,
//     bool? gpsPoor,
//     double? accuracyMeters,
//     bool? anchorSet,
//   }) {
//     return TrackingState(
//       isTracking: isTracking ?? this.isTracking,
//       lapCount: lapCount ?? this.lapCount,
//       status: status ?? this.status,
//       lastPosition: lastPosition ?? this.lastPosition,
//       goingToB: goingToB ?? this.goingToB,
//       demoMode: demoMode ?? this.demoMode,
//       gpsPoor: gpsPoor ?? this.gpsPoor,
//       accuracyMeters: accuracyMeters ?? this.accuracyMeters,
//       anchorSet: anchorSet ?? this.anchorSet,
//     );
//   }

//   @override
//   List<Object?> get props => [
//     isTracking,
//     lapCount,
//     status,
//     lastPosition?.latitude,
//     lastPosition?.longitude,
//     goingToB,
//     demoMode,
//     gpsPoor,
//     accuracyMeters,
//     anchorSet,
//   ];
// }

// // ───────────────── CUBIT
// class TrackingCubit extends Cubit<TrackingState> {
//   final double pointALat;
//   final double pointALng;
//   final double pointBLat;
//   final double pointBLng;

//   final double proximityRadiusMeters;

//   StreamSubscription<Position>? _positionSub;
//   SharedPreferences? _prefs;

//   DateTime? _lastUpdateAt;

//   late LoopClosureDetector _loopDetector;
//   bool _anchorInternal = false;

//   bool _isTestMode = false;

//   // NEW: required accuracy thresholds
//   late double _requiredAccToAnchor; // how good we need to be to lock anchor
//   late double _maxAccToProcess; // how bad we allow samples to be

//   TrackingCubit({
//     required this.pointALat,
//     required this.pointALng,
//     required this.pointBLat,
//     required this.pointBLng,
//     this.proximityRadiusMeters = 50.0,
//   }) : super(
//          const TrackingState(
//            isTracking: false,
//            lapCount: 0,
//            status: 'Ready to track',
//            lastPosition: null,
//            goingToB: true,
//            demoMode: false,
//          ),
//        ) {
//     _initPrefs();
//     _loopDetector = LoopClosureDetector(
//       LoopClosureConfig(
//         enterRadiusMeters: 8.0,
//         exitRadiusMeters: 16.0,
//         minTravelDistanceMeters: 20.0,
//         minTravelTime: const Duration(seconds: 10),
//       ),
//     );
    
//     // Set accuracy thresholds (in meters)
//     _requiredAccToAnchor = 15.0;  // Require high accuracy to set anchor
//     _maxAccToProcess = 30.0;      // Discard updates worse than this
//   }

//   Future<void> _initPrefs() async {
//     _prefs = await SharedPreferences.getInstance();
//     _isTestMode = _prefs?.getBool('test_mode') ?? false;
//   }

//   // Start tracking with optimized location settings
//   Future<void> startTracking() async {
//     if (state.isTracking) return;

//     // Check and request permissions
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       emit(state.copyWith(
//         status: 'Please enable location services',
//         isTracking: false,
//       ));
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission != LocationPermission.whileInUse &&
//           permission != LocationPermission.always) {
//         emit(state.copyWith(
//           status: 'Location permissions are required',
//           isTracking: false,
//         ));
//         return;
//       }
//     }

//     // Configure location settings for high accuracy
//     const locationSettings = LocationSettings(
//       accuracy: LocationAccuracy.bestForNavigation,  // Highest accuracy
//       distanceFilter: 1,  // Minimum distance (in meters) to trigger updates
//       timeLimit: const Duration(seconds: 10),  // Timeout for getting location
//     );

//     // Start listening to position updates
//     _positionSub = Geolocator.getPositionStream(locationSettings: locationSettings)
//         .listen((position) {
//       _handleNewPosition(position);
//     }, onError: (e) {
//       emit(state.copyWith(
//         status: 'Location error: ${e.toString()}',
//         gpsPoor: true,
//       ));
//     });

//     emit(state.copyWith(
//       isTracking: true,
//       status: 'Tracking started',
//       gpsPoor: false,
//     ));
//   }

//   void _handleNewPosition(Position position) {
//     final now = DateTime.now();
    
//     // Skip if we got an update too soon (avoid duplicate updates)
//     if (_lastUpdateAt != null && 
//         now.difference(_lastUpdateAt!) < const Duration(milliseconds: 500)) {
//       return;
//     }
//     _lastUpdateAt = now;

//     // Check accuracy
//     final accuracy = position.accuracy;
//     final isAccurate = accuracy <= _maxAccToProcess;
    
//     // Update state with accuracy info
//     emit(state.copyWith(
//       lastPosition: position,
//       accuracyMeters: accuracy,
//       gpsPoor: accuracy > _requiredAccToAnchor,
//       status: isAccurate ? 'Tracking position' : 'Poor GPS signal',
//     ));

//     if (!isAccurate) return;

//     // Process the position update
//     _processPositionUpdate(position);
//   }

//   void _processPositionUpdate(Position position) {
//     // Anchor when good enough
//     if (!_anchorInternal && position.accuracy <= _requiredAccToAnchor) {
//       _loopDetector.setAnchor(position);
//       _anchorInternal = true;
//       emit(
//         state.copyWith(
//           anchorSet: true,
//           status:
//               'Anchor set (±${position.accuracy.toStringAsFixed(0)} m). Begin your circuit.',
//         ),
//       );
//       return;
//     }

//     // If we still don't have an anchor, keep informing the user
//     if (!_anchorInternal) {
//       emit(
//         state.copyWith(
//           status:
//               'Waiting for GPS lock (need ≤ ±${_requiredAccToAnchor.toStringAsFixed(0)} m, current ±${position.accuracy.toStringAsFixed(0)} m)…',
//         ),
//       );
//       return;
//     }

//     // Feed loop-closure
//     final closed = _loopDetector.onPosition(position);
//     if (closed) {
//       final next = (state.lapCount + 1).clamp(0, 7);
//       emit(state.copyWith(lapCount: next, status: 'Lap $next/7 completed'));
//       _prefs?.setInt('lapCount', next);
//     } else if (state.status.startsWith('Lap')) {
//       // maintain a neutral status after the toasty message
//       emit(state.copyWith(status: 'Walking…'));
//     }
//   }

//   void stop() {
//     _positionSub?.cancel();
//     _positionSub = null;
//     emit(state.copyWith(isTracking: false, status: 'Tracking stopped'));
//   }

//   void reset() {
//     emit(
//       state.copyWith(
//         lapCount: 0,
//         status: 'Ready to track',
//         goingToB: true,
//         anchorSet: false,
//       ),
//     );
//     _prefs?.setInt('lapCount', 0);
//     _anchorInternal = false;
//     _loopDetector.clearAnchor();
//   }

//   // NEW: let UI trigger re-anchoring
//   void recalibrateAndReanchor() {
//     _anchorInternal = false;
//     _loopDetector.clearAnchor();
//     emit(
//       state.copyWith(
//         anchorSet: false,
//         status: 'Recalibrating… walk a few steps, waiting for good GPS',
//       ),
//     );
//   }

//   // NEW: open settings/maps to “warm up” GPS
//   Future<void> openGpsSettings() async {
//     // Try OS location settings
//     await Geolocator.openLocationSettings();
//   }

//   Future<void> openMapsToWarmGPS() async {
//     // Launch a maps app to force a GPS lock
//     final Uri gmaps = Uri.parse('https://maps.google.com/?q=Current+Location');
//     if (await canLaunchUrl(gmaps)) {
//       await launchUrl(gmaps, mode: LaunchMode.externalApplication);
//     }
//   }

//   @override
//   Future<void> close() {
//     _positionSub?.cancel();
//     return super.close();
//   }
// }
