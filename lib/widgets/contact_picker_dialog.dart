import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:contact_reminder/configs/app_constants.dart';
import 'package:contact_reminder/models/contact.dart';
import 'package:contact_reminder/services/databse.dart';
import 'package:contact_reminder/widgets/theme_text_field.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../configs/colors.dart';
import '../configs/dimensions.dart';

class ContactPickerDialog extends StatefulWidget {
  const ContactPickerDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<ContactPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  final List<Contact> _searchResult = [];
  final List<Contact> reminderContacts = [];
  late Database _database;

  final List<Contact> _contacts = [];
  final List<Contact> _selectedContact = [];
  bool _isInit = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (_isInit) {
      // _database = Database(AppConstants.DATABASE);
      // _database.getAll();
      _searchController.addListener(searchListener);
      final status = await Permission.contacts.status;
      if (status.isDenied||status.isPermanentlyDenied) {
        if ((await Permission.contacts.request()) == PermissionStatus.denied || (await Permission.contacts.request()) == PermissionStatus.permanentlyDenied) {
          SnackBar snackBar =
              const SnackBar(content: Text("Contact permission required"));
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.pop(context);
          return;
        }
      }
      ContactsService.getContacts().then((value) async {
        _contacts.clear();
        List<ContactModel> dbList = await contactFromDb();
        _contacts.addAll(value);

        for (var element in _contacts) {
            if (dbList.indexWhere((e) => e.identifier == element.identifier) !=
                -1) {
              _selectedContact.add(element);
            }
          }
        setState(() {});
      });
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          Dimensions.RADIUS_SIZE_TEN,
        ),
      ),
      backgroundColor: ColorPallet.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: Dimensions.PADDING_SIZE_LARGE,
              bottom: Dimensions.PADDING_SIZE_LARGE,
            ),
            alignment: Alignment.center,
            child: const Text(
              "Add Contact In Your Reminder",
              style: TextStyle(
                color: Colors.black,
                fontSize: Dimensions.FONT_SIZE_LARGE,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              right: 12,
            ),
            child: ThemeInputField(
              hint: "Search Name or Number...",
              icon: Container(),
              showDivider: false,
              separatorVisible: false,
              controller: _searchController,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _contacts.isEmpty
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
                : _searchController.text.isNotEmpty
                    ? ListView.builder(
                        itemCount: _searchResult.length,
                        itemBuilder: (context, index) {
                          final contact = _searchResult[0];
                          return ListTile(
                            key: ValueKey(index),
                            leading: Checkbox(
                              checkColor: ColorPallet.whiteColor,
                              activeColor: ColorPallet.primaryColor,
                              // fillColor: ColorPallet.primaryColor,

                              key: ValueKey(index),
                              value: _selectedContact.indexWhere(
                                      (element) =>
                                          element.phones ==
                                          _contacts[index].phones,
                                      0) !=
                                  -1,
                              onChanged: (value) => onChange(value, index),
                            ),
                            title: AutoSizeText(
                              contact.displayName.toString(),
                              style: const TextStyle(
                                fontSize: Dimensions.FONT_SIZE_LARGE,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: (contact.phones == null ||
                                    (contact.phones?.isEmpty ?? false))
                                ? null
                                : AutoSizeText(
                                    contact.phones!.first.value.toString(),
                                    style: TextStyle(
                                      color: ColorPallet.blackColor
                                          .withOpacity(0.6),
                                    ),
                                  ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          return ListTile(
                            key: ValueKey(index),
                            leading: Checkbox(
                              checkColor: ColorPallet.whiteColor,
                              activeColor: ColorPallet.primaryColor,
                              // fillColor: ColorPallet.primaryColor,

                              key: ValueKey(index),
                              value: _selectedContact.indexWhere(
                                      (element) => element.phones == _contacts[index].phones,0) !=
                                  -1,
                              onChanged: (value) => onChange(value, index),
                            ),
                            title: AutoSizeText(
                              contact.displayName.toString(),
                              style: const TextStyle(
                                fontSize: Dimensions.FONT_SIZE_LARGE,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: (contact.phones == null ||
                                    (contact.phones?.isEmpty ?? false))
                                ? null
                                : AutoSizeText(
                                    contact.phones!.first.value.toString(),
                                    style: TextStyle(
                                      color: ColorPallet.blackColor
                                          .withOpacity(0.6),
                                    ),
                                  ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: ColorPallet.primaryColor,
              ),
              onPressed: onSave,
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }

  searchListener() {
    if (_contacts.isEmpty) {
      return;
    }
    final searchText = _searchController.text;
    _searchResult.clear();
    if (searchText.isEmpty) {
      setState(() {});
      return;
    }
    log(searchText);
    _searchResult.addAll(_contacts
        .where((element) =>
            (element.displayName?.toLowerCase().contains(searchText.toLowerCase()) ?? false) ||
            ((element.phones?.length ?? 0) > 0
                ? element.phones?.first.value?.contains(searchText) ?? false
                : false))
        .toList());
    setState(() {});
  }

  onChange(value, index) {
    log(value.toString());
    if (value ?? false) {
      _selectedContact.add(_contacts[index]);
    } else {
      _selectedContact.remove(_contacts[index]);
    }
    setState(() {});
  }

  Future<Box> openHiveBox(String boxName) async {
    if (!kIsWeb && !Hive.isBoxOpen(boxName)) {
      Hive.init((await getApplicationDocumentsDirectory()).path);
      Hive.registerAdapter(ContactModelAdapter());
    }
    return await Hive.openBox(boxName);
  }

  Future<List<ContactModel>> contactFromDb() async {
    var box = await openHiveBox(AppConstants.DATABASE_NAME);
     List<dynamic> list = box.isNotEmpty ? await box.get(0) : [];
    List<ContactModel> modelList = [];
    for(var c in list){
      c as ContactModel;
      modelList.add(c);
    }
    return modelList;
  }

  onSave() async {
    var box = await openHiveBox(AppConstants.DATABASE_NAME);
    await box.clear();
    List<ContactModel> model = [];
    _selectedContact.forEach((element) {
      print("identifier --> ${element.identifier}");
      model.add(ContactModel(
          name: element.displayName,
          number: (element.phones?.isNotEmpty ?? false)
              ? element.phones?.first.value
              : "",
          createdDate: DateTime.now(),
          identifier: element.identifier));
    });
    await box.add(model);
    Navigator.pop(context);
  }
}