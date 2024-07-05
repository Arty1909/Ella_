import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
part 'ranges.g.dart';

@HiveType(typeId: 1)
class Range {
  Range({required this.start, required this.end});

  @HiveField(0)
  DateTime start;

  @HiveField(1)
  DateTime end;
}
