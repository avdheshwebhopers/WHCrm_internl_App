import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/network/network_api_services.dart';
import '../../../res/app_url/app_urls.dart';
import '../../../utils/utils.dart';
import 'package:http/http.dart' as http;

class CallDetailsViewModel extends GetxController {

  final _apiService = NetworkApiServices();

  // Observable variables for call details
  var id = ''.obs;
  var type = ''.obs;
  var duration = ''.obs;
  var date = ''.obs;
  var fromNumber = ''.obs;
  var toNumber = ''.obs;
  var calltype = ''.obs;
  final loading = false.obs;

  Future<void> callDetailApi(BuildContext context,
      Uint8List latestMp3FilePath) async {
      loading.value = true;

    // Define the list of fields to check for emptiness
    final fieldNames = [
      'ID',
      'Type',
      'Duration',
      'Date',
      'From Number',
      'To Number'
      'Call Type'
    ];

    final fields = [id, type, duration, date, fromNumber, toNumber];

    for (int i = 0; i < fields.length; i++) {

      if (fields[i].value.isEmpty) {
        loading.value = false;
        print("$id, $type, $duration, $date, $fromNumber, $toNumber");
        Utils.errorAlertDialogue("${fieldNames[i]} is empty", context);
        return;
      }
    }

    // Get the latest MP3 file path
    // Check if the duration is 0
    // Ensure the latest MP3 file data is not empty

    if (latestMp3FilePath.isEmpty) {
      loading.value = false;
      Utils.errorAlertDialogue("Latest MP3 file data is empty", context);
      return;
    }

    // ... check for other fields and handle validation

    var url = AppUrls
        .leadDetailApi ;
    // Assuming AppUrls.callDetailApi is your API endpoint
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Attach the MP3 file as a part

    request.files.add(
      http.MultipartFile.fromBytes(
        'call_record',
        latestMp3FilePath,
        filename: '$toNumber.mp3',
      ),
    );

    // Add other fields to the request
    request.fields.addAll({
      'id': id.value,
      'type': type.value,
      'duration': duration.value,
      'date': date.value,
      'from_number': fromNumber.value,
      'to_number': toNumber.value,
      'call_type': calltype.value,
    });

    try {
      print('Sending request...');
      // String token = await _apiService.postApiResponseToken();
      var response = await _apiService.postApiResponserequest(url, request , 'token');

      // Check the response status
      if (response != null) {
        print('Response received: $response');
        if (response is Map<String, dynamic>) {
          print(response);
          Utils.successDialogue("Data Sent Successfully", context);
        } else {
          Utils.errorAlertDialogue("Data Missing $response", context);
        }
      } else {
        // Handle error response
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