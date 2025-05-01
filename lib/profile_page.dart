import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Get the currently logged-in user
  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E90FF), Color(0xFF4682B4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8.0,
              color: Colors.blue[900]!.withOpacity(0.7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Display user information if available
                    if (currentUser != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentUser!.email ?? 'N/A', // Display email or 'N/A'
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          // You can add more user information here if available (e.g., display name, photo URL)
                          // if (currentUser!.displayName != null) ...[
                          //   const SizedBox(height: 12),
                          //   Text(
                          //     'Name:',
                          //     style: TextStyle(
                          //       fontSize: 18,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.white70,
                          //     ),
                          //   ),
                          //   const SizedBox(height: 4),
                          //   Text(
                          //     currentUser!.displayName!,
                          //     style: TextStyle(
                          //       fontSize: 18,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ],
                          // if (currentUser!.photoURL != null) ...[
                          //   const SizedBox(height: 12),
                          //   Text(
                          //     'Profile Picture:',
                          //     style: TextStyle(
                          //       fontSize: 18,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.white70,
                          //     ),
                          //   ),
                          //   const SizedBox(height: 8),
                          //   CircleAvatar(
                          //     radius: 40,
                          //     backgroundImage: NetworkImage(currentUser!.photoURL!),
                          //   ),
                          // ],
                        ],
                      )
                    else
                      const Text(
                        'User not logged in.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
