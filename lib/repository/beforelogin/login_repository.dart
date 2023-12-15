import 'package:whsuits_crm/response_model/login_response_model.dart';
import '../../resources/app_urls.dart';
import '../network/base_api_services.dart';
import '../network/network_api_services.dart';

class LoginRepository{

  BaseApiServices apiServices = NetworkApiServices();

  Future<LoginResponseModel> login(dynamic data) async {
    try{
      dynamic response =  await apiServices.postApiResponse(AppUrls.login, data);
      return response = LoginResponseModel.fromJson(response);
    }catch(e){
      rethrow;
    }
  }
}