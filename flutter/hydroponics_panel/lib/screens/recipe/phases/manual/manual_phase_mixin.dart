import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/manual_phase_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/phase_model.dart';
import 'package:hydroponics_panel/screens/recipe/phases/phase_list_provider.dart';

mixin ManualPhaseMixin <T extends StatefulWidget> on State<T>  {
  final formKey = GlobalKey<FormBuilderState>();
  String? name;
  String? description;
  int? duration;
  late PhaseListProvider phases;
  ManualPhaseModel? phaseModel;

  PhaseModel? model;
  void validateAndCreate();

  Widget header(String text, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Center(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Text(text,
                    style: Theme.of(context).textTheme.labelMedium))));
  }
}