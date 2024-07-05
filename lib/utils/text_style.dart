import 'package:flutter/material.dart';
import '../res/colors/app_color.dart';

class TextWithStyle{

 static containerTitle(context, String message){
    return Text(
        message,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
         color: Colors.black
      ),
    );
  }

  static productTitle(context, String message){
    return Text(
      message,
      maxLines: 2,
      style: TextStyle(
          fontSize: 16,
          color: AppColors.backgroundcolor,
          fontWeight: FontWeight.bold),
    );
  }
}