import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/response_model/login_response_model.dart';

class UserViewModel{

  Future<bool> saveUser(LoginResponseModel user)async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('accessToken', user.accessToken.toString());
    sp.setString('first_name', user.user!.firstName.toString());
    sp.setString('last_name', user.user!.lastName.toString());
    sp.setString('id', user.user!.id.toString());
    sp.setBool('is_admin', user.user!.isAdmin ?? false); // Ensure a default value if it can be null
    return true;
  }

  Future<LoginResponseModel> getUser()async{

  final SharedPreferences sp = await SharedPreferences.getInstance();
  final String? token = sp.getString('accessToken');
  final String? name = sp.getString('first_name');
  final String? lastname = sp.getString('last_name');
  final String? id = sp.getString('id');
  final bool? isOwner = sp.getBool('is_admin');

  return LoginResponseModel(
  accessToken : token.toString(),
  user: User(
  firstName: name.toString(),
  lastName: lastname.toString(),
  id: id.toString(),
  isAdmin: isOwner,
  ));
  }

  Future<bool> remove()async{
  final SharedPreferences sp = await SharedPreferences.getInstance();
  sp.remove('accessToken');
  return true;
  }
}