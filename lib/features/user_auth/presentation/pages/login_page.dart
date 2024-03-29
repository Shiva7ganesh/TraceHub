import 'package:flutter/material.dart';
import 'package:lostandfound/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:lostandfound/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:lostandfound/global/common/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? _selectedOrganization;
  bool _organizationDropdownError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Image.asset(
                  'assets/loginpage.png',
                  height: 150,
                  width: 150,
                ),
                SizedBox(height: 20),
                Text(
                  "Login",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _organizationDropdownError ? Colors.red[100] : Colors
                        .white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedOrganization,
                    onChanged: (value) {
                      setState(() {
                        _selectedOrganization = value;
                        _organizationDropdownError = false;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          _organizationDropdownError = true;
                        });
                        return 'Please select organization';
                      }
                      return null;
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'CMRIT',
                        child: Text('CMR Institute Of Technology, Hyderabad'),
                      ),
                      // Add more organizations as needed
                    ],
                    decoration: InputDecoration(
                      hintText: 'Select college/Organization',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Email",
                  isPasswordField: false,
                ),
                SizedBox(height: 10),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Password",
                  isPasswordField: true,
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _signIn();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: _isSigning
                          ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    _signInWithGoogle();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.google,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Sign in with Google",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Please use your organization email to login",
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?"),
                SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                          (route) => false,
                    );
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    if (_selectedOrganization == null || _selectedOrganization!.isEmpty) {
      setState(() {
        _organizationDropdownError = true;
        _isSigning = false;
      });
      showToast(message: "Please select organization");
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isSigning = false;
      });
      showToast(message: "Please enter email and password");
      return;
    }

    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
    }

    setState(() {
      _isSigning = false;
    });

    if (userCredential != null) {
      showToast(message: "User is successfully signed in");
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      showToast(message: "Some error occurred");
    }
  }

  _signInWithGoogle() async {
    setState(() {
      _isSigning = true; // Set the flag to indicate signing in process started
    });
    if (_selectedOrganization == null || _selectedOrganization!.isEmpty) {
      setState(() {
        _organizationDropdownError = true;
        _isSigning = false;
      });
      showToast(message: "Please select organization");
      return;
    }

    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn
          .signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);

        final String? email = userCredential.user!.email;
        final String? userId = userCredential.user!.uid;
        final String? username = userCredential.user!.displayName;

        if (email != null &&
            (email.endsWith('@cmrithyderabad.edu.in') ||
                email.endsWith('@cmrithyderabad.ac.in'))) {
          // Store user data in Firestore
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'email': email,
            'username': username,
            'organization': _selectedOrganization,
            // Add other fields as needed
          });

          Navigator.pushNamed(context, "/home");
        } else {
          // Sign out the user if the email is not valid
          await _googleSignIn.signOut();
          showToast(
              message: "Access denied. Please use a College email address.");
          // Reset the Google sign-in page
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      showToast(message: "Some error occurred: $e");
    } finally {
      setState(() {
        _isSigning =
        false; // Reset the signing flag after sign-in process is completed
      });
    }
  }
}