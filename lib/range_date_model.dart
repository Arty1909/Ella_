import 'package:flutter/material.dart';

class RangeDate {
  DateTime start;
  DateTime end;
  Color
      color; // Using int for color for simplicity, you may need to handle colors differently

  RangeDate({
    required this.start,
    required this.end,
    this.color = Colors.blue,
  });
}
