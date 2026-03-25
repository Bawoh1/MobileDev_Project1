import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'Screens/splash_screen.dart'; 
import 'Screens/home_screen.dart'; 
import 'Screens/workout_log_screen.dart'; 
import 'Screens/progress_screen.dart';
import 'Screens/settings_screen.dart';

void main() {

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep native screen up
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // For desktop platforms, initialize sqflite ffi
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/workout': (context) => const WorkoutLogScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/settings': (context) => SettingsScreen(
              onThemeToggle: _toggleTheme,
              isDarkMode: _themeMode == ThemeMode.dark,
            ),
      },
    );
  }
}
