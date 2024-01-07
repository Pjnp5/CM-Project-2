import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uachado/models/item.dart';

import '../constants/app_theme.dart';
import '../utils/custom_drawer.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  String? _selectedTag; // Make _selectedTag nullable
  final List<String> _tags = [];
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false; // New variable to track loading state
  String dep_id = "";
  String _userName = '';
  String _userEmail = '';
  bool _personel = false;

  @override
  void initState() {
    super.initState();
    _fetchTags(); // Fetch tags from Firestore on init
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName =
          prefs.getString('name') ?? 'User Name'; // Default name if not found
      _userEmail = prefs.getString('email') ??
          'user@example.com'; // Default email if not found
      List<String> parts = _userEmail.split("@");
      setState(() {
        dep_id = parts[0];
      });
      _personel = prefs.getBool('personnel') ?? false;
    });
  }

  Future<void> _fetchTags() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('tags').get();
    _tags.clear(); // Clear existing tags
    for (var doc in querySnapshot.docs) {
      _tags.add(doc.data()['tag']);
    }
    setState(() {});
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await uploadImage(imageFile);
      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      backgroundColor: appTheme.colorScheme.secondary,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.photo_library,
                      color: appTheme.colorScheme.primary),
                  title: Text('Photo Library',
                      style: TextStyle(color: appTheme.colorScheme.primary)),
                  onTap: () {
                    _getImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: Icon(Icons.photo_camera,
                    color: appTheme.colorScheme.primary),
                title: Text('Camera',
                    style: TextStyle(color: appTheme.colorScheme.primary)),
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

  Future<String> uploadImage(File imageFile) async {
    String fileName =
        'images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> submitItem() async {
    if (_imageFile == null ||
        _selectedTag == null ||
        _descriptionController.text.isEmpty) {
      _showSnackBar('All fields are required.', Colors.red);
      return;
    }

    setState(() => _isLoading = true); // Start loading

    try {
      String imageUrl = await uploadImage(_imageFile!);

      Item newItem = Item(
        description: _descriptionController.text,
        tag: _selectedTag!,
        imageUrl: imageUrl,
        dep_stored: dep_id,
        dateAdded: DateTime.now(),
        // Add current date
        is_retrieved: false,
      );

      await saveItemData(newItem.toJson());
      _showSnackBar('Item uploaded successfully', Colors.green);

      // After uploading, send a notification to users interested in the tag
      sendNotificationToFlask(newItem.tag, 'New Item Available',
          'A new item has been added', imageUrl);

      _resetForm();
    } catch (e) {
      _showSnackBar('Error uploading item: $e', Colors.red);
    }

    setState(() => _isLoading = false); // End loading
  }

  Future<void> sendNotificationToFlask(
      String topic, String title, String message, String imageUrl) async {
    const url = 'YOUR_FLASK_SERVER_URL/sendNotification';
    final headers = {'Content-Type': 'application/json'};
    final body = {
      'topic': topic,
      'title': title,
      'message': message,
      'image_url': imageUrl,
    };

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _resetForm() {
    _descriptionController.clear();
    _selectedTag = null;
    _imageFile = null;
    setState(() {});
  }

  Future<void> saveItemData(Map<String, dynamic> itemData) async {
    CollectionReference items = FirebaseFirestore.instance.collection('items');
    return items
        .add(itemData)
        .then((value) => print("Item Added"))
        .catchError((error) => print("Failed to add item: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item', style: appTheme.textTheme.titleLarge),
        backgroundColor: const Color(0xFFcab6aa), // Use appTheme colors
      ),
      backgroundColor: appTheme.colorScheme.secondary,
      endDrawer: CustomDrawer(
        userName: _userName,
        userEmail: _userEmail,
        personel: _personel,
        onItemsListScreen: false,
        onDropPoints: false,
        onFoundItem: true,
        onItemRetrieved: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              DropdownButton<String>(
                dropdownColor: appTheme.colorScheme.secondary,
                hint: Text('Select Tag', style: appTheme.textTheme.bodyLarge),
                value: _selectedTag,
                onChanged: (newValue) {
                  setState(() {
                    _selectedTag = newValue;
                  });
                },
                items: _tags.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: appTheme.textTheme.bodyLarge),
                  );
                }).toList(),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(
                    color: appTheme.colorScheme.primary, // Initial label color
                  ),
                  floatingLabelStyle: TextStyle(
                    color: appTheme.colorScheme.primary, // Focused label color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          appTheme.colorScheme.primary, // Initial border color
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: appTheme
                            .colorScheme.primary), // Focused border color
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: appTheme.colorScheme.primary,
                        backgroundColor: appTheme.colorScheme.secondary,
                        // Text color
                        elevation: 4,
                        // Add more shadow
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Add Picture',
                          style: appTheme.textTheme.labelLarge
                              ?.copyWith(color: appTheme.colorScheme.primary)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _imageFile == null
                        ? Text('No Image Selected',
                            style: appTheme.textTheme.bodyLarge
                                ?.copyWith(color: appTheme.colorScheme.primary),
                            textAlign: TextAlign.center)
                        : Image.file(_imageFile!, height: 100),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitItem,
                style: ElevatedButton.styleFrom(
                  foregroundColor: appTheme.colorScheme.primary,
                  backgroundColor: appTheme.colorScheme.secondary,
                  // Text color
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 4,
                ),
                child: Text('Submit',
                    style: appTheme.textTheme.labelLarge
                        ?.copyWith(color: appTheme.colorScheme.primary)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _isLoading
          ? CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(appTheme.colorScheme.primary),
            ) // Show loading indicator when processing
          : null,
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFFcab6aa),
      selectedItemColor: appTheme.colorScheme.primary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
