// ignore: file_names

import 'package:flutter/material.dart';
import '../res/colors/app_color.dart';

class Button extends StatelessWidget {
  Button({
    this.onPress,
    required this.title,
    this.isLoading = false,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onPress;
  final String title;
  final bool isLoading; // New parameter for loading

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        minimumSize: Size(
          MediaQuery.of(context).size.width / 1.3,
          MediaQuery.of(context).size.height / 15,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator( // Loading indicator
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      )
          : Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
