
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/PasswordInputField.dart';
import '../../../utils/utils.dart';
import '../../../view_models/controller/login/login_viewmodel.dart';

class InputPasswordWidget extends StatelessWidget {
  InputPasswordWidget({Key? key}) : super(key: key);

  final loginVM = Get.put(LoginViewModel()) ;

  @override
  Widget build(BuildContext context) {
    return Obx(() => TextFormField(
      controller: loginVM.passwordController.value,
      focusNode: loginVM.passwordFocusNode.value,
      decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Enter your password',
          prefixIcon: const Icon(CupertinoIcons.padlock_solid),
          suffixIcon: IconButton(
            icon: Icon(
              loginVM.obscureText.value ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              loginVM.toggleObscureText();
            },
          ),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
          )
      ),
      obscureText: loginVM.obscureText.value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter password';
        }
        return null;
      },
      onChanged: (value) {
        loginVM.password.value = value;
      },
    ));
  }
}