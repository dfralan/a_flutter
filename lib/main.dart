import 'package:flutter/material.dart';
import 'views/welcome_view.dart';
import 'services/app_coordinator.dart';

void main() async {
  // Ensure Flutter binding is initialized first
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the app coordinator
  await AppCoordinator.instance.initialize();
  runApp(const AFlutterApp());
}

class AFlutterApp extends StatelessWidget {
  const AFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'a - Nostr Client',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF8B5CF6),
          surface: Color(0xFF1A1A1A),
          background: Color(0xFF0F0F0F),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFD1D5DB),
          onBackground: Color(0xFFD1D5DB),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF9CA3AF),
            side: const BorderSide(color: Color(0xFF374151)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1,
          ),
          headlineMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9CA3AF),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFFD1D5DB),
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
      home: const WelcomeView(),
    );
  }
}
