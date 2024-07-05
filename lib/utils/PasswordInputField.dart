import 'package:flutter/material.dart';

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
    return TextFormField(
      style: const TextStyle(fontSize: 16),
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
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20),
        border: InputBorder.none,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(widget.prefixIcon, size: 25),
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(
              _obscureText ? widget.suffixIcon : Icons.visibility_off,
              size: 30,
              color: Colors.grey,
            ),
          ),
        ),
        hintText: widget.hintText,
      ),
    );
  }
}