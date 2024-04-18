import 'dart:async';

import 'package:hydroponics_framework/datamodels/recipes/phase/phase_model.dart';

class PhaseListProvider {

  List<PhaseModel> phases = [];
  int selected = -1;
  int size() => phases.length;

  StreamController<PhaseModel?> modelController = StreamController.broadcast();
  Stream<PhaseModel?> modelStream() => modelController.stream;

  StreamController<bool> changeController = StreamController.broadcast();
  Stream<bool> changeStream() => changeController.stream;

  PhaseModel modelAt(int index) => phases[index];
  void updateModelAtIndex(int index, PhaseModel model) => phases[index] = model;
  void load(List<PhaseModel> phases) {
    this.phases = phases;
    if(phases.isNotEmpty) {
      modelController.add(phases[0]);
    }
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final PhaseModel item = phases.removeAt(oldIndex);
    phases.insert(newIndex, item);
    changeController.add(true);
  }

  void addModel(PhaseModel model) {
    phases.add(model);
    modelController.add(model);
    changeController.add(true);
  }

  void updateModel(PhaseModel model) {
    var phase = phases.indexed.firstWhere((e) => e.$2.phaseId == model.phaseId);
    phases[phase.$1] = model;
    modelController.add(model);
    changeController.add(true);
  }

  void removeModel(String phaseId) {
    var phase = phases.indexed.firstWhere((e) => e.$2.phaseId == phaseId);
    phases.removeAt(phase.$1);
    modelController.add(null);
    changeController.add(true);
  }

  void select(int index) {
    selected = index;
    if(index >= 0 && index < phases.length) {
      modelController.add(phases[index]);
    } else {
      modelController.add(null);
    }
  }
}
