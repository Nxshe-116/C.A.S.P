import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/auth/reg.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        // Sign in with Firebase Authentication
        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Navigate to the home screen after successful sign-in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(uid: userCredential.user!.uid)),
        );
      } on FirebaseAuthException catch (e) {
        // Handle errors
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(children: [
          Image.asset(
            "assets/images/agric.jpg",
            fit: BoxFit.contain,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              if (Responsive.isDesktop(context))
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Image.asset(
                      "assets/images/12.png",
                      height: 450,
                    ),
                  ),
                ),
              Expanded(
                  flex: 2,
                  // Display the currently selected page
                  child: Container(
                    color: primaryColor,
                  )),
            ],
          ),
        ]),
      ),
      // body: Padding(
      //   padding: const EdgeInsets.all(16.0),
      //   child: Form(
      //     key: _formKey,
      //     child: Column(
      //       children: [
      //         TextFormField(
      //           controller: _emailController,
      //           decoration: InputDecoration(labelText: 'Email'),
      //           validator: (value) {
      //             if (value == null || value.isEmpty) {
      //               return 'Please enter your email';
      //             }
      //             return null;
      //           },
      //         ),
      //         TextFormField(
      //           controller: _passwordController,
      //           decoration: InputDecoration(labelText: 'Password'),
      //           obscureText: true,
      //           validator: (value) {
      //             if (value == null || value.isEmpty) {
      //               return 'Please enter your password';
      //             }
      //             return null;
      //           },
      //         ),
      //         SizedBox(height: 20),
      //         ElevatedButton(
      //           onPressed: _signIn,
      //           child: Text('Sign In'),
      //         ),
      //         TextButton(
      //           onPressed: () {
      //             // Navigate to the registration screen
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(builder: (context) => RegistrationScreen()),
      //             );
      //           },
      //           child: Text('Don\'t have an account? Register here'),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
