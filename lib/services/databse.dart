import 'package:contact_reminder/configs/app_constants.dart';
import 'package:contact_reminder/models/track_contact_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/contact_model.dart';
import '../models/item.dart';

class Database {
  var box;

  static Future<Box> openTrackBox() async {
    const boxName = AppConstants.TRACK_CONTACT_DATABASE_NAME;
    if (!Hive.isBoxOpen(boxName)) {
      Hive.init((await getApplicationDocumentsDirectory()).path);
      Hive.registerAdapter(TrackContactModelAdapter());
    }
    return await Hive.openBox(boxName);
  }

  static Future<Box> openContactBox() async {
    const boxName = AppConstants.CONTACT_DATABASE_NAME;
    if (!Hive.isBoxOpen(boxName)) {
      Hive.init((await getApplicationDocumentsDirectory()).path);
      Hive.registerAdapter(ContactModelAdapter());
      Hive.registerAdapter(ItemAdapter());
    }
    return await Hive.openBox(boxName);
  }

  get(number) {
    try {
      return box.get(number);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  getAll() {
    try {
      return box.getAll();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void insert(data) {
    try {
      box.add(data);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void delete(number) {
    try {
      box.delete(number);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void deleteAll() {
    try {
      box.deleteAll();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
}
