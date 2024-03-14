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

import '../../models/response_model/call_type.dart';
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
      await _getCallLog(phoneNumberToSearch);
      Uint8List latestMp3FilePath = await _getLatestMp3FileData();
      if (latestMp3FilePath.isNotEmpty) {
        _setCallDetails(phoneNumberToSearch, latestMp3FilePath);
      }
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

  Future<void> _makeCall(Map<String, dynamic> customer) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(customer['primary_contact']);
    } catch (e) {
      print('Error calling number: $e');
    }
  }

  Future<void> _setCallDetails(String phoneNumberToSearch, Uint8List latestMp3FilePath) async {
    Customer customerData = await CallTypeViewmodel.loadCustomerCallType();
    String leadId = _selectedcustomer!['id'] ;

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
    // print("to number is ${_latestCallLogEntry!.cachedMatchedNumber.toString()}");


    // Set from number based on answered or not answered
    if (_latestCallLogEntry?.duration == 0) {
      print("notanswered: ${_latestCallLogEntry?.duration} , ${customerData.notAnswered}");
      _customerDetailsViewModel.calltype.value = customerData.notAnswered ?? "";
    } else {
      print("answered: ${_latestCallLogEntry?.duration} , ${customerData.answered}");
      _customerDetailsViewModel.calltype.value = customerData.answered ?? "";
    }
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