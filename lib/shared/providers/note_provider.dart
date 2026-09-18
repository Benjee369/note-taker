import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:notes/shared/database/note_preview_database.dart';
import 'package:notes/shared/models/folder_model.dart';
import 'package:notes/shared/models/note_preview_model.dart';
import 'package:uuid/uuid.dart';
import 'package:notes/shared/database/folder_database.dart';
import 'package:notes/shared/database/note_database.dart';
import 'package:notes/shared/database/open_note_database.dart';
import 'package:notes/shared/models/note_model.dart';

class NoteProvider with ChangeNotifier {
  final NoteDatabase noteDatabase;
  final OpenNoteDatabase openNoteDatabase;
  final PreviewDatabase previewDatabase;
  final FolderDatabase folderDatabase;

  late final Future<void> initialLoad;

  NoteProvider(
    this.noteDatabase,
    this.openNoteDatabase,
    this.folderDatabase,
    this.previewDatabase,
  ) {
    initialLoad = getNotes();
  }

  List<NoteModel> _notes = [];
  List<NotePreviewModel> _previews = [];
  // bool _isGettingNotes = false;
  NoteModel? _noteModel;

  List<NoteModel> get notes => _notes;
  List<NotePreviewModel> get previews => _previews;
  // bool get isGettingNotes => _isGettingNotes;
  NoteModel? get noteModel => _noteModel;

  List<FolderModel> _folders = [];
  List<FolderModel> get folders => _folders;

  final Set<String> _collapsedFolderUuids = {};
  Set<String> get collapsedFolderUuids => _collapsedFolderUuids;

  void toggleFolderCollapse(String folderUuid) {
    if (_collapsedFolderUuids.contains(folderUuid)) {
      _collapsedFolderUuids.remove(folderUuid);
    } else {
      _collapsedFolderUuids.add(folderUuid);
    }
    notifyListeners();
  }

  void clearNotes() {
    _notes = [];
    notifyListeners();
  }

  Future<void> setOpenNote(String uuid) async {
    await getSingleNote(uuid);
    await openNoteDatabase.setOpenNote(uuid);
  }

  Future<bool> checkOpenNote() async {
    final noteUuid = await openNoteDatabase.getOpenNote();
    if (noteUuid != null) {
      await getSingleNote(noteUuid);
      return true;
    } else {
      return false;
    }
  }

  Future<void> clearOpenNote() async {
    await openNoteDatabase.clearOpenNote();
    _noteModel = null;
    notifyListeners();
  }

  Future<void> saveNote(NoteModel note) async {
    final index = _notes.indexWhere(
      (n) => n.uuid == note.uuid,
    );
    if (index == -1) {
      _notes.add(note);
    } else {
      _notes[index] = note;
    }

    final previewIndex = _previews.indexWhere((p) => p.uuid == note.uuid);
    final newPreview = NotePreviewModel(
      uuid: note.uuid,
      createdDate: note.createdDate,
      contentPreview: note.content.length > 30
          ? note.content.substring(0, 30)
          : note.content,
      folderUuid: note.folderUuid,
      isPinned: note.isPinned,
    );

    if (previewIndex == -1) {
      _previews.add(newPreview);
    } else {
      _previews[previewIndex] = newPreview;
    }

    notifyListeners();

    await previewDatabase.saveNotePreview(note);
    await noteDatabase.saveNote(note);
    await setOpenNote(note.uuid);
  }

  void quickSaveNote(NoteModel note, String content) {
    final updatedNote = note.copyWith(content: content);
    _noteModel = updatedNote;
    notifyListeners();
  }

  Future<void> getSingleNote(String uuid) async {
    final index = _notes.indexWhere(
      (n) => n.uuid == uuid,
    );
    if (index != -1) {
      _noteModel = _notes[index];
    } else {
      _noteModel = await noteDatabase.getSingleNote(uuid);
      if (_noteModel != null) {
        _notes.add(_noteModel!);
      }
    }
    notifyListeners();
  }

  Future<void> getNotes() async {
    log(
      'getting notes...',
      name: 'NoteProvider',
    );

    _previews = await previewDatabase.getNotesPreview();
    _folders = await folderDatabase.getFolders();
    notifyListeners();
  }

  Future<void> setPinned(
    String uuid,
    bool pinned,
  ) async {
    final previewIndex = _previews.indexWhere((p) => p.uuid == uuid);
    if (previewIndex != -1) {
      final oldPreview = _previews[previewIndex];
      _previews[previewIndex] = NotePreviewModel(
        uuid: oldPreview.uuid,
        createdDate: oldPreview.createdDate,
        contentPreview: oldPreview.contentPreview,
        folderUuid: oldPreview.folderUuid,
        isPinned: pinned,
      );
      notifyListeners();
    }

    final note = await noteDatabase.getSingleNote(uuid);
    if (note != null) {
      final updated = note.copyWith(isPinned: pinned);

      final index = _notes.indexWhere((n) => n.uuid == uuid);
      if (index != -1) {
        _notes[index] = updated;
      }

      await noteDatabase.saveNote(updated);
      await previewDatabase.saveNotePreview(updated);
    }
  }

  Future bulkDeleteNotes(Set<String> uuids) async {
    for (String uuid in uuids) {
      await deleteNote(
        uuid,
        shouldRefresh: false,
      );
    }
  }

  Future deleteNote(
    String uuid, {
    bool shouldRefresh = true,
  }) async {
    _notes.removeWhere(
      (n) => n.uuid == uuid,
    );
    _previews.removeWhere(
      (n) => n.uuid == uuid,
    );
    notifyListeners();
    await noteDatabase.deleteNote(uuid);
    await previewDatabase.deleteNote(uuid);

    if (_noteModel?.uuid == uuid) {
      clearOpenNote();
    }
    if (shouldRefresh) {
      getNotes();
    }
  }

  Future getFolders() async {
    final folders = await folderDatabase.getFolders();
    _folders = folders;
    notifyListeners();
  }

  Future<void> createFolder(
    FolderModel folder,
  ) async {
    log(
      'creating folder ${folder.toJson()}...',
      name: 'FolderProvider',
    );
    await folderDatabase.saveFolder(folder);
    await getFolders();
    notifyListeners();
  }

  Future<void> addToFolder(
    String noteUuid,
    String? folderUuid,
  ) async {
    log(
      'adding file: $noteUuid to folder: $folderUuid...',
      name: 'NoteProvider',
    );

    final previewIndex = _previews.indexWhere((p) => p.uuid == noteUuid);
    if (previewIndex != -1) {
      final oldPreview = _previews[previewIndex];
      _previews[previewIndex] = NotePreviewModel(
        uuid: oldPreview.uuid,
        createdDate: oldPreview.createdDate,
        contentPreview: oldPreview.contentPreview,
        folderUuid: folderUuid,
        isPinned: oldPreview.isPinned,
      );
      notifyListeners();
    }

    final note = await noteDatabase.getSingleNote(noteUuid);
    if (note != null) {
      final updated = note.copyWith(folderUuid: folderUuid);
      await saveNote(updated);
    }
    log(
      'added file to folder...',
      name: 'NoteProvider',
    );
  }

  Future deleteFolder(String folderUuid) async {
    final noteUuids = _previews
        .where((n) => n.folderUuid == folderUuid)
        .map((n) => n.uuid)
        .toSet();

    await bulkDeleteNotes(noteUuids);

    _folders.removeWhere((f) => f.uuid == folderUuid);
    notifyListeners();

    await folderDatabase.deleteFolder(folderUuid);
  }

  Future removeNoteFromFolder(String noteUuid) async {
    final previewIndex = _previews.indexWhere((p) => p.uuid == noteUuid);
    if (previewIndex != -1) {
      final oldPreview = _previews[previewIndex];
      _previews[previewIndex] = NotePreviewModel(
        uuid: oldPreview.uuid,
        createdDate: oldPreview.createdDate,
        contentPreview: oldPreview.contentPreview,
        folderUuid: null,
        isPinned: oldPreview.isPinned,
      );
      notifyListeners();
    }

    NoteModel? note;
    final idx = _notes.indexWhere((n) => n.uuid == noteUuid);
    if (idx != -1) {
      note = _notes[idx];
    } else {
      note = await noteDatabase.getSingleNote(noteUuid);
    }
    if (note != null) {
      final newNote = note.copyWith(folderUuid: null);
      if (idx != -1) {
        _notes[idx] = newNote;
      } else {
        _notes.add(newNote);
      }
      if (_noteModel?.uuid == noteUuid) {
        _noteModel = newNote;
      }
      notifyListeners();
      await noteDatabase.saveNote(newNote);
      await previewDatabase.saveNotePreview(newNote);
    }
  }

  Future changeFolderName(
    FolderModel folder,
    String newName,
  ) async {
    final updatedFolder = folder.copyWith(
      name: newName,
    );

    final index = _folders.indexWhere(
      (f) => f.uuid == folder.uuid,
    );
    if (index != -1) {
      _folders[index] = updatedFolder;
    }
    notifyListeners();
    await folderDatabase.saveFolder(updatedFolder);
  }

  Future<void> duplicateNote(String uuid) async {
    final originalNote = await noteDatabase.getSingleNote(uuid);
    if (originalNote != null) {
      final now = DateTime.now();
      const uuidGen = Uuid();
      final duplicateUuid = uuidGen.v4();
      final duplicateNote = NoteModel(
        uuid: duplicateUuid,
        content: originalNote.content,
        createdDate: now,
        updatedDate: now,
        isPinned: originalNote.isPinned,
        folderUuid: originalNote.folderUuid,
      );
      await saveNote(duplicateNote);
    }
  }

  List<Universal> processNotesAndFolders() {
    List<Universal> processed = [];
    for (final folder in _folders) {
      processed.add(Folder(folder));

      if (!_collapsedFolderUuids.contains(folder.uuid)) {
        processed.addAll(
          _previews.where((n) => n.folderUuid == folder.uuid).map(
                (n) => PreviewNote(n),
              ),
        );
      }
    }

    processed.addAll(
      _previews.where((n) => n.folderUuid == null).map(
            (n) => PreviewNote(n),
          ),
    );
    return processed;
  }
}

abstract class Universal {}

class Folder extends Universal {
  final FolderModel folderModel;
  Folder(this.folderModel);
}

class PreviewNote extends Universal {
  final NotePreviewModel previewModel;
  PreviewNote(this.previewModel);
}
