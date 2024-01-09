
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uachado/screens/login_screen.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
          child: ElevatedButton(
              child: const Text('Logout'), onPressed: () => _signOut(context))),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      // Handle errors or show an alert to the user
    }
  }
}
