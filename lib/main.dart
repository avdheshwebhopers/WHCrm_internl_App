import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:whsuites_calling/res/colors/app_color.dart';
import 'package:whsuites_calling/res/routes/routes.dart';
import 'package:whsuites_calling/view/call/call_view.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async {
  Platform.isAndroid?
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD7x0K9O-ulJQr8r6xxl8glbahEXZJFcXg",
      appId: "1:400761969368:android:02ffdeb660ad94ccf1d5ad",
      messagingSenderId: "400761969368",
      projectId: "whsuites-firebase",
    ),
  )
      :await Firebase.initializeApp();
}


Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColors.backgroundcolor,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();


  Platform.isAndroid?
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD7x0K9O-ulJQr8r6xxl8glbahEXZJFcXg",
      appId: "1:400761969368:android:02ffdeb660ad94ccf1d5ad",
      messagingSenderId: "400761969368",
      projectId: "whsuites-firebase",
    ),
  )
      :await Firebase.initializeApp();
  //await Cart().loadCart();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              fontFamily: "SFPro-Rounded",
              brightness: Brightness.light,
              primarySwatch: Colors.indigo,
              scaffoldBackgroundColor: AppColors.backgroundcolor,
              appBarTheme: AppBarTheme(
                  color: AppColors.backgroundcolor.withOpacity(1),
                  iconTheme: const IconThemeData(
                      color: Colors.black
                  ))
          ),
        getPages: AppRoutes.appRoutes(),
      );
  }
}



