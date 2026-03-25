import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'home_screen.dart';

// SplashScreen is the loading screen that plays a short animation before the home screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// SingleTickerProviderStateMixin lets this widget drive an animation
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Setup the "Pump" animation — logo grows slightly larger
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    // Grow the logo from normal size (1.0) to 120% size (1.2) with a bouncy curve
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // 2. Once Flutter draws its first frame, swap out the native splash for our animated one
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove(); // Removes the static image
      _controller.forward();        // Starts the Flutter animation immediately
    });

    // 3. When the animation finishes, fade-transition to the home screen
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            // The new screen we're going to
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            // Fade in the home screen over the splash
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  // Clean up the animation controller when the screen is removed
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark background to match the gym theme
      backgroundColor: const Color(0xFF1E1E1E), 
      body: Center(
        // ScaleTransition makes the logo grow using the animation
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset(
            'assets/images/MainLogoIcon.png',
            width: 180, 
          ),
        ),
      ),
    );
  }
}
