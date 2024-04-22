import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../res/colors/app_color.dart';

class TextWithStyle{
  static register(context, String message){
    return Text(message,
      maxLines: 1,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryColor,
      ),
    );
  }

  static appBarTitle(context, String message) {
    return Text(
      message,
      style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        color: Colors.black
      ),
    );
  }

  static containerTitle(context, String message){
    return Text(
        message,
      style: GoogleFonts.mavenPro(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
         color: Colors.black
      ),
    );
  }

  static svgIconTitle(context, String message){
    return Text(
        message,
      style: TextStyle(
        letterSpacing: 0.4,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static pngIconTitle(context, String message){
    return Text(
        message,
      textAlign: TextAlign.center,
      style: TextStyle(
        letterSpacing: 0.4,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static promotionalTitle (context, String message){
    return Text(
      message,
      style: TextStyle(
          fontSize: 16.sp,
          letterSpacing: 0.5,
          wordSpacing: 1,
      ),
    );
  }

  static productTitle(context, String message){
    return Text(
      message,
      maxLines: 2,
      style: GoogleFonts.nunito(
          fontSize: 16.sp,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold),
    );
  }

  static productTypeName(context, String message){
    return Text(
      message,
      style: TextStyle(
          fontSize: 14.sp,
        color: Colors.black87
      ),
    );
  }

  static productDescription(context, String message){
    return Text(
      message,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 16.sp,color: Colors.black.withOpacity(0.7),),
    );
  }

  static productPrice(context, String? message){
    return Text(
      '₹$message',
      style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold),
    );
  }

  static addToCartTitles(context, String message){
    return Text(message,
      maxLines: 1,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: Colors.white,
      ),);
  }

  static contactUsTitle(context, String message){
    return Text(
      message,
      style: TextStyle(
          color: Colors.white,
          fontSize: 17.sp,
          fontWeight: FontWeight.w500),
    );
  }

  static mrProfileHeading(context, String message){
    return Text(message,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600
      ),);
  }

  static mrProfileTitles(context, String message){
    return Text(message,
      maxLines: 1,
      style: TextStyle(
          fontSize: 16.sp,
          color: Colors.black,
      ),);
  }

  static customerName(context ,String? message){
    return Text(
      message ?? 'Na',
      style: TextStyle(
          fontSize: 19.sp,
          fontWeight: FontWeight.w600),
    );
  }

  static customerDetails(context ,String? message){
    return Text(
      message ?? 'Na',
      style: TextStyle(
        color: Colors.black54,
        fontSize: 16.5.sp,
      ),
    );
  }

  static customerProductDetails(context ,String? message){
    return Text(
      message ?? 'Na',
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 16.5.sp,
      ),
    );
  }

  static customerTimeDetails(context ,String? message){
    return Text(
      message ?? 'Na',
      style: TextStyle(
        color: Colors.black54,
        fontSize: 15.sp,
      ),
    );
  }

  static customerStatus(context ,String? message, color){
    return Text(
      message ?? 'Na',
      style: TextStyle(
        color: color,
        fontSize: 17.sp,
        fontWeight: FontWeight.w400,
          letterSpacing: 1
      ),
    );
  }

}