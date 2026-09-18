import 'package:flutter/material.dart';
import 'package:notes/shared/widgets/text_widget.dart';
import 'package:notes/shared/constants/app_sizes.dart';

class SettingsTileWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function(String) onTap;
  final bool isSelected;

  const SettingsTileWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => onTap.call(title),
            child: Container(
              margin: EdgeInsets.only(bottom: 4),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: isSelected ? theme.secondary.withAlpha(30) : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 22,
                  ),
                  gapW8,
                  TextWidget(text: title)
                ],
              ),
            ),
          ),
        ),
        // Divider(
        //   height: 1,
        // )
      ],
    );
  }
}
