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
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const CustomButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // border: Border.all(
          //   color: Colors.black,
          //   width: 0,
          //   style: BorderStyle.solid,
          // ),
          color: primaryColor,
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: secondaryColor,
          //     spreadRadius: 0,
          //     blurRadius: 0,
          //     offset: Offset(0, 5),
          //   ),
          // ],
        ),
        margin: EdgeInsets.only(top: 40, left: 20.0, right: 20.0),
        width: 900.w,
        height: 45.0,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
                color: Colors.white),
          ),
        ),
      ),
    );
  }
}
