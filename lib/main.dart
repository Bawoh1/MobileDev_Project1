import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'Screens/splash_screen.dart'; 
import 'Screens/home_screen.dart'; 
import 'Screens/workout_log_screen.dart'; 
import 'Screens/progress_screen.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/workout': (context) => const WorkoutLogScreen(),
        '/progress': (context) => const ProgressScreen(),
      },
    );
  }
}
