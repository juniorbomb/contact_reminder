import 'dart:typed_data';

import 'package:hive/hive.dart';

import 'item.dart';

part 'contact.g.dart';

@HiveType(typeId: 1)
class ContactModel {
  ContactModel({
    this.identifier,
    this.displayName,
    this.givenName,
    this.middleName,
    this.prefix,
    this.suffix,
    this.familyName,
    this.company,
    this.jobTitle,
    this.emails,
    this.phones,
    this.avatar,
    this.birthday,
    this.androidAccountTypeRaw,
    this.androidAccountName,
  });

  @HiveField(0)
  String? identifier;
  @HiveField(1)
  String? displayName;
  @HiveField(2)
  String? givenName;
  @HiveField(3)
  String? middleName;
  @HiveField(4)
  String? prefix;
  @HiveField(5)
  String? suffix;
  @HiveField(6)
  String? familyName;
  @HiveField(7)
  String? company;
  @HiveField(8)
  String? jobTitle;
  @HiveField(9)
  String? androidAccountTypeRaw;
  @HiveField(10)
  String? androidAccountName;
  @HiveField(11)
  List<Item>? emails = [];
  @HiveField(12)
  List<Item>? phones = [];
  @HiveField(13)
  Uint8List? avatar;
  @HiveField(14)
  DateTime? birthday;

  static Map _toMap(ContactModel contact) {
    var emails = [];
    for (Item email in contact.emails ?? []) {
      emails.add(Item.toMap(email));
    }
    var phones = [];
    for (Item phone in contact.phones ?? []) {
      phones.add(Item.toMap(phone));
    }

    final birthday = contact.birthday == null
        ? null
        : "${contact.birthday!.year.toString()}-${contact.birthday!.month.toString().padLeft(2, '0')}-${contact.birthday!.day.toString().padLeft(2, '0')}";

    return {
      "identifier": contact.identifier,
      "displayName": contact.displayName,
      "givenName": contact.givenName,
      "middleName": contact.middleName,
      "familyName": contact.familyName,
      "prefix": contact.prefix,
      "suffix": contact.suffix,
      "company": contact.company,
      "jobTitle": contact.jobTitle,
      "androidAccountType": contact.androidAccountTypeRaw,
      "androidAccountName": contact.androidAccountName,
      "emails": emails,
      "phones": phones,
      "avatar": contact.avatar,
      "birthday": birthday
    };
  }

  Map toMap() {
    return ContactModel._toMap(this);
  }
}
