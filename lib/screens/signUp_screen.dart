import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    // Check for empty fields
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill in all fields"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Validate email format
    RegExp emailRegexp = RegExp(r'^\S+@\S+\.\S+$');
    if (!emailRegexp.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter a valid email address"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Password strength and length check
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Password should be at least 6 characters long"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Passwords do not match"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      UserModel newUser = UserModel(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        dep: false,
      );
      await FirebaseFirestore.instance. collection('users').doc(userCredential.user?.uid).set(newUser.toMap());

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', _emailController.text.trim());
      await prefs.setString('name', _nameController.text.trim());


      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Account created successfully!"),
        backgroundColor: Colors.green,
      ));

      // Navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()), // Replace HomeScreen with your home screen widget
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Error during sign up";
      if (e.code == 'email-already-in-use') {
        errorMessage = "The email address is already in use";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is invalid";
      }
      // Add more FirebaseAuthException handling as needed

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An unknown error occurred"),
        backgroundColor: Colors.red,
      ));
    }
  }


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
                _buildTextField(context, Icons.person, 'Full Name', controller: _nameController),
                const SizedBox(height: 16),
                _buildTextField(context, Icons.email, 'Email', controller: _emailController),
                const SizedBox(height: 16),
                _buildTextField(context, Icons.lock, 'Password', isPassword: true, controller: _passwordController),
                const SizedBox(height: 16),
                _buildTextField(context, Icons.lock, 'Confirm Password', isPassword: true, controller: _confirmPasswordController),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    signUp();
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
                    Navigator.of(context).pop();
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

  Widget _buildTextField(BuildContext context, IconData icon, String hint, {bool isPassword = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
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
