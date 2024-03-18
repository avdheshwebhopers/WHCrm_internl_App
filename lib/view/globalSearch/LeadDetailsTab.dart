import 'dart:io';

import 'package:call_log/call_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';

import '../../models/response_model/call_type.dart';
import '../../view_models/controller/call_detail/lead_detail_viewmodel.dart';
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

class LeadDetailsTab extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const LeadDetailsTab({Key? key, required this.data}) : super(key: key);

  @override
  _LeadDetailsTabState createState() => _LeadDetailsTabState();
}

class _LeadDetailsTabState extends State<LeadDetailsTab> with WidgetsBindingObserver {
  CallLogEntry? _latestCallLogEntry;
  final LeadDetailsViewModel _leadDetailsViewModel = Get.find<LeadDetailsViewModel>();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  SongModel? _latestSong;
  DateTime? selectedDate;

  // Variable to store the selected lead data
  Map<String, dynamic>? _selectedLead;

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
  void _updateSelectedLead(Map<String, dynamic> lead) {
    setState(() {
      _selectedLead = lead;
    });
  }

  // Method to handle app resumed
  void _onAppResumed() async {
    if (_callDisconnected && _selectedLead != null) {
      final String phoneNumberToSearch = "+91" + _selectedLead!['mobile'];
      await _getCallLog(phoneNumberToSearch);
      Uint8List latestMp3FilePath = await _getLatestMp3FileData();
      if (latestMp3FilePath.isNotEmpty) {
        _showDialogBox(phoneNumberToSearch, latestMp3FilePath);
      }
    }
  }

  Future<void> _showDialogBox(String phoneNumber, Uint8List mp3FileData) async {
    String text = ''; // Define text variable here
    String? selectedOption;
    Lead leadData = await CallTypeViewmodel.loadLeadCallType();


    DateTime? selectedDateTime;
    // Define this variable in your widget class

    selectedOption = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(""),
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
                SizedBox(height: 2.h),
                ListTile(
                  title:
                   selectedDateTime == null
                      ? Text('Select Date and Time' ,
                   style: TextStyle( fontSize: 15.sp , fontWeight: FontWeight.w400),)
                      : Text(' ${selectedDateTime.toString()}',
                   style: TextStyle(fontSize: 15.sp , fontWeight: FontWeight.w500),),
                  trailing: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
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
                  ),
                ),
                SizedBox(height: 1.h),
                Divider(height: 1.h) ,
                SizedBox(height: 2.h),

                Text("Select your call type" , style: TextStyle(fontSize: 16.sp , fontWeight: FontWeight.w500),),
                SizedBox(height: 1.h),

                ListTile(
                  title: Text('Answered' , style: TextStyle(fontSize: 16.sp ),),
                  leading: Radio<String>(
                    value: "${leadData.answered}",
                    groupValue: selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('Not Answered', style: TextStyle(fontSize: 16.sp ),),
                  leading: Radio<String>(
                    value: "${leadData.notAnswered}",
                    groupValue: selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('Wrong Number', style: TextStyle(fontSize: 16.sp ),),
                  leading: Radio<String>(
                    value: "${leadData.wrongNumber}",
                    groupValue: selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('Number Busy', style: TextStyle(fontSize: 16.sp ),),
                  leading: Radio<String>(
                    value: "${leadData.numberBusy}",
                    groupValue: selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (text.isNotEmpty && selectedOption != null && selectedDate != null) {
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
    if (text != null && text.isNotEmpty && selectedOption != null) {
      _setCallDetails(phoneNumber, mp3FileData, text, selectedOption!);
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

  Future<void> _getCallLog(String phoneNumberToSearch) async {
    final Iterable<CallLogEntry> result = await CallLog.query(number: phoneNumberToSearch);
    setState(() {
      _latestCallLogEntry = result.isNotEmpty ? result.first : null;
    });
  }

  Future<void> _makeCall(Map<String, dynamic> lead) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(lead['mobile']);
    } catch (e) {
      print('Error calling number: $e');
    }
  }

  Future<void> _setCallDetails(String phoneNumberToSearch, Uint8List latestMp3FilePath , String remark , String selectedcalltype) async {
    String leadId = _selectedLead!['id'] ;
    Lead leadData = await CallTypeViewmodel.loadLeadCallType();


    _leadDetailsViewModel.id.value = leadId.toString() ?? '';

    _leadDetailsViewModel.type.value = _latestCallLogEntry?.callType.toString() ?? '';
    _leadDetailsViewModel.duration.value = _latestCallLogEntry?.duration?.toString() ?? '';
    _leadDetailsViewModel.date.value = _latestCallLogEntry?.timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(_latestCallLogEntry!.timestamp!).toString()
        : '';

    _leadDetailsViewModel.fromNumber.value =
        _latestCallLogEntry?.simDisplayName?.toString() ?? "";
    _leadDetailsViewModel.toNumber.value =
        phoneNumberToSearch;
   _leadDetailsViewModel.createFrom.value = 'mobile'.toString() ;
    print("createfrom: ${_leadDetailsViewModel.createFrom.value.toString()}");

    _leadDetailsViewModel.remark.value =
        remark.toString();
    // print("to number is ${_latestCallLogEntry!.cachedMatchedNumber.toString()}");


    // Set from number based on answered or not answered
    _leadDetailsViewModel.calltype.value = selectedcalltype.toString() ?? "";
       print("notanswered: ${_leadDetailsViewModel.id.value.toString()} , ${_leadDetailsViewModel.type.value} , ${_leadDetailsViewModel.duration.value},"
           " ${_leadDetailsViewModel.date.value} , ${_leadDetailsViewModel.fromNumber.value } , ${_leadDetailsViewModel.toNumber.value } , ${_leadDetailsViewModel.remark.value } ${selectedcalltype}");

    // if (_latestCallLogEntry?.duration == 0) {
    //   print("notanswered: ${_latestCallLogEntry?.duration} , ${leadData.notAnswered}");
    //   _leadDetailsViewModel.calltype.value = leadData.notAnswered ?? "";
    // } else {
    //   print("answered: ${_latestCallLogEntry?.duration} , ${leadData.answered}");
    //   _leadDetailsViewModel.calltype.value = leadData.answered ?? "";
    // }
    _leadDetailsViewModel.leadDetailApi(context, latestMp3FilePath);

  }



  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        final lead = widget.data[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${lead['firstName']}'),
                        Text('${lead['email']}'),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.phone),
                      onPressed: () {
                        _makeCall(lead);
                        _updateSelectedLead(lead);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
