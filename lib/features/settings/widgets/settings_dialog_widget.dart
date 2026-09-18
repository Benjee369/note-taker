import 'package:flutter/material.dart';
import 'package:notes/features/settings/screens/settings_screen.dart';

Future<dynamic> settingsDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: SettingsScreen(),
      );
    },
  );
}
