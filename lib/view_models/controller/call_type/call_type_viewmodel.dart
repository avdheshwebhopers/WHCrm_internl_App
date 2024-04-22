import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/response_model/call_type.dart';
import '../../../repository/beforelogin/login_repository.dart';

class CallTypeViewmodel extends GetxController {
  final _api = LoginRepository();

  Future<void> callTypeApi() async {
    try {
      var apiResponse = await _api.callTypeApi();

      if (apiResponse != null) {
        var responseData = apiResponse as Map<String, dynamic>;

        if (responseData.containsKey('lead') && responseData.containsKey('customer')) {
          var leadData = responseData['lead'];
          var customerData = responseData['customer'];
          CallType callType = CallType(lead: Map<String, dynamic>.from(leadData) , customer: Map<String, dynamic>.from(customerData));
          print("leadData: ${responseData['lead']}");
          await saveCallType(callType);
          print("customerData: ${responseData['customer']}");
        //  await saveCallType(callType);
        }
      } else {
        // Handle API response error, if needed
      }
    } catch (e) {
      // Handle API call error
      print("Error: $e");
    }
  }

  static Future<void> saveCallType(CallType callType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (callType.lead != null) {
      callType.lead!.forEach((key, value) async {
        await prefs.setString('lead_$key', value.toString());
      });
    }
    if (callType.customer != null) {
      callType.customer!.forEach((key, value) async {
        await prefs.setString('customer_$key', value.toString());
      });
    }
  }

  static Future<CallType> loadCallType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> leadData = {};
    Map<String, dynamic> customerData = {};

    prefs.getKeys().forEach((key) {
      if (key.startsWith('lead_')) {
        leadData[key.substring(5)] = prefs.getString(key);
      } else if (key.startsWith('customer_')) {
        customerData[key.substring(9)] = prefs.getString(key);
      }
    });

    return CallType(lead: leadData.isNotEmpty ? leadData : null, customer: customerData.isNotEmpty ? customerData : null);
  }
}