import 'package:flutter/material.dart';
import 'package:notes/shared/database/folder_database.dart';
import 'package:notes/shared/database/note_preview_database.dart';
import 'package:notes/shared/database/system_settings_database.dart';
import 'package:notes/shared/providers/system_settings_provider.dart';
import 'package:notes/app/app.dart';
import 'package:notes/features/settings/providers/settings_tab_index_provider.dart';
import 'package:provider/provider.dart';
import 'package:notes/shared/database/note_database.dart';
import 'package:notes/shared/database/open_note_database.dart';
import 'package:notes/shared/providers/note_provider.dart';

import '../shared/providers/user_details_provider.dart';

class ProviderLayer extends StatelessWidget {
  const ProviderLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => NoteDatabase()),
        Provider(create: (_) => OpenNoteDatabase()),
        Provider(create: (_) => SystemSettingsDatabase()),
        Provider(create: (_) => FolderDatabase()),
        Provider(create: (_) => PreviewDatabase()),
        ChangeNotifierProvider(
          create: (context) => SettingsTabIndexProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserDetailsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SystemSettingsProvider(
            context.read<SystemSettingsDatabase>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => NoteProvider(
            context.read<NoteDatabase>(),
            context.read<OpenNoteDatabase>(),
            context.read<FolderDatabase>(),
            context.read<PreviewDatabase>(),
          ),
        ),
      ],
      child: App(),
    );
  }
}
