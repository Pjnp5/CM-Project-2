import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uachado/screens/add_screen.dart';
import 'package:uachado/screens/home_screen.dart';

import 'constants/app_theme.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? name = prefs.getString('name');
  if (kDebugMode) {
    print(name);
  }
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (isLoggedIn) {
      runApp(
        ChangeNotifierProvider(
          create: (context) => MyAppState(),
          child: MyApp(loggedIn: true),
        ),
      );
    } else {
      runApp(
        ChangeNotifierProvider(
          create: (context) => MyAppState(),
          child: MyApp(loggedIn: false),
        ),
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization failed: $e');
    }
    // Handle the error or show an error message to the user
  }
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: Consumer<MyAppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            home: Scaffold(
              body: appState.currentPage,
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: appState.currentIndex,
                onTap: (index) {
                  appState.currentIndex = index;
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Define your pages here
  final List<Widget> pages = [
    HomeScreen(), // First page
    AddScreen(), // Second page
  ];

  Widget get currentPage => pages[_currentIndex];
}
