import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:lostandfound/features/user_auth/presentation/pages/login_page.dart';
import 'package:lostandfound/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:lostandfound/global/common/toast.dart';

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
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      _signUp();
                    },
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?"),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                                  (route) => false);
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
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
    if (username.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty) {
      showToast(message: "Please enter valid details");
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    // Check email domain
    if (!email.endsWith("cmritonline.ac.in") && !email.endsWith("cmrithyderabad.edu.in")) {
      showToast(message: "Use organization or college mail");
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    // Validate password strength
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(password)) {
      showToast(message: "Password must be at least 8 characters long, include an uppercase letter, a number, and a special character");
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

    //Check if mobile number is right or not
    if(phoneNumber.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phoneNumber)){
        showToast(message: "Please enter only numbers with length 10");
        setState(() {
          isSigningUp = false;
        });
        return;
    }

    User? user = await _auth.signUpWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
      phoneNumber: phoneNumber,
    );

    setState(() {
      isSigningUp = false;
    });

    if (user != null) {
      showToast(message: "User is successfully created");

      // Store the Firebase user ID along with other user details
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'organization': _selectedOrganization,
      });

      Navigator.pushNamed(context, "/home");
    } else {
      showToast(message: "Some error happened");
    }
  }
}
