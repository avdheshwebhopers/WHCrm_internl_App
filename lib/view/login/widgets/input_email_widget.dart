import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../utils/textfields.dart';
import '../../../utils/utils.dart';
import '../../../view_models/controller/login/login_viewmodel.dart';

class InputEmailWidget extends StatelessWidget {
   InputEmailWidget({Key? key}) : super(key: key);

  final loginVM = Get.put(LoginViewModel()) ;

  @override
  Widget build(BuildContext context) {
    return  TextInputField(
      titleController: loginVM.emailController.value,
      titleFocusNode: loginVM.emailFocusNode.value,
      hintText: 'Enter email or mobile number',
      prefixIcon: CupertinoIcons.mail,

      titleValidator: (value){
        if (value!.isEmpty) {
          Utils.textError(context, "Please Enter Email");
        }
        // else if (!validateEmail(value)) {
        //   Utils.textError(
        //       context, "Please Enter a Valid Email");
        // }
      },

      onFieldSubmitted: (value){
        print(value);
        //Utils.(context, loginVM.emailFocusNode.value, loginVM.passwordFocusNode.value);
      },
      // decoration: InputDecoration(
      //     hintText: 'email_hint'.tr,
      // ),
    );
  }

   // bool validateEmail(String email) {
   //   String emailPattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
   //   RegExp regex = RegExp(emailPattern);
   //   return regex.hasMatch(email);
   // }
}




