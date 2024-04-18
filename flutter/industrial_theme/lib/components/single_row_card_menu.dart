import 'package:flutter/material.dart';

class SingleRowCardMenu extends StatelessWidget {
  final List<Widget> menuCards;

  const SingleRowCardMenu({required this.menuCards, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.stretch,
        children : [
          Expanded(
              flex : 3,
              child:
              Container(
                  width: double.infinity,
                  color : Colors.transparent
              )
          ),
          Expanded(
              flex:4,
              child:
              Container(
                  width: double.infinity,
                  color : Colors.transparent,
                  child : _createMenu()
              )),
          Expanded(
              flex : 3,
              child:
              Container(
                  width: double.infinity,
                  color : Colors.transparent
              )
          ),
        ]
    );
  }

  Widget _createMenu() {
    List<Widget> row = [];
    for(Widget card in menuCards) {
      row.add(AspectRatio(
          aspectRatio: 1 / 1,
          child: card
        )
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: row,);
  }
}