import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_panel/screens/recipe/dialogs/dialog_mixin.dart';

class NumericInput extends StatefulWidget {
  final double? value;
  final double maxValue;
  final double minValue;
  final String units;
  final int decimalPlaces;

  const NumericInput({
    this.value,
    required this.minValue,
    required this.maxValue,
    required this.units,
    required this.decimalPlaces,
    super.key
  });

  @override
  State<NumericInput> createState() => _NumericInputState();
}

class _NumericInputState extends State<NumericInput> with DialogMixin {
  List<int> optionsList = [];
  var logger = Logger();

  String displayValue = "";
  String errorText = "";

  @override
  void initState() {
    displayValue = widget.value.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: double.infinity,
      height: double.infinity,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 400,
                height: 700,
                child: Card(
                    elevation: 0,
                    color: Colors.black,
                    margin: const EdgeInsetsDirectional.only(
                        start: 20.0, end: 20.0),
                    //shape: const RoundedRectangleBorder(
                    //    side: BorderSide(color: Colors.white)
                    //),
                    child: Column( children : [//Expanded( child:
                      _inputField(displayValue),
                      _errorField(),
                      Flexible(child:GridView.count(
                        primary: false,
                        padding: const EdgeInsets.all(0),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 3,
                        childAspectRatio: 1 / 1,
                        children: [
                          _numericKey(1),
                          _numericKey(2),
                          _numericKey(3),
                          _numericKey(4),
                          _numericKey(5),
                          _numericKey(6),
                          _numericKey(7),
                          _numericKey(8),
                          _numericKey(9),
                          _decimalPointKey(),
                          _numericKey(0),
                          _deleteKey()
                        ],
                          )
                    )]),))
    ]));
  }

  Widget _numericKey(int number) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.orangeAccent,
              width: 1.0,
              style: BorderStyle.solid),
        ),
        child: InkWell(
            onTap: () => setState(() => _addCharacter(number.toString())), // Get.back(result: number),
            child: Center(
              child: Text(number.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall),
            )));
  }

  Widget _decimalPointKey() {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.orangeAccent,
              width: 1.0,
              style: BorderStyle.solid),
        ),
        child: InkWell(
            onTap: () {
              if(widget.decimalPlaces > 0) {
                setState(() => _addCharacter("."));
              }
            },
            child: Center(
              child: Text(".",
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall),
            )));
  }

  Widget _deleteKey() {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.orangeAccent,
              width: 1.0,
              style: BorderStyle.solid),
        ),
        child: InkWell(
            onTap: () => setState(() => _removeCharacter()),
            child: const Center(
              child: Icon(Icons.backspace, color: Colors.white60)
            )));
  }

  Widget _inputField(String value) {
    return Row(children : [
      Expanded( flex: 2,
          child: Padding( padding : const EdgeInsets.only(right: 5),
              child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.orangeAccent,
                  width: 1.0,
                  style: BorderStyle.solid
              ),
            ),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                child: Text(value, style : textStyle(context))
            )
          )
      )),
      Expanded( flex: 1,
        child: Padding( padding : const EdgeInsets.only(left: 5),
      child:Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orangeAccent,
                width: 0.5,
                style: BorderStyle.solid),
              ),
            child: InkWell(
              onTap: () => _validateAndSave(),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 35, 20, 30),
                child:Center(child : Icon(Icons.done, color: Colors.green,)))
        )
       )))
    ]);
  }

  Widget _errorField() {
    return Row( children : [
      Expanded( child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Text(errorText, style : errorTextStyle(context))
          )
      )]);
  }
    bool _addCharacter(String char) {
      String newValue = displayValue+char;
      if(newValue.isNum) {
        List<String> parts = newValue.split(".");
        if(parts.length == 2) {
          if(parts[1].length <= widget.decimalPlaces) {
            errorText = "";
            displayValue = newValue;
          }
        } else {
          errorText = "";
          displayValue = newValue;
        }
      }
      return true;
    }
    bool _removeCharacter() {
      if (displayValue.isNotEmpty) {
        String newValue = displayValue.substring(0, displayValue.length - 1);
        if(newValue.isNotEmpty) {
          if (newValue.isNum) {
            errorText = "";
            displayValue = newValue;
          }
        } else {
          errorText = "";
          displayValue = newValue;
        }
      }
      return true;
    }

    _validateAndSave() {
        final value = double.parse(displayValue);
        if(value > widget.maxValue) {
          setState(() => errorText = "Maximum value is ${widget.maxValue}");
        } else if(value < widget.minValue) {
          setState(() => errorText = "Minimum value is ${widget.minValue}");
        } else {
          Get.back(result: value);
        }
    }
}
