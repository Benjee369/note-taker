import 'package:flutter/material.dart';
import 'package:notes/shared/models/folder_model.dart';
import 'package:notes/shared/models/note_preview_model.dart';
import 'package:notes/shared/widgets/note_widget.dart';
import 'package:notes/shared/widgets/text_widget.dart';
import 'package:notes/shared/providers/note_provider.dart';
import 'package:provider/provider.dart';
import 'computer_folder_widget.dart';

class NoteView extends StatelessWidget {
  final int index;
  final List<Universal> processedList;
  final Set<String> selectedNotes;
  final Set<String> collapsedFolderUuids;
  final Function(LongPressStartDetails, NotePreviewModel)? onLongPress;
  final Function(TapDownDetails, NotePreviewModel)? onSecondaryTap;
  final Function(TapDownDetails, FolderModel)? onFolderSecondaryTap;
  final Function(NotePreviewModel) onTap;
  final Function(FolderModel)? onFolderTap;

  const NoteView({
    super.key,
    required this.index,
    required this.processedList,
    required this.selectedNotes,
    required this.collapsedFolderUuids,
    this.onLongPress,
    this.onSecondaryTap,
    required this.onTap,
    this.onFolderSecondaryTap,
    this.onFolderTap,
  });

  @override
  Widget build(BuildContext context) {
    final note = processedList[index];
    final theme = Theme.of(context).colorScheme;

    if (note is Folder) {
      final f = note.folderModel;
      final isCollapsed = collapsedFolderUuids.contains(f.uuid);

      return DragTarget<PreviewNote>(
        onWillAcceptWithDetails: (details) => true,
        onAcceptWithDetails: (details) {
          context.read<NoteProvider>().addToFolder(
                details.data.previewModel.uuid,
                f.uuid,
              );
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return InkWell(
            onSecondaryTapDown: (details) {
              onFolderSecondaryTap?.call(
                details,
                f,
              );
            },
            onTap: () => onFolderTap?.call(f),
            child: ComputerFolderWidget(
              isCollapsed: isCollapsed,
              isHovered: isHovering,
              f: f,
            ),
          );
        },
      );
    }
    if (note is PreviewNote) {
      final n = note.previewModel;
      final selected = selectedNotes.contains(n.uuid);
      final isInFolder = n.folderUuid != null;

      return Draggable<PreviewNote>(
        data: note,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
            child: TextWidget(
              text: note.previewModel.contentPreview,
              maxLines: 1,
              overFlow: TextOverflow.ellipsis,
              size: 14,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.4,
          child: NoteWidget(
            note: n,
            isSelected: selected,
            isInFolder: isInFolder,
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressStart: (details) => onLongPress?.call(
            details,
            n,
          ),
          onSecondaryTapDown: (details) {
            onSecondaryTap?.call(
              details,
              n,
            );
          },
          onTap: () => onTap.call(n),
          child: NoteWidget(
            note: n,
            isSelected: selected,
            isInFolder: isInFolder,
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }
}
