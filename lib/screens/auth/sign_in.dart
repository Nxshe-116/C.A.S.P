import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/auth/components/components.dart';
import 'package:admin/screens/auth/reg.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool isLoading = false;
  //final _formKey = GlobalKey<FormState>();
  final formKey =
      GlobalKey<FormState>(); // Add this at the top of your _SignInScreenState
  final FocusNode emailFocusNode = FocusNode(); // Add FocusNode for email
  final FocusNode passwordFocusNode = FocusNode(); // Add FocusNode for password

  @override
  void dispose() {
    emailFocusNode.dispose(); // Dispose FocusNode
    passwordFocusNode.dispose(); // Dispose FocusNode
    super.dispose();
  }

  Future<void> signIn() async {
    setState(() {
      isLoading = true; // Start loading
    });
    try {
      final email = controller.text.trim();
      final password = passwordController.text.trim();

      // Check if email or password is empty
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Email and password cannot be empty.',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white, // Change background color
          duration: Duration(seconds: 3), // Set duration
          behavior: SnackBarBehavior.floating, // Make it floating
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Add rounded corners
          ),
        ));

        return;
      }

      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if userCredential or user is null
      if (userCredential.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Authentication failed. Please try again.',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white, // Change background color
          duration: Duration(seconds: 3), // Set duration
          behavior: SnackBarBehavior.floating, // Make it floating
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Add rounded corners
          ),
        ));

        return;
      }

      // Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      print('User UID: ${userCredential.user!.uid}');
      print('User Document Exists: ${userDoc.exists}');
      print('User Data: ${userDoc.data()}');

      // Check if user document exists and has data
      if (!userDoc.exists || userDoc.data() == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'User not found.',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white, // Change background color
          duration: Duration(seconds: 3), // Set duration
          behavior: SnackBarBehavior.floating, // Make it floating
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Add rounded corners
          ),
        ));

        return;
      }

      // Extract user data
      final userData = userDoc.data() as Map<String, dynamic>;
      final name = userData['firstName'] ?? '';
      final lastName = userData['lastName'] ?? '';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('name', name);
      await prefs.setString('lastName', lastName);
      await prefs.setString('uid', userCredential.user!.uid);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Signed In Successfully',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // Change background color
        duration: Duration(seconds: 3), // Set duration
        behavior: SnackBarBehavior.floating, // Make it floating
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Add rounded corners
        ),
      ));

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MainScreen(
                  uid: userCredential.user!.uid,
                  name: name,
                  lastName: lastName,
                )),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password or email.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(errorMessage)),
      // );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          errorMessage,
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // Change background color
        duration: Duration(seconds: 3), // Set duration
        behavior: SnackBarBehavior.floating, // Make it floating
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Add rounded corners
        ),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'An unexpected error occurred. Please try again.',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // Change background color
        duration: Duration(seconds: 3), // Set duration
        behavior: SnackBarBehavior.floating, // Make it floating
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Add rounded corners
        ),
      ));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Stop loading in any case
        });
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
                            onTap: () => signIn(),
                            isLoading: isLoading,
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
