import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:contact_reminder/services/databse.dart';
import 'package:contact_reminder/services/toast_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../configs/app_constants.dart';
import '../../configs/colors.dart';
import '../../configs/dimensions.dart';
import '../../models/track_contact_model.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({Key? key}) : super(key: key);

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  List<TrackContactModel> contacts = [];
  bool _isLoading = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _isLoading = true;
    setState(() {});
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Tracked Contacts".toUpperCase(),
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            Visibility(
              visible: contacts.isNotEmpty,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 12),
                  Text(
                    "Contacts: " + contacts.length.toString(),
                    style: const TextStyle(
                      color: ColorPallet.secondaryColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ToastService.show("Long press to remove all");
                    },
                    onLongPress: () async {
                      try {
                        final box = await Database.openTrackBox();
                        await box.clear();
                        ToastService.show("Clear");
                        await _loadData();
                        setState(() {});
                      } on Exception catch (e) {
                        ToastService.show(
                            "Something went wrong! try again later");
                      }
                    },
                    child: const Text(
                      "Remove all",
                      style: TextStyle(
                        color: ColorPallet.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(
                            color: ColorPallet.primaryColor,
                          ),
                          SizedBox(height: 12),
                          AutoSizeText(
                            "Loading...",
                            style: TextStyle(
                              color: ColorPallet.primaryColor,
                              fontSize: Dimensions.FONT_SIZE_LARGE,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : contacts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 150 - 8),
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
                              Transform(
                                transform: Matrix4.translationValues(-15, 0, 0),
                                child: Transform.rotate(
                                  angle: -math.pi / 8,
                                  child: Image.asset(
                                    "assets/icons/down-arrow-curved.png",
                                    color: ColorPallet.primaryColor
                                        .withOpacity(0.4),
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: contacts.length,
                          separatorBuilder: (context, index) => const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Divider(),
                          ),
                          itemBuilder: (context, index) {
                            final contact = contacts[index];

                            return ContactLogItem(
                              contact: contact,
                              onDismissed: () async {
                                contacts.removeWhere((element) =>
                                    element.identifier == contact.identifier);
                                await onDelete();
                                setState(() {});
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  _loadData() {
    contactFromDb().then((value) {
      setState(() {
        _isLoading = false;
        contacts = value.reversed.toList();
      });
    });
  }

  Future<List<TrackContactModel>> contactFromDb() async {
    var box = await openHiveBox(AppConstants.TRACK_CONTACT_DATABASE_NAME);
    // await box.clear();
    print("Db Data --> ${box.get(0)}");
    List<dynamic> list = box.isNotEmpty ? await box.get(0) : [];
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

  onDelete() async {
    var box = await openHiveBox(AppConstants.TRACK_CONTACT_DATABASE_NAME);
    await box.clear();
    List<TrackContactModel> model = [];
    for (var element in contacts) {
      model.add(
        TrackContactModel(
          name: element.name,
          number: element.number ?? "",
          createdDate: DateTime.now(),
          identifier: element.identifier,
        ),
      );
    }
    await box.add(model);
  }
}

class ContactLogItem extends StatelessWidget {
  ContactLogItem({
    Key? key,
    required this.contact,
    required this.onDismissed,
  }) : super(key: key);

  final TrackContactModel contact;
  Function()? onDismissed;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(contact.identifier),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onDismissed,
              child: Container(
                color: ColorPallet.redColor,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    Text(
                      "delete",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onDismissed,
              child: Container(
                color: ColorPallet.redColor,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    Text(
                      "delete",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          child: const Icon(
            Icons.person,
            color: ColorPallet.secondaryColor,
          ),
        ),
        title: AutoSizeText(
          contact.name ?? "Unknown",
          style: const TextStyle(
            fontSize: Dimensions.FONT_SIZE_LARGE,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AutoSizeText(
              contact.number ?? "+0 0000000000",
              style: TextStyle(
                color: ColorPallet.blackColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
