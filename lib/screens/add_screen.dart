import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'droppoints_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  String? _selectedTag; // Make _selectedTag nullable
  final List<String> _tags = ['Tag1', 'Tag2', 'Tag3']; // Example tags
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;

  Future<String> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? 'User';
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Photo Library'),
                  onTap: () {
                    _getImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DropdownButton<String>(
              hint: Text('Select Tag'),
              value: _selectedTag,
              onChanged: (newValue) {
                setState(() {
                  _selectedTag = newValue;
                });
              },
              items: _tags.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Add Picture'),
            ),
            Container(
              height: 200,
              color: Colors.grey[300],
              child: _imageFile == null
                  ? Center(child: Text('No Image Selected'))
                  : Image.file(_imageFile!),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Submit logic
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
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
