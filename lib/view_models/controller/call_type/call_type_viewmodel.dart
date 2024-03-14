import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/response_model/call_type.dart';
import '../../../repository/beforelogin/login_repository.dart';

class CallTypeViewmodel extends GetxController{

  final _api = LoginRepository();

  Future<void>  callTypeApi() async{
    try {
      // Call the API to get data
      var apiResponse = await _api.callTypeApi();

      // Handle the API response
      if (apiResponse != null) {
        // Assuming the response contains data in the format of Lead or Customer
        var responseData = apiResponse as Map<String, dynamic>;

        if (responseData.containsKey('lead')) {
          // If it's Lead data, parse it and save it using the ViewModel
          var leadData = responseData['lead'];
          Lead lead = Lead.fromJson(leadData);
          await saveLeadCallType(lead);
        } else if (responseData.containsKey('customer')) {
          // If it's Customer data, parse it and save it using the ViewModel
          var customerData = responseData['customer'];
          Customer customer = Customer.fromJson(customerData);
          await saveCustomerCallType(customer);
        }
      } else {
        // Handle API response error, if needed
      }
    } catch (e) {
      // Handle API call error
      print("Error: $e");
    }
  }

  static Future<void> saveLeadCallType(Lead lead) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('leadNumberBusy', lead.numberBusy ?? "");
    await prefs.setString('leadAnswered', lead.answered ?? "");
    await prefs.setString('leadWrongNumber', lead.wrongNumber ?? "");
    await prefs.setString('leadNotAnswered', lead.notAnswered ?? "");
    await prefs.setString('leadMeetingFixed', lead.meetingFixed ?? "");
    await prefs.setString('leadLookingForJob', lead.lookingForJob ?? "");
  }

  // Load Lead call type from shared preferences
  static Future<Lead> loadLeadCallType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Lead(
      numberBusy: prefs.getString('leadNumberBusy'),
      answered: prefs.getString('leadAnswered'),
      wrongNumber: prefs.getString('leadWrongNumber'),
      notAnswered: prefs.getString('leadNotAnswered'),
      meetingFixed: prefs.getString('leadMeetingFixed'),
      lookingForJob: prefs.getString('leadLookingForJob'),
    );
  }

  // Save Customer call type to shared preferences
  static Future<void> saveCustomerCallType(Customer customer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('customerFeedbackCallAnswered', customer.feedbackCallAnswered ?? "");
    await prefs.setString('customerNotAnswered', customer.notAnswered ?? "");
    await prefs.setString('customerWrongNumber', customer.wrongNumber ?? "");
    await prefs.setString('customerMeetingFixed', customer.meetingFixed ?? "");
    await prefs.setString('customerNumberBusy', customer.numberBusy ?? "");
    await prefs.setString('customerRenewalCallNotAnswered', customer.renewalCallNotAnswered ?? "");
    await prefs.setString('customerPendingPaymentNotAnswered', customer.pendingPaymentNotAnswered ?? "");
    await prefs.setString('customerRenewalCallNumberBusy', customer.renewalCallNumberBusy ?? "");
    await prefs.setString('customerAnswered', customer.answered ?? "");
    await prefs.setString('customerRenewalCallAnswered', customer.renewalCallAnswered ?? "");
    await prefs.setString('customerPendingPaymentAnswered', customer.pendingPaymentAnswered ?? "");
    await prefs.setString('customerFeedbackCallNotAnswered', customer.feedbackCallNotAnswered ?? "");
    await prefs.setString('customerFeedbackCallNumberBusy', customer.feedbackCallNumberBusy ?? "");
    await prefs.setString('customerPendingPaymentNumberBusy', customer.pendingPaymentNumberBusy ?? "");
  }

  // Load Customer call type from shared preferences
  static Future<Customer> loadCustomerCallType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Customer(
      feedbackCallAnswered: prefs.getString('customerFeedbackCallAnswered'),
      notAnswered: prefs.getString('customerNotAnswered'),
      wrongNumber: prefs.getString('customerWrongNumber'),
      meetingFixed: prefs.getString('customerMeetingFixed'),
      numberBusy: prefs.getString('customerNumberBusy'),
      renewalCallNotAnswered: prefs.getString('customerRenewalCallNotAnswered'),
      pendingPaymentNotAnswered: prefs.getString('customerPendingPaymentNotAnswered'),
      renewalCallNumberBusy: prefs.getString('customerRenewalCallNumberBusy'),
      answered: prefs.getString('customerAnswered'),
      renewalCallAnswered: prefs.getString('customerRenewalCallAnswered'),
      pendingPaymentAnswered: prefs.getString('customerPendingPaymentAnswered'),
      feedbackCallNotAnswered: prefs.getString('customerFeedbackCallNotAnswered'),
      feedbackCallNumberBusy: prefs.getString('customerFeedbackCallNumberBusy'),
      pendingPaymentNumberBusy: prefs.getString('customerPendingPaymentNumberBusy'),
    );
  }
}