import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uachado/constants/app_theme.dart';
import 'package:uachado/screens/login_screen.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.colorScheme.secondary,
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: const Color(0xFFcab6aa), // Use appTheme colors
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProfileInfo(context),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => _signOut(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator(); // Loading indicator
        }

        final prefs = snapshot.data!;
        final name = prefs.getString('name') ?? 'User Name';
        final email = prefs.getString('email') ?? 'user@example.com';
        final isPersonnel = prefs.getBool('personnel') ?? false;

        // Generate initials for the user's avatar
        final initials = name.isEmpty
            ? '?'
            : name.split(' ').map((word) => word[0]).take(2).join('');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: appTheme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              email,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (isPersonnel)
              Text(
                'Personnel Account',
                style: TextStyle(
                  fontSize: 16,
                  color: appTheme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (!isPersonnel)
              Text(
                'User Account',
                style: TextStyle(
                  fontSize: 16,
                  color: appTheme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20), // Additional space
          ],
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      // Handle errors or show an alert to the user
    }
  }
}
