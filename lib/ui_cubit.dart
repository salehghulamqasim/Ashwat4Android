// lib/ui_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';

// UI State
class UiState extends Equatable {
  final bool isTestMode;
  final PermissionStatus permissionStatus;
  final String? showMessage;

  const UiState({
    this.isTestMode = false,
    this.permissionStatus = PermissionStatus.denied,
    this.showMessage,
  });

  UiState copyWith({
    bool? isTestMode,
    PermissionStatus? permissionStatus,
    String? showMessage,
  }) {
    return UiState(
      isTestMode: isTestMode ?? this.isTestMode,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      showMessage: showMessage,
    );
  }

  @override
  List<Object?> get props => [isTestMode, permissionStatus, showMessage];
}

// UI Cubit
class UiCubit extends Cubit<UiState> {
  UiCubit() : super(const UiState());

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final isTestMode = _prefs?.getBool('isTestMode') ?? false;

    emit(state.copyWith(isTestMode: isTestMode));

    await _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final whenInUse = await Permission.locationWhenInUse.request();

    if (whenInUse.isGranted) {
      final always = await Permission.locationAlways.request();
      emit(state.copyWith(permissionStatus: always));
    } else if (whenInUse.isPermanentlyDenied) {
      emit(
        state.copyWith(permissionStatus: PermissionStatus.permanentlyDenied),
      );
    } else {
      emit(
        state.copyWith(
          permissionStatus: whenInUse,
          showMessage: 'Location permission is required for tracking',
        ),
      );
    }
  }

  void toggleTestMode(bool isTestMode) {
    emit(state.copyWith(isTestMode: isTestMode));
    _prefs?.setBool('isTestMode', isTestMode);
  }

  void showMessage(String message) {
    emit(state.copyWith(showMessage: message));
    // Clear message after showing
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!isClosed) {
        emit(state.copyWith(showMessage: null));
      }
    });
  }
}
