
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PasswordInputField extends StatefulWidget {
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? hintText;
  final bool obscureText;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted; // New parameter

  const PasswordInputField({
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.obscureText = true,
    this.focusNode,
    this.validator,
    this.onFieldSubmitted, // New parameter
    Key? key,
  }) : super(key: key);

  @override
  _PasswordInputFieldState createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.2,
      borderRadius: BorderRadius.circular(20.h),
      child: TextFormField(
        style: TextStyle(fontSize: 16.sp),
        controller: widget.controller,
        focusNode: widget.focusNode,
        maxLines: widget.obscureText ? 1 : null,
        textInputAction: TextInputAction.next,
        obscureText: _obscureText,
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted, // Added this line
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20.h),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.h)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 2.w, 2.h),
            child: Icon(widget.prefixIcon, size: 3.h),
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 2.w, 2.h),
              child: Icon(
                _obscureText ? widget.suffixIcon : Icons.visibility_off,
                size: 3.h,
                color: Colors.grey,
              ),
            ),
          ),
          hintText: widget.hintText,
        ),
      ),
    );
  }
}




