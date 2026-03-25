// Packages this app uses
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/splash_screen.dart'; 
import 'Screens/home_screen.dart'; 
import 'Screens/workout_log_screen.dart'; 
import 'Screens/progress_screen.dart';
import 'Screens/settings_screen.dart';

// This is the first function that runs when the app starts
void main() {

  // Make sure Flutter is ready before doing anything
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the native splash screen showing until Flutter is ready
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Desktop computers (Windows, Linux, Mac) need a special database setup
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Start the app
  runApp(const MyApp());
}

// MyApp is the root widget — it holds the whole app
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Tracks whether the app is in dark or light mode (dark by default)
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    // Load the saved theme when the app first opens
    _loadTheme();
  }

  // Reads the saved theme choice from storage
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Switches between dark and light mode, then saves the choice
  Future<void> _toggleTheme() async {
    final isDark = _themeMode != ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Hide the "debug" banner in the top-right corner
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      // The app starts on the splash screen
      initialRoute: '/',
      // All the screens in the app and their route names
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/workout': (context) => const WorkoutLogScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/settings': (context) => SettingsScreen(
              onThemeToggle: () => _toggleTheme(),
              isDarkMode: _themeMode == ThemeMode.dark,
            ),
      },
    );
  }
}
