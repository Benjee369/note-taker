import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes/shared/widgets/text_widget.dart';
import 'package:notes/shared/constants/app_sizes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notes/app/provider_layer.dart';

class SetupWizardScreen extends StatelessWidget {
  const SetupWizardScreen({super.key});

  Future<void> _selectFolder(BuildContext context) async {
    final selectedDirectory = await FilePicker.getDirectoryPath();
    if (selectedDirectory == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hive_directory', selectedDirectory);

    if (!context.mounted) return;
    Hive.init(selectedDirectory);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ProviderLayer()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextWidget(
              text: 'Welcome to NoteTaker',
              size: 24,
              fontWeight: FontWeight.bold,
            ),
            gapH12,
            const Text(
              'Choose where you want your note database to be saved.',
            ),
            gapH24,
            ElevatedButton(
              onPressed: () => _selectFolder(context),
              child: const Text('Choose Storage Location'),
            ),
          ],
        ),
      ),
    );
  }
}
