import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes/shared/providers/note_provider.dart';
import 'package:notes/shared/widgets/custom_app_bar.dart';
import 'package:notes/shared/widgets/no_note_widget.dart';
import 'package:notes/shared/constants/app_images.dart';
import 'package:notes/shared/constants/strings.dart';
import 'package:notes/platform/mobile/widgets/home_drawer.dart';

class MobileHomeScreen extends StatefulWidget {
  final Widget noteView;
  final VoidCallback createNewNote;
  final VoidCallback selectAndUnselectAll;
  final VoidCallback bulkDeleteNotes;
  final Set<String> selectedNotes;

  const MobileHomeScreen({
    super.key,
    required this.noteView,
    required this.createNewNote,
    required this.selectAndUnselectAll,
    required this.bulkDeleteNotes,
    required this.selectedNotes,
  });

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => widget.createNewNote(),
        child: Icon(Icons.add),
      ),
      appBar: CustomAppBar(
        buttonType: AppBarButtonType.menuButton,
        title: Strings.notes,
        actions: [
          if (widget.selectedNotes.isNotEmpty) ...[
            IconButton(
              onPressed: () => widget.selectAndUnselectAll(),
              icon: Icon(Icons.select_all_rounded),
            ),
            IconButton(
              onPressed: () => widget.bulkDeleteNotes(),
              icon: Icon(Icons.delete_rounded),
            ),
          ]
        ],
      ),
      body: noteProvider.previews.isEmpty
          ? const NoNoteWidget(
              message: Strings.addYourFirst,
              image: AppImages.noNotes,
            )
          :
          // context.watch<SystemSettingsProvider>().systemSettingsModel.viewMode
          //         ? Expanded(
          //             child: GridView.builder(
          //               gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          //                 maxCrossAxisExtent: 200,
          //                 childAspectRatio: 1,
          //               ),
          //               itemCount: notesNFolders.length,
          //               itemBuilder: (context, index) {
          //                 return NoteView(
          //                   index: index,
          //                   processedList: notesNFolders,
          //                   selectedNotes: selectedNotes,
          //                   onTap: (note) => openNote(note),
          //                   onLongPress: (details, note) => onLongPress(
          //                     note,
          //                     details: details,
          //                   ),
          //                   onSecondaryTap: (details, note) {
          //                     onLongPress(
          //                       note,
          //                       tapDownDetails: details,
          //                     );
          //                   },
          //                 );
          //               },
          //             ),
          //           )
          //         :
          Expanded(
              child: widget.noteView,
            ),
      drawer: HomeDrawer(),
    );
  }
}
