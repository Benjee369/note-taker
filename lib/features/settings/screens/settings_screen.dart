import 'package:flutter/material.dart';
import 'package:notes/features/settings/models/settings_tab_model.dart';
import 'package:notes/shared/widgets/text_widget.dart';
import 'package:notes/features/settings/providers/settings_tab_index_provider.dart';
import 'package:notes/features/settings/widgets/account_tab.dart';
import 'package:notes/features/settings/widgets/appearance_tab.dart';
import 'package:notes/features/settings/widgets/settings_tile_widget.dart';
import 'package:notes/features/settings/widgets/updates_tab.dart';
import 'package:provider/provider.dart';
import 'package:notes/shared/constants/strings.dart';

import '../../../shared/constants/app_sizes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<SettingsTabModel> tabs = [
    SettingsTabModel(
      title: Strings.appearance,
      icon: Icons.looks_rounded,
      page: AppearanceTab(),
    ),
    SettingsTabModel(
      title: Strings.account,
      icon: Icons.person_2_rounded,
      page: AccountTab(),
    ),
    SettingsTabModel(
      title: Strings.updates,
      icon: Icons.update_rounded,
      page: UpdatesTab(),
    )
  ];

  String subTitle = Strings.appearance;

  void changeTab(
    SettingsTabIndexProvider indexProvider,
    int index,
    String title,
  ) {
    indexProvider.setIndex(index);
    setState(() {
      subTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Consumer<SettingsTabIndexProvider>(
      builder: (context, index, child) {
        return SizedBox(
          height: 500,
          child: Row(
            children: [
              Container(
                width: 250,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: Strings.settings,
                      fontWeight: FontWeight.bold,
                      size: 22,
                    ),
                    gapH12,
                    Column(
                      children: tabs.asMap().entries.map(
                        (t) {
                          final keyIndex = t.key;
                          final title = t.value.title;
                          final icon = t.value.icon;
                          return SettingsTileWidget(
                            title: title,
                            icon: icon,
                            onTap: (title) => changeTab(index, keyIndex, title),
                            isSelected: index.currentIndex == keyIndex,
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: TextWidget(
                              text: subTitle,
                              size: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 320),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close_rounded),
                          )
                        ],
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: index.currentIndex,
                          children: tabs.map((t) => t.page).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
