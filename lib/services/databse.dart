import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Database {
  var box;

  Database(String dbName) {
    box = Hive.openBox(dbName);
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
