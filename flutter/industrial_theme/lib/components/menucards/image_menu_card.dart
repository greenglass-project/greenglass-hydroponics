import 'package:flutter/material.dart';

class ImageMenuCard extends StatelessWidget {
  final Color borderColour;

  final Image image;
  final String label;
  final Function() onTap;

  const ImageMenuCard({
    required this.image,
    required this.label,
    required this.onTap,
    this.borderColour = Colors.greenAccent,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
        shape: RoundedRectangleBorder(side: BorderSide(color: borderColour)),
        child: InkWell(
            onTap: onTap,
            child: Column(children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      color: Colors.transparent,
                      child: Center(
                          child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: image)))),
              Expanded(
                  flex: 1,
                  child: Center(
                      child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall,
                  )))
            ])));
  }
}
