
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:whsuites_calling/view/login/widgets/input_email_widget.dart';
import 'package:whsuites_calling/view/login/widgets/input_password_widget.dart';
import 'package:whsuites_calling/view/login/widgets/login_button_widget.dart';
import '../../res/colors/app_color.dart';
import '../../view_models/controller/login/login_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  final loginVM = Get.put(LoginViewModel()) ;
  final _formkey = GlobalKey<FormState>();
  bool _rememberMe = false;


  String? token;

  @override
  void initState() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    () async {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted permission');
        }
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        if (kDebugMode) {
          print('User granted provisional permission');
        }
      } else {
        if (kDebugMode) {
          print('User declined or has not accepted permission');
        }
      }

      messaging.getToken().then((value) {
        token = value;

        if (kDebugMode) {
          print('FCM TOKEN>>>>>>: ${value!}');
        }
      });
    }();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 20.h,
        centerTitle: false,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login Account',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Hello, welcome back to your account',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1.h,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
        body: SingleChildScrollView(
        child: Center(
        child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h , horizontal: 4.w),
           child: Column(
            children: <Widget>[
             Card(
              elevation: 0,
              color: AppColors.cardColor,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.h),
              ),
              child: Padding(
                padding: EdgeInsets.all(2.h),
                 child: Column(
                  mainAxisSize: MainAxisSize.min,
                   children: [
                   Form(
                   key: _formkey,
                   child: Column(
                       children: [
                    SizedBox(height: 2.h),

                    InputEmailWidget(),
                     SizedBox(height: 1.h),
                  InputPasswordWidget(),
                       ],
                   ),
                   ),
                   SizedBox(height: 1.5.h),

                     Row(
                       children: <Widget>[
                         Padding(
                           padding: EdgeInsets.only(left: 1.w),
                           // Adding padding to the left
                           child: Transform.scale(
                             scale: 0.12.h,
                             // You can adjust the scale value for checkbox size
                             child: Checkbox(
                               value: _rememberMe,
                               // You need to manage this value in your state
                               onChanged: (value) {
                                 setState(() {
                                   _rememberMe = value!;
                                 });
                               },
                               activeColor: AppColors.primaryColor,
                               visualDensity: VisualDensity(
                                   horizontal: -0.02.h, vertical: -0.02.h),
                             ),
                           ),
                         ),
                         Text(
                           'I agree to the terms and conditions',
                           style: TextStyle(fontSize: 14.sp),
                         ),
                       ],
                     ),
                 SizedBox(height: 2.h),
            LoginButtonWidget(formKey: _formkey)
          ],
        ),
      ),
    ),
              SizedBox(height: 0.1.h),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
    ],
    ),
    ),),
    ),
    );
  }
}
