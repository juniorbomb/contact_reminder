import 'package:call_log/call_log.dart';
import 'package:contact_reminder/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {

  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];
  Iterable<CallLogEntry> _callLogEntries = <CallLogEntry>[];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

  }

  Future<Iterable<CallLogEntry>> _callLogs() async {
    var now = DateTime.now();
    int from = now.subtract(const Duration(days: 60)).millisecondsSinceEpoch;
    int to = now.subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    return await CallLog.query(
      dateFrom: from,
      dateTo: to,
      durationFrom: 0,
      durationTo: 60,
      name: 'name',
      number: 'number',
      // type: CallType.incoming,
    );
  }

  Future _smsLogs() async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox, SmsQueryKind.sent],
         //pass number for particular sms(optional)
        address: '+919824930348',
        // Count of sms (0 if you want latest msg of above address)
        count: 0,
      );
      debugPrint('sms inbox messages: ${messages.length}');

      setState(() => _messages = messages);
    } else {
      await Permission.sms.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle mono = TextStyle(fontFamily: 'monospace');
    final List<Widget> children = <Widget>[];
    for (CallLogEntry entry in _callLogEntries) {
      children.add(
        Column(
          children: <Widget>[
            const Divider(),
            Text('F. NUMBER  : ${entry.formattedNumber}', style: mono),
            Text('C.M. NUMBER: ${entry.cachedMatchedNumber}', style: mono),
            Text('NUMBER     : ${entry.number}', style: mono),
            Text('NAME       : ${entry.name}', style: mono),
            Text('TYPE       : ${entry.callType}', style: mono),
            Text('DATE       : ${DateTime.fromMillisecondsSinceEpoch(entry.timestamp??0)}',
                style: mono),
            Text('DURATION   : ${entry.duration}', style: mono),
            Text('ACCOUNT ID : ${entry.phoneAccountId}', style: mono),
            Text('SIM NAME   : ${entry.simDisplayName}', style: mono),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
        ),
      );
    }
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final Iterable<CallLogEntry> result = await CallLog.query();
                      setState(() {
                        _callLogEntries = result;
                      });
                    },
                    child: const Text('Get all'),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Workmanager().registerOneOffTask(
                        DateTime.now().millisecondsSinceEpoch.toString(),
                        'simpleTask',
                        existingWorkPolicy: ExistingWorkPolicy.replace,
                      );
                    },
                    child: const Text('Get all in background'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  shrinkWrap: true,
                  physics:const NeverScrollableScrollPhysics(),
                  children: children,
                ),
              )
            ],
          ),
        ),
      
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
          _smsLogs();
        },
          child: const Icon(Icons.refresh),
        ),
    );
  }
}
