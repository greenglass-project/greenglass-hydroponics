import 'package:flutter/material.dart';

class GridCardMenu extends StatelessWidget {
  final List<Widget> menuCards;

  const GridCardMenu({required this.menuCards, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.stretch,
        children : [
          Expanded( child:
          GridView.count(
            primary: false,
            padding: const EdgeInsets.all(50),
            crossAxisSpacing: 0,
            mainAxisSpacing: 40,
            crossAxisCount: 4,
            childAspectRatio: 1 / 0.85,
            children: menuCards
            ))
        ]
    );
  }
}