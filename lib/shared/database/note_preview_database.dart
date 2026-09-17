import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:notes/shared/models/note_preview_model.dart';

import 'package:notes/shared/models/note_model.dart';

class PreviewDatabase {
  static Box? _noteBox;

  Future<Box> getBox() async {
    if (_noteBox != null && _noteBox!.isOpen) return _noteBox!;
    _noteBox = await Hive.openBox('notesPreviewBox');
    return _noteBox!;
  }

  Future saveNotePreview(NoteModel note) async {
    String content = '';
    final contentLength = note.content.length;
    if (contentLength > 30) {
      content = note.content.substring(0, 30);
    } else {
      content = note.content;
    }
    final notePreview = NotePreviewModel(
      uuid: note.uuid,
      createdDate: note.createdDate,
      contentPreview: content,
      folderUuid: note.folderUuid,
      isPinned: note.isPinned,
    );
    final box = await getBox();
    await box.put(
      note.uuid,
      notePreview.toJson(),
    );
    log(
      'saved preview with id ${note.uuid}...',
      name: 'PreviewDatabase',
    );
  }

  Future<List<NotePreviewModel>> getNotesPreview() async {
    log(
      'getting previews...',
      name: 'PreviewDatabase',
    );
    final box = await getBox();

    final values = box.values;
    if (values.isNotEmpty) {
      final notes = values
          .map(
            (note) => NotePreviewModel.fromJson(
              Map<String, dynamic>.from(note),
            ),
          )
          .toList();
      return notes;
    }
    log(
      'no previews found..',
      name: 'PreviewDatabase',
    );
    return [];
  }

  Future deleteNote(String uuid) async {
    final box = await getBox();
    await box.delete(uuid);
    log(
      'deleted preview $uuid...',
      name: 'PreviewDatabase',
    );
  }
}
