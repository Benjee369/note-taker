import 'package:flutter/material.dart';
import 'package:notes/shared/providers/user_details_provider.dart';
import 'package:notes/shared/widgets/button_primary.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/text_widget.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  Future<void> signInWithGoogle() async {
    Dialogs.loading(context);
    final auth = await context.read<UserDetailsProvider>().signIn();
    if (auth) {
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, user, child) {
        if (user.user != null) {
          final userDetails = user.user;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: userDetails?.displayName ?? '',
                fontWeight: FontWeight.bold,
                size: 18,
              ),
              TextWidget(text: userDetails?.email ?? ''),
              gapH20,
              ButtonPrimary(
                active: true,
                text: 'Sign Out',
                function: user.signOut,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: 'Sign in to sync notes online.',
              fontWeight: FontWeight.bold,
              size: 18,
            ),
            gapH20,
            ButtonPrimary(
              active: true,
              text: 'Sign in with Google',
              function: () async {
                await signInWithGoogle();
              },
            ),
            gapH64,
          ],
        );
      },
    );
  }
}
