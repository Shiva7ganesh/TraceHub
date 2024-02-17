import 'package:flutter/material.dart';
import 'package:lostandfound/MyHomePage.dart';
import 'package:lostandfound/log_in.dart'; // Import your HomePage widget here

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
      home: LoginDemo(), // Set your HomePage as the home screen
    );
  }
}
