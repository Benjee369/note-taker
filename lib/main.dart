import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notes/shared/providers/platform_provider.dart';
import 'package:notes/app/provider_layer.dart';
import 'package:notes/app/setup_wizard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

const _hiveDirKey = 'hive_directory';
const _hiveSubDir = 'NoteTakerBoxes';

Future<String> _resolveHiveDirectory(SharedPreferences prefs) async {
  final saved = prefs.getString(_hiveDirKey);
  if (saved != null) return saved;

  if (isDesktop) {
    return '';
  }

  final dir = await getApplicationSupportDirectory();
  return '${dir.path}/$_hiveSubDir';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final hiveDir = await _resolveHiveDirectory(prefs);

  if (hiveDir.isEmpty) {
    runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SetupWizardScreen(),
      ),
    );
  } else {
    Hive.init(hiveDir);
    runApp(
      const ProviderLayer(),
    );
  }
}
