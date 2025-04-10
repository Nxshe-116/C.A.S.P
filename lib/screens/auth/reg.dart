import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/auth/components/components.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final userId = userCredential.user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'userId': userId,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'selectedCompanies': [], // Initialize with an empty list
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Successfully registered',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

        // Save login state in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('name', firstName);
        await prefs.setString('lastName', lastName);
        await prefs.setString('uid', userCredential.user!.uid);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => MainScreen(
                    uid: userCredential.user!.uid,
                    name: firstName,
                    lastName: lastName,
                  )),
          (Route<dynamic> route) => false,
        );
      } on FirebaseAuthException catch (e) {
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

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            errorMessage,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4FAFF),
      body: SafeArea(
        child: Responsive(
          mobile: _buildMobileLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/agric.jpg",
          fit: BoxFit.fill,
          width: double.infinity,
          height: double.infinity,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Center(
                child: Text(
                  'Predicting Climate Resilient Stock Prices',
                  style: TextStyle(
                      fontSize: 55,
                      fontWeight: FontWeight.bold,
                      color: bgColor),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Color(0xFFF4FAFF),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _buildRegistrationForm(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset(
            "assets/images/agric.jpg",
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildRegistrationForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            "assets/images/12.png",
            height: 100,
          ),
          SizedBox(height: 20),
          Text(
            "Welcome",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 35,
                fontWeight: FontWeight.w900),
          ),
          Text(
            "Enter your credentials to continue",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.normal),
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
            title: "Register",
            onTap: _register,
          ),
        ],
      ),
    );
  }
}
