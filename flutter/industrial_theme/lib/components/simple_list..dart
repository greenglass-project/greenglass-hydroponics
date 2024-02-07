import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ListEntry {
  final String title;
  final String? subTitle;
  final dynamic selectionValue;

  ListEntry(this.title, this.subTitle, this.selectionValue);
}

class SimpleListScreen extends StatelessWidget {
  final List<ListEntry> entries;
  final String detailsScreen;
  final Color borderColour;
  final logger = Logger();

  SimpleListScreen({
    required this.entries,
    required this.detailsScreen,
    this.borderColour=Colors.lightBlue,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(100, 100, 100, 100),
        child: ListView(children: _createlist(context)),
      ))
    ]);
  }

  List<Widget> _createlist(BuildContext context) {
    List<Widget> list = [];
    for (ListEntry entry in entries) {
      list.add(Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 10.0),
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: borderColour,
                    width: 1.0,
                    style: BorderStyle.solid),
              ),
              child: InkWell(
                  onTap: () => _showDetail(entry),
                  child: _tile(entry, context))
    )));
    }
    return list;
  }

  ListTile _tile(ListEntry entry, BuildContext context) {
    if(entry.subTitle != null) {
      return ListTile(
          title: Text(entry.title,
              style: Theme.of(context).textTheme.labelMedium),
          subtitle: Text(entry.subTitle!!,
              style: Theme.of(context).textTheme.bodySmall),
          minVerticalPadding: 15.0
      );

    } else {
      return ListTile(
        title: Text(entry.title,
          style: Theme.of(context).textTheme.labelMedium
        ),
        minVerticalPadding: 15.0
      );
    }
  }

  _showDetail(ListEntry entry) {
    logger.d("Show detail $detailsScreen, ${entry.selectionValue}");
    Get.toNamed(detailsScreen, arguments: entry.selectionValue);
  }
}
