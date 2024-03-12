import '../../data/network/network_api_services.dart';
import '../../res/app_url/app_urls.dart';
import '../../view_models/controller/user_preference/user_prefrence_view_model.dart';


class LoginRepository {

  final _apiService = NetworkApiServices();


  Future<dynamic> loginApi(var data) async {
    dynamic response = await _apiService.postApiResponse( AppUrls.loginApi , data);
    return response;
  }

  Future<dynamic> leadDetailApi(var data) async {
    dynamic response = await _apiService.postApiResponse( AppUrls.leadDetailApi , data);
    return response;
  }

  Future<dynamic> customerDetailApi (var data) async {
    dynamic response = await _apiService.postApiResponse( AppUrls.customerDetailApi , data);
    return response;
  }

  Future<dynamic> globalSearchApi (var data) async {
    dynamic response = await _apiService.postApiResponse( AppUrls.globalSearchApi , data);
    return response;
  }

  Future<dynamic> logOutApi (var data) async {
    dynamic response = await _apiService.postApiResponse( AppUrls.logoutApi , data);
    return response;
  }

  Future<dynamic> callTypeApi (var data) async {
    dynamic response = await _apiService.postApiResponse( AppUrls.callType , data);
    return response;
  }

   Future<String> profileApi() async {
    UserViewModel userViewModel = UserViewModel();
    String id = (await userViewModel.getUser()).user?.id ?? '';
    dynamic response = await _apiService.getApiResponse( "${AppUrls.profileApi}/$id" );
    print("profile response: $response");
    return response;
  }


}





