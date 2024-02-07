import 'package:flutter/material.dart';

class TextMenuCard extends StatelessWidget {
  final String label;
  final String? description;
  final Color borderColour;
  final Function() onTap;

  const TextMenuCard(
      {required this.label,
      required this.onTap,
      this.description,
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
    if (description == null) {
      return Column(children: [
        Expanded(
            flex: 1,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Center(
                    child: Text(
                  label,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium,
                ))))
      ]);
    } else {
      return Column(children: [
        Expanded(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Center(
                    child: Text(
                  label,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium,
                )))),
          Row( children: [
            Expanded( child:
            Padding(
            padding : const EdgeInsets.fromLTRB(50, 0, 50, 50),
            child: Text(
              description!,
              maxLines: 4,
              textAlign: TextAlign.center,
              softWrap: true,
              style: Theme.of(context).textTheme.bodySmall,
            )
            )
          )
        ])
      ]);
    }
  }
}
