
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class CallControllers extends GetxController {
  late io.Socket socket;
  final RxString receivedPhoneNumber = RxString('');
  final RxString receivedID = RxString('');
  final RxString type = RxString('');
  final RxString answered = RxString('');
  final RxString notAnswered = RxString('');

  String accessToken = '';

  final _receivedPhoneNumberController = StreamController<String>();
  Stream<String> get receivedPhoneNumberStream => _receivedPhoneNumberController.stream;

  final _receivedIDController = StreamController<String>();
  Stream<String> get receivedIDStream => _receivedIDController.stream;

  final _typeController = StreamController<String>();
  Stream<String> get typeStream => _typeController.stream;

  final _answeredController = StreamController<String>();
  Stream<String> get answeredStream => _answeredController.stream;

  final _notAnsweredController = StreamController<String>();
  Stream<String> get notAnsweredStream => _notAnsweredController.stream;

  @override
  void onInit() {
    super.onInit();
    accessToken = Get.arguments?['accessToken'] ?? '';
    print("accessToken>>>>> $accessToken");
    initSocket();
    // Make sure initSocket is called during initialization
  }

  Future<void> initSocket() async {
    socket = io.io("https://webhopers.whsuites.com:3006/socket", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    socket.connect();

    socket.onConnect((data) => _handleConnectedSocket());
    socket.onDisconnect((data) => _handleDisconnectedSocket());

    final deviceToken = await _getDeviceToken();
    print("deviceToken: $deviceToken");

    print(socket);

    socket.on('make-call-$deviceToken', (data) {
      print('Received message from server: $data');
      receivedPhoneNumber.value = data["phone"];
      receivedID.value = data["id"];
      type.value = data["type"];
      answered.value = data["call_type"]["Answered"];
      notAnswered.value = data["call_type"]["Not Answered"];
      print('Emitting phone number: ${receivedPhoneNumber.value} , ${receivedID.value} , ${type.value} , ${answered.value} , ${notAnswered.value}');
      _handleReceivedPhoneNumber(receivedPhoneNumber.value , receivedID.value , type.value , answered.value , notAnswered.value);
    });
  }

  void _handleConnectedSocket() {
    // Perform any actions that require a connected socket
    print('Handling connected socket');
  }

  void _handleDisconnectedSocket() {
    // Perform any actions when the socket is disconnected
    print('Handling disconnected socket');
  }

  void _handleReceivedPhoneNumber(String phoneNumber , String id , String type , String answered , String notAnswered)  {
    // Perform any actions with the received phone number
    print('Received phone number: $phoneNumber , $id ');
    // Emit the received phone number through the stream
    _receivedPhoneNumberController.add(phoneNumber);
    _receivedIDController.add(id);
    _typeController.add(type);
    _answeredController.add(answered);
    _notAnsweredController.add(notAnswered);
  }

  Future<String> _getDeviceToken() async {
    final messaging = FirebaseMessaging.instance;
    return await messaging.getToken() ?? "abed12345";
  }

  @override
  void onClose() {
    // Close the socket when the controller is disposed
    socket.disconnect();
    super.onClose();

    // Close the stream controllers only when the socket is disconnected
    if (!socket.connected) {
      _receivedPhoneNumberController.close();
      _receivedIDController.close();
    }
  }
}


