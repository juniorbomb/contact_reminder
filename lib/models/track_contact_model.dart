import 'package:hive/hive.dart';
part 'track_contact_model.g.dart';

@HiveType(typeId: 0)
class TrackContactModel extends HiveObject {
  TrackContactModel(
      {this.name, this.numbers, this.createdDate, this.identifier});

  @HiveField(0)
  String? name;

  @HiveField(1)
  List<String>? numbers;

  @HiveField(2)
  DateTime? createdDate;

  @HiveField(3)
  String? identifier;

  get dateTime => null;
}
