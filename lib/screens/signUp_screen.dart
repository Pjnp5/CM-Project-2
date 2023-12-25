import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
                const SizedBox(height: 32),
                Text(
                  'Create your UAchado Account',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(context, Icons.person, 'Full Name'),
                const SizedBox(height: 16),
                _buildTextField(context, Icons.email, 'Email'),
                const SizedBox(height: 16),
                _buildTextField(context, Icons.lock, 'Password', isPassword: true),
                const SizedBox(height: 16),
                _buildTextField(context, Icons.lock, 'Confirm Password', isPassword: true),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Add sign-up logic here
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFFcab6aa), backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  ),
                  child: const Text('Sign Up', style: TextStyle(color: Color(0xFFcab6aa), fontSize: 20)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // or Navigator.of(context).pushReplacement(FadeRoute(page: const LoginScreen())); to go back with an animation
                  },
                  child: const Text(
                    'Already have an account?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      decoration: TextDecoration.none,
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
      {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white70, fontSize: 16),
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
