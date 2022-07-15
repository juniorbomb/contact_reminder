import 'dart:developer';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:call_log/call_log.dart';
import 'package:contact_reminder/configs/app_constants.dart';
import 'package:contact_reminder/configs/colors.dart';
import 'package:contact_reminder/models/track_contact_model.dart';
import 'package:contact_reminder/models/contact_log_model.dart';
import 'package:contact_reminder/models/log_type.dart';
import 'package:contact_reminder/services/toast_service.dart';
import 'package:contact_reminder/widgets/shimmer_view/get_shimmer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../configs/dimensions.dart';
import '../../widgets/contact/contact_log_item.dart';

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
  List<TrackContactModel> numbers = [];
  List<CallLogEntry> _callLogEntries = [];
  List<SmsMessage> _smsEntries = [];

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
          offset: 0,
        ),
        onRefresh: _onRefresh,
        controller: _refreshController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: !_isLoading
            ? historyLog.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2),
                        const Spacer(),
                        const AutoSizeText(
                          "No contacts found",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorPallet.darkBlackColor,
                            fontSize: Dimensions.FONT_SIZE_LARGE,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const AutoSizeText(
                          "track your first contact",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorPallet.darkBlackColor,
                            fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        // const SizedBox(height: 12),

                        Transform(
                          transform: Matrix4.translationValues(-15, 0, 0),
                          child: Transform.rotate(
                            angle: -math.pi / 8,
                            child: Image.asset(
                              "assets/icons/down-arrow-curved.png",
                              color: ColorPallet.primaryColor.withOpacity(0.4),
                              height: MediaQuery.of(context).size.height * 0.2,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: historyLog.length,
                    separatorBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Divider(),
                    ),
                    itemBuilder: (context, index) {
                      final entry = historyLog[index];
                      return ContactLogItem(
                        entry: entry,
                        key: ValueKey(entry.numbers),
                      );
                    },
                    shrinkWrap: true,
                  )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: ListView.separated(
                  itemCount: 20,
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(),
                  ),
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
    await _getSMSLogs();
    historyLog.clear();
    numbers.clear();
    numbers = await contactFromDb();
    Map<Permission, PermissionStatus> permissionStatus = await [
      Permission.sms,
      Permission.phone,
      Permission.contacts,
    ].request();
    if (!(permissionStatus[Permission.sms]?.isGranted ?? false)) {
      ToastService.show("No sms permission");
    }
    if (!(permissionStatus[Permission.phone]?.isGranted ?? false)) {
      ToastService.show("No phone permission");
    }
    if (!(permissionStatus[Permission.contacts]?.isGranted ?? false)) {
      ToastService.show("No contact permission");
    }

    for (var number in numbers) {
      if (number.numbers?.isEmpty ?? true) {
        continue;
      }
      const regexString = r"[^0-9+]"; // ^\w\s -- remove all special char
      final reg = RegExp(regexString);
      number.numbers =
          number.numbers?.map((e) => e.replaceAll(reg, '')).toList() ?? [];

      print("Number ==>" + (number.numbers?.join(", ").toString() ?? "try"));
      CallLogEntry? callLogEntry =
          await _getLastCallLogOf(number.numbers ?? []);
      SmsMessage? smsMessage = await _getLastSmsLogOf(number.numbers ?? []);

      print("sms ==>" + (smsMessage?.address ?? "address"));
      print("sms ==>" + (smsMessage?.body ?? "address"));

      ContactLogModel contactLogModel = ContactLogModel(
        callType: CallType.unknown,
        dateTime: DateTime.now(),
        duration: 0,
        message: "Unknown",
        name: number.name ?? "",
        numbers: number.numbers ?? [],
        type: Type.call,
        sender: "Unknown",
      );

      if (smsMessage != null && callLogEntry != null) {
        print("name ==>" + number.name.toString());
        print("sms date ==>" + smsMessage.date.toString());
        print("sms ==>" + smsMessage.body.toString());

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
            numbers: [smsMessage.address ?? "unknown"],
            type: Type.sms,
          );
        } else {
          contactLogModel = contactLogModel.copyWith(
            callType: callLogEntry.callType,
            dateTime: DateTime.fromMillisecondsSinceEpoch(
                callLogEntry.timestamp ?? 0),
            type: Type.call,
            duration: callLogEntry.duration,
            numbers: [callLogEntry.number ?? "unknown"],
            name: callLogEntry.name,
          );
        }
      } else if (smsMessage != null) {
        contactLogModel = contactLogModel.copyWith(
          sender: smsMessage.sender,
          name: number.name,
          dateTime: smsMessage.date!,
          message: smsMessage.body,
          numbers: [smsMessage.address ?? "unknown"],
          type: Type.sms,
        );
      } else if (callLogEntry != null) {
        contactLogModel = contactLogModel.copyWith(
          callType: callLogEntry.callType,
          dateTime:
              DateTime.fromMillisecondsSinceEpoch(callLogEntry.timestamp ?? 0),
          type: Type.call,
          duration: callLogEntry.duration,
          numbers: [callLogEntry.number ?? "unknown"],
          name: callLogEntry.name,
        );
      } else {
        continue;
      }
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

  _getSMSLogs() async {
    var status = await Permission.sms.status;
    if (status.isGranted) {
      final result = await _query.getAllSms;
      _smsEntries = result.toList();
    }
  }

  Future<CallLogEntry?> _getLastCallLogOf(List<String> numbers) async {
    CallLogEntry? callLogEntry;
    const regex = r"[^0-9+]";
    final reg = RegExp(regex);
    List<CallLogEntry> result = [];
    for (var call in _callLogEntries) {
      for (var num in numbers) {
        if (call.number?.replaceAll(reg, "").contains(num) ?? false) {
          print("match sms numbers ==> ${call.number?.replaceAll(reg, "")}");
          result.add(call);
        }
      }
    }

    result.sort((a, b) =>
        b.timestamp
            ?.compareTo(a.timestamp ?? DateTime.now().millisecondsSinceEpoch) ??
        0);
    callLogEntry = result.isNotEmpty ? result[0] : null;
    return callLogEntry;
  }

  Future<SmsMessage?> _getLastSmsLogOf(List<String> numbers) async {
    SmsMessage? message;
    const regex = r"[^0-9+]";
    final reg = RegExp(regex);
    List<SmsMessage> result = [];
    for (var sms in _smsEntries) {
      for (var num in numbers) {
        if (sms.address?.replaceAll(reg, "").contains(num) ?? false) {
          result.add(sms);
          print("match sms numbers ==> ${sms.address?.replaceAll(reg, "")}");
        }
      }
    }
    result.sort((a, b) => b.date?.compareTo(a.date ?? DateTime.now()) ?? 0);
    message = result.isNotEmpty ? result[0] : null;
    return message;
  }

  Future<List<TrackContactModel>> contactFromDb() async {
    var box = await openHiveBox(AppConstants.TRACK_CONTACT_DATABASE_NAME);

    List<dynamic> list = box.isNotEmpty ? (await box.get(0) ?? []) : [];
    List<TrackContactModel> modelList = [];
    for (var c in list) {
      c as TrackContactModel;
      modelList.add(c);
    }
    return modelList;
  }

  Future<Box> openHiveBox(String boxName) async {
    if (!kIsWeb && !Hive.isBoxOpen(boxName)) {
      Hive.init((await getApplicationDocumentsDirectory()).path);
      Hive.registerAdapter(TrackContactModelAdapter());
    }
    return await Hive.openBox(boxName);
  }
}
