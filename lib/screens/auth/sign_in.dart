import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/auth/components/components.dart';
import 'package:admin/screens/auth/reg.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        final email = controller.text.trim();
        final password = passwordController.text.trim();

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
                      child: Text(
                    'Smarter Agriculture, \nSmarter Investments.',
                    style: TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: bgColor),
                  )),
                ),
              Expanded(
                  flex: 2,
                  // Display the currently selected page
                  child: Container(
                    color: bgColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Image.asset(
                            "assets/images/12.png",
                            height: 200,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Welcome",
                                style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 27,
                                    fontWeight: FontWeight.w800)),
                            Text("Enter your credentials to continue ",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                        CustomTextField(
                            controller: controller,
                            hintText: "Email",
                            leadingIcon: Icons.person),
                        SizedBox(height: 15),
                        CustomPasswordField(
                            controller: passwordController,
                            hintText: "Password",
                            leadingIcon: Icons.lock),
                      ],
                    ),
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
