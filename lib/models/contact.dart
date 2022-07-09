import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 0)
class ContactModel extends HiveObject {

  ContactModel(
    {this.name,this.number,this.createdDate,this.identifier}
  );

  @HiveField(0)
  String? name;

  @HiveField(1)
  String? number;

  @HiveField(2)
  DateTime? createdDate;

  @HiveField(3)
  String? identifier;
}
