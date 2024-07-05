import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/textfields.dart';
import '../../../utils/utils.dart';
import '../../../view_models/controller/login/login_viewmodel.dart';

class InputEmailWidget extends StatelessWidget {
  InputEmailWidget({Key? key}) : super(key: key);

  final loginVM = Get.put(LoginViewModel());

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: loginVM.emailController.value,
      focusNode: loginVM.emailFocusNode.value,
      decoration: const InputDecoration(
          labelText: 'Email',
          hintText: 'Enter your email',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
        prefixIcon: Icon(CupertinoIcons.mail_solid)
      ),
      
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter email';
        }
        return null;
      },
      onChanged: (value) {
        loginVM.email.value = value;
      },
    );
  }
}
