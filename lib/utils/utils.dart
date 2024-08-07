import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whsuites_calling/utils/text_style.dart';

class Utils {

  static void textError(BuildContext context, String message) {
    Flushbar(
      messageText: Text(message,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16,color: Colors.white),  ),
      icon: Icon(Icons.error, color: Colors.white, size: 30),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red.shade700,
      borderRadius: BorderRadius.circular(10),
      margin: EdgeInsets.fromLTRB(20, 10 , 20 , 20),
      padding: EdgeInsets.all(20),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    ).show(context);

  }
  static void successText(BuildContext context, String message) {
    Flushbar(
      messageText: Text(message,style: const TextStyle(fontWeight: FontWeight.w500 , fontSize: 16,color: Colors.white),  ),
      icon: const Icon(Icons.check_circle, color: Colors.white, size: 30),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green.shade800,
      borderRadius: BorderRadius.circular(20),
      margin: EdgeInsets.fromLTRB(20, 10 , 20 , 20),
      padding: EdgeInsets.all(20),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    ).show(context);

  }

  static void errorAlertDialogue(String? message, BuildContext context) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Padding(
            padding: EdgeInsets.all(20),
            child: Icon(Icons.error_outline, textDirection: TextDirection.ltr, color: Colors.red, size: 50,),
          ),
          content: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Text(message!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
          ),
        );
      },
    );
  }

  static void successDialogue(String? message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Padding(
            padding: EdgeInsets.all(20),
            child: Icon(Icons.check_circle_outlined, textDirection: TextDirection.ltr, color: Colors.green, size: 50,),
          ),
          content: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Text(message!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
          ),
        );
      },
    );
  }

  static void confirmationDialogue(String? message , String? title ,onPress, BuildContext context){

    showDialog(context: context, builder: (BuildContext context){
      return CupertinoAlertDialog(
        title: TextWithStyle.containerTitle(context, title!),
        content: Padding(
          padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
          child: Text(message!,textAlign: TextAlign.center,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
        ),
        actions: <Widget> [
          CupertinoDialogAction(child: const Text("Cancel"),
            onPressed: (){
              Navigator.of(context).pop();
            },),
          CupertinoDialogAction(child: const Text('OK'),
              onPressed: onPress),
        ],
      );
    });
  }
}