
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
    return  PasswordInputField(
      controller: loginVM.passwordController.value,
      focusNode: loginVM.passwordFocusNode.value,
      prefixIcon: CupertinoIcons.lock_circle,

      suffixIcon: Icons.visibility,
      hintText: 'Enter password',
      obscureText: true,
      validator: (value){
        if(value!.isEmpty){
          Utils.textError(context, "Please Enter Password");
        }
      },
      onFieldSubmitted: (value){
      },
    );
  }
}


