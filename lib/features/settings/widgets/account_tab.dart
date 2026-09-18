import 'package:flutter/material.dart';
import 'package:notes/shared/providers/user_details_provider.dart';
import 'package:notes/shared/widgets/button_primary.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/services/auth_service.dart';
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
    try {
      final user = context.read<UserDetailsProvider>();
      final auth = AuthService();
      final userDetails = await auth.signInWithGoogle();
      user.setUserCredentials(userDetails);
    } finally {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailsProvider>(
      builder: (context, user, child) {
        if (user.user != null) {
          final userDetails = user.user?.user;
          return Column(
            children: [
              TextWidget(
                text: userDetails?.displayName ?? '',
              ),
              TextWidget(text: userDetails?.email ?? ''),
              ButtonPrimary(
                active: true,
                text: 'Sign Out',
                function: () {},
              ),
            ],
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget(text: 'Sign in to sync notes online.'),
              gapH12,
              ButtonPrimary(
                active: true,
                text: 'Sign in with Google',
                function: () async {
                  await signInWithGoogle();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
