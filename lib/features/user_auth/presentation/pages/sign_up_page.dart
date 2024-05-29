import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:lostandfound/features/user_auth/presentation/pages/login_page.dart';
import 'package:lostandfound/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:lostandfound/global/common/toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool isSigningUp = false;
  String? _selectedOrganization;
  bool _organizationDropdownError = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void showToast({
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
    int durationInSeconds = 5,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      // Display the toast for as long as possible
      gravity: gravity,
      timeInSecForIosWeb: durationInSeconds,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    // Manually dismiss the toast after the specified duration
    Future.delayed(Duration(seconds: durationInSeconds), () {
      Fluttertoast.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
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
                    "Sign Up",
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _organizationDropdownError
                          ? Colors.red[100]
                          : Colors.white,
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
                    controller: _usernameController,
                    hintText: "Username",
                    isPasswordField: false,
                  ),
                  SizedBox(height: 10),
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
                  SizedBox(height: 10),
                  FormContainerWidget(
                    controller: _phoneNumberController,
                    hintText: "Mobile Number",
                    isPasswordField: false,
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _signUp,
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: isSigningUp
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          "Sign Up",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?"),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                                  (route) => false);
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Didn't receive verification email?"),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: _resendVerificationEmail,
                        child: Text(
                          "Resend Link",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String phoneNumber = _phoneNumberController.text.trim();

    // Validate username, email, password, and mobile number
    if (username.isEmpty || email.isEmpty || password.isEmpty ||
        phoneNumber.isEmpty) {
      showToast(message: "Please enter valid details");
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    // Check email domain
    if (!email.endsWith("cmritonline.ac.in") &&
        !email.endsWith("cmrithyderabad.edu.in")) {
      showToast(message: "Use organization or college mail");
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    // Validate password strength
    if (!RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(password)) {
      showToast(
          message: "Password must be at least 8 characters long, include an uppercase letter, a number, and a special character");
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    // Check if organization is selected
    if (_selectedOrganization == null || _selectedOrganization!.isEmpty) {
      setState(() {
        _organizationDropdownError = true;
      });
      showToast(message: "Please select organization");
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    // Check if mobile number is valid
    if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      showToast(message: "Please enter a valid 10-digit mobile number");
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        // Store the Firebase user ID along with other user details
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'phoneNumber': phoneNumber,
          'organization': _selectedOrganization,
        });

        showToast(
            message: "User is successfully created. Please verify your email.");

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
        );
      } else {
        showToast(message: "Some error happened");
      }
    } catch (e) {
      showToast(message: e.toString());
    }

    setState(() {
      isSigningUp = false;
    });
  }

  void _resendVerificationEmail() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      if (email.isEmpty || password.isEmpty) {
        showToast(message: "Please enter both email and password.");
        return;
      }
      // Attempt to sign in with the email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        showToast(
            message: "Verification email resent. Please check your inbox.");
      } else if (user != null && user.emailVerified) {
        showToast(message: "Email is already verified.");
      } else {
        showToast(message: "No user found. Please sign up first.");
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e) {
          case 'user-not-found':
            showToast(message: "No user found for that email.");
            break;
          case 'The supplied auth credential is incorrect, malformed or has expired.':
            showToast(message: "Wrong password provided.");
            break;
          default:
            showToast(message: "Failed to resend verification email. Error: ${e
                .message}");
        }
      } else {
        showToast(message: "An unexpected error occurred. Please try again.");
      }
    }
  }
}