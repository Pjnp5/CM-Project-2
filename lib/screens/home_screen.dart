import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    String retrievedName = prefs.getString('name') ?? 'User';
    setState(() {
      userName = retrievedName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UAchado', style: GoogleFonts.montserrat()),
        backgroundColor: const Color(0xFFcab6aa),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $userName',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildFeatureSection('Recent Finds', Icons.search, context),
              _buildFeatureSection('Report Lost Item', Icons.report_problem, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureSection(String title, IconData icon, BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: () {
          // Handle navigation or actions
        },
      ),
    );
  }
}
