import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'login_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if running in debug mode to use emulators
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    try {
      FirebaseFunctions.instance.useFunctionsEmulator('10.0.2.2', 5002);
      print('Configured to use Firebase Functions emulator at 10.0.2.2:5002');
    } catch (e) {
      print('Failed to connect to Functions emulator: $e');
    }
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      print('Configured to use Firestore emulator at localhost:8080');
    } catch (e) {
      print('Failed to connect to Firestore emulator: $e');
    }
    // You might also want to configure Auth emulator if needed
    // try {
    //   await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    //   print('Configured to use Auth emulator at localhost:9099');
    // } catch (e) {
    //   print('Failed to connect to Auth emulator: $e');
    // }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        cardTheme: const CardTheme(elevation: 4),
        // Add this to remove the debug banner
        // debugShowCheckedModeBanner: false,
      ),
      // The home property now uses FutureBuilder to show SplashScreen first
      home: FutureBuilder(
        // Simulate a delay for the splash screen
        future: Future.delayed(const Duration(seconds: 2)), // Enforce a minimum 2-second splash screen display
        builder: (context, snapshot) {
          // Once the splash screen duration is over, show the AuthWrapper
          if (snapshot.connectionState == ConnectionState.done) {
            return const AuthWrapper();
          }
          // While waiting for the delay, show the splash screen
          return const SplashScreen();
        },
      ),
    );
  }
}

// This widget listens to authentication state changes and navigates accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to Firebase Authentication state changes
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the connection is waiting (checking auth state) show a loading indicator or splash
        if (snapshot.connectionState == ConnectionState.waiting) {
          // You could show a loading spinner here if the splash screen is already gone
          // For now, we rely on the initial FutureBuilder in MyApp for the splash delay
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // If there is a user logged in (snapshot.hasData is true and snapshot.data is not null)
        if (snapshot.hasData) {
          // Navigate to the Home Page
          return const WeatherHomePage();
        }
        // If there is no user logged in
        return const LoginPage();
      },
    );
  }
}
