import 'package:flutter/cupertino.dart';

class SettingsTabModel {
  final String title;
  final IconData icon;
  final Widget page;

  SettingsTabModel({
    required this.title,
    required this.icon,
    required this.page,
  });
}
