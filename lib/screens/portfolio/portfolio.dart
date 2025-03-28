import 'package:admin/constants.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';

class PortfolioScreen extends StatelessWidget {
  final String name;
  final String lastName;
  final String uid;

  const PortfolioScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.uid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              text: "History",
              name: name,
              lastName: lastName,
            ),
            SizedBox(height: defaultPadding),
          ],
        ),
      ),
    );
  }
}
