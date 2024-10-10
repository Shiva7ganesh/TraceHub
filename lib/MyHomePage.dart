import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/AdminApprovalTab.dart';
import 'package:lostandfound/app_state.dart';
import 'founditemspage.dart'; // Import FoundItemsPage widget here
import 'lostitemspage.dart'; // Import LostItemsPage widget here
import 'UserProfilePage.dart'; // Import UserProfilePage widget here

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost & Found App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool isAdmin = false;
  List<String> _adminEmails = [];

  List<Widget> _widgetOptions() => <Widget>[
    LostItemsPage(),
    FoundItemsPage(),
    AppState().isAdmin ? AdminApprovalTab() : UserProfilePage()
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _fetchAdminEmails() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(minutes: 1),
    ));
    await remoteConfig.fetchAndActivate();
    String adminEmailsString = remoteConfig.getString('admin_emails');
    _adminEmails = adminEmailsString.split(',').map((email) => email.trim()).toList();
  }

  Future<void> _checkAdminStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _fetchAdminEmails();
      setState(() {
        isAdmin = _adminEmails.contains(user.email);
      });
      if (isAdmin) {
        AppState().isAdmin = true;
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trace Hub'),
        automaticallyImplyLeading: false,
      ),
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Lost Items',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Found Items',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppState().isAdmin ? 'Approvals' : 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
