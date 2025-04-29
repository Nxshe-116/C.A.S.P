// ignore_for_file: deprecated_member_use

import 'dart:ui_web' as ui;
import 'dart:html' as html;

import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/screens/auth/sign_in.dart';
import 'package:admin/screens/main/main_screen.dart'; // Import MainScreen
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

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
        appId: "1:511015749458:web:680ca3cde836fcbf831c8b",
      ),
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Check if the user is logged in using SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final name = prefs.getString('name') ?? '';
  final lastName = prefs.getString('lastName') ?? '';
  final uid = prefs.getString('uid') ?? '';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MenuAppController()),
        // Add other providers here if needed
      ],
      child: MyApp(
        isLoggedIn: isLoggedIn,
        name: name,
        lastName: lastName,
        uid: uid,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String name;
  final String lastName;
  final String uid;

  const MyApp(
      {Key? key,
      required this.isLoggedIn,
      required this.name,
      required this.lastName,
      required this.uid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'C.A.S.P',
        theme: ThemeData(
          useMaterial3: true, // Enable Material 3
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green, // Adjust based on your branding
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ).apply(bodyColor: Colors.black),
          scaffoldBackgroundColor: const Color(0xFFfefefe),
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => MenuAppController(),
            ),
          ],
          // Navigate to MainScreen if logged in, otherwise to SignInScreen
          child: isLoggedIn
              ? MainScreen(uid: uid, name: name, lastName: lastName)
              : SignInScreen(),
        ),
      ),
    );
  }

  void registerPdfViewer() {
    if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory(
        'pdf-iframe',
        (int viewId) {
          final element = html.DivElement()
            ..id = 'pdf-iframe-$viewId'
            ..style.width = '100%'
            ..style.height = '100%';

          return element;
        },
      );
    }
  }
}
