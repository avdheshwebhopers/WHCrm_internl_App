import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:whsuites_calling/models/response_model/login_response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../repository/beforelogin/login_repository.dart';
import '../../../res/routes/routes_name.dart';
import '../../../utils/utils.dart';
import '../user_preference/user_prefrence_view_model.dart';

class LoginViewModel extends GetxController {
  final _api = LoginRepository();
  final userViewModel = UserViewModel();

  final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;

  final emailFocusNode = FocusNode().obs;
  final passwordFocusNode = FocusNode().obs;

  final loading = false.obs;

  Future<void> loginApi(BuildContext context) async {
    if (emailController.value.text.isEmpty || passwordController.value.text.isEmpty) {
      Utils.errorAlertDialogue("Please enter email and password", context);
      return;
    }

    loading.value = true;

    final deviceToken = await _getDeviceToken();

    Map data = {
      'email': emailController.value.text,
      'password': passwordController.value.text,
      'device_id': deviceToken,
    };

    try {
      final value = await _api.loginApi(data);
      if (value is Map<String, dynamic> && value.containsKey('accessToken')) {
        await _handleSuccessfulLogin(context, value);
      } else {
        Utils.errorAlertDialogue("Invalid Credentials", context);
      }
    }
    catch (error) {
      loading.value = false;
      if (kDebugMode) {
        print(error.toString());
      }
    }
  }

  Future<String> _getDeviceToken() async {
    final messaging = FirebaseMessaging.instance;
    return await messaging.getToken() ?? "abed12345";
  }

  Future<void> _handleSuccessfulLogin(
      BuildContext context, Map<String, dynamic> value) async {
    // Check if 'accessToken' and 'user' are present in the response
    if (value.containsKey('accessToken') && value.containsKey('user')) {
      final loginResponseModel = LoginResponseModel(
        accessToken: value['accessToken'].toString(),
        user: User(
          firstName: value['user']['first_name'].toString(),
          lastName: value['user']['last_name'].toString(),
          id: value['user']['id'].toString(),
          isAdmin: value['user']['is_admin'] ?? false,
        ),
      );

      // Debug prints
      print('User Information Before Save: ${loginResponseModel.user!.firstName}');

      // Save the user information
      await userViewModel.saveUser(loginResponseModel);

      // Debug prints

      Get.delete<LoginViewModel>();

      Get.toNamed(
        RouteName.callview,
      );

      Utils.successDialogue("Logged In Successfully", context);
    }
    else {
      Utils.errorAlertDialogue("Invalid Credentials", context);
    }
  }
}
