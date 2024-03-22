
import 'dart:io';

import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:whsuites_calling/view_models/controller/call_detail/customer_detail_viewmodel.dart';
import 'package:workmanager/workmanager.dart';

import '../../view_models/controller/call_type/call_type_viewmodel.dart';


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

class CustomerDetailsTab extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const CustomerDetailsTab({Key? key, required this.data}) : super(key: key);

  @override
  _CustomerDetailsTabState createState() => _CustomerDetailsTabState();
}

class _CustomerDetailsTabState extends State<CustomerDetailsTab> with WidgetsBindingObserver {
  CallLogEntry? _latestCallLogEntry;
  final CustomerDetailsViewModel _customerDetailsViewModel = Get.find<CustomerDetailsViewModel>();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  SongModel? _latestSong;

  // Variable to store the selected lead data
  Map<String, dynamic>? _selectedcustomer;

  @override
  void initState() {
    super.initState();
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

  // Method to update the selected lead
  void _updateSelectedLead(Map<String, dynamic> customer) {
    setState(() {
      _selectedcustomer = customer;
    });
  }



  // Method to handle app resumed
  void _onAppResumed() async {
    if (_callDisconnected && _selectedcustomer != null) {
      final String phoneNumberToSearch = "+91" + _selectedcustomer!['primary_contact'];
      _getCallLog(phoneNumberToSearch); // Fetch call logs each time app resumes
      Uint8List latestMp3FilePath = await _getLatestMp3FileData();
      if (latestMp3FilePath.isNotEmpty) {
        _showDialogBox(phoneNumberToSearch, latestMp3FilePath);
      }
    }
  }

  Future<void> _showDialogBox(String phoneNumber, Uint8List mp3FileData) async {
    String text = ''; // Define text variable here
    String? selectedOption;
    var callTypeData = await CallTypeViewmodel.loadCallType();

    DateTime? selectedDateTime;

    selectedOption = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("ACTIVITY UPDATE" ,
          style:  TextStyle(fontSize: 20.sp),),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: "Enter your Remark"),
                    onChanged: (value) => setState(() => text = value),
                  ),
                  SizedBox(height: 2.h), // Adjust as needed
                  GestureDetector(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(), // Restrict to today and onward
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            selectedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    child: ListTile(
                      title: selectedDateTime == null
                          ? Text('Set Reminder', style: TextStyle(fontSize: 17.sp))
                          : Text(
                        ' ${selectedDateTime.toString()}',
                        style: TextStyle(fontSize: 15.sp),
                      ),
                      trailing: Icon(Icons.calendar_today),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Divider(),
                  SizedBox(height: 2.h),
                  Text(
                    "Your Duration is ${_latestCallLogEntry?.duration.toString()},",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(height: 1.h),
                  if (callTypeData.lead != null)
                    DropdownButtonFormField<String>(
                      value: selectedOption,
                      hint: Text('Select Call Type'),
                      onChanged: (String? value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      style: TextStyle(fontSize: 16.0 , color: Colors.black87),
                      items: callTypeData.lead!.keys.map((key) {
                        return DropdownMenuItem<String>(
                          value: callTypeData.lead![key],
                          child: Text(key),
                        );
                      }).toList(),
                    ),
                ],
              );
            },
          ),
        ),
        actions: [
          if (_latestCallLogEntry?.duration == 0)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
          ElevatedButton(
            onPressed: () {
              if (selectedOption != null) {
                Navigator.pop(context, selectedOption);
              } else {
                // Display an error message or handle incomplete form data
              }
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
    if (selectedOption != null) {
      String formattedDateTime =
          selectedDateTime?.toIso8601String() ?? ''; // Format DateTime to string
      _setCallDetails(
          phoneNumber, mp3FileData, text, selectedOption!, formattedDateTime);
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

  Future<void> _getCallLog  (String phoneNumberToSearch) async {
    try {
      final Iterable<CallLogEntry> result = await CallLog.query();
      List<CallLogEntry> callLogs = result.toList();
      setState(() {
        for (CallLogEntry entry in callLogs) {
          print('-------------------------------------');
          print('Formatted Number: ${entry.formattedNumber}');
          print('Cached Matched Number: ${entry.cachedMatchedNumber}');
          print('Number: ${entry.number}');
          print('Name: ${entry.name}');
          print('Call Type: ${entry.callType}');
          print('Date: ${DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)}');
          print('Duration: ${entry.duration}');
          print('Phone Account ID: ${entry.phoneAccountId}');
          print('SIM Display Name: ${entry.simDisplayName}');
          print('-------------------------------------');
        }
        _latestCallLogEntry = callLogs.isNotEmpty ? callLogs.first : null;
      });
    } on PlatformException catch (e) {
      print("Failed to get call logs: '${e.message}'.");
    }
  }

  Future<void> _makeCall(Map<String, dynamic> customer) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(customer['primary_contact']);
      _getCallLog("+91${customer['primary_contact']}");
    } catch (e) {
      print('Error calling number: $e');
    }
  }

  Future<void> _setCallDetails(String phoneNumberToSearch, Uint8List latestMp3FilePath , String remark , String selectedcalltype,
      String reminder) async {
    String leadId = _selectedcustomer!['id'] ;
    dynamic customerData = await CallTypeViewmodel.loadCallType();


    _customerDetailsViewModel.id.value = leadId.toString() ?? '';

    _customerDetailsViewModel.type.value = _latestCallLogEntry?.callType.toString() ?? '';
    _customerDetailsViewModel.duration.value = _latestCallLogEntry?.duration?.toString() ?? '';
    _customerDetailsViewModel.date.value = _latestCallLogEntry?.timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(_latestCallLogEntry!.timestamp!).toString()
        : '';

    _customerDetailsViewModel.fromNumber.value =
        _latestCallLogEntry?.simDisplayName?.toString() ?? "";
    _customerDetailsViewModel.toNumber.value =
        phoneNumberToSearch;
    _customerDetailsViewModel.createFrom.value = 'mobile'.toString() ;
    _customerDetailsViewModel.reminder.value = reminder.toString() ;
    print("createfrom: ${_customerDetailsViewModel.createFrom.value.toString()}");

    _customerDetailsViewModel.remark.value =
        remark.toString();
    // print("to number is ${_latestCallLogEntry!.cachedMatchedNumber.toString()}");


    // Set from number based on answered or not answered
    _customerDetailsViewModel.calltype.value = selectedcalltype.toString() ?? "";
    print("notanswered: ${_customerDetailsViewModel.id.value.toString()} , ${_customerDetailsViewModel.type.value} , ${_customerDetailsViewModel.duration.value},"
        " ${_customerDetailsViewModel.date.value} , ${_customerDetailsViewModel.fromNumber.value } , ${_customerDetailsViewModel.toNumber.value } , ${_customerDetailsViewModel.remark.value } ${selectedcalltype}");

    // if (_latestCallLogEntry?.duration == 0) {
    //   print("notanswered: ${_latestCallLogEntry?.duration} , ${leadData.notAnswered}");
    //   _leadDetailsViewModel.calltype.value = leadData.notAnswered ?? "";
    // } else {
    //   print("answered: ${_latestCallLogEntry?.duration} , ${leadData.answered}");
    //   _leadDetailsViewModel.calltype.value = leadData.answered ?? "";
    // }

    _customerDetailsViewModel.customerDetailApi(context, latestMp3FilePath);
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        // Use the actual data from the list
        final customer = widget.data[index];
        return Card(
          child: Padding(
            padding:  EdgeInsets.all(2.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${customer['firstName']}',
                      style: TextStyle(
                          fontSize: 14.sp
                      ),
                    ),
                    Text('${customer['primaryEmail']}'),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.phone),
                  onPressed: () {
                        _makeCall(customer);
                        _updateSelectedLead(customer);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}