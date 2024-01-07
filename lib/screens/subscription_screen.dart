import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_theme.dart';
import '../utils/custom_drawer.dart';
import '../utils/notification_system.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<String> selectedTags = []; // Store the selected tags
  List<String> tags = []; // Available tags
  String _userName = '';
  String _userEmail = '';
  bool _personnel = false;
  late FCMService fcmService; // Declare an instance of FCMService
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  // Map to associate tags with their corresponding icons
  final Map<String, IconData> tagIcons = {
    'Óculos': Icons.visibility,
    'Chapéu': Icons.wb_sunny,
    'Outra': Icons.category, // Default icon for tags without a specific icon
    'Mala': Icons.luggage,
    'Carteira': Icons.wallet_membership,
    'Garrafa Térmica': Icons.thermostat,
    'Chaveiro': Icons.vpn_key,
    'Livro': Icons.book,
    'Guarda-Chuva': Icons.umbrella,
    'Sapatilhas': Icons.directions_run,
    'Relógio': Icons.watch,
  };

  @override
  void initState() {
    super.initState();
    _fetchTags(); // Fetch tags when the screen loads
    _loadUserInfo();
    fcmService = FCMService(scaffoldKey: scaffoldKey);
    fcmService.initialize();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName =
          prefs.getString('name') ?? 'User Name'; // Default name if not found
      _userEmail = prefs.getString('email') ??
          'user@example.com'; // Default email if not found
      _personnel = prefs.getBool('personnel') ?? false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscribe to Tags', style: appTheme.textTheme.titleLarge),
        backgroundColor: const Color(0xFFcab6aa), // Use appTheme colors
      ),
      backgroundColor: appTheme.colorScheme.secondary,
      endDrawer: CustomDrawer(
        userName: _userName,
        userEmail: _userEmail,
        personel: _personnel,
        onItemsListScreen: true,
        onDropPoints: false,
        onFoundItem: false,
        onItemRetrieved: false,
      ),
      body: ListView.builder(
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = selectedTags.contains(tag);
          final iconData = tagIcons[tag] ?? Icons.category; // Default icon

          return ListTile(
            leading: Icon(
              iconData,
              color: isSelected ? appTheme.colorScheme.primary : Colors.grey,
            ),
            title: Row(
              children: [
                Text(tag, style: const TextStyle(fontSize: 18.0)),
                const SizedBox(width: 8.0),
                Icon(
                  iconData,
                  color:
                      isSelected ? appTheme.colorScheme.primary : Colors.grey,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedTags.remove(tag);
                } else {
                  selectedTags.add(tag);
                }
              });
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              if (selectedTags.isNotEmpty) {
                fcmService.subscribeToTopic(selectedTags);
                showSnackbar('Subscribed', 'Subscribed to all selected topics!');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.colorScheme.secondary,
            ),
            child: Text('Subscribe',
                style: TextStyle(color: appTheme.colorScheme.primary)),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              fcmService.unsubscribeFromTopics(tags);
              showSnackbar('Unsubscribed', 'Unsubscribed from all topics!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Unsubscribe All',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  void showSnackbar(String title, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    scaffoldKey.currentState?.showSnackBar(snackBar);
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFFcab6aa), // Use appTheme colors
      selectedItemColor: appTheme.colorScheme.primary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
