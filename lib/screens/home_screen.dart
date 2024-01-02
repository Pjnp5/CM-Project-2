import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uachado/main.dart';
import 'droppoints_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

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

  Future<String?> _getLocalImagePath(String imageUrl) async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    String fileName = path.basename(imageUrl);
    File localFile = File(path.join(documentDirectory.path, fileName));

    return localFile.existsSync() ? localFile.path : null;
  }

  Future<String> _downloadAndSaveImage(String imageUrl, String fileName) async {
    var response = await http.get(Uri.parse(imageUrl));
    var documentDirectory = await getApplicationDocumentsDirectory();
    File file = File(path.join(documentDirectory.path, fileName));
    file.writeAsBytesSync(response.bodyBytes);
    return file.path;
  }

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Connected to a mobile network or wifi
    } else {
      return false; // No internet connection
    }
  }

  Future<List<Map<String, dynamic>>> _fetchNonRetrievedItems() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasInternet =
        await _checkInternetConnection(); // Implement this function to check internet connectivity

    if (hasInternet) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('isRetrieved', isEqualTo: false)
          .limit(5)
          .get();

      List<Map<String, dynamic>> itemsWithDepartment = [];
      for (var doc in querySnapshot.docs) {
        var item = doc.data() as Map<String, dynamic>;
        String depStored = item['dep_stored'];
        DocumentSnapshot departmentSnapshot = await FirebaseFirestore.instance
            .collection('departments')
            .doc(depStored)
            .get();
        var department = departmentSnapshot.data() as Map<String, dynamic>;
        item['departmentName'] = department['Nome'];

        // Check if the image is already downloaded
        String imageUrl = item['image_url'];
        String fileName = path.basename(imageUrl);
        String? localImagePath = await _getLocalImagePath(imageUrl);

        // If not, download and save the image
        localImagePath ??= await _downloadAndSaveImage(imageUrl, fileName);

        item['localImagePath'] = localImagePath; // Save the local image path
        itemsWithDepartment.add(item);
      }

      // Store fetched data in SharedPreferences
      await prefs.setString('lastItems', jsonEncode(itemsWithDepartment));
      await prefs.setString('lastFetchTime', DateTime.now().toIso8601String());

      return itemsWithDepartment;
    } else {
      if (prefs.containsKey('lastItems')) {
        // Deserialize and return the stored items
        String storedItemsJson = prefs.getString('lastItems')!;
        List storedItems = jsonDecode(storedItemsJson) as List;
        return storedItems.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception(
            'No internet connection. Please connect to the internet to fetch latest items.');
      }
    }
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
                leading: FutureBuilder(
                  future: _getLocalImagePath(item['image_url']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data != null) {
                      String imagePath = snapshot.data
                          as String; // Cast to non-nullable String
                      return Image.file(File(imagePath), width: 50, height: 50);
                    } else {
                      return Image.network(item['image_url'],
                          width: 50, height: 50);
                    }
                  },
                ),
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
      //bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final appState = Provider.of<MyAppState>(context);

    return BottomNavigationBar(
      currentIndex: appState.currentIndex,
      onTap: (index) {
        appState.currentIndex = index;
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Add'),
      ],
    );
  }
}
