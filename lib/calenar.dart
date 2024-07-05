import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_3/ranges.dart';
import 'package:custom_calendar_viewer/custom_calendar_viewer.dart';
import 'package:flutter_application_3/hive_setup.dart';

Future<void> main() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(RangeAdapter());
  }
  boxRanges = await Hive.openBox<Range>('rangesBox');
  runApp(const MyCalendar());
}

class MyCalendar extends StatelessWidget {
  const MyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calendar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int checked = 0;
  late List<RangeDate> ranges;

  @override
  void initState() {
    super.initState();
    ranges = [];
  }

  void _handleSaveButtonPressed() {
    if (boxRanges.isOpen) {
      boxRanges.clear();
      for (int i = 0; i < ranges.length - checked; i++) {
        boxRanges.add(Range(start: ranges[i].start, end: ranges[i].end));
      }
    }
  }

  void _handleCheckButtonPressed() {
    if (ranges.isNotEmpty) {
      DateTime lastStart = ranges.last.start;
      DateTime nextStartPrediction = lastStart.add(
        Duration(days: _averageDistanceBetweenDates(_parseDateRanges(ranges))),
      );

      RangeDate nextPrediction = RangeDate(
        start: nextStartPrediction,
        end: nextStartPrediction.add(
          Duration(days: _averageDuration(ranges)),
        ),
        color: Colors.cyan,
      );

      setState(() {
        checked = 1;
        ranges.add(nextPrediction);
      });
    }
  }

  List<DateTime> _parseDateRanges(List<RangeDate> dateRanges) {
    return dateRanges.map((r) => r.start).toList();
  }

  int _averageDistanceBetweenDates(List<DateTime> dates) {
    if (dates.isEmpty || dates.length < 2) {
      return 0;
    }
    int totalDays = 0;
    for (int i = 1; i < dates.length; i++) {
      totalDays += dates[i].difference(dates[i - 1]).inDays;
    }
    return totalDays ~/ (dates.length - 1);
  }

  int _averageDuration(List<RangeDate> dateRanges) {
    if (dateRanges.isEmpty) {
      return 0;
    }
    int totalDuration = 0;
    for (RangeDate range in dateRanges) {
      totalDuration += range.end.difference(range.start).inDays;
    }
    return totalDuration ~/ dateRanges.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double maxAvailableWidth = constraints.maxWidth;
            double maxAvailableHeight = constraints.maxHeight;
            double halfHeight = constraints.maxHeight * 0.54;
            double aspectRatio = 1;
            double calculatedWidth = halfHeight / aspectRatio;

            double effectiveWidth = calculatedWidth > maxAvailableWidth
                ? maxAvailableWidth // Ensure it doesn't exceed the available width
                : calculatedWidth;

            return Center(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Align in center
                children: [
                  SizedBox(
                    height: halfHeight, // Half of the available height
                    width: effectiveWidth, // Maintain aspect ratio
                    child: CustomCalendarViewer(
                      ranges: ranges,
                      calendarType: CustomCalendarType.multiRanges,
                      calendarStyle: CustomCalendarStyle.normal,
                    ),
                  ),
                  Spacer(flex: 2), // Space to push buttons up
                  ElevatedButton(
                    onPressed: _handleSaveButtonPressed,
                    child: const Text("Save"),
                  ),
                  SizedBox(height: 20), // Space between buttons
                  ElevatedButton(
                    onPressed: _handleCheckButtonPressed,
                    child: const Text("Check"),
                  ),
                  Spacer(flex: 1), // Space at the bottom
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
