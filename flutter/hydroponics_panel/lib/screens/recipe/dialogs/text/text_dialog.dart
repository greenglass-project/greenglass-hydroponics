import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class TextDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  const TextDialog(this.title, this.initialValue, {super.key});

  @override
  State<StatefulWidget> createState() => _TextDialogState();
}

class _TextDialogState extends State<TextDialog> {
  final formKey = GlobalKey<FormBuilderState>();

  String? phaseName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        //width: double.infinity,
        height: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 400,
                  height: 210,
                  child: Card(
                      elevation: 0,
                      color: Colors.black,
                      margin: const EdgeInsetsDirectional.only(
                          start: 20.0, end: 20.0),
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white)
                      ),
                      child: FormBuilder(
                          key: formKey,
                          child: Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.center,
                              children : [
                                Padding(
                                  padding:const  EdgeInsets.fromLTRB(0, 20, 0, 20),
                                    child:Text(widget.title,
                                    style: Theme.of(context).textTheme.titleSmall
                                ))

                              ]),
                          Row(children: [
                            Expanded(flex: 1, child: Container()),
                            Expanded(
                                flex: 4,
                                child: FormBuilderTextField(
                                  autofocus: true,
                                  name: 'phasename',
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                  initialValue: widget.initialValue,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(
                                        errorText:
                                            "Please enter the phase name")
                                  ]),
                                  onSaved: (v) => phaseName = v,
                                )),
                            Expanded(flex: 1, child: Container()),
                          ]),
                             Row(mainAxisAlignment: MainAxisAlignment.end,
                                children : [
                                  InkWell(
                                    child: const Padding(
                                      padding:EdgeInsets.fromLTRB(0, 20, 80, 20),
                                      child: Icon(
                                          Icons.done,
                                          color : Colors.green,
                                        size : 32
                                      )
                                    ),
                                      onTap: () {
                                        if (formKey.currentState != null &&
                                            formKey.currentState!
                                                .saveAndValidate() == true) {
                                          Get.back(result: phaseName);
                                        }
                                      })
                                  ]),
                          ]))))
            ]));
  }
}
