import 'package:flutter/material.dart';

class IndustrialTheme {
  ThemeData theme() {
    return ThemeData(
      primarySwatch: Colors.lightGreen,
      textTheme: const TextTheme(
        displayLarge:
        TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(
            fontSize: 48.0,
            color: Colors.white,
            fontWeight: FontWeight.w200,
            fontFamily: "Roboto"),
        titleMedium: TextStyle(
            fontSize: 32.0,
            color: Colors.white,
            fontWeight: FontWeight.w200,
            fontFamily: "Roboto"),
        titleSmall: TextStyle(
            fontSize: 24.0,
            color: Colors.white,
            fontWeight: FontWeight.w200,
            fontFamily: "Roboto"),
        bodyMedium: TextStyle(
            fontSize: 32.0,
            color: Colors.white60,
            fontWeight: FontWeight.w200,
            fontFamily: "Rokkitt"),
        bodySmall: TextStyle(
            fontSize: 24.0,
            color: Colors.white60,
            fontWeight: FontWeight.w200,
            fontFamily: "Rokkitt"),
        labelSmall: TextStyle(
            fontSize: 24.0,
            color: Colors.white,
            fontWeight: FontWeight.w200,
            fontFamily: "Roboto"),
        labelLarge: TextStyle(
            fontSize: 48.0,
            color: Colors.white,
            fontWeight: FontWeight.w200,
            fontFamily: "Roboto"),
        labelMedium: TextStyle(
            fontSize: 32.0,
            color: Colors.white,
            fontWeight: FontWeight.w200,
            fontFamily: "Roboto"),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        errorStyle: TextStyle(
          fontSize: 32.0,
          fontFamily: "Roboto",
          color: Colors.red,
          fontWeight: FontWeight.w200,
        ),
        errorMaxLines: 4,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 25,
          horizontal: 25,
        ),
        labelStyle: TextStyle(
          fontSize: 36,
          decorationColor: Colors.red,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 36,
          decorationColor: Colors.white,
        ),
        hintStyle: TextStyle(
          fontSize: 36,
          decorationColor: Colors.red,
        ),
      ),
    );
  }


}