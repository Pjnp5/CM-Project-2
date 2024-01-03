import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uachado/models/item.dart';
import 'dart:io';

import '../constants/app_theme.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  String? _selectedTag; // Make _selectedTag nullable
  final List<String> _tags = [
    'Carteira',
    'Relógio',
    'Mala',
    'Chaveiro'
  ]; // Example tags
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;


  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String imageUrl = await uploadImage(imageFile);
      await saveImageData(imageUrl);
      setState(() {
        _imageFile = imageFile;
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
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () {
                    _getImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
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

  Future<void> saveImageData(String imageUrl) async {
    CollectionReference images =
        FirebaseFirestore.instance.collection('images');
    return images
        .add({
          'url': imageUrl,
          // Add other data if necessary
        })
        .then((value) => print("Image Added"))
        .catchError((error) => print("Failed to add image: $error"));
  }



  Future<void> submitItem() async {
    if (_imageFile == null ||
        _selectedTag == null ||
        _descriptionController.text.isEmpty) {
      print('All fields are required.');
      return;
    }

    try {
      // Upload image to Firebase Storage
      String imageUrl = await uploadImage(_imageFile!);

      // Create an Item object
      Item newItem = Item(
        description: _descriptionController.text,
        tag: _selectedTag!,
        imageUrl: imageUrl,
      );

      // Save the item to Firestore
      await saveItemData(newItem.toJson());
      print('Item uploaded successfully');
    } catch (e) {
      print('Error uploading item: $e');
    }
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
        title: Text('Add Item', style: GoogleFonts.montserrat()),
        backgroundColor:
            const Color(0xFFcab6aa), // Use the same color as in HomeScreen
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Add New Item',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        'Montserrat' // Use the same font family as in HomeScreen
                    ),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                hint: const Text('Select Tag'),
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
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
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
                        foregroundColor: Colors.black, backgroundColor: Colors.grey,
                      ),
                      child: const Text('Add Picture'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _imageFile == null
                        ? const Text('No Image Selected', textAlign: TextAlign.center)
                        : Image.file(_imageFile!, height: 100),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitItem,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text('Submit', style: GoogleFonts.montserrat()),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
