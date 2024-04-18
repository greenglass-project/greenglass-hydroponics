import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

enum Status {
  UNKNOWN,
  NOT_CALIBRATED,
  CALIBRATING,
  CALIBRATED
}

class CalibrationStatusRow extends StatefulWidget {
  final int completedState;
  final Stream<int> stateStream;

  CalibrationStatusRow({
    required this.completedState,
    required this.stateStream
  });

  @override
  State<StatefulWidget> createState() => _CalibrationStatusRowState();
}

class _CalibrationStatusRowState extends State<CalibrationStatusRow> {

  Status status = Status.UNKNOWN;
  final logger = Logger();

  @override
  initState() {
    super.initState();
    widget.stateStream.listen((state) {
      setState(() {
        if (state == 0)
          status = Status.NOT_CALIBRATED;
        else if (state < widget.completedState)
          status = Status.CALIBRATING;
        else if (state == widget.completedState)
          status = Status.CALIBRATED;
        else
          status = Status.UNKNOWN;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
    Center( child:
      Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: _statusText(context)
    ),
    )]);
  }

  Widget _statusText(BuildContext context) {
    logger.d("DISPLAY STATUS = ${status.name}");
   if(status == Status.NOT_CALIBRATED)
      return Text("Not calibrated", style: Theme
          .of(context)
          .textTheme
          .titleMedium!
          .copyWith(color: Colors.red));
    else if(status == Status.CALIBRATING)
      return Text("Calibrating", style: Theme
          .of(context)
          .textTheme
          .titleMedium!
          .copyWith(color: Colors.orange));
     else if(status == Status.CALIBRATED)
      return Text("Calibrated", style: Theme
          .of(context)
          .textTheme
          .titleMedium!
          .copyWith(color: Colors.green));
     else
      return Text("", style: Theme
        .of(context)
        .textTheme
        .titleMedium);
  }
}





