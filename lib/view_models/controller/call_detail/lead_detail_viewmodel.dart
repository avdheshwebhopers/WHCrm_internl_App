import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/network/network_api_services.dart';
import '../../../res/app_url/app_urls.dart';
import '../../../utils/utils.dart';
import 'package:http/http.dart' as http;

class LeadDetailsViewModel extends GetxController {
  final _apiService = NetworkApiServices();

  // Observable variables for call details
  var id = ''.obs;
  var type = ''.obs;
  var duration = ''.obs;
  var date = ''.obs;
  var fromNumber = ''.obs;
  var toNumber = ''.obs;
  var calltype = ''.obs;
  var remark = ''.obs;
  var createFrom = ''.obs;
  var reminder = ''.obs;
  final loading = false.obs;

  Future<String> _getDeviceToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('accessToken') ?? '';
  }
  Future<void> leadDetailApi(BuildContext context, Uint8List? latestMp3FilePath, String? directoryPath) async {

    loading.value = true;

    // Define the list of fields to check for emptiness
    final fieldNames = [
      'ID',
      'Type',
      'Duration',
      'Date',
      'From Number',
      'To Number',
      'Call Type',
      'Create From',
      'Reminder'
    ];

    final fields = [type, duration, date, fromNumber, toNumber, calltype];

    for (int i = 0; i < fields.length; i++) {
      if (fields[i].value.isEmpty) {
        loading.value = false;
        Utils.errorAlertDialogue("${fieldNames[i]} is empty", context);
        return;
      }
    }

    if (id.value.isEmpty) {
      Utils.errorAlertDialogue("Waiting for the call", context);
      return;
    }

    var url = AppUrls.leadDetailApi;
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Check if duration is 0, if so, don't send the MP3 file
    if (duration.value == '0') {
      // Proceed with sending other data or return if appropriate
      request.fields.addAll({
        'id': id.value,
        'type': type.value,
        'duration': duration.value,
        'date': date.value,
        'from_number': fromNumber.value,
        'to_number': toNumber.value,
        'call_type': calltype.value,
        'remark': remark.value,
        'create_from': createFrom.value,
        'reminder': reminder.value
      });
    } else {
      if (latestMp3FilePath != null && directoryPath != null) {
        String? originalExtension = directoryPath.split('.').last;
        String filename = '${toNumber.value}.$originalExtension'; // Construct the filename with the original extension

        request.files.add(
          http.MultipartFile.fromBytes(
            'call_record',
            latestMp3FilePath,
            filename: filename,
          ),
        );

        // Print the filename
        print('Filename being sent: $filename');
        print('path is here: $directoryPath');
        // Log or print the request object to inspect it
        print('Request object after adding file: $request');
        // Log the size of the file being sent
        print('File size: ${latestMp3FilePath.length} bytes');
      }

      // Add other fields to the request
      request.fields.addAll({
        'id': id.value,
        'type': type.value,
        'duration': duration.value,
        'date': date.value,
        'from_number': fromNumber.value,
        'to_number': toNumber.value,
        'call_type': calltype.value,
        'remark': remark.value,
        'create_from': createFrom.value,
        'reminder': reminder.value
      });
    }

    final token = await _getDeviceToken();

    try {
      print('Sending request...');
      print("Token: >>$token");
      var response = await _apiService.postApiResponserequest(url, request, token);

      // Check the response status
      if (response != null) {
        print('Response received: $response');
        if (response is Map<String, dynamic>) {
          print(response);
          Utils.successDialogue("Call Placed Successfully", context);
        } else {
          Utils.errorAlertDialogue("Data Missing $response", context);
        }
      } else {
        Utils.errorAlertDialogue("Failed to send data.", context);
      }
    } catch (error) {
      loading.value = false;
      print('Error sending request: $error');
      if (kDebugMode) {
        print(error.toString());
      }
    }
  }
}
