import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class ContactModel extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late int age;
}
