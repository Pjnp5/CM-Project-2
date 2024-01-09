import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_theme.dart';
import '../utils/custom_drawer.dart';

class RetrievedItemScreen extends StatefulWidget {
  const RetrievedItemScreen({super.key});

  @override
  _FoundItemsScreenState createState() => _FoundItemsScreenState();
}

class _FoundItemsScreenState extends State<RetrievedItemScreen> {
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
    List<Map<String, dynamic>> items = [];
    try {
      String dep_id = _userEmail.split("@")[0];
      var query = FirebaseFirestore.instance
          .collection('items')
          .where('isRetrieved', isEqualTo: false)
          .where('dep_stored', isEqualTo: dep_id)
          .orderBy("dateAdded", descending: true);
      if (selectedTag != 'Todos') {
        query = query.where('tag', isEqualTo: selectedTag);
      }
      QuerySnapshot querySnapshot = await query.get();

      itemsWithDepartment.clear();

      for (var doc in querySnapshot.docs) {
        var item = doc.data() as Map<String, dynamic>;
        item['id'] = doc.id;
        String depStored = item['dep_stored'];
        DocumentSnapshot departmentSnapshot = await FirebaseFirestore.instance
            .collection('departments')
            .doc(depStored)
            .get();
        var department = departmentSnapshot.data() as Map<String, dynamic>;
        var departmentName = department['Nome']
            .replaceAll(
                RegExp(r'[^A-Za-z ]'), '') // Remove non-alphabetic characters
            .split(' ')
            .where(
                (word) => word.isNotEmpty && word[0] == word[0].toUpperCase())
            .map((word) => word[0].toUpperCase())
            .join();

        if (departmentName.length > 2) {
          item['departmentName'] = departmentName;
        } else {
          item['departmentName'] = department['Nome'];
        }
        items.add(item);
      }

      // Call setState to trigger a rebuild of the UI
      return items;
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching items: $error");
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_userName Inventory'),
        backgroundColor: const Color(0xFFcab6aa),
      ),
      backgroundColor: appTheme.colorScheme.secondary,
      endDrawer: CustomDrawer(
        userName: _userName,
        userEmail: _userEmail,
        personel: _personel,
        onItemsListScreen: false,
        onDropPoints: false,
        onFoundItem: false,
        onItemRetrieved: true,
        onSub: false,
      ),
      body: Column(
        children: [
          Center(
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
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              color: appTheme.colorScheme.primary,
              onRefresh: () async {
                setState(() async {
                  itemsWithDepartment.clear();
                  itemsWithDepartment = await _fetchFoundItems();
                });
              },
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchFoundItems(), // This should remain here
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        backgroundColor: appTheme.colorScheme.primary,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          appTheme
                              .colorScheme.secondary, // Adjust color as needed
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
                        final item = snapshot.data![index];
                        return _buildItemCard(item);
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
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
                  color: appTheme.colorScheme.primary, // Adjust color as needed
                );
              },
            ),
          ),
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
                  const SizedBox(height: 3),
                  Text(
                    'Tag: ${item['tag']}',
                    style: TextStyle(
                        color: appTheme
                            .colorScheme.primary), // Adjust color as needed
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFFcab6aa)),
                    ),
                    onPressed: () {
                      _markItemAsRetrieved(item); // Mark the item as retrieved
                    },
                    child: Text('Mark as Retrieved',
                        style: TextStyle(color: appTheme.colorScheme.primary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markItemAsRetrieved(Map<String, dynamic> item) async {
    try {
      // Update the Firestore document to mark the item as retrieved
      await FirebaseFirestore.instance
          .collection('items')
          .doc(item['id']) // Use the item's document ID
          .update({'isRetrieved': true, 'retrievedTimestamp': DateTime.now()});

      // Show a success message or perform any other necessary actions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Item marked as retrieved successfully.'),
        ),
      );

      final updatedItems = await _fetchFoundItems();
      setState(() {
        // Update the list of items with the newly fetched data
        itemsWithDepartment = updatedItems;
      });
    } catch (error) {
      // Handle any errors that occur during the process
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error marking item as retrieved.'),
        ),
      );
    }
  }
}
