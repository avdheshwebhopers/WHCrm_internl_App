import '../../data/network/network_api_services.dart';
import '../../res/app_url/app_urls.dart';
import '../../view_models/controller/user_preference/user_prefrence_view_model.dart';

class LoginRepository {

  final _apiService = NetworkApiServices();

  Future<dynamic> loginApi(var data) async {
    dynamic response = await _apiService.postApi( AppUrls.loginApi , data);
    return response;
  }

  Future<dynamic> leadDetailApi(var data) async {
    dynamic response = await _apiService.postApi( AppUrls.leadDetailApi , data);
    return response;
  }

  Future<dynamic> customerDetailApi (var data) async {
    dynamic response = await _apiService.postApi( AppUrls.customerDetailApi , data);
    return response;
  }

  Future<dynamic> globalSearchApi (var data) async {
    dynamic response = await _apiService.postApi( AppUrls.globalSearchApi , data);
    return response;
  }

  Future<dynamic> logOutApi (var data) async {
    dynamic response = await _apiService.postApi( AppUrls.logoutApi , data);
    return response;
  }

  Future<dynamic> callTypeApi () async {
    dynamic response = await _apiService.getApi( AppUrls.callType);
    return response;
  }

  Future<String> profileApi() async {
    UserViewModel userViewModel = UserViewModel();
    String id = (await userViewModel.getUser()).user?.id ?? '';
    dynamic response = await _apiService.getApi( "${AppUrls.profileApi}/$id" );
    print("profile response: $response");
    return response;
  }

}
