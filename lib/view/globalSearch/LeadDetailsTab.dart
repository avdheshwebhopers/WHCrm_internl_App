import 'dart:io';

import 'package:call_log/call_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:workmanager/workmanager.dart';

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

  Future<void> _makeCall(Map<String, dynamic> lead) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(lead['mobile']);
    } catch (e) {
      print('Error calling number: $e');
    }
  }

  Future<void> _setCallDetails(String phoneNumberToSearch, Uint8List latestMp3FilePath) async {
    Lead leadData = await CallTypeViewmodel.loadLeadCallType();
    String leadId = _selectedLead!['id'] ;

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
    // print("to number is ${_latestCallLogEntry!.cachedMatchedNumber.toString()}");


    // Set from number based on answered or not answered
    if (_latestCallLogEntry?.duration == 0) {
      print("notanswered: ${_latestCallLogEntry?.duration} , ${leadData.notAnswered}");
      _leadDetailsViewModel.calltype.value = leadData.notAnswered ?? "";
    } else {
      print("answered: ${_latestCallLogEntry?.duration} , ${leadData.answered}");
      _leadDetailsViewModel.calltype.value = leadData.answered ?? "";
    }
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