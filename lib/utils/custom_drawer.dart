import 'package:flutter/material.dart';
import 'package:uachado/screens/add_screen.dart';
import 'package:uachado/screens/droppoints_screen.dart';
import 'package:uachado/screens/item_retrieved.dart';
import 'package:uachado/screens/subscription_screen.dart';

import '../screens/foundItems_screen.dart';
import '../screens/login_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final bool personel;
  final bool onItemsListScreen; // Add this variable
  final bool onFoundItem; // Add this variable
  final bool onDropPoints;
  final bool onItemRetrieved;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.personel,
    required this.onItemsListScreen, // Initialize this variable
    required this.onFoundItem,
    required this.onDropPoints, // Initialize this variable
    required this.onItemRetrieved,
  }); // Pass key parameter to super constructor

  void _navigateToItemsList(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    // Handle navigation to Items List screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FoundItemsScreen()),
    ).then((_) {
      // After navigating back from the new page, close the drawer if needed
      scaffoldKey.currentState?.closeEndDrawer();
    });
  }

  void _navigateToReportLostItem(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddScreen()),
    ).then((_) {
      // After navigating back from the new page, close the drawer if needed
      scaffoldKey.currentState?.closeEndDrawer();
    });
  }

  void _navigateToDropPoints(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DropOffPointsScreen()),
    ).then((_) {
      // After navigating back from the new page, close the drawer if needed
      scaffoldKey.currentState?.closeEndDrawer();
    });
  }

  void _navigateToRetrieveItem(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RetrievedItemScreen()),
    ).then((_) {
      // After navigating back from the new page, close the drawer if needed
      scaffoldKey.currentState?.closeEndDrawer();
    });
  }

  void _navigateToNotifications(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    ).then((_) {
      // After navigating back from the new page, close the drawer if needed
      scaffoldKey.currentState?.closeEndDrawer();
    });
  }

  void _navigateToSettings(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    // Handle navigation to Settings screen
    // ...
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0] : "U",
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: const BoxDecoration(color: Color(0xFFcab6aa)),
          ),
          if (!onItemsListScreen)
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Items List'),
              onTap: () {
                scaffoldKey.currentState
                    ?.closeEndDrawer(); // Close the right-end drawer
                _navigateToItemsList(context, scaffoldKey);
              },
            ),
          if (personel && !onFoundItem)
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Report Lost Item'),
              onTap: () {
                _navigateToReportLostItem(context, scaffoldKey);
              },
            ),
          if (personel && !onItemRetrieved)
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('Mark Item as Found'),
              onTap: () {
                _navigateToRetrieveItem(context, scaffoldKey);
              },
            ),
          if (!personel && !onDropPoints)
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Locate Item Drop Points'),
              onTap: () {
                _navigateToDropPoints(context, scaffoldKey);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Subscribe tag'),
            onTap: () {
              _navigateToNotifications(context, scaffoldKey);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        // Close the dialog
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Clear user data or handle logout logic
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
