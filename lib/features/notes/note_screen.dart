import 'dart:async';
import 'package:flutter/material.dart';
import 'package:markdown_editor_live/markdown_editor_live.dart';
import 'package:notes/shared/providers/system_settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:notes/shared/providers/platform_provider.dart';
import 'package:notes/shared/widgets/custom_app_bar.dart';
import 'package:notes/shared/constants/strings.dart';
import 'package:notes/shared/models/note_model.dart';
import 'package:notes/shared/providers/note_provider.dart';

class NoteScreen extends StatefulWidget {
  final bool? isNewNote;
  final bool? isDrawerOpen;
  final VoidCallback? toggleDrawer;

  const NoteScreen({
    super.key,
    this.isNewNote = false,
    this.isDrawerOpen = true,
    this.toggleDrawer,
  });

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final _uuid = Uuid().v4();
  Timer? _debouncer;
  String _currentText = '';
  String? _activeNoteUuid;

  Future saveNote() async {
    final isNew = widget.isNewNote == true;
    final now = DateTime.now();
    final noteProvider = context.read<NoteProvider>().noteModel;

    final note = NoteModel(
      uuid: isNew ? _uuid : noteProvider!.uuid,
      content: _currentText,
      createdDate: isNew ? now : noteProvider!.createdDate,
      updatedDate: now,
      isPinned: noteProvider?.isPinned ?? false,
      folderUuid: noteProvider?.folderUuid,
    );
    await context.read<NoteProvider>().saveNote(note);
  }

  void onTypingChange(String text) {
    _currentText = text;
    final isNew = widget.isNewNote == true;
    final now = DateTime.now();
    final noteProvider = context.read<NoteProvider>().noteModel;

    final note = NoteModel(
      uuid: isNew ? _uuid : noteProvider!.uuid,
      content: _currentText,
      createdDate: isNew ? now : noteProvider!.createdDate,
      updatedDate: now,
      isPinned: noteProvider?.isPinned ?? false,
      folderUuid: noteProvider?.folderUuid,
    );
    context.read<NoteProvider>().quickSaveNote(
          note,
          _currentText,
        );

    if (_debouncer?.isActive ?? false) _debouncer?.cancel();
    _debouncer = Timer(const Duration(milliseconds: 1000), () {
      saveNote();
    });
  }

  void closeNote() {
    context.read<NoteProvider>().clearOpenNote();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    final noteProvider = context.read<NoteProvider>();
    _currentText = noteProvider.noteModel?.content ?? '';
    _activeNoteUuid = noteProvider.noteModel?.uuid;

    noteProvider.addListener(_onNoteChanged);
  }

  void _onNoteChanged() {
    final note = context.read<NoteProvider>();
    final model = note.noteModel;
    if (model == null) {
      Scaffold.of(context).closeEndDrawer();
      return;
    }

    if (model.uuid != _activeNoteUuid) {
      _activeNoteUuid = model.uuid;
      _currentText = model.content;
      _debouncer?.cancel();
    }
  }

  @override
  void dispose() {
    _debouncer?.cancel();
    context.read<NoteProvider>().removeListener(_onNoteChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    // final textTheme = Theme.of(context).textTheme;

    return Consumer2<NoteProvider, SystemSettingsProvider>(
      builder: (
        context,
        noteProvider,
        systemSettingProvider,
        child,
      ) {
        final fontSettings =
            systemSettingProvider.systemSettingsModel.noteFontSettings;
        final sideBarWidth =
            systemSettingProvider.systemSettingsModel.sideBarWidth;
        return SafeArea(
          child: Scaffold(
            appBar: isMobile
                ? CustomAppBar(
                    title: Strings.note,
                    buttonType: AppBarButtonType.backButton,
                    onBackPress: () => closeNote(),
                  )
                : CustomAppBar(
                    buttonType: AppBarButtonType.custom,
                    title: Strings.note,
                    customIcon: widget.isDrawerOpen == true
                        ? Icons.chevron_left_rounded
                        : Icons.menu,
                    onBackPress: () => widget.toggleDrawer?.call(),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                        icon: Icon(Icons.info),
                      ),
                    ],
                  ),
            body: MarkdownEditor(
              key: Key(noteProvider.noteModel?.uuid ?? ''),
              initialValue: noteProvider.noteModel?.content,
              onChanged: onTypingChange,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: isMobile
                    ? EdgeInsets.zero
                    : EdgeInsets.symmetric(
                        horizontal: sideBarWidth / 3,
                        vertical: 40,
                      ),
              ),
              style: TextStyle(
                color: theme.primary,
                fontWeight:
                    fontSettings.isFontWeighted ? FontWeight.bold : null,
                fontSize: fontSettings.fontSize,
                height: fontSettings.fontHeight,
              ),
            ),
          ),
        );
      },
    );
  }
}
