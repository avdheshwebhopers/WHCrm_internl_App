
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../res/routes/routes_name.dart';
import '../../view_models/controller/user_preference/user_prefrence_view_model.dart';
import '../app_exceptions.dart';
import 'base_api_services.dart';

class NetworkApiServices extends BaseApiServices {

  @override
  Future deleteApiResponse(String url) async {
    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson ;
    try {
      final response = await http.delete(Uri.parse(url)).timeout( const Duration(seconds: 10));
      responseJson  = _returnResponse(response) ;
    }on SocketException {
      throw InternetException('');
    }on RequestTimeOut {
      throw RequestTimeOut('Request Time out');

    }
    return responseJson ;
  }

  @override
  Future getApiResponse(String url) async {
    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson ;
    try {
      final response = await http.get(Uri.parse(url)).timeout( const Duration(seconds: 10));
      responseJson  = _returnResponse(response) ;
    }on SocketException {
      throw InternetException('');
    }on RequestTimeOut {
      throw RequestTimeOut('Request Time out');
    }
    return responseJson ;

  }

  @override
  Future postApiResponse(String url, dynamic data) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }
    final sp = await SharedPreferences.getInstance();
    String? token = sp.getString('accessToken');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${token ?? ''}"
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      final responseJson = _returnResponse(response);
      if (kDebugMode) {
        print("Json response : ${responseJson.toString()}");
      }
      return responseJson;
    } catch (e) {
      _handleError(e);
      rethrow; // Propagate the error up the chain
    }
  }

  @override
  Future postApiResponserequest(String url, http.MultipartRequest request, String token) async {
    if (kDebugMode) {
      print(url);
      print(request);
    }

    try {
      // Set the authorization header
      request.headers['Authorization'] = 'Bearer ${token ?? ''}';

      // Use http.Client to send the multipart request
      final client = http.Client();
      final response = await client.send(request).timeout(const Duration(seconds: 10));

      // Read and parse the response
      final responseBody = await response.stream.bytesToString();
      final responseJson = _returnResponse(http.Response(responseBody, response.statusCode));
      if (kDebugMode) {
        print("Json response : ${responseJson.toString()}");
      }

      // Try to extract the token from the response headers
      final responseToken = response.headers['authorization'] ?? json.decode(responseBody)['authorization'];

      // Close the client
      client.close();

      // Access the response token here (responseToken)
      print("Response Token: $responseToken");

      return responseJson;
    } catch (e) {
      _handleError(e);
      rethrow; // Propagate the error up the chain
    }
  }

// Helper function to handle errors
  void _handleError(dynamic e) {
    if (e is SocketException) {
      throw InternetException('');
    } else if (e is TimeoutException) {
      throw RequestTimeOut('Request Time out');
    }
  }

  Future<String> postApiResponseToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('accessToken') ?? '';
  }

  @override
  Future postEmptyParmApiResponse(String url, bodyParms) async {
    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson ;
    try {
      final response = await http.post(Uri.parse(url)).timeout( const Duration(seconds: 10));
      responseJson  = _returnResponse(response) ;
    }on SocketException {
      throw InternetException('');
    }on RequestTimeOut {
      throw RequestTimeOut('Request Time out');
    }
    print(responseJson.toString());
    return responseJson ;
  }

  @override
  Future putApiResponse(String url, bodyParms)async {
    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson ;
    try {
      final response = await http.put(Uri.parse(url)).timeout( const Duration(seconds: 10));
      responseJson  = _returnResponse(response) ;
    }on SocketException {
      throw InternetException('');
    }on RequestTimeOut {
      throw RequestTimeOut('Request Time out');
    }
    print(responseJson.toString());
    return responseJson ;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        return responseJson;

      case 201:
        var responseJson = json.decode(response.body.toString());
        print("json response is here: $responseJson");
        return responseJson;

      case 400:
        var responseJson = json.decode(response.body.toString());
        return responseJson;

      case 401:
        _handleUnauthorized();
        break;

      case 403:
        var responseJson = json.decode(response.body.toString());
        return responseJson;

      case 404:
        var responseJson = json.decode(response.body.toString());
        return responseJson;

      case 405:
        var responseJson = json.decode(response.body.toString());
        return responseJson;

      case 422:
        var responseJson = json.decode(response.body.toString());
        return responseJson;

      case 500:
        var responseJson = json.decode(response.body.toString());
        return responseJson;

      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}

// Handle the unauthorized scenario
void _handleUnauthorized() async {

  // Show an alert dialog indicating session expired
  await Get.defaultDialog(
    barrierDismissible: false,
    title: "Session Expired",
    middleText: "Your session has expired. Please log in again.",
    onConfirm: () async {
      // Clear any user-related data
      await _logoutAndNavigateToSignIn();
    },
  );
}

// Logout the user and navigate to the sign-in screen
Future<void> _logoutAndNavigateToSignIn() async {
  UserViewModel userViewModel = UserViewModel();

  // Clear any user-related data
  userViewModel.remove();

  // Navigate to the login view and clear the entire navigation stack
  Get.offAllNamed(RouteName.loginView);
}








