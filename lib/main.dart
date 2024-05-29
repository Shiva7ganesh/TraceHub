import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:lostandfound/MyHomePage.dart';
import 'package:lostandfound/features/app/splash_screen/splash_screen.dart';
import 'package:lostandfound/features/user_auth/presentation/pages/login_page.dart';
import 'package:lostandfound/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:lostandfound/features/user_auth/presentation/pages/profilepage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCsHDQtI9DItQgSqwy45_y2xG9tDGxuER8",
        appId: "1:540215271818:web:8b22d4aee01acdce862873",
        messagingSenderId: "540215271818",
        projectId: "flutter-firebase-9c136",
        // Your web Firebase config options
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trace Hub',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => MyHomePage(),
      },
    );
  }
}