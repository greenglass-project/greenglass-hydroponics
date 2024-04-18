import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChangeableDouble {
  double value;
  ChangeableDouble(this.value);
}

class ChangeableInt {
  int value;
  ChangeableInt(this.value);
}

class ChangeableString {
  String value;
  ChangeableString(this.value);
}

class ChangeableOnOffSchedule {
  int? duration;
  int? period;
  int? start;
  int? end;
  ChangeableOnOffSchedule(this.duration,  this.period, this.start, this.end);
}

mixin DialogMixin {
  
  TextStyle textStyle(BuildContext context){
    return Theme.of(context).textTheme.labelSmall!;
  }

  TextStyle errorTextStyle(BuildContext context){
    return Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.red);
  }

  BoxBorder borderStyle() {
    return Border.all(
        color: Colors.orangeAccent,
        width: 0.25,
        style: BorderStyle.solid);
  }

  Widget clickableTextField(BuildContext context, String text, Function onTouch) {
    return Container(
        decoration: BoxDecoration(border: borderStyle()),
        child: InkWell(
            onTap: () => onTouch(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text(text, style: textStyle(context)),
            )
        )
    );
  }

  Widget changeableTextField(BuildContext context, ChangeableString cs, Function onTouch) {
    return Container(
        decoration: BoxDecoration(border: borderStyle()),
        child: InkWell(
            onTap: () => onTouch(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text(cs.value, style: textStyle(context)),
            )
        )
    );
  }

  Widget changeableIntervalField(BuildContext context, int value, Function onTouch) {
    String display;
    if(value <120) {
      display = "${value} mins";
    } else {
      int hrs = value~/60;
      display = "$hrs hours";
    }
    return Container(
        decoration: BoxDecoration(border: borderStyle()),
        child: InkWell(
            onTap: () => onTouch(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text(display, style: textStyle(context)),

    )
        )
    );
  }

  Widget changeableIntField(BuildContext context, int value, Function onTouch) {
    return Container(
        decoration: BoxDecoration(border: borderStyle()),
        child: InkWell(
            onTap: () => onTouch(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text(value.toString(), style: textStyle(context)),
            )
        )
    );
  }

  Widget changeableDoubleField(BuildContext context, double value, Function onTouch) {
    return Container(
        decoration: BoxDecoration(border: borderStyle()),
        child: InkWell(
            onTap: () => onTouch(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text(value.toString(), style: textStyle(context)),
            )
        )
    );
  }

  Widget changeableTimeField(BuildContext context, int value, Function onTouch) {
    final format = NumberFormat("00");
    return Container(
        decoration: BoxDecoration(border: borderStyle()),
        child: InkWell(
            onTap: () => onTouch(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text("${format.format(value)}:00", style: textStyle(context)),
            )
        )
    );
  }

  Widget changeableDaysField(BuildContext context, int value, Function onTouch) {
    return Container(
        decoration: BoxDecoration(border: borderStyle()),
        child: InkWell(
            onTap: () => onTouch(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text(value.toString(),
                  style: textStyle(context)),
            )
        )
    );
  }

  Widget displayOnlyField(BuildContext context, String value) {
    final runes = Runes(value);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Text(String.fromCharCodes(runes), style: textStyle(context)),
    );
  }
}