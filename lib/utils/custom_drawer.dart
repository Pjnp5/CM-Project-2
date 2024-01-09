import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_theme.dart';
import '../main.dart';
import '../screens/login_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final bool personel;
  final bool onItemsListScreen; // Add this variable
  final bool onFoundItem; // Add this variable
  final bool onDropPoints;
  final bool onItemRetrieved;
  final bool onSub;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.personel,
    required this.onItemsListScreen, // Initialize this variable
    required this.onFoundItem,
    required this.onDropPoints, // Initialize this variable
    required this.onItemRetrieved,
    required this.onSub,
  }); // Pass key parameter to super constructor

  void _navigateToItemsList(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    // Handle navigation to Items List screen
    Provider.of<MyAppState>(context, listen: false).currentIndex = 5;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              Provider.of<MyAppState>(context, listen: false).pages[5]),
    ).then((_) {
      // After navigating back from the new page, close the drawer if needed
      scaffoldKey.currentState?.closeEndDrawer();
    });
  }

  void _navigateToReportFoundItem(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    Provider.of<MyAppState>(context, listen: false).currentIndex = 3;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              Provider.of<MyAppState>(context, listen: false).pages[3]),
    ).then((_) {
      // After navigating back from the new page, close the drawer if needed
      scaffoldKey.currentState?.closeEndDrawer();
    });
  }

  void _navigateToDropPoints(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    Provider.of<MyAppState>(context, listen: false).currentIndex = 4;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              Provider.of<MyAppState>(context, listen: false).pages[4]),
    ).then((_) {
      // After navigating back from the new page, close the drawer if needed
      scaffoldKey.currentState?.closeEndDrawer();
    });
  }

  void _navigateToRetrieveItem(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    Provider.of<MyAppState>(context, listen: false).currentIndex = 2;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              Provider.of<MyAppState>(context, listen: false).pages[2]),
    ).then((_) {
      // After navigating back from the new page, close the drawer if needed
      scaffoldKey.currentState?.closeEndDrawer();
    });
  }

  void _navigateToNotifications(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    Provider.of<MyAppState>(context, listen: false).currentIndex = 6;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              Provider.of<MyAppState>(context, listen: false).pages[6]),
    ).then((_) {
      // After navigating back from the new page, close the drawer if needed
      scaffoldKey.currentState?.closeEndDrawer();
    });
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
                style: TextStyle(
                  fontSize: 40.0,
                  color: appTheme.colorScheme.primary,
                ),
              ),
            ),
            decoration: const BoxDecoration(color: Color(0xFFcab6aa)),
          ),
          if (!onItemsListScreen)
            ListTile(
              leading: Icon(Icons.list, color: appTheme.colorScheme.primary),
              title: const Text('Items List'),
              textColor: appTheme.colorScheme.primary,
              onTap: () {
                scaffoldKey.currentState
                    ?.closeEndDrawer(); // Close the right-end drawer
                _navigateToItemsList(context, scaffoldKey);
              },
            ),
          if (personel && !onFoundItem)
            ListTile(
              leading: Icon(Icons.report_problem,
                  color: appTheme.colorScheme.primary),
              title: const Text('Report Found Item'),
              textColor: appTheme.colorScheme.primary,
              onTap: () {
                _navigateToReportFoundItem(context, scaffoldKey);
              },
            ),
          if (personel && !onItemRetrieved)
            ListTile(
              leading: Icon(Icons.check, color: appTheme.colorScheme.primary),
              title: const Text('Mark Item as Found'),
              textColor: appTheme.colorScheme.primary,
              onTap: () {
                _navigateToRetrieveItem(context, scaffoldKey);
              },
            ),
          if (!personel && !onDropPoints)
            ListTile(
              leading: Icon(Icons.map, color: appTheme.colorScheme.primary),
              title: const Text('Locate Item Drop Points'),
              textColor: appTheme.colorScheme.primary,
              onTap: () {
                _navigateToDropPoints(context, scaffoldKey);
              },
            ),
          if (!personel && !onSub)
            ListTile(
              leading: Icon(Icons.warning, color: appTheme.colorScheme.primary),
              title: const Text('Report Lost Item'),
              textColor: appTheme.colorScheme.primary,
              onTap: () {
                _navigateToNotifications(context, scaffoldKey);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            textColor: Colors.red,
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
                        onPressed: () async {
                          // Clear user data or handle logout logic
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();
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
