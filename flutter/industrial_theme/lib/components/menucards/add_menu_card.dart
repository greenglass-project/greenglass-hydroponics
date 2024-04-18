import 'package:flutter/material.dart';

class AddMenuCard extends StatelessWidget {
  final String label;
  final Color borderColour;
  final Function() onTap;

  const AddMenuCard(
      {required this.label,
      required this.onTap,
      this.borderColour = Colors.greenAccent,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
        shape: RoundedRectangleBorder(side: BorderSide(color: borderColour)),
        child: InkWell(onTap: onTap, child: _body(context)));
  }

  Widget _body(BuildContext context) {
    return Column(children: [
      const Expanded(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: Center(
                  child: Icon(
                Icons.add_sharp,
                size: 48,
                color: Colors.white54,
              )))),
      Row(children: [
        Expanded(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(50, 0, 50, 50),
                child: Text(
                  label,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodySmall,
                )))
      ])
    ]);
  }
}
