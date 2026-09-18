import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvg extends StatelessWidget {
  final String assetPath;
  final double? height;
  final double? width;

  const CustomSvg({
    super.key,
    required this.assetPath,
    this.height,
    this.width,
  });

  Future<String> _loadSvg(BuildContext context) async {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final svgString = await rootBundle.loadString(assetPath);

    final color = primaryColor
        .toARGB32()
        .toRadixString(16)
        .substring(2);

    return svgString.replaceAll(
      '#currentColor',
      '#$color',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadSvg(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: height,
            width: width,
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return SizedBox(
            height: height,
            width: width,
          );
        }

        return SvgPicture.string(
          snapshot.data!,
          height: height,
          width: width,
        );
      },
    );
  }
}
