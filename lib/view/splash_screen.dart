
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:whsuites_calling/res/colors/app_color.dart';
import '../view_models/services/splash_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  SplashServices splashScreen = SplashServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    splashScreen.isLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      body: Center(
        child: Image.asset(
          'assets/gif/incoming_call.gif', // Update with the correct path to your GIF in the assets folder
          width: 20.w, // Adjust the width as needed
          height: 20.h, // Adjust the height as needed
          fit: BoxFit.contain, // Adjust the BoxFit property as needed
        ),
      ),
    );
  }
}
