import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
// Removed unused import 'home_page.dart'; as navigation is handled by AuthWrapper

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // State to toggle between Login and Sign Up
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800), // Animation duration
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut), // Smooth fade animation
    );
    _controller.forward(); // Start the animation when the widget is initialized
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Function to toggle between Login and Sign Up forms
  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
      _emailController.clear();
      _passwordController.clear();
    });
  }

  // Function to handle email/password login or sign up
  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Log in with email and password
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Sign up with email and password
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      // Authentication state change will be handled by AuthWrapper,
      // which will navigate to HomePage automatically.
    } on FirebaseAuthException catch (e) {
      String message;
      if (_isLogin) {
        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided for that user.';
        } else {
          message = 'Login failed. ${e.message}';
        }
      } else {
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'The account already exists for that email.';
        } else {
          message = 'Sign up failed. ${e.message}';
        }
      }
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Handle other potential errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a new GoogleSignIn instance
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // Specify the server client ID for Google Sign-In with Firebase
        // This should be your Web client ID from Google Cloud Console
        serverClientId: '858999507653-nsqfkqjpo7tug7tp396ql4keaa3rlba4.apps.googleusercontent.com',
      );

      // Attempt to sign in with Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // If the user cancelled the sign-in, return
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain the auth details from the Google request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential with the Google ID token and access token
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Authentication state change will be handled by AuthWrapper,
      // which will navigate to HomePage automatically.

    } on PlatformException catch (e) {
      // Handle PlatformException specifically (e.g., sign_in_failed)
      print('PlatformException during Google Sign-In: ${e.code}, ${e.message}, ${e.details}');
      String message = 'Google Sign-In failed.';
      if (e.code == 'sign_in_failed') {
        // You can add more specific handling based on e.details if needed
        message = 'Google Sign-In failed. Please check your setup (SHA fingerprints, google-services.json).';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Handle other potential errors
      print('Error during Google Sign-In: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during Google Sign-In: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background gradient for the login page
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!.withOpacity(0.8), Colors.blue[300]!.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Card(
                elevation: 8.0,
                color: Colors.white.withOpacity(0.9), // Semi-transparent white card
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title (Login or Sign Up)
                      Text(
                        _isLogin ? 'Login' : 'Sign Up',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Email Input Field
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Colors.blue[900]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50]!.withOpacity(0.5),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      // Password Input Field
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Colors.blue[900]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50]!.withOpacity(0.5),
                        ),
                        obscureText: !_isPasswordVisible,
                      ),
                      const SizedBox(height: 24),
                      // Submit Button (Login or Sign Up)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5.0,
                        ),
                        onPressed: _isLoading ? null : _submitForm, // Disable button when loading
                        child: _isLoading && !_isLogin // Show loading indicator for sign up
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          _isLogin ? 'Login' : 'Sign Up',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Toggle Button (Switch between Login and Sign Up)
                      TextButton(
                        onPressed: _isLoading ? null : _toggleForm, // Disable button when loading
                        child: Text(
                          _isLogin ? 'Need an account? Sign Up' : 'Have an account? Login',
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Divider with "OR"
                      Row(
                        children: [
                          const Expanded(child: Divider(thickness: 1, color: Colors.blueGrey)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('OR', style: TextStyle(color: Colors.blueGrey[700])),
                          ),
                          const Expanded(child: Divider(thickness: 1, color: Colors.blueGrey)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Google Sign-In Button
                      ElevatedButton.icon(
                        icon: Image.asset(
                          'assets/Googlelogo.png', // Ensure you have this asset
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50), // Full width button
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5.0,
                        ),
                        onPressed: _isLoading ? null : _signInWithGoogle, // Disable button when loading
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
