import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'Screens/splash_screen.dart'; // Ensure this path is correct for your splash screen
import 'Screens/home_screen.dart'; // Add import for HomeScreen
import 'Screens/workout_log_screen.dart'; // Add import for WorkoutLogScreen

void main() {

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // 1. PRESERVE: Keep native screen up until we say so!
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 🔥 THIS FIXES YOUR ERROR
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/workout': (context) => const WorkoutLogScreen(),
      },
    );
  }
}
