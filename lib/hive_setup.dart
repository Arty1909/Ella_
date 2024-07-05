import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_3/ranges.dart';

// Declare and initialize boxRanges
late Box<Range> boxRanges;

Future<void> initHive() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(RangeAdapter());
  }
  // Initialize boxRanges
  boxRanges = await Hive.openBox<Range>('rangesBox');
}
