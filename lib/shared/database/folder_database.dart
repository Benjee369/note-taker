import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:notes/shared/models/folder_model.dart';

class FolderDatabase {
  static Box? _folderBox;

  Future<Box> getBox() async {
    if (_folderBox != null && _folderBox!.isOpen) return _folderBox!;
    _folderBox = await Hive.openBox('foldersBox');
    return _folderBox!;
  }

  Future saveFolder(FolderModel folder) async {
    final box = await getBox();
    await box.put(folder.uuid, folder.toJson());
    log(
      'saved folder with id ${folder.uuid}...',
      name: 'FolderDatabase',
    );
  }

  Future<List<FolderModel>> getFolders() async {
    log(
      'getting folders...',
      name: 'FolderDatabase',
    );
    final box = await getBox();

    final values = box.values;
    if (values.isNotEmpty) {
      final folders = values
          .map(
            (folder) => FolderModel.fromJson(
              Map<String, dynamic>.from(folder),
            ),
          )
          .toList();
      log(
        'got (${folders.length})list of folders ${folders.map((f) => f.uuid)}...',
        name: 'FolderDatabase',
      );
      return folders;
    }
    log(
      'no folders found..',
      name: 'FolderDatabase',
    );
    return [];
  }

  Future<FolderModel?> getSingleFolder(String uuid) async {
    final box = await getBox();
    final folder = await box.get(uuid);
    if (folder == null) return null;
    return FolderModel.fromJson(
      Map<String, dynamic>.from(folder),
    );
  }

  Future deleteFolder(String uuid) async {
    final box = await getBox();
    await box.delete(uuid);
    log(
      'deleted folder $uuid...',
      name: 'FolderDatabase',
    );
  }
}
