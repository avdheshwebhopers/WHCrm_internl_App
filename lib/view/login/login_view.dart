import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whsuites_calling/view/login/widgets/input_email_widget.dart';
import 'package:whsuites_calling/view/login/widgets/input_password_widget.dart';
import 'package:whsuites_calling/view/login/widgets/login_button_widget.dart';
import '../../res/colors/app_color.dart';
import '../../utils/Button.dart';
import '../../view_models/controller/login/login_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final loginVM = Get.put(LoginViewModel());

  final _formkey = GlobalKey<FormState>();
  //bool _rememberMe = false;

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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Column(
            children: <Widget>[
              SizedBox(height: height/3.5),
              const Text(
                'Login',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: height/20),
              const Text(
            'Hello, welcome back to your account',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),),
              const SizedBox(height: 20),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    InputEmailWidget(),
                    const SizedBox(height:10),
                    InputPasswordWidget(),
                  ],
                ),
              ),
              SizedBox(height: height/25),
              LoginButtonWidget(formKey: _formkey),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class LoginButtonWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  LoginButtonWidget( {Key? key, required this.formKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginViewModel>(
      builder: (loginVM) {
        return Obx(() => Button(
            title: 'Login',
            isLoading: loginVM.loading.value,
            onPress: () {
              FocusScope.of(context).unfocus();
              if (formKey.currentState != null && formKey.currentState!.validate()) {
                loginVM.loginApi(context);
              }
            }
        ),
        );
      },
    );
  }
}