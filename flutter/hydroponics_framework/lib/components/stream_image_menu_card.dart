import 'package:flutter/material.dart';
import 'package:hydroponics_framework/components/stream_image.dart';

class StreamImageMenuCard extends StatelessWidget {
  final Color borderColour;
  final double margin;

  final String imageTopic;
  final String label;
  final Function() onTap;

  const StreamImageMenuCard({
    required this.imageTopic,
    required this.label,
    required this.onTap,
    this.borderColour = Colors.greenAccent,
    this.margin = 20.0,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin: EdgeInsetsDirectional.only(start: margin, end: margin),
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
                              padding: const EdgeInsets.fromLTRB(15, 20, 15,15),
                              child: StreamImage(
                                topic: imageTopic
                              )
                          )
                      )
                  )
              ),
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
