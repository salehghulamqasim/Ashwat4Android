import 'package:geolocator/geolocator.dart';

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
