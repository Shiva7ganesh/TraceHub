import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/MyHomePage.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
          ));
    });
  }

  Widget build(BuildContext context) {
    final text = '"DISCOVER THE LOST,. RETURN THE FOUND"';
    final parts = text.split('.'); // Split text into two parts based on comma
    final firstPart = parts[0];
    final secondPart =
        parts.length > 1 ? parts[1] : ''; // Handle case when there's no comma

    return Scaffold(
      backgroundColor: Colors.white, // Change the background color as needed
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/loginpage.png', // Replace 'splash_image.jpg' with your image asset
              width: 2000, // Adjust width as needed
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  firstPart.trim(),
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontFamily:
                        'HandwrittenFont', // Change text color as needed
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  secondPart.trim(),
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black, // Change text color as needed
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
