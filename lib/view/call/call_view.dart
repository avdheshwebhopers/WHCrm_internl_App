
import 'dart:async';
import 'dart:io';
import 'package:call_log/call_log.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whsuites_calling/res/assets/image_assets.dart';
import 'package:whsuites_calling/res/colors/app_color.dart';
import 'package:whsuites_calling/utils/text_style.dart';
import 'package:whsuites_calling/view/call/CallControllers.dart';
import 'package:whsuites_calling/view_models/controller/call_detail/lead_detail_viewmodel.dart';
import 'package:whsuites_calling/view_models/controller/call_type/call_type_viewmodel.dart';
import 'package:workmanager/workmanager.dart';
import '../../repository/beforelogin/login_repository.dart';
import '../../res/routes/routes_name.dart';
import '../../utils/utils.dart';
import '../../view_models/controller/call_detail/customer_detail_viewmodel.dart';
import '../../view_models/controller/user_preference/user_prefrence_view_model.dart';
import 'package:path/path.dart' as path;


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

  final CallTypeViewmodel _callTypeViewmodel = Get.find<CallTypeViewmodel>();
  Map<String, dynamic>? _lead;

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
  String _directoryPath = '';

  CallLogEntry? _latestCallLogEntry;
  final _api = LoginRepository();

  @override
  void initState() {
    super.initState();
    retrievePermissionsAndInitData();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initData() async {
    try {
      _directoryPath = await _getDirectoryPathFromLocalStorage();

      // Call the API function from your view model
      await _callTypeViewmodel.callTypeApi();
      // Load call type data from shared preferences after calling the API
      var callType = await CallTypeViewmodel.loadCallType();

      // Print lead and customer data
      setState(() {
        // Update the UI after loading data
      });
    } catch (e) {
      // Handle error initializing data
      print('Error initializing data: $e');
    }
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
      String? latestMp3FileName = await _getLatestMp3FileName();
      if (latestMp3FilePath.isNotEmpty) {
        _setCallDetails(phoneNumberToSearch, latestMp3FilePath , latestMp3FileName!);
      }
    }
  }

  Future<void> retrievePermissionsAndInitData() async {
    try {
      // Retrieve permissions and wait for the result
      bool hasPermission = await retrievePermissions();
      if (hasPermission) {
        // Proceed with initializing data
        await _initData();

        setState(() {
          setupStreamListeners();
        });
      } else {
        // Handle case where permissions are not granted
        print('Permissions denied for accessing audio resources.');
        // Optionally, you can prompt the user to grant permissions again
        // Or provide guidance on how to grant permissions manually
      }
    } catch (e) {
      // Handle error retrieving permissions or initializing data
      print('Error initializing data: $e');
    }
  }

  Future<bool> retrievePermissions() async {
    try {
      // Check and request permissions
      bool hasPermission = await _audioQuery.checkAndRequest();
      if (hasPermission) {
        print("Permissions retrieved successfully.");
        // Request call log permissions specifically if not already granted
        await _requestCallLogPermissionIfNeeded();
      } else {
        print('Permissions denied for accessing audio resources.');
      }
      return hasPermission;
    } catch (e) {
      // Handle error retrieving permissions
      print('Error retrieving permissions: $e');
      return false;
    }
  }

  Future<void> _requestCallLogPermissionIfNeeded() async {
    final status = await Permission.phone.status;
    if (!status.isGranted) {
      final result = await Permission.phone.request();
      if (result.isGranted) {
        print("Call log permission granted.");
      } else {
        print("Call log permission denied.");
        // Optionally handle the case where call log permission is denied
      }
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
   // handleOutgoingCall(phoneNumber);
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
  //
  // Future<void> makeCallInBackground(String phoneNumber) async {
  //   try {
  //     final backgroundChannel = MethodChannel('background_service');
  //     await backgroundChannel.invokeMethod(
  //         'makeCall', {'phoneNumber': _phoneNumberController});
  //   } on PlatformException catch (e) {
  //     print('Failed to make call in background: ${e.message}');
  //   }
  // }
  //
  // void handleOutgoingCall(String phoneNumber) {
  //   // Check for necessary permissions
  //   _checkPermissions().then((granted) {
  //     if (granted) {
  //       // Make call either in foreground or background
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         // Check app's lifecycle state
  //         if (WidgetsBinding.instance.lifecycleState ==
  //             AppLifecycleState.resumed) {
  //           _makeCall(phoneNumber);
  //         } else {
  //           // App is in background, make call using background service
  //         }
  //       });
  //     } else {
  //       // Handle case where permissions are not granted
  //       print('Permissions not granted to make call.');
  //     }
  //   });
  // }

  // Method to check necessary permissions
  Future<bool> _checkPermissions() async {
    final status = await Permission.phone.status;
    if (!status.isGranted) {
      final result = await Permission.phone.request();
      return result.isGranted;
    }
    return true;
  }

  Future<String?> _selectDirectoryPath(BuildContext context) async {
    try {
      // Open file picker to select directory
      String? directoryPath = await FilePicker.platform.getDirectoryPath();
      return directoryPath;
    } catch (e) {
      print('Error selecting directory: $e');
      return null;
    }
  }


  Future<void> saveDirectoryPath(String directoryPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('directoryPath', directoryPath);
  }

  Future<String> _getDirectoryPathFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? directoryPath = prefs.getString('directoryPath');
    if (directoryPath != null && directoryPath.isNotEmpty) {
      return directoryPath;
    } else {
      throw Exception('Directory path not found in local storage');
    }
  }

  Future<String?> _getLatestMp3FileName() async {
    _directoryPath = await _getDirectoryPathFromLocalStorage();
    if (_directoryPath.isEmpty) {
      throw Exception('Directory path not found in local storage');
    }

    try {
      Directory directory = Directory(_directoryPath);
      List<FileSystemEntity> files = directory.listSync(recursive: true);
      List<File> mp3Files = files
          .where((file) => file.path.toLowerCase().endsWith('.mp3') || file.path.toLowerCase().endsWith('.aac') || file.path.toLowerCase().endsWith('.wav')
          || file.path.toLowerCase().endsWith('.wma') || file.path.toLowerCase().endsWith('.dolby') || file.path.toLowerCase().endsWith('.digital') || file.path.toLowerCase().endsWith('.dts')
          || file.path.toLowerCase().endsWith('.m4a'))
          .map((file) => File(file.path))
          .toList();

      if (mp3Files.isNotEmpty) {
        // Sort files by date modified to get the latest one
        mp3Files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

        // Get the name of the latest mp3 file
        String fileName = path.basename(mp3Files.first.path);
        // print("filename in function is : $fileName");
        return fileName;
      }
    } catch (e) {
      print('Error accessing directory or reading file: $e');
    }
    return null; // Return null if no file found
  }

  Future<Uint8List> _getLatestMp3FileData() async {
    _directoryPath = await _getDirectoryPathFromLocalStorage();
    if (_directoryPath.isEmpty) {
      throw Exception('Directory path not found in local storage');
    }

    try {
      Directory directory = Directory(_directoryPath);
      List<FileSystemEntity> files = directory.listSync(recursive: true);
      List<File> mp3Files = files
          .where((file) => file.path.toLowerCase().endsWith('.mp3') || file.path.toLowerCase().endsWith('.aac') || file.path.toLowerCase().endsWith('.wav')
          || file.path.toLowerCase().endsWith('.wma') || file.path.toLowerCase().endsWith('.dolby') || file.path.toLowerCase().endsWith('.digital') || file.path.toLowerCase().endsWith('.dts')
          || file.path.toLowerCase().endsWith('.m4a'))          .map((file) => File(file.path))
          .toList();

      if (mp3Files.isNotEmpty) {
        // Sort files by date modified to get the latest one
        mp3Files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

        // Read the latest mp3 file data
        Uint8List fileData = await mp3Files.first.readAsBytes();
        return fileData;
      }
    } catch (e) {
      print('Error accessing directory or reading file: $e');
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

  void _setCallDetails(String phoneNumberToSearch,
      Uint8List latestMp3FilePath , String filename) {
    if (_type == "lead") {
      _leadDetailsViewModel.id.value = _receivedID.toString();
      _leadDetailsViewModel.type.value =
          _latestCallLogEntry?.callType.toString() ?? '';
      _leadDetailsViewModel.duration.value =
          _latestCallLogEntry?.duration?.toString() ?? '';
      _leadDetailsViewModel.createFrom.value = 'web'.toString() ;
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
      _leadDetailsViewModel.remark.value = "Call placed";
      // print("to number is ${_latestCallLogEntry!.cachedMatchedNumber.toString()}");
      if (_latestCallLogEntry?.duration == 0) {
        print("notanswered: ${_latestCallLogEntry?.duration} , $_notAnswered");
        _leadDetailsViewModel.calltype.value = _notAnswered;
      } else {
        print("answered: ${_latestCallLogEntry?.duration} , $_answered");
        _leadDetailsViewModel.calltype.value = _answered;
      }
      _leadDetailsViewModel.leadDetailApi(context, latestMp3FilePath , filename);

      // print("data: $_receivedID ,$_type , $_answered , $_notAnswered");
    }
    else if (_type == "customer") {
      _customerDetailsViewModel.id.value = _receivedID.toString();
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
        print("answered: ${_latestCallLogEntry?.duration} , $_answered , $latestMp3FilePath");
        _customerDetailsViewModel.calltype.value = _answered;
      }
      // print("data: $_receivedID ,$_type , $_answered , $_notAnswered");
      _customerDetailsViewModel.customerDetailApi(context, latestMp3FilePath , filename);
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

  void _callNumber(String phoneNumber) async {
    try {
      final String directoryPath = await _getDirectoryPathFromLocalStorage();
      print("directory path: $directoryPath");

      if (directoryPath.isNotEmpty) {
        // Directory path is not empty, proceed with making the call
        await FlutterPhoneDirectCaller.callNumber("+91" + phoneNumber);
      }
        // Directory path is empty, show dialog to select directory
    } catch (e) {
      await _showDirectorySelectionDialog();

      print('Error making call: $e');
    }
  }

  Future<void> _showDirectorySelectionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Please Select Directory" ,
          style: TextStyle(fontSize: 18.sp , fontWeight: FontWeight.w500),),
          content: Text("You haven't selected a directory for recordings. Click on the folder Icon on the top right corner of the AppBar and Select the Directory first. "),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _getManualDirectoryPath(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Directory Path'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter directory path'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

@override
  Widget build(BuildContext context) {
    const TextStyle mono = TextStyle(fontFamily: 'monospace');

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
            // Add logic to manually input directory path
            String? manualDirectoryPath = await _getManualDirectoryPath(context);
            if (manualDirectoryPath != null) {
              await saveDirectoryPath(manualDirectoryPath);
            }
          },
          icon: const Icon(Icons.add_circle),
        ),
        IconButton(
          onPressed: () async {
            // Add logic to choose directory path and save it locally
            String? directoryPath = await _selectDirectoryPath(context);
            if (directoryPath != null) {
              await saveDirectoryPath(directoryPath);
            }
          },
          icon: const Icon(Icons.folder),
        ),
        IconButton(
          onPressed: () async {
            Utils.confirmationDialogue(
                '', "ARE YOU SURE YOU WANT TO LOGOUT", () {
              onLogout();
            }, context);
          },
          icon: const Icon(Icons.logout),
        ),
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
                   onTap: () async {
                     try {
                       // Retrieve the directory path from local storage
                       String? directoryPath = await _getDirectoryPathFromLocalStorage();
                       if (directoryPath != null && directoryPath.isNotEmpty) {
                         // Navigate to the global search view while passing the directory path
                         Get.toNamed(
                           RouteName.globalSearchView,
                           arguments: directoryPath, // Pass directory path as argument
                         );
                       } else {
                         // If directory path is not available, show a message to select a directory
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text('Directory path not found. Please select a directory first.'),
                           ),
                         );
                       }
                     } catch (e) {
                       // Handle any errors that occur while retrieving the directory path
                       Utils.textError(context , "Directory path not found. Please select a directory first.",);
                       print('Error retrieving directory path: $e');
                     }
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