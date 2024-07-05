import 'dart:async';
import 'dart:io';
import 'package:call_log/call_log.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whsuites_calling/res/assets/image_assets.dart';
import 'package:whsuites_calling/res/colors/app_color.dart';
import 'package:whsuites_calling/utils/text_style.dart';
import 'package:whsuites_calling/view/call/CallControllers.dart';
import 'package:whsuites_calling/view_models/controller/call_detail/lead_detail_viewmodel.dart';
import 'package:whsuites_calling/view_models/controller/call_type/call_type_viewmodel.dart';
import 'package:workmanager/workmanager.dart';
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

  final LeadDetailsViewModel _leadDetailsViewModel =
      Get.find<LeadDetailsViewModel>();
  final CustomerDetailsViewModel _customerDetailsViewModel =
      Get.find<CustomerDetailsViewModel>();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  final TextEditingController _phoneNumberController = TextEditingController();
  final CallControllers _callControllers = Get.find<CallControllers>();
  UserViewModel userViewModel = UserViewModel();
  List<Widget> views = [];
  String _receivedID = "";
  String _type = "";
  String _answered = "";
  String _notAnswered = "";
  String? _directoryPath;
  CallLogEntry? _latestCallLogEntry;

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
      final String phoneNumberToSearch = "+91${_phoneNumberController.text}";
      print('Number >>>>: $phoneNumberToSearch');
      await _getCallLog(phoneNumberToSearch);
      Uint8List? latestMp3FilePath = await _getLatestMp3FileData();
      String? latestMp3FileName = await _getLatestMp3FileName();
      _setCallDetails(phoneNumberToSearch, latestMp3FilePath, latestMp3FileName);
      //  }
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

  Future<void> saveDirectoryPath(String? directoryPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (directoryPath != null && directoryPath.isNotEmpty) {
      await prefs.setString('directoryPath', directoryPath);
    } else {
      await prefs.remove('directoryPath');
    }
  }

  Future<String?> _getDirectoryPathFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('directoryPath');
  }

  Future<String?> _getLatestMp3FileName() async {
    String? directoryPath = await _getDirectoryPathFromLocalStorage();
    if (directoryPath == null || directoryPath.isEmpty) {
      print('Directory path not found in local storage');
      return null;
    }
    try {
      Directory directory = Directory(directoryPath);
      List<FileSystemEntity> files = directory.listSync(recursive: true);
      List<File> mp3Files = files
          .where((file) => file.path.toLowerCase().endsWith('.mp3') ||
          file.path.toLowerCase().endsWith('.aac') ||
          file.path.toLowerCase().endsWith('.wav') ||
          file.path.toLowerCase().endsWith('.wma') ||
          file.path.toLowerCase().endsWith('.dolby') ||
          file.path.toLowerCase().endsWith('.digital') ||
          file.path.toLowerCase().endsWith('.dts') ||
          file.path.toLowerCase().endsWith('.m4a'))
          .map((file) => File(file.path))
          .toList();

      if (mp3Files.isNotEmpty) {
        mp3Files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        return path.basename(mp3Files.first.path);
      }
    } catch (e) {
      print('Error accessing directory or reading file: $e');
    }
    return null;
  }

  Future<Uint8List?> _getLatestMp3FileData() async {
     String? _directoryPath = await _getDirectoryPathFromLocalStorage();
    if (_directoryPath == null || _directoryPath.isEmpty) {
      print('Directory path not found in local storage');
      return null;
    }

    try {
      Directory directory = Directory(_directoryPath);
      List<FileSystemEntity> files = directory.listSync(recursive: true);
      List<File> mp3Files = files
          .where((file) => file.path.toLowerCase().endsWith('.mp3') ||
          file.path.toLowerCase().endsWith('.aac') ||
          file.path.toLowerCase().endsWith('.wav') ||
          file.path.toLowerCase().endsWith('.wma') ||
          file.path.toLowerCase().endsWith('.dolby') ||
          file.path.toLowerCase().endsWith('.digital') ||
          file.path.toLowerCase().endsWith('.dts') ||
          file.path.toLowerCase().endsWith('.m4a'))
          .map((file) => File(file.path))
          .toList();

      if (mp3Files.isNotEmpty) {
        mp3Files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        return await mp3Files.first.readAsBytes();
      }
    } catch (e) {
      print('Error accessing directory or reading file: $e');
    }
    return null;
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text('Are you sure you want to exit?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              // Close the app
              SystemNavigator.pop();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _updatePhoneNumber(String phoneNumber) {
    _phoneNumberController.text = phoneNumber;
    print('Updating phone number: $phoneNumber');
    print('Requesting data from WebSocket... $phoneNumber');
  }

  Future<void> _getCallLog(String phoneNumberToSearch) async {
    final Iterable<CallLogEntry> result =
        await CallLog.query(number: phoneNumberToSearch);
    setState(() {
      _latestCallLogEntry = result.isNotEmpty ? result.first : null;
    });
  }

  void _setCallDetails(String phoneNumberToSearch, Uint8List? latestMp3FilePath, String? filename) {
    if (_type == "lead") {
      _leadDetailsViewModel.id.value = _receivedID.toString();
      _leadDetailsViewModel.type.value = _latestCallLogEntry?.callType.toString() ?? '';
      _leadDetailsViewModel.duration.value = _latestCallLogEntry?.duration?.toString() ?? '';
      _leadDetailsViewModel.createFrom.value = 'web'.toString();
      _leadDetailsViewModel.date.value = _latestCallLogEntry?.timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(_latestCallLogEntry!.timestamp!).toString()
          : '';
      _leadDetailsViewModel.fromNumber.value = _latestCallLogEntry?.simDisplayName?.toString() ?? "";
      _leadDetailsViewModel.toNumber.value = phoneNumberToSearch;
      _leadDetailsViewModel.remark.value = "Call placed";
      if (_latestCallLogEntry?.duration == 0) {
        _leadDetailsViewModel.calltype.value = _notAnswered;
      } else {
        _leadDetailsViewModel.calltype.value = _answered;
      }
      _leadDetailsViewModel.leadDetailApi(context, latestMp3FilePath, filename ?? 'na');
    } else if (_type == "customer") {
      _customerDetailsViewModel.id.value = _receivedID.toString();
      _customerDetailsViewModel.type.value = _latestCallLogEntry?.callType.toString() ?? '';
      _customerDetailsViewModel.duration.value = _latestCallLogEntry?.duration?.toString() ?? '';
      _customerDetailsViewModel.date.value = _latestCallLogEntry?.timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(_latestCallLogEntry!.timestamp!).toString()
          : '';
      _customerDetailsViewModel.fromNumber.value = _latestCallLogEntry?.simDisplayName?.toString() ?? "";
      _customerDetailsViewModel.toNumber.value = phoneNumberToSearch;
      if (_latestCallLogEntry?.duration == 0) {
        _customerDetailsViewModel.calltype.value = _notAnswered;
      } else {
        _customerDetailsViewModel.calltype.value = _answered;
      }
      _customerDetailsViewModel.customerDetailApi(context, latestMp3FilePath, filename ?? 'na');
    }
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
    await FlutterPhoneDirectCaller.callNumber("+91" + phoneNumber);
    // try {
    //   final String directoryPath = await _getDirectoryPathFromLocalStorage();
    //   print("directory path: $directoryPath");
    //
    //   if (directoryPath.isNotEmpty) {
    //     // Directory path is not empty, proceed with making the call
    //   }
    //   // Directory path is empty, show dialog to select directory
    // } catch (e) {
    //   await _showDirectorySelectionDialog();
    //
    //   print('Error making call: $e');
    // }
  }

  Future<void> _showDirectorySelectionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Please Select Directory",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          content: const Text(
              "You haven't selected a directory for recordings. Click on the folder Icon on the top right corner of the AppBar and Select the Directory first. "),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _getManualDirectoryPath(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Directory Path'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter directory path'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },);
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(
                height: 20,
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
        future: userViewModel.getUser().then(
            (user) => '${user.user!.firstName} ${user.user!.lastName ?? ''}'),
        // Retrieve the first name
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('...'); // Placeholder while loading
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            // Display the first name dynamically in the AppBar
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello,',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  snapshot.data!, // Display the first name here
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          } else {
            return const Text('No user data available.');
          }
        },
      ),
      actions: [
        IconButton(
          onPressed: () async {
            // Add logic to manually input directory path
            String? manualDirectoryPath =
                await _getManualDirectoryPath(context);
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
            Utils.confirmationDialogue('', "ARE YOU SURE YOU WANT TO LOGOUT",
                () {
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
    return Column(
      children: [
        Image.asset(
          'assets/image/logo.png',
          scale: 3.0,
          //scale: width/2, // Adjust the width of the image as needed
        ),
        const SizedBox(height: 20),
        const Expanded(
          child: Text(
            'Your attention to detail and ability to accurately document customer interactions ensure that our records are always up-to-date and reliable. Your warmth and enthusiasm shines through in every conversation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Text(
          'Looking for the next call \n to be placed.....',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10,),
        GestureDetector(
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

                Get.toNamed(
                  RouteName.globalSearchView,
                  arguments: "", // Pass directory path as argument
                );
                // If directory path is not available, show a message to select a directory
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Directory path not found. Please select a directory first.'),
                  ),
                );
              }
            } catch (e) {
              // Handle any errors that occur while retrieving the directory path
              Utils.textError(context, "Directory path not found. Please select a directory first.",);
              print('Error retrieving directory path: $e');
            }
          },
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(20))
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(CupertinoIcons.search,color: AppColors.backgroundcolor,),
                  Expanded(child: TextWithStyle.productTitle(context, '  Make Calls with Global Search ➜'))
                ],
              ),
            ),
        ),
      ],
    );
  }
}
