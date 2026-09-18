import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:notes/features/settings/widgets/theme_color_widget.dart';
import 'package:provider/provider.dart';
import 'package:notes/shared/providers/system_settings_provider.dart';
import 'package:notes/shared/widgets/text_widget.dart';
import 'package:notes/shared/constants/app_sizes.dart';
import 'package:notes/shared/constants/strings.dart';

class AppearanceTab extends StatefulWidget {
  const AppearanceTab({super.key});

  @override
  State<AppearanceTab> createState() => _AppearanceTabState();
}

class _AppearanceTabState extends State<AppearanceTab> {
  List<String> colors = ["orange", "green", "blue", "red", "purple"];
  List<double> fontSizes = [8, 12, 16, 20, 24];

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemSettingsProvider>(
        builder: (context, settings, child) {
      final noteSettings = settings.systemSettingsModel.noteFontSettings;
      return Column(
        children: [
          Material(
            type: MaterialType.transparency,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 50),
                    child: Icon(
                      settings.systemSettingsModel.theme
                          ? Icons.wb_sunny_rounded
                          : Icons.mode_night_rounded,
                    ),
                  ),
                  gapW4,
                  TextWidget(
                    text: Strings.darkMode,
                    align: TextAlign.center,
                  ),
                  Spacer(),
                  Switch(
                    value: !settings.systemSettingsModel.theme,
                    onChanged: (_) {
                      settings.toggleTheme();
                    },
                  ),
                ],
              ),
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Icon(
                    Icons.color_lens_rounded,
                  ),
                  gapW4,
                  TextWidget(
                    text: 'Change theme color',
                    align: TextAlign.center,
                  ),
                  Spacer(),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      isExpanded: true,
                      hint: ThemeColorWidget(
                        name: settings.systemSettingsModel.themeColorName,
                        systemSettings: settings,
                      ),
                      items: colors
                          .map(
                            (c) => DropdownItem(
                              value: c,
                              height: 30,
                              child: ThemeColorWidget(
                                name: c,
                                systemSettings: settings,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => {settings.changeThemeColor(val!)},
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 30,
                        width: 140,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Icon(
                    Icons.text_fields_rounded,
                  ),
                  gapW4,
                  TextWidget(
                    text: 'Note text style',
                    align: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              40,
              0,
              5,
              5,
            ),
            child: Column(
              children: [
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Icon(Icons.text_increase_rounded),
                        gapW8,
                        TextWidget(text: 'Font size'),
                        Spacer(),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            hint: TextWidget(
                              text: '${noteSettings.fontSize}px',
                            ),
                            items: fontSizes
                                .map(
                                  (f) => DropdownItem(
                                    value: f,
                                    height: 30,
                                    child: TextWidget(
                                      text: '${f}px',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => settings.changeFontSize(val!),
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              height: 30,
                              width: 140,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Icon(
                          Icons.text_format_rounded,
                        ),
                        gapW4,
                        TextWidget(
                          text: 'Font boldness',
                        ),
                        Spacer(),
                        Switch(
                          value: noteSettings.isFontWeighted,
                          onChanged: (_) {
                            settings.toggleFontWeight();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Icon(
                          Icons.text_format_rounded,
                        ),
                        gapW4,
                        TextWidget(
                          text: 'Font height',
                        ),
                        Spacer(),
                        SizedBox(
                          width: 100,
                          height: 40,
                          child: TextField(),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
