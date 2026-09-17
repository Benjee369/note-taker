import 'package:flutter/material.dart';
import 'package:notes/shared/widgets/text_widget.dart';

import '../constants/app_sizes.dart';
import '../models/folder_model.dart';

class ComputerFolderWidget extends StatelessWidget {
  final bool isCollapsed;
  final bool isHovered;
  final FolderModel f;

  const ComputerFolderWidget({
    super.key,
    required this.isCollapsed,
    required this.isHovered,
    required this.f,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return ColoredBox(
      color: isHovered
          ? theme.colorScheme.primary.withAlpha(90)
          : theme.colorScheme.secondary.withAlpha(80),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Icon(
              isCollapsed
                  ? Icons.keyboard_arrow_right_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 14,
            ),
            gapW12,
            Icon(
              Icons.folder_rounded,
              size: 16,
            ),
            gapW8,
            SizedBox(
              width: size.width * 0.8,
              child: TextWidget(
                text: f.name,
                size: 16,
                fontWeight: FontWeight.bold,
                overFlow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
