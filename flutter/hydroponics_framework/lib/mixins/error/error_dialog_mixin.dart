import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin ErrorDialogMixin {
  void displayError(BuildContext context, String code, String msg) {
    Get.dialog(_error(context, code, msg));
  }

  Widget _error(BuildContext context, String code, String msg) {
    return SizedBox(
        //width: double.infinity,
        height: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 500,
                  height: 200,
                  child: Card(
                      elevation: 0,
                      color: Colors.black,
                      margin: const EdgeInsetsDirectional.only(
                          start: 30.0, end: 30.0),
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white)),
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: Column(children: [
                            Expanded(
                                flex: 1,
                                child: Text("ERROR",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                        .copyWith(color: Colors.red))),
                            Expanded(
                                flex: 1,
                                child: Text(code,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                )),
                            Expanded(flex: 1, child:Text(msg,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    ))
                          ]))))
            ]));
  }
}
