import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uachado/screens/signUp_screen.dart';
import 'package:uachado/utils/emerging_zoom_fade_route.dart';

import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFcab6aa), Color(0xFFe7d4ca)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 48),
                Text(
                  'Welcome to UAchado',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                _buildTextField(
                    context, Icons.person, 'Username', _emailController),
                const SizedBox(height: 16),
                _buildTextField(
                    context, Icons.lock, 'Password', _passwordController,
                    isPassword: true),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    signIn(_emailController.text.trim(),
                        _passwordController.text.trim(), context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFFcab6aa),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 12),
                  ),
                  child: const Text('Login',
                      style: TextStyle(color: Color(0xFFcab6aa))),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        EmergingZoomFadeRoute(page: const SignUpScreen()));
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                      color: Colors.white70,
                      decoration: TextDecoration.none,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, IconData icon, String hint,
      TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white70),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        fillColor: Colors.white24,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter both email and password"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Assuming the user ID is the document ID in Firestore
      String userId = userCredential.user?.uid ?? '';
      if (kDebugMode) {
        print(userId);
      }

      // Fetch user data from Firestore
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', email);
      await prefs.setString('name', fetchUserNameByEmail(email).toString());

      // After successful login, navigate to the main screen or dashboard
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Successfull login!"),
        backgroundColor: Colors.green,
      ));
      // Navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                const HomeScreen()), // Replace HomeScreen with your home screen widget
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      String errorMessage;
      if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else if (e.code == 'user-not-found') {
        errorMessage = "User not found.";
      } else {
        errorMessage = "An error occurred: ${e.message}";
      }
      // Add more FirebaseAuthException handling as needed

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An unknown error occurred"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<String> fetchUserNameByEmail(String email) async {
    try {
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return userQuery.docs.first.data()['name'] ?? 'No Name';
      } else {
        return 'No Name'; // Or handle the case when no user is found
      }
    } catch (e) {
      // Handle or log error
      return 'Error: ${e.toString()}';
    }
  }

}
