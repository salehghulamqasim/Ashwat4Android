// // ! THIS FILE ISNT BEING USED. ALL LOGIC AND UI EXIST IN MAIN.DART
// // lib/features/tracking/domain/loop_closure.dart
// import 'package:geolocator/geolocator.dart';

// /// Configuration for loop-closure detection (return-to-start)
// class LoopClosureConfig {
//   /// Considered "inside" when distance to anchor <= enterRadiusMeters
//   final double enterRadiusMeters;

//   /// Considered "outside" when distance to anchor >= exitRadiusMeters
//   final double exitRadiusMeters;

//   /// Must reach at least this far from anchor while outside
//   final double minTravelDistanceMeters;

//   /// Must spend at least this much time outside before re-enter counts
//   final Duration minTravelTime;

//   const LoopClosureConfig({
//     required this.enterRadiusMeters,
//     required this.exitRadiusMeters,
//     required this.minTravelDistanceMeters,
//     required this.minTravelTime,
//   });
// }

// /// Detects a lap when user leaves the anchor zone and returns to it
// /// with hysteresis (enter/exit), and minimum travel distance/time guards.
// class LoopClosureDetector {
//   final LoopClosureConfig config;

//   Position? _anchor;
//   bool _isOutside = false;
//   double _maxDistanceFromAnchorWhileOutside = 0.0;
//   DateTime? _leftAt;

//   LoopClosureDetector(this.config);

//   bool get hasAnchor => _anchor != null;

//   void setAnchor(Position anchor) {
//     _anchor = anchor;
//     _resetOutsideState();
//   }

//   void clearAnchor() {
//     _anchor = null;
//     _resetOutsideState();
//   }

//   /// Returns true exactly once per loop closure:
//   /// 1) leave (distance >= exitRadius) → 2) enough distance/time outside →
//   /// 3) re-enter (distance <= enterRadius).
//   bool onPosition(Position p) {
//     if (_anchor == null) return false;

//     final double d = Geolocator.distanceBetween(
//       p.latitude,
//       p.longitude,
//       _anchor!.latitude,
//       _anchor!.longitude,
//     );

//     if (_isOutside) {
//       // Track farthest excursion while outside
//       if (d > _maxDistanceFromAnchorWhileOutside) {
//         _maxDistanceFromAnchorWhileOutside = d;
//       }

//       // Re-entry
//       final bool reentered = d <= config.enterRadiusMeters;
//       if (reentered && _leftAt != null) {
//         final bool distanceOk =
//             _maxDistanceFromAnchorWhileOutside >=
//             config.minTravelDistanceMeters;
//         final bool timeOk =
//             DateTime.now().difference(_leftAt!) >= config.minTravelTime;

//         // Successful loop-closure
//         if (distanceOk && timeOk) {
//           _resetOutsideState();
//           return true; // ✅ count one lap
//         }

//         // Re-entered but guards failed → reset to "inside" (no lap)
//         _resetOutsideState();
//         return false;
//       }

//       // Still outside, keep waiting
//       return false;
//     } else {
//       // Leaving the start zone
//       final bool left = d >= config.exitRadiusMeters;
//       if (left) {
//         _isOutside = true;
//         _leftAt = DateTime.now();
//         _maxDistanceFromAnchorWhileOutside = d;
//       }
//       return false;
//     }
//   }

//   void _resetOutsideState() {
//     _isOutside = false;
//     _maxDistanceFromAnchorWhileOutside = 0.0;
//     _leftAt = null;
//   }
// }
