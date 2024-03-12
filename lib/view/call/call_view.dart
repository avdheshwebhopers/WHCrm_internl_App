
import 'dart:async';
import 'dart:io';

import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:whsuites_calling/res/assets/image_assets.dart';
import 'package:whsuites_calling/res/colors/app_color.dart';
import 'package:whsuites_calling/utils/text_style.dart';
import 'package:whsuites_calling/view/call/CallControllers.dart';
import 'package:whsuites_calling/view_models/controller/call_detail/lead_detail_viewmodel.dart';
import 'package:workmanager/workmanager.dart';

import '../../repository/beforelogin/login_repository.dart';
import '../../res/routes/routes_name.dart';
import '../../utils/utils.dart';
import '../../view_models/controller/call_detail/customer_detail_viewmodel.dart';
import '../../view_models/controller/user_preference/user_prefrence_view_model.dart';


void callbackDispatcher() {
  Workmanager().executeTask((dynamic task, dynamic inputData) async {
    print('Background Services are Working!');
    try {
      final Iterable<CallLogEntry> cLog = await CallLog.get();
      print('Queried call log entries');
      for (CallLogEntry entry in cLog) {
        print('-------------------------------------');
        print('F. NUMBER  : ${entry.formattedNumber}');
        print('C.M. NUMBER: ${entry.cachedMatchedNumber}');
        print('NUMBER     : ${entry.number}');
        print('NAME       : ${entry.name}');
        print('TYPE       : ${entry.callType}');
        print('DATE       : ${DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)}');
        print('DURATION   : ${entry.duration}');
        print('ACCOUNT ID : ${entry.phoneAccountId}');
        print('SIM NAME   : ${entry.simDisplayName}');
        print('-------------------------------------');
      }
      return true;
    } on PlatformException catch (e, s) {
      print(e);
      print(s);
      print("callog permission");
      return true;
    }
  });
}

class CallView extends StatefulWidget {
  const CallView({Key? key}) : super(key: key);

  @override
  _CallViewState createState() => _CallViewState();
}

class _CallViewState extends State<CallView> with WidgetsBindingObserver {
  final LeadDetailsViewModel _leadDetailsViewModel = Get.find<
      LeadDetailsViewModel>();
  final CustomerDetailsViewModel _customerDetailsViewModel = Get.find<
      CustomerDetailsViewModel>();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  final TextEditingController _phoneNumberController = TextEditingController();
  final CallControllers _callControllers = Get.find<CallControllers>();
  UserViewModel userViewModel = UserViewModel();
  SongModel? _latestSong;
  bool showBottomNavigation = false;
  List<Widget> views = [];
  String _receivedID = "";
  String _type = "";
  String _answered = "";
  String _notAnswered = "";

  bool _hasPermission = false;
  CallLogEntry? _latestCallLogEntry;
  final _api = LoginRepository();

  @override
  void initState() {
    super.initState();

   // _fetchProfileApi();
    retrievePermissions();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _callDisconnected = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onAppResumed();
      _callDisconnected = false;
    } else if (state == AppLifecycleState.paused) {
      _callDisconnected = true;
    }
  }

  void _onAppResumed() async {
    if (_callDisconnected) {
      final String phoneNumberToSearch = "+91" + _phoneNumberController.text;
      await _getCallLog(phoneNumberToSearch);
      Uint8List latestMp3FilePath = await _getLatestMp3FileData();
      if (latestMp3FilePath.isNotEmpty) {
        _setCallDetails(phoneNumberToSearch, latestMp3FilePath);
      }
    }
  }

  void retrievePermissions({bool retry = false}) async {
    try {
      _hasPermission = await _audioQuery.checkAndRequest(retryRequest: retry);
      if (_hasPermission) {
        print("Permissions retrieved successfully.");
        // Permissions granted, proceed with setup
        setState(() {
          setupStreamListeners();
        });
      } else {
        // Permissions denied
        print('Permissions denied for accessing audio resources.');
        // Optionally, you can prompt the user to grant permissions again
        // Or provide guidance on how to grant permissions manually
      }
    } on PlatformException catch (e) {
      // Platform-specific exception occurred
      print('Platform exception occurred: $e');
      // Handle specific platform exceptions if needed
    } catch (e) {
      // Generic error occurred while checking or requesting permissions
      print('Error retrieving permissions: $e');
      // Optionally, handle the error gracefully or show an error message to the user
    }
  }

  void setupStreamListeners() {
    _callControllers.receivedPhoneNumberStream.listen(_handleReceivedPhoneNumber);
    _callControllers.receivedIDStream.listen(_handleReceivedID);
    _callControllers.typeStream.listen(_handleType);
    _callControllers.answeredStream.listen(_handleAnsweredType);
    _callControllers.notAnsweredStream.listen(_handleNotAnsweredType);
  }

  void _handleReceivedPhoneNumber(String phoneNumber) {
    _updatePhoneNumber(phoneNumber);
    _callNumber(phoneNumber);
    handleOutgoingCall(phoneNumber);
  }

  void _handleReceivedID(String id) {
    setState(() {
      _receivedID = id;
    });
  }

  void _handleType(String type) {
    setState(() {
      _type = type;
    });
  }

  void _handleAnsweredType(String answered) {
    setState(() {
      _answered = answered;
    });
  }

  void _handleNotAnsweredType(String notAnswered) {
    setState(() {
      _notAnswered = notAnswered;
    });
  }

  Future<void> makeCallInBackground(String phoneNumber) async {
    try {
      final backgroundChannel = MethodChannel('background_service');
      await backgroundChannel.invokeMethod(
          'makeCall', {'phoneNumber': _phoneNumberController});
    } on PlatformException catch (e) {
      print('Failed to make call in background: ${e.message}');
    }
  }

  void handleOutgoingCall(String phoneNumber) {
    // Check for necessary permissions
    _checkPermissions().then((granted) {
      if (granted) {
        // Make call either in foreground or background
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Check app's lifecycle state
          if (WidgetsBinding.instance.lifecycleState ==
              AppLifecycleState.resumed) {
            _makeCall(phoneNumber);
          } else {
            // App is in background, make call using background service
            makeCallInBackground(phoneNumber);
          }
        });
      } else {
        // Handle case where permissions are not granted
        print('Permissions not granted to make call.');
      }
    });
  }

  // Method to check necessary permissions
  Future<bool> _checkPermissions() async {
    final status = await Permission.phone.status;
    if (!status.isGranted) {
      final result = await Permission.phone.request();
      return result.isGranted;
    }
    return true;
  }

  Future<void> _makeCall(String phoneNumber) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } catch (e) {
      print('Error calling number: $e');
    }
  }



  Future<Uint8List> _getLatestMp3FileData() async {
    List<SongModel> songs = await _audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    _latestSong = songs.isNotEmpty ? songs.first : null;

    if (_latestSong != null && _latestSong!.data != null) {
      String filePath = _latestSong!.data!;
      File mp3File = File(filePath);
      Uint8List fileData = await mp3File.readAsBytes();
      return fileData;
    }

    return Uint8List(0);
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Confirm Exit'),
            content: Text('Are you sure you want to exit?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  // Close the app
                  SystemNavigator.pop();
                },
                child: Text('Yes'),
              ),
            ],
          ),
    );
    return confirmed ?? false;
  }

  void _updatePhoneNumber(String phoneNumber) {
    print('Updating phone number: $phoneNumber');
    print('Requesting data from WebSocket... $phoneNumber');
  }

  Future<void> _getCallLog(String phoneNumberToSearch) async {
    final Iterable<CallLogEntry> result = await CallLog.query(
        number: phoneNumberToSearch);
    setState(() {
      _latestCallLogEntry = result.isNotEmpty ? result.first : null;
    });
  }

  void _callNumber(String phoneNumber) async {
    try {
      await FlutterPhoneDirectCaller.callNumber("+91" + phoneNumber);
    } catch (e) {
      print('Error calling number: $e');
    }
  }

  void _setCallDetails(String phoneNumberToSearch,
      Uint8List latestMp3FilePath) {
    if (_type == "lead") {
      _leadDetailsViewModel.id.value = _receivedID;
      _leadDetailsViewModel.type.value =
          _latestCallLogEntry?.callType.toString() ?? '';
      _leadDetailsViewModel.duration.value =
          _latestCallLogEntry?.duration?.toString() ?? '';
      _leadDetailsViewModel.date.value = _latestCallLogEntry?.timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(_latestCallLogEntry!.timestamp!)
          .toString()
          : '';
      if (_latestCallLogEntry?.simDisplayName == 0) {
        // print("notanswered: ${_latestCallLogEntry?.duration} , $_notAnswered");
        _leadDetailsViewModel.fromNumber.value =
            _latestCallLogEntry?.simDisplayName?.toString() ?? "";
      } else {
        //print("answered: ${_latestCallLogEntry?.duration} , $_answered");
        _leadDetailsViewModel.fromNumber.value =
            _latestCallLogEntry?.simDisplayName?.toString() ?? "";
      }

      _leadDetailsViewModel.fromNumber.value =
          _latestCallLogEntry?.simDisplayName?.toString() ?? "";
      _leadDetailsViewModel.toNumber.value =
          phoneNumberToSearch;
      // print("to number is ${_latestCallLogEntry!.cachedMatchedNumber.toString()}");

      if (_latestCallLogEntry?.duration == 0) {
        print("notanswered: ${_latestCallLogEntry?.duration} , $_notAnswered");
        _leadDetailsViewModel.calltype.value = _notAnswered;
      } else {
        print("answered: ${_latestCallLogEntry?.duration} , $_answered");
        _leadDetailsViewModel.calltype.value = _answered;
      }
      _leadDetailsViewModel.leadDetailApi(context, latestMp3FilePath);

      // print("data: $_receivedID ,$_type , $_answered , $_notAnswered");
    }
    else if (_type == "customer") {
      _customerDetailsViewModel.id.value = _receivedID;
      _customerDetailsViewModel.type.value =
          _latestCallLogEntry?.callType.toString() ?? '';
      _customerDetailsViewModel.duration.value =
          _latestCallLogEntry?.duration?.toString() ?? '';
      _customerDetailsViewModel.date.value =
      _latestCallLogEntry?.timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(_latestCallLogEntry!.timestamp!)
          .toString()
          : '';
      _customerDetailsViewModel.fromNumber.value =
          _latestCallLogEntry?.simDisplayName?.toString() ?? "";
      _customerDetailsViewModel.toNumber.value =
          phoneNumberToSearch;

      if (_latestCallLogEntry?.duration == 0) {
        print("notanswered customer: ${_latestCallLogEntry
            ?.duration} , $_notAnswered");
        _customerDetailsViewModel.calltype.value = _notAnswered;
      } else {
        print("answered: ${_latestCallLogEntry?.duration} , $_answered");
        _customerDetailsViewModel.calltype.value = _answered;
      }
      // print("data: $_receivedID ,$_type , $_answered , $_notAnswered");

      _customerDetailsViewModel.customerDetailApi(context, latestMp3FilePath);
    }
    // Call the onComplete callback to signal that data sending is complete
    _clearReceivedID();
  }

  // Callback function to clear _receivedID
  void _clearReceivedID() {
    setState(() {
      _receivedID = "";
    });
  }

  void onLogout() {
    setState(() {
      _latestCallLogEntry = null;
      views = [];
      _receivedID = "";
    });
    _callControllers.socket.disconnect();
    _callControllers.onClose();

    userViewModel.remove();

    // Navigate to the login view and clear the entire navigation stack
    Get.offAllNamed(RouteName.loginView);
  }


  @override
  Widget build(BuildContext context) {
    const TextStyle mono = TextStyle(fontFamily: 'monospace');

    // final List<Widget> callLogWidgets = _latestCallLogEntry != null
    //     ? [
    //   const Divider(),
    //   Text('F. NUMBER  : ${_latestCallLogEntry!.formattedNumber}', style: mono),
    //   Text('C.M. NUMBER: ${_latestCallLogEntry!.cachedMatchedNumber}',
    //       style: mono),
    //   Text('NUMBER     : ${_latestCallLogEntry!.number}', style: mono),
    //   Text('NAME       : ${_latestCallLogEntry!.name}', style: mono),
    //   Text('TYPE       : ${_latestCallLogEntry!.callType}', style: mono),
    //   Text(
    //     'DATE       : ${DateTime.fromMillisecondsSinceEpoch(
    //         _latestCallLogEntry!.timestamp!)}',
    //     style: mono,
    //   ),
    //   Text('DURATION   : ${_latestCallLogEntry!.duration}', style: mono),
    //   Text('ACCOUNT ID : ${_latestCallLogEntry!.phoneAccountId}', style: mono),
    //   Text('SIM NAME   : ${_latestCallLogEntry!.simDisplayName}', style: mono),
    // ]
    //     : [];

    return WillPopScope(
      onWillPop: () async {
        return _showExitConfirmationDialog(context);
      },
      child: MaterialApp(
        home: Scaffold(
          appBar: buildAppBar(),
          body: Stack(
            children: [
              // Background Image
              Image.asset(
                ImageAssets.Background,
                // Replace 'background_image.jpg' with your image path
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              // Content of the app
              buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: FutureBuilder<String>(
        future: userViewModel.getUser().then((user) =>
        '${user.user!.firstName} ${user.user!.lastName ?? ''}'),
        // Retrieve the first name
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('...'); // Placeholder while loading
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            // Display the first name dynamically in the AppBar
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello,',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  snapshot.data!, // Display the first name here
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          } else {
            return Text('No user data available.');
          }
        },
      ),
      actions: [
        IconButton(
          onPressed: () async {
            Utils.confirmationDialogue(
                '', "ARE YOU SURE YOU WANT TO LOGOUT", () {
              onLogout();
            }, context);
          },
          icon: const Icon(Icons.logout),
        )
      ],
      backgroundColor: Colors.transparent, // Make app bar transparent
      elevation: 0, // Remove shadow from app bar
    );
  }

  Widget buildBody() {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment(0.0, 0.0),
      children: [
        FractionallySizedBox(
          heightFactor: 0.5, // Adjust the fraction as needed
          child: Image.asset(
            'assets/gif/CRM.gif',
            height: 100.h,
            width: 100.w,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2.h, // Adjust the top padding as needed
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/image/logo.png',
                  // Replace 'your_image.png' with the path to your image asset
                  width: 50, // Adjust the width of the image as needed
                  height: 50, // Adjust the height of the image as needed
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 10.0),
                  child: Container(
                    width: 70.w, // Adjust the width as needed
                    child: Text(
                      'Your attention to detail and ability to accurately document customer interactions ensure that our records are always up-to-date and reliable. Your warmth and enthusiasm shines through in every conversation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 15.h,
          child: Text(
            'Looking for the next call \n to be placed.....',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(0),
                 child: GestureDetector(
                    onTap: () {
                      Get.toNamed(
                      RouteName.globalSearchView
                      );
                      },
          child: Card(
            elevation: 0.5.w,
            margin: EdgeInsets.all(6.w),
            color: AppColors.backgroundcolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Padding(
              padding:  EdgeInsets.symmetric(
                  vertical: 1.h, horizontal: 3.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWithStyle.productTitle(
                    context , 'Make Calls with Global Search'
                  ),
                  IconButton(
                    onPressed: () {

                    },
                    icon: Icon(Icons.arrow_forward
                    , color: AppColors.primaryColor,),
                  ),
                ],
              ),
            ),
          ),
        ),
       ),
        ),
      ],
    );
  }
}