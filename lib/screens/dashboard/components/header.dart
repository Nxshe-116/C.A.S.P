// ignore_for_file: deprecated_member_use

import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/auth/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';

class Header extends StatelessWidget {
  final String text;
  final String name;
  final String lastName;
  const Header({
    Key? key,
    required this.text,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            text,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        Expanded(child: SearchField()),
        ProfileCard(
          lastName: lastName,
          name: name,
        )
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String name;
  final String lastName;
  const ProfileCard({
    Key? key,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 223, 223, 223),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Profile Icon
          ClipOval(
            child: Container(
              color: Colors.grey[300], // Background color for the circle
              height: 38,
              width:
                  38, // Ensure the width is equal to the height for a perfect circle
              child: Icon(
                Icons.person, // Replace with the desired icon
                size: 20, // Adjust the size of the icon as needed
                color: Colors.black, // Icon color
              ),
            ),
          ),

          // Display the username if not on mobile
          if (!Responsive.isMobile(context))
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Text("${name} ${lastName}"),
            ),

          // Dropdown Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.keyboard_arrow_down), // Dropdown icon
            color: Colors
                .white, // Set the background color of the dropdown to white
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10), // Rounded corners for the dropdown
            ),
            offset: Offset(0,
                40), // Adjust the offset to position the dropdown below the arrow
            onSelected: (String value) {
              // Handle menu item selection
              if (value == 'profile') {
                _navigateToProfile(context);
              } else if (value == 'settings') {
                _navigateToSettings(context);
              } else if (value == 'logout') {
                confirmLogout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                // Profile Option
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.black), // Profile icon
                      SizedBox(width: 10), // Spacing between icon and text
                      Text('Profile', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),

                // Settings Option
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings,
                          color: Colors.black), // Settings icon
                      SizedBox(width: 10), // Spacing between icon and text
                      Text('Settings', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),

                // Logout Option
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black), // Logout icon
                      SizedBox(width: 10), // Spacing between icon and text
                      Text('Logout', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  // Navigate to Profile
  void _navigateToProfile(BuildContext context) {
    print("Navigate to Profile");
    // Example: Navigate to the profile screen
    // Navigator.pushNamed(context, '/profile');
  }

  // Navigate to Settings
  void _navigateToSettings(BuildContext context) {
    print("Navigate to Settings");
    // Example: Navigate to the settings screen
    // Navigator.pushNamed(context, '/settings');
  }

  void confirmLogout(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320, // Fixed width
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Are you sure you want to sign out?",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          logout(context);
                        },
                        child: Text(
                          "Sign Out",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 250),
    );
  }

  void logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'User logged out.',
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
        MaterialPageRoute(builder: (context) => SignInScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Error during logout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out. Please try again.')),
      );
    }
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: Color.fromARGB(255, 223, 223, 223),
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.99),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 6),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 223, 223, 223),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset(
              "assets/icons/Search.svg",
              color: primaryColor,
              height: 20,
            ),
          ),
        ),
      ),
    );
  }
}
