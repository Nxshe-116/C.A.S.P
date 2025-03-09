import 'package:admin/controllers/menu_app_controller.dart';
 
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:admin/screens/notif/notification.dart';

import 'package:admin/screens/portfolio/portfolio.dart';
import 'package:admin/screens/profile/profile.dart';
import 'package:admin/screens/insight/insight.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/side_menu.dart';

class MainScreen extends StatefulWidget {

  final String uid;

  const MainScreen({super.key, required this.uid});
  
  @override
  _MainScreenState createState() => _MainScreenState();
}




class _MainScreenState extends State<MainScreen> {
  // Track the current index to switch between different screens
  int _selectedIndex = 0;

  // List of available screens/pages
  static List<Widget> pages = <Widget>[
    DashboardScreen(),
    PortfolioScreen(),
    InsightScreen(),
    NotifictionScreen(),
     ProfileScreen(),
  ];

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index to switch pages
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(
          onMenuItemSelected: _onMenuItemSelected), // Pass the callback
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // It takes 1/6 part of the screen
                child: SideMenu(onMenuItemSelected: _onMenuItemSelected),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              // Display the currently selected page
              child: pages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}
