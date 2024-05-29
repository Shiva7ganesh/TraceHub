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
  bool _isGoogleSigning = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? _selectedOrganization;
  bool _organizationDropdownError = false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenHeight * 0.02;
    double spacing = screenHeight * 0.01;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/loginpage.png',
                  height: screenHeight * 0.2,
                  width: screenWidth * 0.4,
                ),
              ),
              SizedBox(height: spacing * 2),
              Center(
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: screenHeight * 0.035, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: spacing * 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: padding),
                decoration: BoxDecoration(
                  color: _organizationDropdownError ? Colors.red[100] : Colors.white,
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
                    hintText: 'Select College/Organization',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: spacing * 2),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              SizedBox(height: spacing),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              SizedBox(height: spacing * 2),
              GestureDetector(
                onTap: _signIn,
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: _isSigning
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing),
              GestureDetector(
                onTap: _signInWithGoogle,
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: _isGoogleSigning
                        ? CircularProgressIndicator(color: Colors.white)
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.google,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Sign in with Google",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing * 2),
              Center(
                child: Text(
                  "Please use your organization email to login"
                ),
              ),
              SizedBox(height: spacing * 2),
              Center(
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
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Forgot password?"),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: _resetPassword,
                      child: Text(
                        "Reset here",
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      setState(() {
        _isSigning = false;
      });
      showToast(message: 'Failed with error code: ${e.code}');
      print(e.message);
      return;
    }

    if (userCredential != null) {
      if (!userCredential.user!.emailVerified) {
        setState(() {
          _isSigning = false;
        });
        showToast(message: "Please verify your email before logging in.");
        return;
      }

      showToast(message: "User is successfully signed in");
      _showPolicyDialog(); // Show the policy dialog before navigating to home
    } else {
      setState(() {
        _isSigning = false;
      });
      showToast(message: "Some error occurred");
    }
  }

  _signInWithGoogle() async {
    setState(() {
      _isGoogleSigning = true;
    });
    if (_selectedOrganization == null || _selectedOrganization!.isEmpty) {
      setState(() {
        _organizationDropdownError = true;
        _isGoogleSigning = false;
      });
      showToast(message: "Please select organization");
      return;
    }

    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

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

          _showPolicyDialog(); // Show the policy dialog before navigating to home
        } else {
          // Sign out the user if the email is not valid
          await _googleSignIn.signOut();
          await FirebaseAuth.instance.signOut();
          showToast(message: "Access denied. Please use a College email address.");
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
        _isGoogleSigning = false;
      });
    }
  }

  void _resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      showToast(message: "Please enter your email to reset password");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showToast(message: "Password reset link sent to your email");
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  void _showPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Important Notice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'We would like to inform all members that TraceHub is not responsible for any personal belongings or issues encountered with other members of the community.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'If you come across any valuable items, such as electronics or jewelry, please ensure they are handed over to the faculty or the Administrative Office (AO). Under no circumstances should these items be given directly to any individual without proper verification.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(
                    color: Colors.black26,
                    thickness: 1,
                  ),
                  Text(
                    'Team Trace Hub',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Continue to Home Page'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
              },
            ),
          ],
        );
      },
    );
  }
}
