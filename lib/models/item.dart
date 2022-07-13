import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 2)
class Item {
  Item({this.label, this.value});

  @HiveField(0)
  String? label;
  @HiveField(1)
  String? value;

  static Map toMap(Item i) => {"label": i.label, "value": i.value};
}
