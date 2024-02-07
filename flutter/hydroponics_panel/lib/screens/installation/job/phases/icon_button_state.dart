import 'package:flutter/material.dart';

class IconButtonState extends StatelessWidget {
  final IconData icon;
  final Color iconColour;
  final double iconSize;
  final double outerSize;
  final bool state;
  final Function() onTap;
  final Color activeColour;
  final Color inactiveColour;

  const IconButtonState({
    required this.icon,
    this.iconColour = Colors.white,
    this.iconSize = 48.0,
    this.outerSize = 80.0,
    required this.state,
    required this.onTap,
    this.activeColour = Colors.white,
    this.inactiveColour = Colors.white38,
    super.key
  });

  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: SizedBox(width: outerSize, height: outerSize,
            child: state ?
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: activeColour,
                      width: 1.0,
                      style: BorderStyle.solid),
                ),
                child: InkWell(
                    onTap: () => onTap(),
                    child: Icon(icon, size: iconSize, color: iconColour)
                )
            ) :
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: inactiveColour,
                      width: 1.0,
                      style: BorderStyle.solid),
                ),
                child: Icon(icon, size: iconSize, color: Colors.white38,)

            )
        ));
  }
}