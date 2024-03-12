import 'package:get/get.dart';
import 'package:whsuites_calling/data/network/network_api_services.dart';

import '../../../repository/beforelogin/login_repository.dart';

class CallTypeViewmodel extends GetxController{

  final apiservices =NetworkApiServices();
  final _api = LoginRepository();

  RxList<CustomerResult> customerResult = <CustomerResult>[].obs;
  RxList<LeadResult> leadResult = <LeadResult>[].obs;
  RxBool isLoading = false.obs;

  List<Map<String, dynamic>> getCustomerData() {
    return customerResult.map((customer) {
      return {
        'id' : customer.id,
        'firstName': customer.firstName,
        'lastName' : customer.lastName,
        'primaryEmail': customer.primaryEmail,
        'primary_contact' : customer.primaryContact
      };
    }).toList();
  }

  List<Map<String, dynamic>> getLeadData() {
    return leadResult.map((lead) {
      return {
        'id' : lead.id ,
        'firstName': lead.firstName,
        'lastName' : lead.lastName,
        'email': lead.email,
        'mobile' : lead.mobile
      };
    }).toList();
  }

  void search(String query) async {
    try {
      isLoading(true); // Set loading to true before making the API call

      // Call the globalSearchApi to fetch new data
      final response = await _api.globalSearchApi({'search': query});

      // Assuming the response structure matches the CustomerResult and LeadResult
      List<CustomerResult> newCustomerResults = [];
      List<LeadResult> newLeadResults = [];

      // Parse the response data and populate newCustomerResults and newLeadResults
      if (response['customerResult'] != null) {
        newCustomerResults = List<CustomerResult>.from(
            response['customerResult'].map((x) => CustomerResult.fromJson(x)));

        print("customerresponse ${List<CustomerResult>.from(
            response['customerResult'].map((x) => CustomerResult.fromJson(x)))}");
      }

      if (response['leadResult'] != null) {
        newLeadResults = List<LeadResult>.from(
            response['leadResult'].map((x) => LeadResult.fromJson(x)));
      }

      // Update the customerResult and leadResult lists with new data
      customerResult.assignAll(newCustomerResults);
      leadResult.assignAll(newLeadResults);
    } catch (e) {
      // Handle any errors that occur during the API call
      print('Error fetching data: $e');
    } finally {
      isLoading(false); // Set loading to false after API call completes
    }
  }
}
