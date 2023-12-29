import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'droppoints_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<String> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? 'User';
  }

  Future<List<Map<String, dynamic>>> _fetchNonRetrievedItems() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('isRetrieved', isEqualTo: false)
        .limit(5) // Adjust this limit as needed
        .get();

    List<Map<String, dynamic>> itemsWithDepartment = [];
    for (var doc in querySnapshot.docs) {
      var item = doc.data() as Map<String, dynamic>;
      String depStored = item['dep_stored'];

      // Fetch department data
      DocumentSnapshot departmentSnapshot = await FirebaseFirestore.instance
          .collection('departments')
          .doc(depStored)
          .get();

      var department = departmentSnapshot.data() as Map<String, dynamic>;
      item['departmentName'] =
          department['Nome']; // Add department name to item

      itemsWithDepartment.add(item);
    }

    return itemsWithDepartment;
  }

  Widget _buildFeatureCard(String title, IconData icon, String description,
      BuildContext context, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLatestItemsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchNonRetrievedItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No recent items found');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Latest Items',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...snapshot.data!.map((item) {
              // Extract initials (capital letters) from the department name
              String departmentName = item['departmentName'];
              String initials = '';
              if (departmentName
                      .replaceAll(RegExp(r'[^A-Za-z ]'), '')
                      .split(' ')
                      .length >
                  2) {
                initials = departmentName
                    .replaceAll(RegExp(r'[^A-Za-z ]'),
                        '') // Remove non-alphabetic characters
                    .split(' ')
                    .where((word) =>
                        word.isNotEmpty && word[0] == word[0].toUpperCase())
                    .map((word) => word[0].toUpperCase())
                    .join();
              }

              return ListTile(
                title: Text(item['description']),
                subtitle: Text('Stored at: $initials'), // Display initials
                leading: item['image_url'] != null
                    ? Image.network(item['image_url'], width: 50, height: 50)
                    : const Icon(Icons
                        .image_not_supported), // Display an icon if no image
              );
            }),
          ],
        );
      },
    );
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
              FutureBuilder<String>(
                future: _loadUserName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    return Text(
                      'Welcome, ${snapshot.data}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'Locate Item Drop Points',
                Icons.map,
                'Find nearby locations to leave or pick up items',
                context,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DropOffPointsScreen())),
              ),
              _buildFeatureCard(
                'View Items',
                Icons.view_list,
                'Browse through items reported in the system',
                context,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DropOffPointsScreen())),
              ),
              _buildFeatureCard(
                'Report Lost Item',
                Icons.report_problem,
                'Report an item you have lost',
                context,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DropOffPointsScreen())),
              ),
              const SizedBox(height: 20),
              _buildLatestItemsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
