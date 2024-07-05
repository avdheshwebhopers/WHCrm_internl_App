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

  var email = ''.obs;
  var password = ''.obs;
  final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;

  final emailFocusNode = FocusNode().obs;
  final passwordFocusNode = FocusNode().obs;

  final loading = false.obs;
  var obscureText = true.obs;

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  Future<void> loginApi(BuildContext context) async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Utils.errorAlertDialogue("Please enter email and password", context);
      return;
    }

    loading.value = true;

    final deviceToken = await _getDeviceToken();

    Map<String, String> data = {
      'email': email.value,
      'password': password.value,
      'device_id': deviceToken,
    };

    try {
      final value = await _api.loginApi(data);
      if (value is Map<String, dynamic> && value.containsKey('accessToken')) {
        loading.value = false;
        await _handleSuccessfulLogin(context, value);
      } else {
        loading.value = false;
        Utils.errorAlertDialogue("Invalid Credentials", context);
      }
    } catch (error) {
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

  Future<void> _handleSuccessfulLogin(BuildContext context, Map<String, dynamic> value) async {
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
      print('User Information Before Save: ${loginResponseModel.user?.firstName}');

      // Save the user information
      await userViewModel.saveUser(loginResponseModel);

      // Debug prints
      Get.delete<LoginViewModel>();

      Get.toNamed(
        RouteName.callview,
      );

      Utils.successText(context, "Logged In Successfully");
    } else {
      Utils.errorAlertDialogue("Invalid Credentials", context);
    }
  }
}
