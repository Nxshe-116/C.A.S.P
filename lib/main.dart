import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/screens/auth/sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MenuAppController()),
        // Add other providers here if needed
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
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
          child: SignInScreen(),
        ),
      ),
    );
  }
}
