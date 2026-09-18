import 'package:flutter/material.dart';
import 'package:notes/shared/database/first_open_database.dart';
import 'package:notes/shared/providers/user_details_provider.dart';
import 'package:notes/shared/widgets/button_primary.dart';
import 'package:notes/shared/widgets/dialogs.dart';
import 'package:notes/shared/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import '../features/notes/home_screen.dart';
import '../shared/constants/app_sizes.dart';
import '../shared/navigation/navigation.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Future<void> skipSignIn() async {
    final firstOpen = FirstOpenDatabase();
    await firstOpen.setFirstOpenState(true);
    if (!mounted) return;
    Navigation.navigateAndReplace(
      context,
      HomeScreen(),
    );
  }

  Future<void> signInWithGoogle() async {
    Dialogs.loading(context);
    final auth = await context.read<UserDetailsProvider>().signIn();
    if (auth) {
      if (!mounted) return;
      Navigator.pop(context);
      Navigation.navigateAndReplace(
        context,
        HomeScreen(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextWidget(
              text: 'Sign In with Google',
              fontWeight: FontWeight.bold,
            ),
            gapH12,
            TextWidget(
              text: 'Sign in to keep you notes backed up.',
              fontWeight: FontWeight.bold,
            ),
            gapH20,
            ButtonPrimary(
              active: true,
              text: 'Sign in with Google',
              function: () {},
            ),
            gapH8,
            ButtonPrimary(
              active: true,
              text: 'Keep me signed out',
              function: () async {
                await skipSignIn();
              },
            ),
          ],
        ),
      ),
    );
  }
}
