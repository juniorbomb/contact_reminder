import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../configs/app_constants.dart';
import '../../configs/colors.dart';
import '../../configs/dimensions.dart';
import '../../models/contact.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({Key? key}) : super(key: key);

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  List<ContactModel> contacts = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    contacts = await contactFromDb();
    setState(() {});
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
      body: contacts.isEmpty
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
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ContactLogItem(
                  contact: contact,
                  onDismissed: () async {
                    contacts.removeWhere(
                        (element) => element.identifier == contact.identifier);
                    await onDelete();
                    setState(() {});
                  },
                );
              },
            ),
    );
  }

  Future<List<ContactModel>> contactFromDb() async {
    var box = await openHiveBox(AppConstants.DATABASE_NAME);
    // await box.clear();
    print("Db Data --> ${box.get(0)}");
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

  onDelete() async {
    var box = await openHiveBox(AppConstants.DATABASE_NAME);
    await box.clear();
    List<ContactModel> model = [];
    for (var element in contacts) {
      model.add(
        ContactModel(
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

  final ContactModel contact;
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
