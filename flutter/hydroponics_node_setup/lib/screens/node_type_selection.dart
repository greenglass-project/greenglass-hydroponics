import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../webservice/web_service.dart';

class NodeSelectionScreen extends StatefulWidget {

  final WebService webService;

  NodeSelectionScreen(this.webService);

  @override
  State<StatefulWidget> createState() => _NodeSelectionScreenState();
}

class _NodeSelectionScreenState extends State<NodeSelectionScreen> {
  final formKey = GlobalKey<FormBuilderState>();

  List<String> nodeTypes = [];

  void _getNodeTypes() async {
    widget.webService.get("/nodetypes").then((resp) {
      if (resp != 0) {
        setState(() { nodeTypes = List<String>.from(jsonDecode(resp!)); });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          //color: Theme.of(context).colorScheme.primary,
            child: FormBuilder(
                key: formKey,
                child: Row(children: [
                  Spacer(),
                  Column(children: [
                    Spacer(),
                    SizedBox(
                        width: 250,
                        child: FormBuilderDropdown<String>(
                          //initialValue: settings!.nodeType,
                          name: 'nodetype',
                          decoration: const InputDecoration(
                              labelText: 'Node-Type',
                              border: OutlineInputBorder()),
                          onSaved: (v) => {}, //settings!.nodeType = v!,
                          items: nodeTypes
                              .map(
                                (nt) => DropdownMenuItem(
                                alignment: AlignmentDirectional.centerStart,
                                value: nt,
                                child: Text(nt)),
                          )
                              .toList(),
                        ),
                    ),
                    SizedBox(height: 50),
                    OutlinedButton(
                      //style: style,
                        onPressed: () {},
                        child: const Text('Set')
                    ),
                    Spacer()
                  ]),
                  Spacer()
                ]))));
  }
}
