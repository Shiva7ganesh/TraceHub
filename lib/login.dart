// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Login Page',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LoginPage(),
//     );
//   }
// }
//
// class LoginPage extends StatelessWidget {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   Future<User?> _signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
//       final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
//
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleSignInAuthentication.accessToken,
//         idToken: googleSignInAuthentication.idToken,
//       );
//
//       final UserCredential userCredential = await _auth.signInWithCredential(credential);
//       final User? user = userCredential.user;
//
//       if (user != null) {
//         // Ask for additional information
//         await _askAdditionalInfo(user);
//       }
//
//       return user;
//     } catch (error) {
//       print(error);
//       return null;
//     }
//   }
//
//   Future<void> _askAdditionalInfo(User user) async {
//     // Display a dialog to ask for additional info like roll number and phone number
//     String? rollNo = await showDialog<String>(
//       context: null, // You need to replace null with your context
//       builder: (context) => AlertDialog(
//         title: Text('Additional Information'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               decoration: InputDecoration(labelText: 'Roll Number'),
//               onChanged: (value) => rollNo = value,
//             ),
//             TextField(
//               decoration: InputDecoration(labelText: 'Phone Number'),
//               onChanged: (value) => {} /* You can handle phone number here */,
//             ),
//           ],
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, rollNo),
//             child: Text('Submit'),
//           ),
//         ],
//       ),
//     );
//
//     if (rollNo != null) {
//       // Store additional info in Firestore
//       FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//         'rollNo': rollNo,
//         // Add more fields as needed
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _signInWithGoogle,
//               child: Text('Sign in with Google'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Implement email/password sign up for admin
//               },
//               child: Text('Sign up with Email'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
