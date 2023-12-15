import 'package:whsuits_crm/repository/login_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:whsuits_crm/user_viewModel.dart';
import 'package:provider/provider.dart';
import 'package:whsuits_crm/response_model/login_response_model.dart';
import 'package:whsuits_crm/PopUp.dart';
import 'home_screen.dart';

class LoginViewModel with ChangeNotifier{

  final _myRepo = LoginRepository();

  bool _loading = false ;
  bool get loading => _loading ;

  setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  Future<void> login(dynamic data, BuildContext context) async {

    setLoading(true);

    _myRepo.login(data).then((value) {
      setLoading(false);

      if (value.accessToken != null && value.user != null) {
        print("Login successful. Access Token: ${value.accessToken}");

        final userPreferences = Provider.of<UserViewModel>(context, listen: false);
        userPreferences.saveUser(
          LoginResponseModel(
            accessToken: value.accessToken.toString(),
            user: User(
              firstName: value.user?.firstName.toString(),
              isAdmin: value.user?.isAdmin ?? false,
            ),
          ),
        );

        // Print information for debugging
        print("Login successful. Access Token: ${value.accessToken}");

        // Show a success message
        Popup.errorAlertDialogue("Logged In Successfully", context);

        // Navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              token: value.user?.firstName!,
              isAdmin: value.user?.isAdmin ?? false,
            ),
          ),
        );
      } else {
        // Print information for debugging
        print("Login failed. Access Token: ${value.accessToken}, User: ${value.user}");

        // Handle the case where either accessToken or user is null
        Popup.errorAlertDialogue("Invalid Credentials", context);
      }
    }).catchError((error) {
      // Handle errors during login
      setLoading(false);
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

}