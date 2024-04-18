import 'package:flutter/material.dart';

class DriversRegistry {
  Map<String, Widget Function(String)> drivers = {};

  void register(String name, Widget Function(String) build) {
    drivers[name] = build;
  }

  Widget Function(String) build(String name) => drivers[name]!;
}