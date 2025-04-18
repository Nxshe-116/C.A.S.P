// ignore_for_file: deprecated_member_use

import 'package:admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData leadingIcon;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.leadingIcon,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          prefixIcon: Icon(
            leadingIcon,
            color: secondaryColor,
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: secondaryColor,
              width: 1.50,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: secondaryColor,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: secondaryColor,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),

        onChanged: null,
      ),
    );
  }
}

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData leadingIcon;
  final FocusNode? focusNode;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.leadingIcon,
    this.focusNode,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomPasswordFieldState createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: _isObscured,
        decoration: InputDecoration(
          prefixIcon: Icon(
            widget.leadingIcon,
            color: secondaryColor,
          ),
          // suffixIcon: IconButton(
          //   icon: Icon(
          //     _isObscured
          //         ? Icons.remove_red_eye_outlined
          //         : LineAwesomeIcons.remove_red_eye_outlined,
          //     color: secondaryColor,
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       _isObscured = !_isObscured;
          //     });
          //   },
          // ),

          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: secondaryColor, // Set the border color to secondary color
              width: 1.50, // Set border thickness to 1.0
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: secondaryColor,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: secondaryColor,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),

         onChanged: null,
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLoading; // Add this parameter to control loading state

  const CustomButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap, // Disable tap when loading
      child: Container(
        decoration: BoxDecoration(
          color: isLoading ? primaryColor.withOpacity(0.7) : primaryColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        margin: EdgeInsets.only(top: 40, left: 20.0, right: 20.0),
        width: 900.w,
        height: 45.0,
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}