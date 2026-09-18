import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../shared/constants/app_sizes.dart';
import '../../../shared/constants/strings.dart';
import '../../../shared/widgets/text_widget.dart';

class UpdatesTab extends StatefulWidget {
  const UpdatesTab({super.key});

  @override
  State<UpdatesTab> createState() => _UpdatesTabState();
}

class _UpdatesTabState extends State<UpdatesTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    text: Strings.noteTaker,
                    size: 13,
                  ),
                  gapW4,
                  TextWidget(
                    text: 'v ${snapshot.data!.version}',
                    size: 13,
                  ),
                ],
              );
            }
            return const TextWidget(
              text: 'Checking version...',
              size: 13,
            );
          },
        ),
      ],
    );
  }
}
