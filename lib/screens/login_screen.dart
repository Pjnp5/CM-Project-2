import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uachado/screens/signUp_screen.dart';
import 'package:uachado/utils/emerging_zoom_fade_route.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                // Ensure the asset is added to your project.
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
                _buildTextField(context, Icons.person, 'Username'),
                const SizedBox(height: 16),
                _buildTextField(context, Icons.lock, 'Password',
                    isPassword: true),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Add login logic here
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
                    Navigator.of(context).push(EmergingZoomFadeRoute(page: const SignUpScreen()));
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
                // Add more widgets or styling as needed
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, IconData icon, String hint,
      {bool isPassword = false}) {
    return TextField(
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
}
