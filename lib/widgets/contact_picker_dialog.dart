import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:contact_reminder/models/item.dart' as item;
import 'package:contact_reminder/models/track_contact_model.dart';
import 'package:contact_reminder/services/databse.dart';
import 'package:contact_reminder/services/toast_service.dart';
import 'package:contact_reminder/widgets/theme_text_field.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../configs/colors.dart';
import '../configs/dimensions.dart';
import '../models/contact_model.dart';

class ContactPickerDialog extends StatefulWidget {
  const ContactPickerDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<ContactPickerDialog> {
  late TextEditingController _searchController;
  final List<Contact> _searchResult = [];
  final List<Contact> reminderContacts = [];

  final List<Contact> _contacts = [];
  final List<Contact> _selectedContact = [];
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(searchListener);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (_isInit) {
      final status = await Permission.contacts.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        if ((await Permission.contacts.request()) == PermissionStatus.denied ||
            (await Permission.contacts.request()) ==
                PermissionStatus.permanentlyDenied) {
          ToastService.show("Contact permission required");
          Navigator.pop(context);
          return;
        }
      }
      _loadData();
    }
    _isInit = false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            child: Row(
              children: [
                Expanded(
                  child: ThemeInputField(
                    hint: "Search Name or Number...",
                    icon: Container(),
                    showDivider: false,
                    separatorVisible: false,
                    controller: _searchController,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await _updateContactsToDB();
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          _contacts.isEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Center(
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
                  ),
                )
              : Expanded(
                  child: _searchController.text.isNotEmpty
                      ? ListView.separated(
                          itemCount: _searchResult.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final contact = _searchResult[index];
                            return ListTile(
                              key: ValueKey(contact.identifier),
                              leading: Checkbox(
                                checkColor: ColorPallet.whiteColor,
                                activeColor: ColorPallet.primaryColor,
                                // fillColor: ColorPallet.primaryColor,
                                key: ValueKey(index),
                                value: _selectedContact.indexWhere(
                                        (element) =>
                                            element.identifier ==
                                            _searchResult[index].identifier,
                                        0) !=
                                    -1,
                                onChanged: (value) => onChange(
                                  value,
                                  _contacts.indexWhere((element) =>
                                      element.identifier ==
                                      _searchResult[index].identifier),
                                ),
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
                      : ListView.separated(
                          itemCount: _contacts.length,
                          separatorBuilder: (context, index) => const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Divider(),
                          ),
                          itemBuilder: (context, index) {
                            final contact = _contacts[index];
                            return ListTile(
                              key: ValueKey(contact.identifier),
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
                        ),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(45),
                  primary: ColorPallet.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
              onPressed: onSave,
              child: const Text(
                "Save",
                style: TextStyle(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _loadData() async {
    _contacts.clear();
    final result = await getContactsFromDB();

    if (result.isNotEmpty) {
      log("fetching contacts");

      _contacts.addAll(result.map((e) => Contact.fromMap(e.toMap())).toList());
    } else {
      log("updating contact...");
      await _updateContactsToDB();
    }
    setState(() {});

    List<TrackContactModel> trackContacts = await getTrackContacts();

    for (var element in _contacts) {
      if (trackContacts.indexWhere((e) => e.identifier == element.identifier) !=
          -1) {
        _selectedContact.add(element);
      }
    }

    setState(() {});
  }

  searchListener() {
    _searchResult.clear();
    if (_contacts.isEmpty) {
      return;
    }
    final searchText = _searchController.text;
    if (searchText.isEmpty) {
      setState(() {});
      return;
    }
    log(searchText);
    final result = _contacts
        .where((element) =>
            (element.displayName
                    ?.toLowerCase()
                    .contains(searchText.toLowerCase()) ??
                false) ||
            ((element.phones?.length ?? 0) > 0
                ? element.phones?.first.value?.contains(searchText) ?? false
                : false))
        .toList();
    log(result.map((e) => e.displayName).toString());
    _searchResult.addAll(result);
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

  Future _updateContactsToDB() async {
    _contacts.clear();
    var box = await Database.openContactBox();
    await box.clear();
    setState(() {});
    _contacts.addAll(await ContactsService.getContacts());

    List<ContactModel> updatedContacts = [];
    updatedContacts = _contacts
        .map((e) => ContactModel(
              identifier: e.identifier,
              displayName: e.displayName,
              givenName: e.givenName,
              middleName: e.middleName,
              prefix: e.prefix,
              suffix: e.suffix,
              familyName: e.familyName,
              company: e.company,
              jobTitle: e.jobTitle,
              emails: e.emails
                  ?.map<item.Item>(
                      (e) => item.Item(label: e.label, value: e.value))
                  .toList(),
              phones: e.phones
                  ?.map<item.Item>(
                      (e) => item.Item(label: e.label, value: e.value))
                  .toList(),
              avatar: e.avatar,
              birthday: e.birthday,
              androidAccountTypeRaw: e.androidAccountTypeRaw,
              androidAccountName: e.androidAccountName,
            ))
        .toList();

    final key = await box.add(updatedContacts.toList());
    return;
  }

  Future<List<ContactModel>> getContactsFromDB() async {
    var box = await Database.openContactBox();
    List<dynamic> list =
        box.isNotEmpty ? (await box.get(0) ?? []) : []; // 1 - contacts

    List<ContactModel> contacts = [];
    for (var c in list) {
      c as ContactModel;
      contacts.add(c);
    }
    return contacts;
  }

  Future<List<TrackContactModel>> getTrackContacts() async {
    var box = await Database.openTrackBox();
    List<dynamic> list =
        box.isNotEmpty ? (await box.get(0) ?? []) : []; // 0 - track contacts
    List<TrackContactModel> modelList = [];
    for (var c in list) {
      c as TrackContactModel;
      modelList.add(c);
    }
    return modelList;
  }

  onSave() async {
    var box = await Database.openTrackBox();
    await box.clear();
    List<TrackContactModel> trackContacts = [];
    for (var element in _selectedContact) {
      trackContacts.add(
        TrackContactModel(
          name: element.displayName,
          number: (element.phones?.isNotEmpty ?? false)
              ? element.phones?.first.value
              : "",
          createdDate: DateTime.now(),
          identifier: element.identifier,
        ),
      );
    }
    await box.add(trackContacts);
    Navigator.pop(context);
  }
}
