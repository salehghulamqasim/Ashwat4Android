# Hajj/Umrah Tracker

A minimal Flutter MVP for automatically tracking Tawaf (circles around the Kaaba) and Sa'i (walking between Safa and Marwah) during Hajj and Umrah.

## Features

### Core Functionality
- **Automatic Tawaf Detection**: Tracks 7 rounds around the Kaaba (21.422487, 39.826206)
- **Automatic Sa'i Detection**: Tracks 7 back-and-forth walks between Safa and Marwah
- **Hands-free Operation**: No manual input required - starts automatically when near sacred areas
- **Background Tracking**: Works with screen off and in background
- **Privacy-First**: No data collection or transmission - everything stays on device

### Test Mode
- **Simulation Testing**: Test the app without being at the actual locations
- **Tawaf Simulation**: Simulates circular motion around Kaaba
- **Sa'i Simulation**: Simulates back-and-forth motion between Safa and Marwah
- **Adjustable Speed**: Control simulation speed for testing
- **Debug Logs**: Console output for development and testing

### UI Features
- **Large Lap Counters**: Clear display of Tawaf (0/7) and Sa'i (0/7) progress
- **Real-time Stats**: Step count and elapsed time tracking
- **Activity Status**: Shows current location and tracking status
- **Reset Functionality**: Clear all counts and start fresh
- **Test Mode Toggle**: Easy switching between real and test modes

## Technical Details

### Dependencies
- `geolocator: ^11.0.0` - GPS location tracking
- `sensors_plus: ^4.0.2` - Motion detection for step counting
- `shared_preferences: ^2.2.2` - Local data persistence
- `permission_handler: ^11.3.1` - Location permission management

### Sacred Locations
- **Kaaba**: 21.422487, 39.826206
- **Safa**: 21.417105, 39.825101  
- **Marwah**: 21.414826, 39.827015

### Detection Algorithms
- **Tawaf**: Circular motion detection around Kaaba using angle calculations
- **Sa'i**: Back-and-forth motion detection between Safa and Marwah areas
- **Step Counting**: Accelerometer-based step detection
- **Location Filtering**: High-accuracy GPS with distance-based filtering

## Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ahswat4android
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Usage

### Real Mode (Default)
1. Grant location permissions when prompted
2. Go to the sacred areas (Kaaba for Tawaf, Safa/Marwah for Sa'i)
3. Start walking - the app will automatically detect and count laps
4. Monitor progress on the main screen

### Test Mode
1. Toggle "Test Mode ON" in the app
2. Choose between Tawaf or Sa'i simulation
3. Watch the simulated coordinates and lap detection
4. Use "Switch to Tawaf/Sa'i Test" to test different scenarios

### Controls
- **Reset All**: Clear all lap counts and timers
- **Test Mode Toggle**: Switch between real and simulation modes
- **Test Type Switch**: Toggle between Tawaf and Sa'i simulation

## Permissions Required

### Android
- `ACCESS_FINE_LOCATION` - Precise location tracking
- `ACCESS_COARSE_LOCATION` - Approximate location fallback
- `ACCESS_BACKGROUND_LOCATION` - Background tracking

### iOS
- Location When In Use
- Location Always (for background tracking)

## Development Notes

### Testing
- Use Test Mode for development and debugging
- Monitor console logs for simulated positions and lap detection
- Test both Tawaf and Sa'i detection algorithms

### Customization
- Adjust detection thresholds in the constants section
- Modify simulation parameters for different test scenarios
- Customize UI colors and layout as needed

### Privacy
- All data is stored locally using SharedPreferences
- No network requests or data transmission
- Location data is only used for lap detection

## Troubleshooting

### Location Not Working
- Ensure location permissions are granted
- Check if GPS is enabled on device
- Verify you're in the correct sacred areas

### Test Mode Issues
- Restart the app if simulation stops working
- Check console logs for debug information
- Try switching between Tawaf and Sa'i test modes

### Performance
- App is optimized for minimal battery usage
- Background location updates are filtered for efficiency
- Position history is limited to prevent memory issues

## License

This project is for educational and religious purposes. Use responsibly and respectfully.
