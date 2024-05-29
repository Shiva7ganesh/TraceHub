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
                  "Sign Up",
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
                    hintText: 'Select college/Organization',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: spacing * 2),
              FormContainerWidget(
                controller: _usernameController,
                hintText: "Username",
                isPasswordField: false,
              ),
              SizedBox(height: spacing),
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
              SizedBox(height: spacing),
              FormContainerWidget(
                controller: _phoneNumberController,
                hintText: "Mobile Number",
                isPasswordField: false,
              ),
              SizedBox(height: spacing * 2),
              GestureDetector(
                onTap: _signUp,
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isSigningUp
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing * 2),
              Center(
                child: Text(
                  "Please use your organization email to SignUp"),
              ),
              SizedBox(height: spacing * 2),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                              (route) => false,
                        );
                      },
                      child: Text(
                        "Login",
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
                    Text("Didn't receive verification email?"),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: _resendVerificationEmail,
                      child: Text(
                        "Resend Link",
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