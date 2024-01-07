import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_theme.dart';
import '../utils/custom_drawer.dart';

class FoundItemsScreen extends StatefulWidget {
  const FoundItemsScreen({super.key});

  @override
  _FoundItemsScreenState createState() => _FoundItemsScreenState();
}

class _FoundItemsScreenState extends State<FoundItemsScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<Map<String, dynamic>> itemsWithDepartment = [];
  String? selectedTag = 'Todos'; // Default to 'All'
  List<String> tags = ['Todos']; // Initialize with 'All'
  String _userName = '';
  String _userEmail = '';
  bool _personel = false;

  @override
  void initState() {
    super.initState();
    _fetchTags(); // Fetch tags when the screen loads
    _fetchFoundItems(); // Fetch items when the screen loads
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName =
          prefs.getString('name') ?? 'User Name'; // Default name if not found
      _userEmail = prefs.getString('email') ??
          'user@example.com'; // Default email if not found
      _personel = prefs.getBool('personnel') ?? false;
    });
  }

  Future<void> _fetchTags() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('tags').get();
    for (var doc in querySnapshot.docs) {
      tags.add(doc.data()['tag'] as String);
    }
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _fetchFoundItems() async {
    var query = FirebaseFirestore.instance
        .collection('items')
        .where('isRetrieved', isEqualTo: false)
        .orderBy("dateAdded", descending: true);
    if (selectedTag != 'Todos') {
      query = query.where('tag', isEqualTo: selectedTag);
    }
    QuerySnapshot querySnapshot = await query.get();

    List<Map<String, dynamic>> itemsWithDepartment = [];
    for (var doc in querySnapshot.docs) {
      var item = doc.data() as Map<String, dynamic>;
      String depStored = item['dep_stored'];
      DocumentSnapshot departmentSnapshot = await FirebaseFirestore.instance
          .collection('departments')
          .doc(depStored)
          .get();
      print(item);
      var department = departmentSnapshot.data() as Map<String, dynamic>;
      var departmentName = department['Nome']
          .replaceAll(
              RegExp(r'[^A-Za-z ]'), '') // Remove non-alphabetic characters
          .split(' ')
          .where((word) => word.isNotEmpty && word[0] == word[0].toUpperCase())
          .map((word) => word[0].toUpperCase())
          .join();

      if (departmentName.length > 2) {
        item['departmentName'] = departmentName;
      } else {
        item['departmentName'] = department['Nome'];
      }
      itemsWithDepartment.add(item);
    }
    return itemsWithDepartment;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.colorScheme.secondary,
      appBar: AppBar(
        title: const Text('Found Items'),
        backgroundColor: const Color(0xFFcab6aa),
      ),
      endDrawer: CustomDrawer(
        userName: _userName,
        userEmail: _userEmail,
        personel: _personel,
        onItemsListScreen: true,
        onDropPoints: false,
        onFoundItem: false,
        onItemRetrieved: false,
      ),
      body: Column(
        children: [
          Center(
            // Center the dropdown
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: selectedTag,
                  items: tags.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTag = newValue;
                      _fetchFoundItems(); // Refetch items with the new tag
                    });
                  },
                  dropdownColor: appTheme.colorScheme.secondary
                      .withAlpha(230), // Set the dropdown background color
                )),
          ),
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              color: appTheme.colorScheme.primary,
              onRefresh: () async {
                setState(() async {
                  itemsWithDepartment.clear();
                  itemsWithDepartment = await _fetchFoundItems();
                  ;
                });
              },
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchFoundItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 200,
                      // Set the width to match the image width
                      height: 200,
                      // Set a fixed height for the CircularProgressIndicator
                      alignment: Alignment.center,
                      // Center the CircularProgressIndicator
                      child: CircularProgressIndicator(
                        backgroundColor: appTheme.colorScheme.primary,
                        // Background color
                        valueColor: AlwaysStoppedAnimation<Color>(
                          appTheme.colorScheme
                              .secondary, // Color of the indicator itself
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No items found");
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return _buildItemCard(snapshot.data![index]);
                      },
                    );
                  }
                },
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: appTheme.colorScheme.secondary,
      child: Row(
        children: [
          ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(10)),
              child: Image.network(
                item['image_url'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: appTheme.colorScheme.primary,
                  );
                },
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['description'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Stored at: ${item['departmentName']}',
                    style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tag: ${item['tag']}',
                    style: TextStyle(color: appTheme.colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
