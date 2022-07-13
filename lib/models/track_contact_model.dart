import 'package:hive/hive.dart';
part 'track_contact.g.dart';

@HiveType(typeId: 0)
class TrackContactModel extends HiveObject {
  TrackContactModel(
      {this.name, this.number, this.createdDate, this.identifier});

  @HiveField(0)
  String? name;

  @HiveField(1)
  String? number;

  @HiveField(2)
  DateTime? createdDate;

  @HiveField(3)
  String? identifier;

  get dateTime => null;
}
