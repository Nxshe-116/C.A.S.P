import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/screens/auth/sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  try {
    // Initialize Firebase with your project's configuration
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDkT9IzoZLoTIyxwJw__KHarEVRMI_Xmzw",
            authDomain: "casp-20117.firebaseapp.com",
            projectId: "casp-20117",
            storageBucket: "casp-20117.firebasestorage.app",
            messagingSenderId: "511015749458",
            appId: "1:511015749458:web:680ca3cde836fcbf831c8b"));
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'C.A.S.P',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Color(0xFFfefefe),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.black),
        canvasColor: secondaryColor,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MenuAppController(),
          ),
        ],
        child: SignInScreen(),
      ),
    );
  }
}
