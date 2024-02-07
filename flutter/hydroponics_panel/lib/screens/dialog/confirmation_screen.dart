import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:industrial_theme/components/large_text_button.dart';


class ConfirmationDialog extends StatelessWidget {
  //final String text;

  ConfirmationDialog({super.key});

  final text = Get.arguments as String;

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(name: "Confirm", body: _ConfirmationDialogBody(text));
  }
}
class _ConfirmationDialogBody extends StatelessWidget {
  final String text;

  const _ConfirmationDialogBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Row( children : [
      Expanded(
        flex : 1,
          child : Column( children : [ Container()])
      ),
      Expanded(
        flex : 3,
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children : [
            Expanded( child:
              Padding(
                padding:const  EdgeInsetsDirectional.symmetric(vertical: 230),
                child : Column( children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children : [
                      Expanded(
                          child: Text(
                            text,
                            maxLines: 4,
                            style : Theme.of(context).textTheme.titleMedium))]),
                  Expanded(child: Row( children : [ Container()])
                  ),
                  Row( crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children : [
                    LargeTextButton(
                        label : "Cancel",
                        action : () => Get.back(),
                        width : 200,
                        height : 100,
                        colour : Colors.red
                    ),
                      Spacer(),
                      LargeTextButton(
                          label : "OK",
                          action : () => {},
                          width : 200,
                          height : 100,
                          colour : Colors.green
                  ),
                ])
              ])))
        ])
    ),
    Expanded(
      flex : 1,
      child : Column( children : [ Container()])
    )
    ]);
  }
}