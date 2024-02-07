import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class DescriptionDialog extends StatefulWidget {
  const DescriptionDialog({super.key});

  @override
  State<StatefulWidget> createState() => _DescriptionDialogState();
}

class _DescriptionDialogState extends State<DescriptionDialog> {

  final formKey = GlobalKey<FormBuilderState>();

  String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: 800,
              height: 400,
              child: Card(
                  elevation: 0,
                  color: Colors.black,
                  margin:
                  const EdgeInsetsDirectional.only(start: 30.0, end: 30.0),
                  shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white)),
                  child: FormBuilder(
                      key: formKey,
                      child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 30, 70),
                              child: Text(
                                  "Description ", //widget.recipe.description,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .labelMedium),
                            ),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    30, 10, 30, 10),
                                child: FormBuilderTextField(
                                    autofocus: true,
                                    name: 'description',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(
                                          errorText: "Please enter a description"),
                                      FormBuilderValidators.minLength(4,
                                          errorText: "description must be at least 4 chars")
                                    ]),
                                    onSaved: (v) => description = v)
                            ),
                            const Spacer(),
                            Row(children: [
                              InkWell(
                                  onTap: () => Get.back(result: null),
                                  child: const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Icon(Icons.clear,
                                        color: Colors.red, size: 48),
                                  )),
                              const Spacer(),
                              InkWell(
                                  onTap: () => validate(),
                                  //=> validateAndCreate(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Icon(Icons.done,
                                        color: Colors.green, size: 48),
                                  )),
                            ]),
                          ]))))
        ]);
  }

  void validate() {
    if (formKey.currentState != null &&
        formKey.currentState!.saveAndValidate() == true) {
      Get.back(result: description!);
    }
  }
}
