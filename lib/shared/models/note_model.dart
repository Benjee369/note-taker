import 'package:json_annotation/json_annotation.dart';

part 'note_model.g.dart';

@JsonSerializable()
class NoteModel {
  final String uuid;
  final String content;
  final DateTime createdDate;
  final DateTime updatedDate;
  @JsonKey(defaultValue: false)
  final bool isPinned;
  final String? folderUuid;

  NoteModel({
    required this.uuid,
    required this.content,
    required this.createdDate,
    required this.updatedDate,
    required this.isPinned,
    this.folderUuid,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);
  Map<String, dynamic> toJson() => _$NoteModelToJson(this);

  static const Object _sentinel = Object();

  NoteModel copyWith({
    String? uuid,
    String? content,
    DateTime? createDate,
    DateTime? updatedDate,
    bool? isPinned,
    Object? folderUuid = _sentinel,
  }) {
    return NoteModel(
      uuid: uuid ?? this.uuid,
      content: content ?? this.content,
      createdDate: createDate ?? createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      isPinned: isPinned ?? this.isPinned,
      folderUuid: folderUuid == _sentinel
          ? this.folderUuid
          : folderUuid as String?,
    );
  }
}
