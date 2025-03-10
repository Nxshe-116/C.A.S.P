import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/auth/components/components.dart';
import 'package:admin/screens/auth/reg.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode emailFocusNode = FocusNode(); // Add FocusNode for email
  final FocusNode passwordFocusNode = FocusNode(); // Add FocusNode for password

  @override
  void dispose() {
    emailFocusNode.dispose(); // Dispose FocusNode
    passwordFocusNode.dispose(); // Dispose FocusNode
    super.dispose();
  }

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

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // change after auth

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(
                    uid: userCredential.user!.uid,
                    name: 'Nashe',
                    lastName: 'Chagumaira',
                  )),
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
      backgroundColor: Color(0xFFF4FAFF),
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
                    color: Color(0xFFF4FAFF),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            "assets/images/12.png",
                            height: 190,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Welcome",
                                  style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 35,
                                      fontWeight: FontWeight.w900)),
                              Text("Enter your credentials to continue ",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal)),
                            ],
                          ),
                          SizedBox(height: 25.h),
                          CustomTextField(
                              focusNode: emailFocusNode,
                              controller: controller,
                              hintText: "Email",
                              leadingIcon: Icons.person),
                          SizedBox(height: 15),
                          CustomPasswordField(
                              focusNode: passwordFocusNode,
                              controller: passwordController,
                              hintText: "Password",
                              leadingIcon: Icons.lock),
                          CustomButton(
                            title: "Sign In",
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => MainScreen(
                                          uid: '',
                                          name: 'Nissi',
                                          lastName: 'Chagumaira',
                                        )),
                                (Route<dynamic> route) =>
                                    false, // Removes all previous routes
                              );
                            },
                          ),
                          SizedBox(height: 25.h),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text("Don't have an account? ",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal)),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RegistrationScreen()),
                                        );
                                      },
                                      child: Text("Sign up now",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 15,
                                              //  fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.normal)),
                                    ),
                                  ],
                                ),
                              ]),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ]),
      ),
    );
  }
}
