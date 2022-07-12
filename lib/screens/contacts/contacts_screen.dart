import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:call_log/call_log.dart';
import 'package:contact_reminder/configs/app_constants.dart';
import 'package:contact_reminder/configs/colors.dart';
import 'package:contact_reminder/models/contact.dart';
import 'package:contact_reminder/models/contact_log_model.dart';
import 'package:contact_reminder/models/log_type.dart';
import 'package:contact_reminder/widgets/shimmer_view/get_shimmer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../configs/dimensions.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final SmsQuery _query = SmsQuery();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool _isLoading = false;

  List<ContactLogModel> historyLog = [];
  List<ContactModel> numbers = [];
  List<CallLogEntry> _callLogEntries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Contact History".toUpperCase(),
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        // enablePullUp: true, // for loading
        header: const WaterDropMaterialHeader(
          color: Colors.white,
          backgroundColor: ColorPallet.primaryColor,
          offset: -0,
        ),
        onRefresh: _onRefresh,
        controller: _refreshController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: !_isLoading
            ? historyLog.isEmpty
                ? const Center(
                    child: Text(
                      "No contacts found",
                      style: TextStyle(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: historyLog.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final entry = historyLog[index];
                      return ContactLogItem(
                        entry: entry,
                        key: ValueKey(entry.number),
                      );
                    },
                    shrinkWrap: true,
                  )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: ListView.separated(
                  itemCount: 20,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return getContactShimmer(context, false);
                  },
                  shrinkWrap: true,
                ),
              ),
      ),
    );
  }

  void _onRefresh() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _loadData();
    } on Exception catch (e) {
      log(e.toString());
      _refreshController.loadFailed();
    }
    setState(() {
      _isLoading = false;
    });
    // if failed,use refreshFailed()

    _refreshController.refreshCompleted();
  }

  _loadData() async {
    setState(() => _isLoading = true);
    await _getCallLogs();
    historyLog.clear();
    numbers.clear();
    numbers = await contactFromDb();
    for (var number in numbers) {
      CallLogEntry? callLogEntry = await _getLastCallLogOf(number.number ?? "");
      SmsMessage? smsMessage = await _getLastSmsLogOf(number.number ?? "");

      ContactLogModel contactLogModel = ContactLogModel(
        callType: CallType.unknown,
        dateTime: DateTime.now(),
        duration: 0,
        message: "Unknown",
        name: number.name ?? "",
        number: number.number ?? "",
        type: Type.call,
        sender: "Unknown",
      );

      log(callLogEntry?.number ?? "name");
      if (smsMessage != null && callLogEntry != null) {
        if (smsMessage.date!
                .difference(DateTime.fromMillisecondsSinceEpoch(
                    callLogEntry.timestamp ?? 0))
                .inMilliseconds >
            0) {
          contactLogModel = contactLogModel.copyWith(
            sender: smsMessage.sender,
            name: callLogEntry.name,
            dateTime: smsMessage.date!,
            message: smsMessage.body,
            type: Type.sms,
          );
          historyLog.add(contactLogModel);
          continue;
        }
      } else if (smsMessage != null) {
        contactLogModel = contactLogModel.copyWith(
          sender: smsMessage.sender,
          name: number.name,
          dateTime: smsMessage.date!,
          message: smsMessage.body,
          type: Type.sms,
        );
        historyLog.add(contactLogModel);
        continue;
      }
      contactLogModel = contactLogModel.copyWith(
        callType: callLogEntry?.callType,
        dateTime:
            DateTime.fromMillisecondsSinceEpoch(callLogEntry?.timestamp ?? 0),
        type: Type.call,
        duration: callLogEntry?.duration,
        name: callLogEntry?.name,
      );
      historyLog.add(contactLogModel);
    }

    historyLog.sort(
      (a, b) => b.dateTime.compareTo(a.dateTime),
    );
    setState(() => _isLoading = false);
  }

  _getCallLogs() async {
    final status = await Permission.phone.status;
    if (status.isGranted) {
      final Iterable<CallLogEntry> result = await CallLog.query();
      _callLogEntries = result.toList();
    } else {
      await Permission.phone.request();
    }
  }

  Future<CallLogEntry?> _getLastCallLogOf(number) async {
    final status = await Permission.phone.status;
    if (status.isGranted) {
      final result = (await CallLog.query(number: number)).toList();
      return result.isNotEmpty ? result[0] : null;
    } else {
      await Permission.phone.request();
    }
    return null;
  }

  Future<SmsMessage?> _getLastSmsLogOf(number) async {
    SmsMessage? message;
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox, SmsQueryKind.sent],
        address: number,
        count: 0,
      );
      if (messages.isNotEmpty) {
        message = messages[0];
      }
    } else {
      await Permission.sms.request();
    }
    return message;
  }

  Future<List<ContactModel>> contactFromDb() async {
    var box = await openHiveBox(AppConstants.DATABASE_NAME);
    // await box.clear();

    List<dynamic> list = box.isNotEmpty ? await box.get(0) : [];
    List<ContactModel> modelList = [];
    for (var c in list) {
      c as ContactModel;
      modelList.add(c);
    }
    return modelList;
  }

  Future<Box> openHiveBox(String boxName) async {
    if (!kIsWeb && !Hive.isBoxOpen(boxName)) {
      Hive.init((await getApplicationDocumentsDirectory()).path);
      Hive.registerAdapter(ContactModelAdapter());
    }
    return await Hive.openBox(boxName);
  }
}

class ContactLogItem extends StatelessWidget {
  const ContactLogItem({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final ContactLogModel entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 40,
        width: 40,
        alignment: Alignment.center,
        child: Icon(
          entry.type == Type.call ? Icons.call : Icons.message,
          color: ColorPallet.secondaryColor,
        ),
      ),
      title: AutoSizeText(
        entry.name,
        style: const TextStyle(
          fontSize: Dimensions.FONT_SIZE_LARGE,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            entry.type == Type.call
                ? entry.number
                : "Message: " + entry.message,
            style: TextStyle(
              color: ColorPallet.blackColor.withOpacity(0.6),
            ),
          ),
          if (entry.type == Type.call) ...[
            const SizedBox(width: 6),
            Icon(
              entry.callType == CallType.incoming
                  ? Icons.phone_callback
                  : entry.callType == CallType.outgoing
                      ? Icons.phone_forwarded
                      : Icons.phone,
              color: ColorPallet.blackColor.withOpacity(0.6),
              size: 12,
            ),
          ],
        ],
      ),
      trailing: AutoSizeText(
        DateFormat("d MMM hh:mm a").format(entry.dateTime),
        style: TextStyle(
          color: ColorPallet.blackColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
