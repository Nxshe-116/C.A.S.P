import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/auth/components/components.dart';
// import 'package:admin/screens/auth/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (formKey.currentState!.validate()) {
      try {
        final firstName = firstNameController.text.trim();
        final lastName = lastNameController.text.trim();
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        // Create user with Firebase Authentication
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save user details to Firestore
        final userId = userCredential.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'userId': userId,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'selectedCompanies': [], // Initialize with an empty list
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => HomeScreen(userId: userId)),
        // );
      } on FirebaseAuthException catch (e) {
        // Handle errors
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already registered.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak.';
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
            fit: BoxFit.fill,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Center(
                    child: Text(
                  'AI-Powered Insights \n for Agricultural Markets.',
                  style: TextStyle(
                      fontSize: 55,
                      fontWeight: FontWeight.bold,
                      color: bgColor),
                )),
              ),
              if (Responsive.isDesktop(context))
                Expanded(
                    flex: 2,
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
                            SizedBox(height: 25),
                            CustomTextField(
                                controller: firstNameController,
                                hintText: "First name",
                                leadingIcon: Icons.person),
                            CustomTextField(
                                controller: lastNameController,
                                hintText: "Last name",
                                leadingIcon: Icons.person),
                            CustomTextField(
                                controller: emailController,
                                hintText: "Email",
                                leadingIcon: Icons.mail_outline_outlined),
                            SizedBox(height: 15),
                            CustomPasswordField(
                                controller: passwordController,
                                hintText: "Password",
                                leadingIcon: Icons.lock),
                            CustomButton(
                              title: "Sign In",
                              onTap: _register,
                            ),
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
