import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/tracking/cubit/tracking_cubit.dart';
import 'features/tracking/presentation/screens/tracker_screen.dart';

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
      create:
          (_) => TrackingCubit(
            enterRadiusMeters: 8.0,
            exitRadiusMeters: 16.0,
            requiredAccToAnchor: 15.0,
            maxAccToProcess: 30.0,
            minTravelDistanceMeters: 20.0,
            minTravelTime: const Duration(seconds: 10),
          ),
      child: const TrackerScreen(),
    );
  }
}
