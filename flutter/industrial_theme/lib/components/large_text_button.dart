import 'package:flutter/material.dart';

class LargeTextButton extends StatelessWidget {
  final String label;
  final Function action;
  final double width;
  final double height;
  final Color colour;

  const LargeTextButton({
    required this.label,
    required this.action,
    required this.colour,
    super.key,
    this.width = 100.0,
    this.height = 100.0
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => action(),
        child: SizedBox(
          width: width,
          height: height,
          child: Container(
            alignment: AlignmentDirectional.center,
            child : Text(label, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colour) ,
          textAlign: TextAlign.center,)
        ))
    );
  }
}