import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lostandfound/MyHomePage.dart';
import '../../../MaintenanceScreen.dart';
import '../../user_auth/presentation/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    _checkForUpdateAndNavigate();
  }

  Future<void> _checkForUpdateAndNavigate() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval: Duration(minutes: 1),
      ));
      await remoteConfig.fetchAndActivate();

      bool isMaintenanceMode = remoteConfig.getBool('maintenance_mode');
      int minRequiredVersion = remoteConfig.getInt('min_required_version');
      int currentVersion = await _getCurrentVersion();

      if (isMaintenanceMode) {
        _showMaintenanceScreen();
      } else if (currentVersion < minRequiredVersion) {
        _showUpdateRequiredScreen();
      } else {
        _navigateToNextScreen();
      }
    } catch (e) {
      print('Remote Config fetch failed: $e');
      // Proceed with navigation even if update check fails
      _navigateToNextScreen();
    }
  }

  Future<int> _getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return int.parse(packageInfo.buildNumber);
  }

  void _showMaintenanceScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MaintenanceScreen()),
    );
  }

  void _showUpdateRequiredScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UpdateRequiredScreen()),
    );
  }

  void _navigateToNextScreen() {
    // Simulate some delay to showcase the splash screen
    Future.delayed(Duration(seconds: 2), () {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(milliseconds: 800),
          child: Image.asset(
            'assets/loginpage.png', // Replace with your image asset
            width: 200, // Adjust width as needed
            height: 200, // Adjust height as needed
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class UpdateInfo {
  final List<Update> updates;

  UpdateInfo({required this.updates});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    var list = json['updates'] as List;
    List<Update> updatesList = list.map((i) => Update.fromJson(i)).toList();
    return UpdateInfo(updates: updatesList);
  }
}

class Update {
  final int version;
  final int updatePriority;

  Update({required this.version, required this.updatePriority});

  factory Update.fromJson(Map<String, dynamic> json) {
    return Update(
      version: json['version'],
      updatePriority: json['updatePriority'],
    );
  }
}

int getUpdatePriority(int currentAppVersion, UpdateInfo info) {
  final mostImportantUpdates = info.updates
      .where((update) => update.version > currentAppVersion)
      .toList();

  mostImportantUpdates.sort((a, b) => b.updatePriority.compareTo(a.updatePriority));

  return mostImportantUpdates.isNotEmpty ? mostImportantUpdates.first.updatePriority : 0;
}
