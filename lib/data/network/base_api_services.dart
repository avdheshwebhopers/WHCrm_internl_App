
abstract class BaseApiServices{

  Future<dynamic> getApiResponse (String url);

  Future<dynamic> postApiResponse(String url, dynamic data);

  Future<dynamic> postEmptyParmApiResponse(String url, dynamic bodyParms);

  Future<dynamic> deleteApiResponse(String url);

  Future<dynamic> putApiResponse(String url, dynamic bodyParms);

}