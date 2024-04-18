import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/mixins/implementation/implementations_list_mixin.dart';
import 'package:hydroponics_framework/mixins/error/error_dialog_mixin.dart';

import 'package:logger/logger.dart';

import 'package:hydroponics_framework/datamodels/implementation/implementation_model.dart';
import 'package:hydroponics_framework/datamodels/installation/physical_node_model.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_model.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';

import 'package:uuid/uuid.dart';

class AddInstallationDialog extends StatefulWidget {

  const AddInstallationDialog({super.key});

  @override
  State<StatefulWidget> createState() => _AddInstallationDialogState();
}

class _AddInstallationDialogState extends State<AddInstallationDialog> with ImplementationsListMixin, ErrorDialogMixin {
  final formKey = GlobalKey<FormBuilderState>();
  final ms = MicroserviceService.ms;
  var logger = Logger();

  Map<String, String> nodeIds = {};
  String name = "";

  late final ImplementationModel implementation;

  bool selectImpl = true;
 // @override
 // void initState() {
 //   super.initState();
 //   for(var node in implementation.nodes) {
 //     nodeIds[node.type] = "";
  //  }
  //}

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
                  width: 1000,
                  height: 800,
                  child: Card(
                      elevation: 0,
                      color: Colors.black,
                      margin: const EdgeInsetsDirectional.only(
                          start: 20.0, end: 20.0),
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white)),
                      child: selectImpl? _implementationsList() : _installationDetails()//_installationDetails()
                  )
              )
            ]));
  }

  Widget _implementationsList() {
    return Column(children: [
      Row(children: [
        Padding(
          padding:const EdgeInsets.fromLTRB(30, 30, 30, 30),
          child: Text("Implementation Type", style: Theme.of(context)
            .textTheme
            .labelMedium)
          ),
    ]),
    Expanded( child:
      ListView(children: _createlist(context))
    ),
                 Row(children: [
        InkWell(
            onTap: () => Get.back(result: false),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Icon(Icons.clear,
                  color: Colors.red, size: 48),
            )),
        const Spacer(),
      ]),
    ]);
  }

    List<Widget> _createlist(context) {
      List<Widget> list = [];
      for (ImplementationModel i in implementations.values) {
        list.add(Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 10.0, horizontal: 50),
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.greenAccent,
                      width: 1.0,
                      style: BorderStyle.solid),
                ),
                child: InkWell(
                    onTap: () {
                      implementation = i;
                      for(var node in implementation.nodes) {
                        nodeIds[node.implNodeId] = "";
                      }
                      setState(() => selectImpl = false);
                    }, //Get.dialog(AddInstallationDialog(implementation)),
                    child: ListTile(
                        title: Text(i.name,
                            style: Theme.of(context).textTheme.labelMedium),
                        //subtitle: Text(i.systemName,
                        //    style: Theme.of(context).textTheme.bodySmall),
                        minVerticalPadding: 15.0
                    )
                ))));
      }
      return list;
    }

    Widget _installationDetails() {
      return FormBuilder(
          key: formKey,
          child: Column(children: [
            Row(children: [
              Padding(
                  padding:
                  const EdgeInsets.fromLTRB(30, 30, 30, 30),
                  child: Text("Name",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium))
            ]),
            Row(children: [
              Expanded(flex: 1, child: Container()),
              Expanded(
                flex: 4,
                child: FormBuilderTextField(
                    autofocus: true,
                    name: 'name',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: "Please enter a name"),
                      FormBuilderValidators.minLength(4,
                          errorText: "name must be at least 4 chars")
                    ]),
                    //onChanged: (v) => url = v,
                    onSaved: (v) => name = v!),
              ),
              Expanded(flex: 1, child: Container()),
            ]),
            Row(children: [
              Padding(
                  padding:
                  const EdgeInsets.fromLTRB(30, 30, 30, 0),
                  child: Text("Node-ids",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium))
            ]),
            Expanded(
                child: Row(children: [
                  //Expanded(flex: 1, child: Container()),
                  Expanded(
                      flex: 4,
                      child: ListView(children: _nodeList(context))),
                 // Expanded(flex: 1, child: Container()),
                ])),
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
                  onTap: () => _validateAndCreate(),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Icon(Icons.done,
                        color: Colors.green, size: 48),
                  )),
            ]),
          ]));
    }

    List<Widget> _nodeList(BuildContext context) {
      List<Widget> list = [];
      for (var node in implementation.nodes) {
        list.add(Row(children: [
          Expanded( flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(50, 10, 20, 10),
              child:
              Text(node.description.replaceAll("_", " "), style: Theme.of(context).textTheme.labelSmall)
            )
          ),
          Expanded( flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 50, 10),
              child: FormBuilderTextField(
              autofocus: true,
              name: 'nodeId',
              style: const TextStyle(fontSize: 20, color: Colors.white),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                    errorText: "Please enter a node-id"),
                FormBuilderValidators.minLength(10,
                    errorText: "node-id must be at least 10 chars")
              ]),
              onChanged: (v) => nodeIds[node.implNodeId] = v!.trim(),
              onSaved: (v) => {}),
        ))]));
      }
      return list;
    }

    void _validateAndCreate() {
      if (formKey.currentState != null &&
          formKey.currentState!.saveAndValidate() == true) {

        var installation = InstallationModel(
            installationId : Uuid().v4(),
            implementationId : implementation.implementationId,
            name : name,
            description : "",
            physicalNodes : implementation.nodes.map((n) =>
                PhysicalNodeModel(nodeIds[n.implNodeId]!, n.implNodeId))
                .toList()
        );

        const topic = "add.installations";
        ms.request(topic, installation,
                (_) {
                  logger.d(" Received SUCCESS" );
                  Get.back();
                },
                (c,m) {
                  logger.d(" Received ERROR");
                  displayError(context, c, m);
                }
        );
      }
    }
}

