import 'package:admin/models/notifications.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatefulWidget {
  final Function(int) onMenuItemSelected;

  const SideMenu({
    Key? key,
    required this.onMenuItemSelected, // Add this callback
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    int unreadCount = mockAgricultureNotifications
        .where((notification) => !notification.isRead)
        .toList()
        .length;

    return Drawer(
      backgroundColor: Color(0xFFF4FAFF),
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset(
              "assets/images/12.png",
              height: 20,
            ),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () => widget
                .onMenuItemSelected(0), // Trigger page switch to Dashboard
          ),
          DrawerListTile(
            title: "Portfolio",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () => widget
                .onMenuItemSelected(1), // Trigger page switch to Transaction
          ),
          DrawerListTile(
            title: "Insight",
            svgSrc: "assets/icons/menu_store.svg",
            press: () =>
                widget.onMenuItemSelected(2), // Trigger page switch to Store
          ),
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 10, end: 10),
            badgeContent: Text(
              unreadCount.toString(),
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            child: DrawerListTile(
              title: "Notifications",
              svgSrc: "assets/icons/menu_notification.svg",
              press: () => widget.onMenuItemSelected(
                  3), // Trigger page switch to Notifications
            ),
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () =>
                widget.onMenuItemSelected(4), // Trigger page switch to Profile
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(const Color(0x89313628), BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.black87),
      ),
    );
  }
}
