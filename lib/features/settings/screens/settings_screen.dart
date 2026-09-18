import 'package:flutter/material.dart';
import 'package:notes/shared/widgets/text_widget.dart';
import 'package:notes/features/settings/providers/settings_tab_index_provider.dart';
import 'package:notes/features/settings/widgets/account_tab.dart';
import 'package:notes/features/settings/widgets/appearance_tab.dart';
import 'package:notes/features/settings/widgets/settings_tile_widget.dart';
import 'package:notes/features/settings/widgets/updates_tab.dart';
import 'package:provider/provider.dart';
import 'package:notes/shared/constants/strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Widget> tabs = [
    AppearanceTab(),
    AccountTab(),
    UpdatesTab(),
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
                    SettingsTileWidget(
                      title: Strings.appearance,
                      icon: Icons.looks_rounded,
                      onTap: (title) => changeTab(index, 0, title),
                      isSelected: index.currentIndex == 0,
                    ),
                    SettingsTileWidget(
                      title: Strings.account,
                      icon: Icons.person_2_rounded,
                      onTap: (title) => changeTab(index, 1, title),
                      isSelected: index.currentIndex == 1,
                    ),
                    SettingsTileWidget(
                      title:Strings.updates,
                      icon: Icons.update_rounded,
                      onTap: (title) => changeTab(index, 2, title),
                      isSelected: index.currentIndex == 2,
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
                      IndexedStack(
                        index: index.currentIndex,
                        children: tabs,
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
