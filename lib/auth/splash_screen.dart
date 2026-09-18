import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notes/auth/sign_in_screen.dart';
import 'package:notes/shared/providers/user_details_provider.dart';
import 'package:notes/shared/widgets/text_widget.dart';
import 'package:notes/shared/constants/strings.dart';
import 'package:notes/shared/navigation/navigation.dart';
import 'package:notes/shared/constants/app_images.dart';
import 'package:notes/shared/constants/app_sizes.dart';
import 'package:notes/features/notes/home_screen.dart';
import 'package:provider/provider.dart';
import '../shared/database/first_open_database.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  Future<void> init() async {
    final isFirstOpen = await FirstOpenDatabase().getFirstOpenState();
    if (!mounted) return;
    final user = context.read<UserDetailsProvider>();

    if (isFirstOpen && !user.isSignedIn) {
      Navigation.navigateAndReplace(
        context,
        SignInScreen(),
      );
      return;
    }

    Navigation.navigateAndReplace(
      context,
      HomeScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppImages.splashImage,
                height: 200,
                width: 200,
              ),
              gapH12,
              TextWidget(text: Strings.noteTaker),
            ],
          ),
        ),
      ),
    );
  }
}
