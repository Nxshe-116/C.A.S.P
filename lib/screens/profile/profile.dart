import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:admin/screens/profile/setting_toggle.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String lastName;
  final String uid;

  const ProfileScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.uid,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String userProfilePic = "assets/images/man.jpg";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              text: "Profile",
              name: widget.name,
              lastName: widget.lastName,
            ),
            SizedBox(height: defaultPadding),
            Responsive.isMobile(context)
                ? buildMobileLayout()
                : buildDesktopLayout(),
          ],
        ),
      ),
    );
  }

  Widget buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: buildProfileSection(),
        ),
        SizedBox(width: defaultPadding),
        Expanded(
          flex: 4,
          child: SettingsToggle(),
        ),
      ],
    );
  }

  Widget buildMobileLayout() {
    return Column(
      children: [
        buildProfileSection(),
        SizedBox(height: defaultPadding),
        SettingsToggle(),
      ],
    );
  }

  Widget buildProfileSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: !Responsive.isMobile(context) ? 50 : 60,
                backgroundImage: AssetImage(userProfilePic),
              ),
              SizedBox(height: 20),

              // User Name
              Text(
                "${widget.name} ${widget.lastName}",
                style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),

              // Account Settings Section
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Account Settings",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),

              // Settings Cards
              buildSettingCard(
                icon: Icons.password,
                title: "Change Password",
                onTap: () {},
              ),
              SizedBox(height: 8),
              buildSettingCard(
                icon: Icons.privacy_tip,
                title: "Privacy Settings",
                onTap: () {},
              ),
              SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.logout_outlined, color: Colors.white),
                  label: Text(
                    "Log Out",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(
                      vertical: defaultPadding /
                          (Responsive.isMobile(context) ? 1.5 : 1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSettingCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Color(0xFFF4FAFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(
          title,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        minLeadingWidth: 24,
        onTap: onTap,
      ),
    );
  }
}
