

import 'package:get/get.dart';
import 'package:whsuites_calling/res/routes/routes_name.dart';
import 'package:whsuites_calling/view/call/CallBinding.dart';
import 'package:whsuites_calling/view/call/call_view.dart';

import '../../view/login/login_view.dart';
import '../../view/splash_screen.dart';

class AppRoutes {

  static appRoutes() => [
    GetPage(
      name: RouteName.splashScreen,
      page: () => SplashScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 50),
    ),
    GetPage(
      name: RouteName.loginView,
      page: () => LoginView(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 50),
    ),
    GetPage(
      name: RouteName.callview,
      page: () => CallView(),
      binding: CallBinding(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 50),
    ),
  ];
}
