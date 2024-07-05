import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {

  TextInputField({
    this.titleController,
    this.titleFocusNode,
    this.titleValidator,
    this.onFieldSubmitted,
    this.title,
    this.hintText,
    this.prefixIcon,
    Key? key,
  }) : super(key: key);

  final TextEditingController? titleController;
  final FocusNode? titleFocusNode;
  final FormFieldValidator<String>? titleValidator;
  final ValueChanged<String>? onFieldSubmitted;
  final dynamic title;
  final String? hintText;
  final dynamic prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: TextField(
        style: TextStyle(fontSize: 16),
        controller: titleController,
        focusNode: titleFocusNode,
        maxLines: null,
        textInputAction: TextInputAction.next,
        onSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none
          ),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: EdgeInsets.all(5),
            child: Icon(prefixIcon, size: 25),
          ),
          hintText: hintText,
        ),
      ),
    );
  }
}
