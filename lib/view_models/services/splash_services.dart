import 'dart:async';
import 'package:get/get.dart';
import '../../res/routes/routes_name.dart';
import '../controller/user_preference/user_prefrence_view_model.dart';

class SplashServices {

  UserViewModel userPreference = UserViewModel();

  void isLogin(){

    userPreference.getUser().then((value){
      print(value.accessToken);
      if(value.accessToken == "null" || value.accessToken.toString() == ''){
        Timer(const Duration(seconds: 3),
                () => Get.toNamed(RouteName.loginView));
      }else {
        Timer(
          const Duration(seconds: 3),
              () => Get.toNamed(
            RouteName.callview,
            arguments: {'accessToken': value.accessToken},
          ),
        );
      }
    });
  }
}