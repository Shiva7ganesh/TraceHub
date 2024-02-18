import 'package:flutter/material.dart';
import 'package:lostandfound/SplashScreen.dart'; // Import your HomePage widget here

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost & Found App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Set your HomePage as the home screen
    );
  }
}
