
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/Button.dart';
import '../../../view_models/controller/login/login_viewmodel.dart';

class LoginButtonWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  LoginButtonWidget( {Key? key, required this.formKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginViewModel>(
      builder: (loginVM) {
        return Obx(
              () => Button(
            title: 'Login',
            isLoading: loginVM.loading.value,
            onPress: () {
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