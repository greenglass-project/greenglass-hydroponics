import 'package:flutter/material.dart';

class TextRow extends StatelessWidget {
  final String text;

  TextRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Row( children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      ),
      Spacer(),
    ]);
  }
}