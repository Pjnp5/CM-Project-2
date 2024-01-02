import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FoundItemsScreen extends StatefulWidget {
  const FoundItemsScreen({super.key});

  @override
  _FoundItemsScreenState createState() => _FoundItemsScreenState();
}

class _FoundItemsScreenState extends State<FoundItemsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchFoundItems(); // Fetch items when the screen loads
  }

  Future<List<Map<String, dynamic>>> _fetchFoundItems() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('isRetrieved', isEqualTo: false)
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
      var departmentName = department['Nome']
          .replaceAll(
          RegExp(r'[^A-Za-z ]'), '') // Remove non-alphabetic characters
          .split(' ')
          .where(
              (word) => word.isNotEmpty && word[0] == word[0].toUpperCase())
          .map((word) => word[0].toUpperCase())
          .join();

      if (departmentName
          .length >
          2) {
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
      appBar: AppBar(title: const Text('Found Items')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFoundItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
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
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
            child: Image.network(
              item['image_url'],
              width: 100,
              height: 100, // Fixed height for all images
              fit: BoxFit.cover,
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Stored at: ${item['departmentName']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tag: ${item['tag']}',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
