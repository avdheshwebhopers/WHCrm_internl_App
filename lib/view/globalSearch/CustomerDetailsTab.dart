import 'package:call_log/call_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:workmanager/workmanager.dart';


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

class CustomerDetailsTab extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const CustomerDetailsTab({Key? key, required this.data}) : super(key: key);

  Future<void> _makeCall(customer) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(customer['primary_contact']);
    } catch (e) {
      print('Error calling number: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        // Use the actual data from the list
        final customer = data[index];
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
