import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/MyHomePage.dart';
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
    Timer(const Duration(seconds: 2), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ));
      }
    });

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = '"DISCOVER THE LOST,. RETURN THE FOUND"';
    final parts = text.split('.'); // Split text into two parts based on comma
    final firstPart = parts[0];
    final secondPart =
    parts.length > 1 ? parts[1] : ''; // Handle case when there's no comma

    return Scaffold(
      backgroundColor: Colors.black, // Change the background color as needed
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(milliseconds: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/splash_image.png', // Replace 'splash_image.jpg' with your image asset
                width: 2000, // Adjust width as needed
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  Text(
                    firstPart.trim(),
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily:
                      'HandwrittenFont', // Change text color as needed
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    secondPart.trim(),
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white, // Change text color as needed
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
