# Project Architecture

This document describes the architecture and organization of the Hajj/Umrah Tracker Flutter application.

## Directory Structure

```
lib/
├── core/                           # Core application-wide functionality
│   └── theme/                      # Theme configuration
│       └── app_theme.dart         # App theme extension
│
├── features/                       # Feature modules
│   └── tracking/                  # Tracking feature
│       ├── cubit/                 # State management
│       │   ├── tracking_cubit.dart    # Tracking business logic
│       │   └── tracking_state.dart    # Tracking state model
│       │
│       └── presentation/          # UI layer
│           ├── screens/           # Full screen widgets
│           │   └── tracker_screen.dart
│           │
│           └── widgets/           # Reusable widgets
│               ├── lap_counter.dart
│               ├── main_button.dart
│               ├── status_badge.dart
│               └── status_card.dart
│
└── main.dart                      # App entry point
```

## Architecture Layers

### Core Layer (`lib/core/`)
Contains application-wide utilities, constants, and configurations:
- **Theme**: Material Design theme extensions and color schemes

### Features Layer (`lib/features/`)
Organized by feature using clean architecture principles:

#### Tracking Feature (`lib/features/tracking/`)
The main tracking feature is organized into:

1. **Cubit Layer** (`cubit/`): State management using BLoC pattern
   - `tracking_state.dart`: Immutable state model
   - `tracking_cubit.dart`: Business logic for GPS tracking and lap detection

2. **Presentation Layer** (`presentation/`): UI components
   - `screens/`: Full-screen pages
     - `tracker_screen.dart`: Main tracking interface
   - `widgets/`: Reusable UI components
     - `status_badge.dart`: GPS status indicator
     - `status_card.dart`: Current status display
     - `lap_counter.dart`: Lap progress display
     - `main_button.dart`: Start/Stop tracking button

## Design Principles

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Feature-First Organization**: Code is organized by feature, not by type
3. **Reusability**: Widgets are extracted into separate files for reuse
4. **Testability**: Business logic is separated from UI for easier testing
5. **Scalability**: Clear structure makes it easy to add new features

## State Management

The app uses **BLoC (Cubit)** pattern for state management:
- `TrackingCubit` manages GPS location tracking and lap counting
- `TrackingState` holds the current tracking status, lap count, and GPS accuracy
- UI widgets listen to state changes and rebuild accordingly

## Key Features

### Tracking Algorithm
- Anchors to user's starting position on first GPS fix
- Uses hysteresis (enter/exit radius) to prevent false lap detection
- Requires minimum travel distance and time to count a lap
- Filters poor GPS signals for accuracy

### UI Features
- Live/Test mode toggle for indoor testing
- Real-time GPS accuracy indicator
- Lap progress display (current lap out of 7)
- Visual feedback with animations and haptic feedback
- Permission management for location access

## Adding New Features

To add a new feature:
1. Create a new directory under `lib/features/`
2. Organize into `cubit/` and `presentation/` subdirectories
3. Follow the existing pattern for state management
4. Extract reusable widgets into the `widgets/` directory
5. Update `main.dart` to integrate the new feature

## Dependencies

- **flutter_bloc**: State management
- **geolocator**: GPS location tracking
- **shared_preferences**: Local data persistence
- **permission_handler**: Runtime permissions
- **lottie**: Animated backgrounds
- **vibration**: Haptic feedback
