import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hydroponics_framework/date_helpers.dart';

class Utilities {

  static NumberFormat formatter = NumberFormat("00");

  static Uint8List convertStringToUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);

    return unit8List;
  }

  static String convertUint8ListToString(Uint8List uint8list) {
    return String.fromCharCodes(uint8list);
  }

  static TimeOfDay timeOfDayFromString(String value) {
    try {
      final parts = value.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } on Exception {
      throw FormatException("Value $value is bad date-time");
    }
  }

  static String? timeOfDayToString(TimeOfDay? timeOfDay) {
    if(timeOfDay == null) {
      return null;
    } else {
      return "${formatter.format(timeOfDay.hour)}:${formatter.format(
          timeOfDay.minute)}";
    }
  }

  static String formatTimeStamp(DateTime ts, bool showHyphen, bool showSeconds) {
    var buffer = StringBuffer();
    DateTime timestamp = ts.toLocal();
    if(timestamp.isToday()) {
      buffer.write("Today ");
      if(showHyphen) {
        buffer.write("- ");
      }
      buffer.write(formatter.format(timestamp.hour));
      buffer.write(":");
      buffer.write(formatter.format(timestamp.minute));
      if(showSeconds) {
        buffer.write(":");
        buffer.write(formatter.format(timestamp.second));
      }
    } else if(timestamp.isYesterday()) {
      buffer.write("Yesterday ");
      if(showHyphen) {
        buffer.write("- ");
      }
      buffer.write(formatter.format(timestamp.hour));
      buffer.write(":");
      buffer.write(formatter.format(timestamp.minute));
      if(showSeconds) {
        buffer.write(":");
        buffer.write(formatter.format(timestamp.second));
      }
    } else {
      buffer.write(DateFormat("dd-MM-yyyy ").format(timestamp)); //.format(timestamp));
    }

    return buffer.toString();
  }

  static String formatDuration(Duration duration) {
    if(duration.inMinutes < 1) {
      return "${duration.inSeconds} secs";
    } if(duration.inMinutes < 2) {
      return "${duration.inMinutes} min";
    } else if(duration.inHours < 1) {
      return "${duration.inMinutes} mins";
    } else if(duration.inHours < 2) {
      return "${duration.inHours} hour";
    } else if(duration.inHours < 24) {
      return "${duration.inHours} hours";
    } else if(duration.inDays < 2) {
      return "${duration.inDays} day";
    } else {
      return "${duration.inDays} days";
    }
  }
}