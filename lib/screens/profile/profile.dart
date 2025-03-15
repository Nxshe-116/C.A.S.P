import 'package:admin/constants.dart';

import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/header.dart';

import 'package:admin/screens/profile/setting_toggle.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {

  final String userName = "Nashe Chagumaira"; // Example user name
  final String userEmail = "medannashe6@gmail.com"; // Example user email
  final String userProfilePic =
      "assets/images/man.jpg"; // Example profile picture (replace with your own)


    final String name;
  final String lastName;
  final String uid;

  const ProfileScreen({
    Key? key,
    required this.name,
    required this.lastName, required String this.uid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(text: "Profile", name: name, lastName: lastName,),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 800,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Picture Section
                              Center(
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage: AssetImage(userProfilePic),
                                ),
                              ),
                              SizedBox(height: 20),

                              // User Name
                              Center(
                                child: Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        primaryColor, // Use primaryColor for text highlight
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),

                              // User Email
                              Center(
                                child: Text(
                                  userEmail,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              SizedBox(height: 20),

                              // Account Settings Section
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Text(
                                  "Account Settings",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        primaryColor, // Use primaryColor for section titles
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),

                              // Settings List
                              Card(
                                color: Color(0xFFF4FAFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 1.0,
                                child: ListTile(
                                  leading: Icon(Icons.password),
                                  title: Text("Change Password"),
                                  onTap: () {
                                    // Add navigation or functionality here
                                  },
                                ),
                              ),
                              Card(
                                color: Color(0xFFF4FAFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 1.0,
                                child: ListTile(
                                  leading: Icon(Icons.privacy_tip_rounded),
                                  title: Text("Privacy Settings"),
                                  onTap: () {},
                                ),
                              ),
                              SizedBox(
                                height: defaultPadding,
                              ),
                              ElevatedButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: defaultPadding * 2.5,
                                    vertical: defaultPadding /
                                        (Responsive.isMobile(context) ? 2 : 1),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        6.0), // Slightly rounded corners
                                  ),
                                ),
                                onPressed: () {},
                                icon: Icon(
                                  Icons.logout_outlined,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "Log Out",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) SettingsToggle()
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
                if (!Responsive.isMobile(context))
                  Expanded(flex: 4, child: SettingsToggle()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
