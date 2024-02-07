import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/manual_phase_model.dart';
import 'package:uuid/uuid.dart';

import 'manual_phase_mixin.dart';

class ManualPhaseEditDialog extends StatefulWidget {
  final ManualPhaseModel? phaseModel;

  const ManualPhaseEditDialog({this.phaseModel, super.key});

  @override
  State<StatefulWidget> createState() => _ManualPhaseEditDialogState();
}

class _ManualPhaseEditDialogState extends State<ManualPhaseEditDialog> with ManualPhaseMixin {
  //final formKey = GlobalKey<FormBuilderState>();
  //String? name;
  //int? duration;

  @override
  void initState() {
    phaseModel = widget.phaseModel;
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      //width: double.infinity,
        height: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 500,
                  height: 800,
                  child: Card(
                      elevation: 0,
                      color: Colors.black,
                      margin: const EdgeInsetsDirectional.only(
                          start: 20.0, end: 20.0),
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white)),
                      child: FormBuilder(
                          key: formKey,
                          child: Column(children: [
                            header("Manual phase", context),
                            Row(children: [
                              Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(30, 30, 30, 30),
                                  child: Text("Name",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall))
                            ]),
                            Row(children: [
                              //Expanded(flex: 1, child: Container()),
                              Expanded( child: Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(30, 0, 30, 30),
                                  child:FormBuilderTextField(
                                      autofocus: true,
                                      name: 'name',
                                      initialValue: phaseModel != null ? phaseModel!.name : null,
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(
                                            errorText: "Please enter a name"),
                                        FormBuilderValidators.minLength(4,
                                            errorText:
                                            "name must be at least 4 chars")
                                      ]),
                                      onSaved: (v) => name = v ?? ""))
                              )]),
                            Row(children: [
                              Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(30, 0, 30, 30),
                                  child: Text("Description",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall))
                            ]),
                            Row(children: [
                              //Expanded(flex: 1, child: Container()),
                              Expanded( child: Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(30, 0, 30, 30),
                                  child:FormBuilderTextField(
                                      autofocus: true,
                                      name: 'description',
                                      minLines: 3, // Set this
                                      maxLines: 6, // and this
                                      keyboardType: TextInputType.multiline,
                                      initialValue: phaseModel != null ? phaseModel!.description : null,
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(
                                            errorText: "Please enter a description"),
                                        FormBuilderValidators.minLength(10,
                                            errorText:
                                            "description must be at least 10 chars")
                                      ]),
                                      onSaved: (v) => description = v ?? ""))
                              )]),
                            Row(children: [
                              Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(30, 0, 30, 30),
                                  child: Text("Max Duration (days)",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall))
                            ]),
                            Row(children: [
                              //Expanded(flex: 1, child: Container()),
                              Expanded( child: Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(30, 0, 30, 30),
                                  child:FormBuilderTextField(
                                      keyboardType: TextInputType.number,
                                      autofocus: true,
                                      name: 'duration',
                                      initialValue: phaseModel != null ? "${phaseModel!.duration}" : 1.toString(),
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(RegExp(r'[1-9]')),
                                        LengthLimitingTextInputFormatter(1),
                                      ],
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(
                                            errorText: "Please enter a duration"),
                                        FormBuilderValidators.numeric(
                                            errorText: "Enter a number between 1 and 5"),
                                        FormBuilderValidators.maxLength(1,
                                            errorText: "Enter a number between 1 and 5"),
                                      ]),
                                      onSaved: (v) => duration = v != null ? int.parse(v) :0))
                              )]),
                            const Spacer(),
                            Row(children: [
                              InkWell(
                                  onTap: () => Get.back(result: false),
                                  child: const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Icon(Icons.clear,
                                        color: Colors.red, size: 48),
                                  )),
                              const Spacer(),
                              InkWell(
                                  onTap: () => validateAndCreate(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Icon(Icons.done,
                                        color: Colors.green, size: 48),
                                  )),
                            ]),
                          ])))
              )
            ]));
  }

  @override
  void validateAndCreate() {
    if (formKey.currentState != null &&
        formKey.currentState!.saveAndValidate() == true) {

      ManualPhaseModel phase;
      if(phaseModel == null) {
        phase = ManualPhaseModel(
            phaseId: const Uuid().v4(),
            name: name!,
            description: description!,
            duration: duration!
        );
      } else {
        phase = ManualPhaseModel(
            phaseId:phaseModel!.phaseId ,
            name: name!,
            description: description!,
            duration: duration!
        );
      }
      Get.back(result: phase);
    }
  }
}