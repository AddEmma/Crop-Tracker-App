import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/crop_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const CropTrackerApp());
}

class CropTrackerApp extends StatelessWidget {
  const CropTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CropProvider(),
      child: MaterialApp(
        title: 'Crop Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFF4CAF50, const <int, Color>{
            50: Color(0xFFE8F5E8),
            100: Color(0xFFC8E6C9),
            200: Color(0xFFA5D6A7),
            300: Color(0xFF81C784),
            400: Color(0xFF66BB6A),
            500: Color(0xFF4CAF50),
            600: Color(0xFF43A047),
            700: Color(0xFF388E3C),
            800: Color(0xFF2E7D32),
            900: Color(0xFF1B5E20),
          }),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            secondary: const Color(0xFF8D6E63),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF8D6E63),
          ),
        ),
        home: const SplashScreen(), // Start with splash screen
      ),
    );
  }
}
