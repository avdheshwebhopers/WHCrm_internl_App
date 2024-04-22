import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
      elevation: 1.2,
      borderRadius: BorderRadius.circular(20.h),
      child: TextField(
        style: TextStyle(fontSize: 16.sp),
        controller: titleController,
        focusNode: titleFocusNode,
        maxLines: null,
        textInputAction: TextInputAction.next,
        onSubmitted: onFieldSubmitted,
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
          contentPadding: EdgeInsets.fromLTRB(1.w, 2.5.h, 1.w, 2.5.h),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 2.w, 2.h),
            child: Icon(prefixIcon, size: 3.h),
          ),
          hintText: hintText,
        ),
      ),
    );
  }
}
