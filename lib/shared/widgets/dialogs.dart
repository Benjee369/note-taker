import 'package:flutter/material.dart';
import 'package:notes/shared/widgets/text_widget.dart';
import 'package:notes/shared/constants/app_sizes.dart';
import 'package:notes/shared/constants/strings.dart';

class Dialogs {
  //for dialogs with one action
  static Future<dynamic> dialogInform(
    BuildContext buildContext,
    String dialogMessage,
    VoidCallback function,
    String? text, {
    IconData? icon,
    double? iconSize,
    Color? iconColor,
  }) {
    return showDialog(
      context: buildContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: icon != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: iconSize,
                      color: iconColor,
                    ),
                    const SizedBox(height: 16),
                    TextWidget(
                      text: dialogMessage,
                    ),
                  ],
                )
              : TextWidget(
                  text: dialogMessage,
                  align: TextAlign.center,
                ),
          actions: <Widget>[
            TextButton(
              child: Center(
                child: Text(text ?? Strings.ok),
              ),
              onPressed: () {
                function.call();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<dynamic> dialogWithOptions(
    BuildContext buildContext,
    String dialogMessage,
    VoidCallback good,
    VoidCallback bad,
    String? goodText,
    String? badText, {
    IconData? icon,
    double? iconSize,
    Color? iconColor,
  }) {
    return showDialog(
      context: buildContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: icon != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: iconSize,
                      color: iconColor,
                    ),
                    const SizedBox(height: 16),
                    TextWidget(
                      text: dialogMessage,
                    ),
                  ],
                )
              : TextWidget(
                  text: dialogMessage,
                  align: TextAlign.center,
                ),
          actions: <Widget>[
            TextButton(
              child: Center(
                child: Text(goodText ?? Strings.ok),
              ),
              onPressed: () {
                good.call();
              },
            ),
            TextButton(
              child: Center(
                child: Text(badText ?? Strings.ok),
              ),
              onPressed: () {
                bad.call();
              },
            )
          ],
        );
      },
    );
  }

  static Future<dynamic> dialog(
    BuildContext buildContext,
    List<Widget> children,
  ) {
    return showDialog(
      context: buildContext,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        );
      },
    );
  }

  static Future<dynamic> bottomSheet(
    BuildContext context,
    String title, {
    required List<Widget> children,
    double height = 0.4,
  }) {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: size.height * height,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 39,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                gapH8,
                TextWidget(
                  text: title,
                  size: 16,
                ),
                gapH20,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<dynamic> loading(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<dynamic> loadingWithMessage(
      BuildContext context, String message) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                height: 5,
              ),
              TextWidget(
                text: message,
                size: 16,
              )
            ],
          ),
        );
      },
    );
  }

  static Widget loadingInScreen({double? height}) {
    return Center(
      child: SizedBox(
          width: 170, height: height, child: CircularProgressIndicator()),
    );
  }
}
