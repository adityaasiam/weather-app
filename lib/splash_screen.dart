// splash_screen.dart
import 'package:flutter/material.dart';
// Removed unused import 'login_page.dart'; and 'dart:async';
// The navigation logic is now handled by AuthWrapper in main.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Animation duration
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut), // Elastic scaling effect
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn), // Fade in effect
    );

    // Start the animations
    _controller.forward();

    // The navigation away from the splash screen is now handled by the FutureBuilder
    // in main.dart which waits for a duration and then builds AuthWrapper.
    // The AuthWrapper then decides whether to show LoginPage or HomePage based on auth state.
    // Removed the Timer based navigation here.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Background gradient for the splash screen
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[900]!.withOpacity(0.8), Colors.blue[300]!.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated weather icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: const Icon(
                Icons.wb_cloudy, // Weather icon
                size: 100,
                color: Colors.yellow, // Icon color
              ),
            ),
            const SizedBox(height: 20),
            // Animated app title
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'CITY WEATHER', // App title
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Title color
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Animated loading indicator (optional, but good practice)
            FadeTransition(
              opacity: _fadeAnimation,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
