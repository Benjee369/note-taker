import 'package:flutter/material.dart';
import 'package:notes/shared/models/folder_model.dart';
import 'package:notes/shared/providers/platform_provider.dart';
import 'package:notes/shared/widgets/custom_popup_menu.dart';
import 'package:notes/shared/widgets/dialogs.dart';
import 'package:notes/shared/widgets/text_widget.dart';
import 'package:notes/platform/desktop/home_screen.dart';
import 'package:notes/platform/mobile/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:notes/shared/models/note_preview_model.dart';
import 'package:notes/shared/navigation/navigation.dart';
import 'package:notes/shared/widgets/button_primary.dart';
import 'package:notes/shared/constants/app_sizes.dart';
import 'package:notes/shared/constants/strings.dart';
import 'package:notes/shared/models/note_model.dart';
import 'package:notes/shared/providers/note_provider.dart';
import 'package:notes/shared/widgets/note_view.dart';
import 'package:notes/features/notes/note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final uuid = Uuid();
  final Set<String> selectedNotes = {};
  bool gridView = true;
  final now = DateTime.now();

  void createNewNote() async {
    final id = uuid.v4();
    final note = NoteModel(
      uuid: id,
      content: 'New Note',
      createdDate: now,
      updatedDate: now,
      isPinned: false,
    );
    await context.read<NoteProvider>().saveNote(note);
    if (isMobile) {
      if (!mounted) return;
      Navigation.navigateTo(
        context,
        NoteScreen(),
      );
    }
  }

  void openNote(NotePreviewModel note) {
    if (selectedNotes.isNotEmpty) {
      selectNote(note);
    } else {
      context.read<NoteProvider>().setOpenNote(note.uuid).then((_) {
        if (!mounted) return;
        isMobile
            ? Navigation.navigateTo(
                context,
                NoteScreen(),
              )
            : null;
      });
    }
  }

  void checkOpenNote() async {
    final noteProvider = context.read<NoteProvider>();
    final isOpen = await noteProvider.checkOpenNote();
    if (isOpen && isMobile) {
      final note = noteProvider.noteModel!;
      final preview = NotePreviewModel(
        uuid: note.uuid,
        createdDate: note.createdDate,
        contentPreview: note.content.length > 30
            ? note.content.substring(0, 30)
            : note.content,
        folderUuid: note.folderUuid,
        isPinned: note.isPinned,
      );
      openNote(preview);
    }
  }

  void onLongPress(
    NotePreviewModel note, {
    LongPressStartDetails? details,
    TapDownDetails? tapDownDetails,
  }) {
    final position = details?.globalPosition ?? tapDownDetails?.globalPosition;
    if (position == null) return;

    CustomPopupMenu.show(
      context: context,
      position: position,
      items: [
        PopupMenuItemData(
          value: 1,
          icon: Icons.push_pin_rounded,
          label: note.isPinned ? Strings.unpin : Strings.pin,
        ),
        PopupMenuItemData(
          value: 2,
          icon: Icons.check_box_rounded,
          label: Strings.select,
        ),
        PopupMenuItemData(
          value: 3,
          icon: Icons.folder_copy_rounded,
          label: Strings.duplicate,
        ),
        PopupMenuItemData(
          value: 4,
          icon: Icons.delete_rounded,
          label: Strings.delete,
        ),
        PopupMenuItemData(
            value: 5,
            icon: Icons.create_new_folder_rounded,
            label: Strings.addToFolder),
      ],
      onSelected: (value) {
        switch (value) {
          case 1:
            pin(note);
            break;
          case 2:
            selectNote(note);
            break;
          case 3:
            duplicateNote(note);
            break;
          case 4:
            deleteNote(note.uuid);
            break;
          case 5:
            Future.delayed(Duration.zero, () {
              addToFolder(note, position);
            });
            break;
        }
      },
    );
  }

  void addToFolder(
    NotePreviewModel note,
    Offset position,
  ) {
    final folders = context.read<NoteProvider>().folders;

    CustomPopupMenu.show(
      context: context,
      position: position,
      items: folders.asMap().entries.map(
        (f) {
          return PopupMenuItemData(
            value: f.key,
            icon: Icons.folder,
            label: f.value.name,
          );
        },
      ).toList(),
      onSelected: (value) async {
        final folder = folders[value];
        await context.read<NoteProvider>().addToFolder(
              note.uuid,
              folder.uuid,
            );
      },
    );
  }

  void pin(NotePreviewModel note) {
    if (note.isPinned) {
      context.read<NoteProvider>().setPinned(note.uuid, false);
    } else {
      context.read<NoteProvider>().setPinned(note.uuid, true);
    }
  }

  void deleteNote(String uuid) {
    Dialogs.dialogWithOptions(
      context,
      Strings.areYouSure,
      () {
        context.read<NoteProvider>().deleteNote(
              uuid,
              shouldRefresh: false,
            );
        selectedNotes.clear();
        if (mounted) {
          Navigator.pop(context);
        }
      },
      () => Navigator.pop(context),
      Strings.ok,
      Strings.cancel,
    );
  }

  void duplicateNote(NotePreviewModel originalNote) {
    context.read<NoteProvider>().duplicateNote(originalNote.uuid);
  }

  void selectNote(NotePreviewModel note) {
    if (selectedNotes.contains(note.uuid)) {
      setState(() {
        selectedNotes.remove(note.uuid);
      });
    } else {
      setState(() {
        selectedNotes.add(note.uuid);
      });
    }
  }

  void bulkDeleteNotes() async {
    Dialogs.dialogWithOptions(
      context,
      Strings.areYouSureMany(selectedNotes.length),
      () async {
        context.read<NoteProvider>().bulkDeleteNotes(selectedNotes);
        selectedNotes.clear();
        if (mounted) {
          Navigator.pop(context);
        }
      },
      () => Navigator.pop(context),
      Strings.ok,
      Strings.cancel,
    );
  }

  void selectAndUnselectAll() {
    final notes = context.read<NoteProvider>().previews;
    if (selectedNotes.length == notes.length) {
      setState(() {
        selectedNotes.clear();
      });
    } else {
      setState(() {
        selectedNotes.addAll(notes.map((n) => n.uuid).toSet());
      });
    }
  }

  void toggleViewMode() {
    setState(() {
      gridView = !gridView;
    });
  }

  final folderNameController = TextEditingController();

  void createFolder() async {
    Dialogs.dialog(
      context,
      [
        TextWidget(text: Strings.folderName),
        TextField(
          controller: folderNameController,
        ),
        gapH12,
        ButtonPrimary(
          text: 'Create Folder',
          function: () async {
            final id = uuid.v4();
            final folder = FolderModel(
              uuid: id,
              name: folderNameController.text,
              createdDate: now,
            );
            await context.read<NoteProvider>().createFolder(folder);
            if (!mounted) return;
            folderNameController.clear();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void onFolderLongPress(
    FolderModel folder, {
    TapDownDetails? tapDownDetails,
  }) {
    final position = tapDownDetails?.globalPosition;
    if (position == null) return;

    CustomPopupMenu.show(
      context: context,
      position: position,
      items: [
        PopupMenuItemData(
          value: 1,
          icon: Icons.rule_folder_rounded,
          label: Strings.changeName,
        ),
        PopupMenuItemData(
          value: 2,
          icon: Icons.folder_delete_rounded,
          label: Strings.deleteFolder,
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 1:
            changeFolderName(folder);
            break;
          case 2:
            deleteFolder(folder.uuid);
            break;
        }
      },
    );
  }

  Future deleteFolder(String folderUuid) async {
    final noteProvider = context.read<NoteProvider>();
    final noteCount = noteProvider.previews
        .where(
          (n) => n.folderUuid == folderUuid,
        )
        .length;
    Dialogs.dialogWithOptions(
      context,
      Strings.areYouSureManyFolder(noteCount),
      () async {
        await context.read<NoteProvider>().deleteFolder(folderUuid);
        if (!mounted) return;
        Navigator.pop(context);
      },
      () => Navigator.pop(context),
      Strings.ok,
      Strings.cancel,
    );
  }

  void changeFolderName(
    FolderModel folder,
  ) async {
    folderNameController.text = folder.name;
    Dialogs.dialog(
      context,
      [
        TextWidget(text: Strings.changeFolderName),
        TextField(
          controller: folderNameController,
        ),
        IconButton(
          onPressed: () async {
            await context.read<NoteProvider>().changeFolderName(
                  folder,
                  folderNameController.text,
                );
            folderNameController.clear();
            if (!mounted) return;
            Navigator.pop(context);
          },
          icon: Icon(Icons.check_rounded),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    checkOpenNote();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, notes, child) {
        final notesNFolders = notes.processNotesAndFolders();
        return SafeArea(
          child: isMobile
              ? MobileHomeScreen(
                  noteView: ListView.builder(
                    itemCount: notesNFolders.length,
                    itemBuilder: (context, index) {
                      return NoteView(
                        index: index,
                        processedList: notesNFolders,
                        selectedNotes: selectedNotes,
                        collapsedFolderUuids: notes.collapsedFolderUuids,
                        onTap: (note) => openNote(note),
                        onLongPress: (details, note) => onLongPress(
                          note,
                          details: details,
                        ),
                        onSecondaryTap: (details, note) {
                          onLongPress(
                            note,
                            tapDownDetails: details,
                          );
                        },
                        onFolderSecondaryTap: (details, folder) =>
                            onFolderLongPress(
                          folder,
                          tapDownDetails: details,
                        ),
                        onFolderTap: (folder) {
                          notes.toggleFolderCollapse(folder.uuid);
                        },
                      );
                    },
                  ),
                  createNewNote: createNewNote,
                  selectAndUnselectAll: selectAndUnselectAll,
                  bulkDeleteNotes: bulkDeleteNotes,
                  selectedNotes: selectedNotes,
                )
              : DesktopHomeScreen(
                  noteView: ListView.builder(
                    itemCount: notesNFolders.length,
                    // onReorderItem: (oldIndex, newIndex) {
                    //   final isFolder = notesNFolders[oldIndex] is Folder;
                    //
                    //   if (isFolder) return;
                    // },
                    // buildDefaultDragHandles: false,
                    itemBuilder: (context, index) {
                      final isFolder = notesNFolders[index] is Folder;

                      return NoteView(
                        key: ValueKey(index),
                        index: index,
                        processedList: notesNFolders,
                        selectedNotes: selectedNotes,
                        collapsedFolderUuids: notes.collapsedFolderUuids,
                        onTap: (note) => openNote(note),
                        onLongPress: (details, note) => onLongPress(
                          note,
                          details: details,
                        ),
                        onSecondaryTap: (details, note) {
                          onLongPress(
                            note,
                            tapDownDetails: details,
                          );
                        },
                        onFolderSecondaryTap: (details, folder) =>
                            onFolderLongPress(
                          folder,
                          tapDownDetails: details,
                        ),
                        onFolderTap: (folder) {
                          notes.toggleFolderCollapse(folder.uuid);
                        },
                      );
                    },
                  ),
                  selectAndUnselectAll: selectAndUnselectAll,
                  bulkDeleteNotes: bulkDeleteNotes,
                  selectedNotes: selectedNotes,
                  createNewNote: createNewNote,
                  createFolder: createFolder,
                ),
        );
      },
    );
  }
}
